%% time_config.erl
%% Created by geyc May/24/2013
%% 时间配置解析
%% 实现主要思路：将固定配置与临时配置分开，固定配置由策划配置的表生成，临时配置由后台或代码调用insert_temp_config()添加，
%% 固定配置不修改不保存，临时配置存入数据库中，在进程启动时载入或在服务器运行中添加。
%% 载入配置后记录到进程字典中。提供接口取下回可用的活动时间，将临时配置和固定配置分别整理出下次可用的开启时间，取最小的返回即可。
%% 使用方法：
%% 1、在cfg_activity_time中添加时间配置，并将ID定义到timer_config.hrl中
%% 2、在活动模块初始化时调用?READ_TIME_CONFIG(ID)，载入配置，包含固定配置与临时配置
%% 3、调用get_next_time_info()来取到下次活动时间，并根据时间启动定时器，开启活动
%% 4、活动模块添加-behaviour(time_config)，并实现规定的接口，这些接口一般都是在其他进程中使用的，如后台进程；
%%   实现时调用time_config的相应模块
%% 5、如果临时添加活动，调用活动模块的insert_temp_config()即可；get_time_config_list()可查看所有可用的配置；
%%   remove_temp_config()可以删除指定的配置

-module(time_config).

-include("common.hrl").
-include("cfg_record.hrl").
-include("time_config.hrl").

-export([behaviour_info/1
         ]).

-export([get_next_time_info/1,
         get_next_time_info/2,
         get_next_time_info/3,
         get_time_config_list/0,
         insert_temp_config/5,
         read_config/2,
         remove_static_config/1,
         remove_temp_config/1]).

-define(MY_SAVE_PATH,       "time_config").
-define(MY_SAVE_NAME,       Mod).
-define(MY_SAVE_BRANCH,     "").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Interface%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

behaviour_info(callbacks) ->
    [{get_time_config_list, 0},
     {insert_temp_config, 1},
     {remove_temp_config, 1}].

%% 取下次时间配置
%% Between true表示取参照时间<结束时间的活动，false表示取参照时间<开始时间的活动
%% RefTime 参照时间
%% Save true表示要删除已有的无用的配置，false表示不删除已有配置
%% 返回值：false表示没有可用的时间，time_config为可用的时间
get_next_time_info(Between) ->
    get_next_time_info(Between, util:unixtime()).
get_next_time_info(Between, RefTime) ->
    get_next_time_info(Between, RefTime, true).
get_next_time_info(Between, RefTime, Save) ->
    TempConfig = filter_config(temp_config, RefTime, Between, Save),
    StaticConfig = filter_config(static_config, RefTime, Between, Save),
    
    AllList = TempConfig ++ StaticConfig,
    case length(AllList) of
        0 ->
            false;
        _ ->
            Fun = fun(A, B) ->
                          A#time_config.start_time < B#time_config.start_time
                  end,
            NewList = lists:sort(Fun, AllList),
            lists:nth(1, NewList)
    end.

%% 取时间配置列表
get_time_config_list() ->
    List = get(temp_config) ++ get(static_config),
    lists:sort(List).

%% 插入临时
insert_temp_config(StartTime, Duration, Interval, EndStage, Para) ->
    NewConfig = #time_config{start_time = StartTime,
                             duration = Duration,
                             interval = Interval,
                             end_stage = EndStage,
                             id = generate_id(),
                             para = Para},
    OldConfigList = get(temp_config),
    save_tmp_config([NewConfig|OldConfigList]).

%% 读取配置
read_config(Mod, Key) ->
    % 读取临时时间配置
    TempConfig = restore_tmp_config(Mod),
    put(temp_config, TempConfig),

    % 读取固定时间配置
    StaticConfig = read_static_config(Key),
    put(static_config, StaticConfig),

    % 保存模块名
    put(config_module, Mod),

    ok.

%% 删除固定配置
remove_static_config(Id) ->
    StaticConfig = get(static_config),
    case lists:keyfind(Id, #time_config.id, StaticConfig) of
        false -> true;
        _ ->
            NewConfig = lists:keydelete(Id, #time_config.id, StaticConfig),
            put(static_config, NewConfig)
    end.

%% 删除临时配置
remove_temp_config(Id) ->
    TempConfig = get(temp_config),
    case lists:keyfind(Id, #time_config.id, TempConfig) of
        false -> true;
        _ ->
            NewConfig = lists:keydelete(Id, #time_config.id, TempConfig),
            save_tmp_config(NewConfig)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End Interface%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Internal Fun%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 过滤时间配置
filter_config(static_config, RefTime, Between, _) ->
    List = get(static_config),
    Result = get_useable_config(RefTime, Between, List, []),
    put(static_config, Result),
    Result;
filter_config(temp_config, RefTime, Between, Save) ->
    List = get(temp_config),
    NewList = get_useable_config(RefTime, Between, List, []),
    case Save andalso NewList /= List of
        true ->
            save_tmp_config(NewList);
        false ->
            ok
    end,
    NewList.

%% 生成ID
generate_id() ->
    {ok, Id} = game_id:get_new_time_config_id(),
    TimeStr = integer_to_list(util:unixtime(), 16),
    IdStr = integer_to_list(Id, 16),
    lists:flatten(io_lib:format("~8..0s~4..0s", [TimeStr, IdStr])).

%% 取对于参照时间能用的时间配置
get_useable_config(_, _, [], Ret) ->
    Ret;
get_useable_config(RefTime, Between, List, Ret) ->
    [Rcd|Remain] = List,

    % 如果是取在期间的时间的话，只要结束时间大于参照时间即可
    % 如果是取不在期间的时间的话，只要开始时间大等于参照时间即可
    case Between of
        true ->
            Time = Rcd#time_config.start_time + Rcd#time_config.duration,
            case Time > RefTime of
                true ->
                    % 符合条件
                    NewRet = [Rcd|Ret];
                false ->
                    % 不符合条件，通过间隔计算
                    case Rcd#time_config.interval of
                        0 ->
                            % 没有间隔，表示活动只进行一次，那么就没有符合条件的时间了
                            NewRet = Ret;
                        Interval ->
                            % 有间隔，计算时间
                            NewTime = Time + (RefTime - Time + Interval - 1) div Interval * Interval,
                            StartTime = NewTime - Rcd#time_config.duration,
                            case Rcd#time_config.end_stage /= 0 andalso StartTime >= Rcd#time_config.end_stage of
                                true ->
                                    % 有阶段限制且已经过期
                                    NewRet = Ret;
                                false ->
                                    % 无阶段限制或者没有过期
                                    NewRet = [Rcd#time_config{start_time = StartTime}|Ret]
                            end
                    end
            end;
        false ->
            Time = Rcd#time_config.start_time,
            case Time >= RefTime of
                true ->
                    % 符合条件
                    NewRet = [Rcd|Ret];
                false ->
                    % 不符合条件，通过间隔计算
                    case Rcd#time_config.interval of
                        0 ->
                            % 没有间隔，表示活动只进行一次，那么就没有符合条件的时间了
                            NewRet = Ret;
                        Interval ->
                            % 有间隔，计算时间
                            StartTime = Time + (RefTime - Time + Interval - 1) div Interval * Interval,
                            case Rcd#time_config.end_stage /= 0 andalso StartTime >= Rcd#time_config.end_stage of
                                true ->
                                    % 有阶段限制且已经过期
                                    NewRet = Ret;
                                false ->
                                    % 无阶段限制或者没有过期
                                    NewRet = [Rcd#time_config{start_time = StartTime}|Ret]
                            end
                    end
            end
    end,

    get_useable_config(RefTime, Between, Remain, NewRet).

%% 解析配置格式，把rcd_activity_time转成time_config
parse_config_rcd(Rcd) ->
    StartTime = util:datetime_to_unixtime(Rcd#rcd_activity_time.cfg_start_time),
    Duration = parse_time_format(Rcd#rcd_activity_time.cfg_duration),
    Interval = parse_time_format(Rcd#rcd_activity_time.cfg_interval),
    EndStage =
        case Rcd#rcd_activity_time.cfg_end_stage of
            0 -> 0;
            _ -> util:datetime_to_unixtime(Rcd#rcd_activity_time.cfg_end_stage)
        end,

    #time_config{start_time = StartTime,
                 duration = Duration,
                 interval = Interval,
                 end_stage = EndStage,
                 id = generate_id(),
                 para = Rcd#rcd_activity_time.cfg_para}.

%% 解析时间格式
parse_time_format({day,N}) ->
    N * ?SECONDS_PER_DAY;
parse_time_format({hour,N}) ->
    N * ?SECONDS_PER_HOUR;
parse_time_format({min,N}) ->
    N * ?SECONDS_PER_MINUTE;
parse_time_format({sec,N}) ->
    N;
parse_time_format(N) ->
    N.

%% 从配置表读取固定配置
read_static_config(Key) ->
    [parse_config_rcd(Rcd)|| Rcd <- cfg_activity_time:get_activity_time(Key)].

%% 从数据库读取临时时间配置
restore_tmp_config(Mod) ->
    Sql = io_lib:format("select data from gd_common_data where path = '~s' and name = '~p' and branch = '~s'",
                    [?MY_SAVE_PATH, ?MY_SAVE_NAME, ?MY_SAVE_BRANCH]),
    Data = db_sql:get_one(Sql),
    case Data of
        null ->
            % 空数据，返回空列表
            [];
        _ ->
            % 有数据，恢复出来
            DataList = util:bitstring_to_term(Data),
            [#time_config{start_time = StartTime,
                          duration = Duration,
                          interval = Interval,
                          end_stage = EndStage,
                          id = Id,
                          para = Para}|| {StartTime, Duration, Interval, EndStage, Id, Para} <- DataList]
    end.

%% 保存临时配置
save_tmp_config(TempConfig) ->
    put(temp_config, TempConfig),
    save_tmp_config().
save_tmp_config() ->
    Mod = get(config_module),
    List = get(temp_config),
    NewList = [{Rcd#time_config.start_time, Rcd#time_config.duration,
                Rcd#time_config.interval, Rcd#time_config.end_stage,
                Rcd#time_config.id, Rcd#time_config.para} || Rcd <- List],
    Sql = io_lib:format("replace into gd_common_data (path, name, branch, data) values ('~s', '~p', '~s', '~s')",
                        [?MY_SAVE_PATH, ?MY_SAVE_NAME, ?MY_SAVE_BRANCH, util:term_to_string(NewList)]),
    DbRet = db_sql:execute(Sql),
    case DbRet of
        {ok, AffectRow} ->
            AffectRow > 0;
        _ ->
            false
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End Internal Fun%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

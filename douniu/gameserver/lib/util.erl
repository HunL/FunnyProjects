%%%-----------------------------------
%%% @Module  : util
%%% @Author  : xyao
%%% @Email   : jiexiaowen@gmail.com
%%% @Created : 2010.04.15
%%% @Description: 公共函数
%%%-----------------------------------
-module(util).
-include("common.hrl").
-include("record.hrl").
-export([
%%         log/5,
        unixtime/0,
        longunixtime/0,
        unixtime_to_timedesc/1,
        unixtime_to_datetime/1,
        datetime_to_unixtime/1,
        is_same_day/2,
        is_today/1,
        time_desc/0,
        time_desc/1,
        today_zero_time/0,
        week_zero_time/0,
        is_point_in_rect/2,
        md5/1,
        rand/2,
		ceil/1,
		ceil_div/2,
        floor/1,
        sleep/1,
        sleep/2,
        get_list/2,
        implode/2,
        implode/3,
        explode/2,
        explode/3,
        for/3,
        for/4,
        string_to_term/1,
        bitstring_to_term/1,
        term_to_string/1,
        term_to_bitstring/1,
        is_process_alive/1,
        abs/1,
		distance/4,
		int_untokens/2,
		int_tokens/2,
		list_add/2,
		list_mis/2,
		list_multiple/2,
		max/2,
		min/2,
		get_sys_begin_time/0,
		split/1,
		string_to_binary/1,
		get_page/3,
		get_showlist/3,
		get_eff_list/1,		
		find_bit/2,
		replace_bit/3,
		get_base_hours/0,
		oclock/2,
		check_distance/5,
		get_format_ip/1,
		test_time/0,
		check_other_day/1,
		get_diff_day/2,
		get_diff_time/0,
		get_daily_value/3,
		get_daily_value/4,
		shuffle/1,
		get_next_day_second_start/0,
		get_today_second_start/0,
        get_now_second/0,
        get_now_millisecond/0,

        get_today_midnight_sec/0, 
        bool2int/1,
        trigger/1, 
        nth_in_list/2
    ]).

%%用来替代进程字典的接口
-export([put_ets/3,
		get_ets/2,
		erase_ets/2,
		get_all_ets/1]).

%% 在List中的每两个元素之间插入一个分隔符
implode(_S, [])->
	[<<>>];
implode(S, L) when is_list(L) ->
    implode(S, L, []).
implode(_S, [H], NList) ->
    lists:reverse([thing_to_list(H) | NList]);
implode(S, [H | T], NList) ->
    L = [thing_to_list(H) | NList],
    implode(S, T, [S | L]).

%% 字符->列
explode(S, B)->
    re:split(B, S, [{return, list}]).
explode(S, B, int) ->
    [list_to_integer(Str) || Str <- explode(S, B), length(Str) > 0].

thing_to_list(X) when is_integer(X) -> integer_to_list(X);
thing_to_list(X) when is_float(X)   -> float_to_list(X);
thing_to_list(X) when is_atom(X)    -> atom_to_list(X);
thing_to_list(X) when is_binary(X)  -> binary_to_list(X);
thing_to_list(X) when is_list(X)    -> X.

%% %% 日志记录函数
%% log(T, F, A, Mod, Line) ->
%%     {ok, Fl} = file:open("E:/test_log/error_log.txt", [write, append]),
%%     Format = list_to_binary("#" ++ T ++" ~s[~p:~p] " ++ F ++ "\r\n"),
%%     {{Y, M, D},{H, I, S}} = erlang:localtime(),
%%     Date = list_to_binary([integer_to_list(Y),"-", integer_to_list(M), "-", integer_to_list(D), " ", integer_to_list(H), ":", integer_to_list(I), ":", integer_to_list(S)]),
%%     %%?INFO(print,Fl, unicode:characters_to_list(Format), [Date, Mod, Line] ++ A),
%%     file:close(Fl).    

%% 取得当前的unix时间戳
unixtime() ->
    {M, S, _} = erlang:now(),
    M * 1000000 + S.

longunixtime() ->
    {M, S, Ms} = erlang:now(),
    M * 1000000000 + S*1000 + Ms div 1000.

%% 把从1970年1月1日0点的秒数转成年月日的时间格式:1970-01-01 00:00:00（数据库中datatime的格式）
unixtime_to_timedesc(UnixTime) ->
    case UnixTime of
        _ when is_integer(UnixTime)->
            {{Year, Month, Day}, {Hour, Min, Sec}} = unixtime_to_datetime(UnixTime),
            lists:flatten(io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w",
                                        [Year, Month, Day, Hour, Min, Sec]));
        _ -> UnixTime
    end.

%% 把从1970年1月1日0点的秒数转成{{Year, Month, Day}, {Hour, Min, Sec}}
unixtime_to_datetime(UnixTime) ->
    case UnixTime of
        _ when is_integer(UnixTime)->
            calendar:now_to_local_time({UnixTime div 1000000, UnixTime rem 1000000, 0});
        _ -> UnixTime
    end.

%% 把{{Year, Month, Day}, {Hour, Min, Sec}}这种时间格式转成到1970年1月1日0点的秒数
datetime_to_unixtime(DateTime) ->
    case DateTime of
        {{_, _, _}, {_, _, _}} ->
            {{Year, Month, Day}, {Hour, Min, Sec}} = erlang:localtime_to_universaltime(DateTime),
            (calendar:date_to_gregorian_days(Year, Month, Day) - 
                 calendar:date_to_gregorian_days(1970, 1, 1)) * 3600 * 24 + 
                calendar:time_to_seconds({Hour, Min, Sec});
        _ ->
            DateTime
    end.

%% 判断Time1和Time2是否是同一天
is_same_day(Time1, Time2) ->
    {{Y1, M1, D1}, _} = unixtime_to_datetime(Time1),
    {{Y2, M2, D2}, _} = unixtime_to_datetime(Time2),

    (D1 == D2) andalso (M1 == M2) andalso (Y1 == Y2).

%% 判断Time是否是今天
is_today(Time) ->
    is_same_day(unixtime(), Time).

time_desc() ->
    time_desc(1).

time_desc(1) ->
    {{Year, Month, Day}, {Hour, Min, Sec}} = erlang:localtime(),
    lists:flatten(io_lib:format("~4..0w~2..0w~2..0w~2..0w~2..0w~2..0w",[Year, Month, Day, Hour, Min, Sec])).

%% 取今天0点的时间到1970年1月1日0点的秒数
today_zero_time() ->
    DateTime = {date(), {0, 0, 0}},
    datetime_to_unixtime(DateTime).

%% 取本周一0点的时间到1970年1月1日0点的秒数
week_zero_time() ->
    DateTime = {date(), {0, 0, 0}},
    Time = datetime_to_unixtime(DateTime),
    CurWeek = calendar:day_of_the_week(date()),
    Time - (CurWeek - 1) * ?SECONDS_PER_DAY.

%% 转换成HEX格式的md5
md5(S) ->
    lists:flatten([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(S))]).

%% 产生一个介于Min到Max之间的随机整数,[Min, Max]
rand(Same, Same) -> Same;
rand(Min, Max) ->
    %% 如果没有种子，将从核心服务器中去获取一个种子，以保证不同进程都可取得不同的种子
    case get("rand_seed") of
        undefined ->
            RandSeed = mod_rand:get_seed(),
            random:seed(RandSeed),
            put("rand_seed", RandSeed);
        _ -> skip
    end,
    %% random:seed(erlang:now()),
    M = Min - 1,
    random:uniform(Max - M) + M.

%%向上取整
ceil(N) when N < 0 ->
	trunc(N);
ceil(N) ->
    T = trunc(N),
    case N == T of
        true  -> T;
        false -> 1 + T
    end.

%% 对A除以B的商向上取整
ceil_div(A, B) ->
	C = A div B,
	case A rem B == 0 of
		true -> C;
		false -> C + 1
	end.
	
%%向下取整
floor(X) ->
    T = trunc(X),
    case (X < T) of
        true -> T - 1;
        _ -> T
    end.

 sleep(T) ->
    receive
    after T -> ok
    end.

 sleep(T, F) ->
    receive
    after T -> F()
    end.

get_list([], _) ->
    [];
get_list(X, F) ->
    F(X).

%% for循环
for(Max, Max, F) ->
    F(Max);
for(I, Max, F)   ->
    F(I),
    for(I+1, Max, F).

%% 带返回状态的for循环
%% @return {ok, State}
for(Max, Min, _F, State) when Min<Max -> {ok, State};
for(Max, Max, F, State) -> F(Max, State);
for(I, Max, F, State)   -> {ok, NewState} = F(I, State), for(I+1, Max, F, NewState).

%% term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]"
term_to_string(Term) ->
    %%binary_to_list(list_to_binary(io_lib:format("~p", [Term]))).
	%%use a more effecional way
	lists:flatten(io_lib:format("~p", [Term])).

%% term序列化，term转换为bitstring格式，e.g., [{a},1] => <<"[{a},1]">>
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~p", [Term])).

%% term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> undefined
            end;
        _Error ->
            undefined
    end.

%% term反序列化，bitstring转换为term，e.g., <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).
    
    
%%=============================================================
%% code below was add by dizengrong@gmail.com at 2011-8-7
%%=============================================================
%% 全局分布式进程检查器
is_process_alive(Pid) 
	when is_pid(Pid) ->
    	rpc:call(node(Pid), erlang, is_process_alive, [Pid]).
    	

abs(N) ->
	erlang:abs(N).
%% 	case N >= 0 of
%% 		true -> N;
%% 		false -> -N
%% 	end.

%% 计算坐标(X1, Y1) 与 (X2, Y2)的距离
distance(X1, Y1, X2, Y2) ->
	math:sqrt((X1 - X2)*(X1 - X2) + (Y1 - Y2)*(Y1 - Y2)).

%% 将一整数列表按分割服打包为一个字符串，如[1,2,3]，用"|"来分割打包的话就是"1|2|3"
%% [1]打包则为"1"，[]打包则为""，即为空[]
int_untokens(IntList, Separator) ->
	Size = length(IntList),
	int_untokens_help(Size, IntList, Separator).

int_untokens_help(0, [], _Separator) -> "";
int_untokens_help(1, [Int], _Separator) -> integer_to_list(Int);
int_untokens_help(Size, [Int | Rest], Separator) ->
	Str = int_untokens_help(Size - 1, Rest, Separator),
	integer_to_list(Int) ++ Separator ++ Str.

%% 将由许多整数和分割符组成的字符串解析为一个整数的列表，如"1|2|3"则被解析为[1,2,3]
%% 参数Seperator指定了分隔符
int_tokens(IntStr, Seperator) ->
	Index = string:chr(IntStr, Seperator),
	case Index > 0 of
		true ->
			Id = list_to_integer(string:substr(IntStr, 1, Index - 1)),
			lists:append(int_tokens(string:substr(IntStr, Index + 1), Seperator), [Id]);
		false ->
			[list_to_integer(string:substr(IntStr, 1))]
	end.

%% 将两个list中对应位置上的值进行相加并将结果组成一个list
%% 如：[1,2,3] + [2,2,2] = [3,4,5]
list_add([], []) -> [];
list_add(L1, L2) ->
	AddFun = fun(A1, A2) -> A1 + A2 end,
	two_list_map(L1, L2, AddFun, []).


%% 将L1中对应位置上元素减去L2对应位置上的元素，并将结果组成一个list
%% 如：[1,2,3] - [2,2,2] = [-1,0,1]
list_mis(L1, L2) ->
	MisFun = fun(A1, A2) -> A1 - A2 end,
	two_list_map(L1, L2, MisFun, []).

list_multiple(L1, L2) ->
	MulFun = fun(A1, A2) -> A1 * A2 end,
	two_list_map(L1, L2, MulFun, []).


%% 将2个list对应位置上的元素作为参数传递给函数MapFun，并将得到的结果组成一个list返回
two_list_map([], [], _MapFun, Result) -> Result;
two_list_map([E1 | L1], [E2 | L2], MapFun, Result) ->
	T = MapFun(E1, E2),
	two_list_map(L1, L2, MapFun, lists:append(Result, [T])).

%% 取两个整数中大的数
max(Num1, Num2) ->
	if
		Num1 > Num2 ->
			Num1;
		true ->
			Num2
	end.

%% 取两个整数中小的数
min(Num1, Num2) ->
	if
		Num1 > Num2 ->
			Num2;
		true ->
			Num1
	end.
    
%% 获取当前秒数(从1970年0:0:0开始)
get_now_second() ->
    {MegaSecs, Secs, _MicroSecs} = os:timestamp(),
    MegaSecs*1000*1000 + Secs.

get_now_millisecond() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    1000000000 * MegaSecs + Secs * 1000 + MicroSecs div 1000.

get_today_midnight_sec() ->
    {Hour, Min, Sec} = time(),
    Now = Hour*3600 + Min*60 + Sec,
    util:get_now_second() - Now.

%% 获取当前时区第二天的开始秒数（1970年开始）
get_next_day_second_start() ->
	Sec = calendar:datetime_to_gregorian_seconds({erlang:date(), {0,0,0}}),	%获取当天凌晨的本地时间（自1970年开始的秒数）,
	Sec + ?SECONDS_PER_DAY.

%% 获取当前时区第二天的开始秒数（1970年开始）
get_today_second_start() ->
	calendar:datetime_to_gregorian_seconds({erlang:date(), {0,0,0}}).	%获取当天凌晨的本地时间（自1970年开始的秒数）,

%% 获取系统第二天开始时间秒数
get_sys_begin_time() ->
	SysBeginTime = data_system:get(38),
	%% {erlang:date(), Time}时区为本机时区
	BaseTime = calendar:datetime_to_gregorian_seconds({erlang:date(), SysBeginTime}),
	%% {calendar:local_time()}时区为本机时区
	NowTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Time1970 = calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}}),
	?INFO("NowTime=~p", [NowTime - Time1970]),
	if
		NowTime > BaseTime ->
			BaseTime - Time1970 - get_diff_time();  %% 有8个小时的时差
		true ->
			BaseTime - Time1970 - ?SECONDS_PER_DAY - get_diff_time() %% 有8个小时的时差
	end.

test_time() ->
	BaseTime = calendar:datetime_to_gregorian_seconds({erlang:date(), erlang:time()}),
	NowTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Time1970 = calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}}),
	NowTime1 = unixtime(),
	?INFO( "BaseTime=[~p], NowTime1=[~p]", [BaseTime, NowTime1]),
	{(NowTime - Time1970- 8*3600) - NowTime1 , (BaseTime - Time1970 - 8*3600) - NowTime1}.

%% 检查传入时间是否比今天开始时间早，即检查当前时间与传入时间是否不在同一天
check_other_day(ComTime) ->
	NowTime = unixtime(),
	case get_diff_day(ComTime, NowTime) of
		{later, _} ->
			true;
		the_same_day ->
			false;
		_Other ->
			true
	end.

%% Time1 < Time2 返回:{later, 时间差}
%% Time1 > Time2 返回:{before, 时间差}
%% Time1 = Time2 返回:the_same_day
get_diff_day(Time1, Time2) ->	
%% 	{H, M, S} = ?SYS_BEGIN_TIME,
	{H, M, S} = data_system:get(38),
	TmpTime1 = Time1 + get_diff_time()  - (H*3600 + M*60 + S),
	TmpTime2 = Time2 + get_diff_time()  - (H*3600 + M*60 + S),
	case (TmpTime2  div ?SECONDS_PER_DAY  - TmpTime1  div ?SECONDS_PER_DAY) of
		Time when Time > 0 ->
			{later, Time};
		Time when Time < 0 ->
			{before, -Time};
		_Time ->
			the_same_day
	end.

%% 获取因为时区不一样引起的时间差
get_diff_time() ->
	%% unxitime()取的是从0年0月0日0时0分0秒距离现在的秒数（时区为0）
	NowTime = unixtime(),
	{Days, {H, M, S}} = calendar:seconds_to_daystime(NowTime),
	%% date(), time()取的是从1970年到现在的秒数（时区为本机所设置时区）
	Days1 = calendar:date_to_gregorian_days(date()),
	{H1, M1, S1} = time(),
	
	DiffTime = (Days1-Days-?DAYS_FROM_0_TO_1970)*?SECONDS_PER_DAY + (H1-H)*?SECONDS_PER_HOUR + (M1-M)*?SECONDS_PER_MINUTE + (S1-S),
	DiffTime.
	





%% 将字段列表用“,”分割。	
split(Str)->
	case length(Str) of 
		0->"";
		_N->"," 
	end.

%% 获取分页表示时的页码，输入（所取页数，所有记录数，每页显示数）
%% 输出：（ok，显示页序号，总页数，本页记录数）。	
get_page(Page,Num,Enum)->
	Ptt = Num div Enum,
	Prr = Num rem Enum,
	Pt = case Prr==0 of true->Ptt;false-> Ptt+1 end,
	Page1 = case Page>Pt of true->1;false->Page end,
	if (Prr==0)->{ok,Page1,Pt,Enum};
			(Pt==Page1)->{ok,Page1,Pt,Prr};
			(Pt>Page1)->{ok,Page1,Pt,Enum}
	end.

%% 获取分页显示的列表中本次需要显示的list。	
get_showlist(List,Page,Pnum)->
	case List of
		[]->{0,0,0,[]};
		ML->
			if(Page==0)->{0,0,length(ML),ML};
				true->			
					case get_page(Page,length(ML),Pnum) of
						{ok,Pg,Pt,Num}->
							ML1 = lists:sublist(ML, (Pg-1)*Pnum+1, Num),
							{Pt,Pg,Num,ML1};
						_->{0,0,0,[]}
					end
			end
	end.
	
%%	将字符串用二进制表示。
string_to_binary(List)->
	N = list_to_binary(List),Ln=length(List),<<Ln:16,N/binary>>.
	
get_eff_list(Data)->
	{ok,Tokens1,_} = erl_scan:string(binary_to_list(Data)++"."),
	{ok,Y1} = erl_parse:parse_term(Tokens1),
	Y1.	


%% N 从1开始 Bin 要找的Bin
find_bit(N,Bin) ->
	if
		(size(Bin) *8) >= N ->
			N1 = N-1,
			<< _:N1,Bin1:1,_/bitstring >> = Bin,
			Bin1;
		true ->
			0
	end.

%% 替换 N从1开始
replace_bit(N,Value,Bin) ->
	if
		(size(Bin) *8) >= N ->
			N1 = N-1,
			<< Bin1:N1,_:1,Bin2/bitstring >> = Bin,			
			{ok,<< Bin1:N1,Value:1,Bin2/bitstring >>} ;
		true ->
			{ok,Bin}
	end.

%% 这个方法对传递进来的utctime没有考虑到时区的问题，因此被废弃了
%% %% 检查Time1和Time2是否是同一天，两个参数都是unixtime类型
%% %% 是同一天则返回0，Time1的天数大于Time2的天数返回1，Time1的天数小于Time2的天数返回2
%% is_same_day(Time1, Time2) ->
%% 	{Day1, _} = calendar:seconds_to_daystime(Time1),
%% 	{Day2, _} = calendar:seconds_to_daystime(Time2),
%% 	if
%% 		Day1 == Day2 -> 0;
%% 		Day1 >  Day2 -> 1;
%% 		true ->			2
%% 	end.

%%用来获取每日事件基准时间。
%%以小时数表示。
%%基准时间不一样则表示与上一次事件已经相差一天，可以重新执行
get_base_hours()->
	%%tax re-count will be reset on 3:00am every day.
	%%so set the day *24 + 3 as base line.
	{H,_,_} = time(),
	if
		%%3点之后，当天基准小时数为
		H > ?TIME_OFFSET ->
			calendar:date_to_gregorian_days(date())*24+?TIME_OFFSET;
		true->
			(calendar:date_to_gregorian_days(date())-1)*24+?TIME_OFFSET
	end.

%%判断时间now在容差interval内是否整点
-spec oclock(pos_integer(), pos_integer())->true|false.
oclock(Now,Interval)->
	%%用现在秒数，对3600取余数，如果余数<?TIME_OUT * 0.5，或者余数>3600-?TIME_OUT * 0.5,
	R = Now rem 3600,
	(R < Interval * 0.5) orelse (R > 3600-Interval*0.5).

%% 判断点是否在矩形内，用矩形左上、右下的坐标确定矩形
is_point_in_rect({X, Y}, {X1, Y1, X2, Y2}) ->
    X >= X1 andalso X =< X2 andalso Y >= Y1 andalso Y =< Y2.

%% 检测点（X1, Y1）到点的（X2, Y2）距离是否小于等于Distance
check_distance(X1, Y1, X2, Y2, Distance) ->
	(erlang:abs(X1 - X2) =< Distance andalso erlang:abs(Y1 - Y2) =< Distance).

%% 获取点分十进制格式的ip字符串
get_format_ip(Socket) ->
	{ok, {{Ip1, Ip2, Ip3, Ip4}, _}} = inet:peername(Socket),
	Address1 = io_lib:format("~p.~p.~p.~p", [Ip1, Ip2, Ip3, Ip4]),
	Address1.



%%用来替换memcache中大量使用的进程字典接口
put_ets(Ets,Key,Value)->
	?INFO("put_ets ~p, ~p, ~p", [Ets,Key,Value]),
	Ret = case ets:lookup(Ets,Key) of
		[]->
			undefined;
		[{Key,Old_value}]->
			Old_value
	end,
	
	ets:insert(Ets,{Key,Value}),
	Ret.

get_ets(Ets,Key)->
	?INFO("get_ets ~p, ~p,", [Ets,Key]),
	case ets:lookup(Ets, Key) of
		[]->
			undefined;
		[{Key,Value}]->
			Value
	end.

erase_ets(Ets,Key)->
	?INFO("erase_ets ~p, ~p, ~p", [Ets,Key,[]]),
	Ret = case ets:lookup(Ets,Key) of
		[]->
			undefined;
		[{Key,Value}]->
			Value
	end,
	ets:delete(Ets,Key),
	Ret.

get_all_ets(Ets)->
	?INFO("put_ets ~p, ~p, ~p", [Ets,[],[]]),
	ets:tab2list(Ets).

-spec get_daily_value(any(), any(), integer()) -> any().
get_daily_value(OrigValue, ResetTo, LastUpdateTime) ->
	Now = util:unixtime(),
	get_daily_value(OrigValue, ResetTo, LastUpdateTime, Now).

-spec get_daily_value(any(), any(), integer(), integer()) -> any().
get_daily_value(OrigValue, ResetTo, LastUpdateTime, Now) ->
	case util:get_diff_day(LastUpdateTime, Now) of
		the_same_day -> OrigValue;
		_ -> ResetTo
	end.

%list随机洗牌
shuffle(List)-> 
	Size = length(List) + 1,
	List_Rand = [{mod_rand:int(Size),Elem1} || Elem1 <- List],
	List_Sorted = lists:keysort(1,List_Rand),
	Res = [Elem2 || {_RandKey, Elem2}<-List_Sorted],
	Res.

%%true|false转换成整形
bool2int(Bool) ->
    case Bool of
        true -> 1;
        false -> 0
    end.


%%是否触发一个随机事件
%%Rate 概率，小数
trigger(Rate) ->
    Rand = mod_rand:float(),
    if
        Rand =< Rate ->
            true;
        true ->
            false
    end.

%%找出一个元素是列表中的第几个
%%return error|{ok,Nth}
nth_in_list(Ele,List) ->
    nth_in_list_1(Ele, List,1).
nth_in_list_1(_Ele,[],_Nth)->
    error;
nth_in_list_1(Ele,[TmpEle|RestList],Nth) ->
    case Ele of
        TmpEle ->
            {ok,Nth};
        _ ->
            nth_in_list_1(Ele, RestList, Nth+1)
    end.


        

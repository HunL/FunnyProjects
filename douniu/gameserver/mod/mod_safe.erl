%%Author: gavin
%%Create: 2013-3-6
%%Description: GM封禁权限：禁言、封号、封IP、踢下线功能
-module(mod_safe).
-behaviour(gen_server).

-include("common.hrl").

%% API
-export([start_link/0,
    shutup/3, %forbid role to talk
    forbid_role/3, %forbid role to login
    forbid_ip/3, %forbid ip to login
    kick/1, %kick role logout
    role_login/3, %role login notice
    handle_timeout/1 
]).
        

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

%-compile(export_all). %for test

-record(state, {}).

%%角色权限表
-define(TAB_FORBID_LOGIN, forbid_role_login).
-define(TAB_FORBID_IP, forbid_ip_login).
-define(TAB_FORBID_TALK, forbid_talk).


%%role permission type
-define(PERM_TP_SHUTUP, 1).  %forbid the role to talk
-define(PERM_TP_FORBID_LOGIN, 2). %forbid the role login
-define(PERM_TP_FORBID_IP, 3). %forbid role login from the ip address 


%%每隔一定时间扫描一次权限表，单位秒
-define(PERM_GAP_TIME, 30). 

%%%===================================================================
%%% API
%%%===========================e=======================================
%%禁言
%%RoleId 角色ID
%%Enable true|false
%%TimeSec 封禁时间单位秒,解禁时忽略
shutup(RoleId, Enable, TimeSec)->
    ?INFO("shutup:~p,~p, ~p~n", [RoleId, Enable, TimeSec]),
    %?DBLOG(?MODULE, log_gm_opt,[] )
    gen_server:cast(?MODULE, {shutup, RoleId, Enable, TimeSec}).

%%封号
%%Enable true|false
%%TimeSec 封禁时间单位秒,解禁时忽略
forbid_role(RoleId, Enable, TimeSec)->
    ?INFO("forbid role:~p, ~p, ~p~n", [RoleId, Enable, TimeSec]),
    gen_server:cast(?MODULE, {forbid_role, RoleId, Enable,TimeSec}).

%%封ip
%%Enable true|false
%%TimeSec 封禁时间单位秒,解禁时忽略
forbid_ip(Ip, Enable, TimeSec) ->
    ?INFO("forbid role:~p, ~p, ~p ~n", [Ip, Enable, TimeSec]),
    gen_server:cast(?MODULE, {forbid_ip, Ip, Enable, TimeSec}).

%%踢下线
kick(RoleId) ->
    ?INFO("kick:~p~n", [RoleId]),
    gen_server:cast(?MODULE, {kick, RoleId}).

%%角色登录通知
role_login(RoleId, Socket, RolePid) ->
    {ok, {{Ip1, Ip2, Ip3, Ip4}, _Port}} =  inet:peername(Socket), 
    Ip = io_lib:format("~p.~p.~p.~p", [Ip1, Ip2, Ip3, Ip4]),
    FormatIp = lists:flatten(Ip),
    ?INFO("role login, ~p, ~p", [RoleId, FormatIp]),
    gen_server:cast(?MODULE, {role_login, RoleId, FormatIp, RolePid}).

%%超时回调函数
handle_timeout({}) ->
    gen_server:cast(?MODULE, {handle_timeout}).
    

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    ets:new(?TAB_FORBID_LOGIN,[public, named_table, set, {keypos, 1}]),
    ets:new(?TAB_FORBID_IP,[public, named_table, set, {keypos, 1}]),
    ets:new(?TAB_FORBID_TALK,[public, named_table, set, {keypos, 1}]),
    load_forbid_role_from_db(),
    load_forbid_ip_from_db(),
    start_timer(?PERM_GAP_TIME),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast({shutup, RoleId, Enable, TimeSec}, State) ->
    do_shutup(RoleId, Enable, TimeSec),
    {noreply, State};

handle_cast({forbid_role, RoleId, Enable, TimeSec}, State) ->
    do_forbid_role(RoleId, Enable, TimeSec),
    {noreply, State};

handle_cast({forbid_ip, Ip, Enable, TimeSec}, State) ->
    do_forbid_ip(Ip, Enable, TimeSec),
    {noreply, State};

handle_cast({kick, RoleId}, State) ->
    case mod_account:get_pid_by_roleid(RoleId) of 
        {true, RolePid} ->
            do_kick(RolePid, "GM kick");
        _ ->
            ?INFO("role not online"),
            ok
    end,
    {noreply, State};

handle_cast({role_login, RoleId, Ip, RolePid}, State) ->
    ?INFO("role_login:~p,~p,~p", [RoleId, Ip, RolePid]),
    case do_role_login(RoleId, Ip) of
        ok -> ok;
        shutup ->
            ?INFO("role is shutup"),
            mod_role:shutup(RolePid, true);
        {forbid_login, Reason} -> 
            ?INFO("ip or role is forbid"),
            do_kick(RolePid, Reason)
    end,
    {noreply, State};

handle_cast({handle_timeout}, State) ->
    refresh_perm_tab(),
    start_timer(?PERM_GAP_TIME),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%database 
load_forbid_role_from_db()->
    Sql = io_lib:format("select gd_roleid, gd_type, gd_end from gd_forbid_role", []), 
    Res = db_sql:get_all(Sql),
    
    %把超过封禁时间的删除掉
    TimeNow = util:unixtime(),
    F = fun(X) ->
            [XRoleId, XType, XEndStamp]  = X,
            if
                (XEndStamp > 0) and (XEndStamp < TimeNow) ->
                    delete_forbid_role_from_db(XRoleId, XType),
                    false;
                true -> 
                    true
            end
    end,
    Res2 = lists:filter(F, Res),

    ForbidLoginList = [{XRoleId, XEndStamp} ||
        [XRoleId, XType, XEndStamp] <- Res2, XType == ?PERM_TP_FORBID_LOGIN],
    ForbidTalkList = [{XRoleId, XEndStamp} ||
        [XRoleId, XType, XEndStamp] <- Res2, XType == ?PERM_TP_SHUTUP],

    insert(?TAB_FORBID_LOGIN, ForbidLoginList),
    insert(?TAB_FORBID_TALK, ForbidTalkList),
    ok.



load_forbid_ip_from_db()->
    Sql = io_lib:format("select gd_ip,gd_end from gd_forbid_ip", []),
    Res = db_sql:get_all(Sql), 

    %把超过封禁时间的删除掉
    TimeNow = util:unixtime(),
    F = fun(X) ->
            [XIp, XEndStamp] = X,
            if
                (XEndStamp > 0) and (XEndStamp < TimeNow) ->
                    delete_forbid_ip_from_db(binary_to_list(XIp)),
                    false;
                true -> 
                    true
            end
    end,
    ForbidList = [{binary_to_list(XIp), XEndStamp}
        || [XIp, XEndStamp] <- Res],
    ?INFO("Forbid ip list:~p, ~p", [ForbidList, Res]),
    insert(?TAB_FORBID_IP, ForbidList),
    ok.

save_forbid_role_to_db(RoleId, Type, EndStamp)->
    Sql = io_lib:format("replace into gd_forbid_role(gd_roleid, gd_type, gd_end)
        values(~p,~p,~p)", [RoleId, Type, EndStamp]),
    ok = mod_db_server:execute_one(0, Sql).

save_forbid_ip_to_db(Ip, EndStamp) ->
    Sql = io_lib:format("replace into gd_forbid_ip(gd_ip, gd_end) values(~p,~p)", [Ip, EndStamp]),
    ok = mod_db_server:execute_one(0, Sql).

delete_forbid_role_from_db(RoleId, Type) ->
    Sql = io_lib:format("delete from gd_forbid_role where gd_roleid=~p and
        gd_type=~p", [RoleId, Type]),
    ok = mod_db_server:execute_one(0, Sql).

delete_forbid_ip_from_db(Ip) ->
    Sql = io_lib:format("delete from gd_forbid_ip where gd_ip=~p", [Ip]),
    ok = mod_db_server:execute_one(0, Sql).

%%
insert(Tab, Object) ->
    ets:insert(Tab, Object).

member(Tab, Key) ->
    ets:member(Tab, Key).

lookup(Tab, Key) ->
    ets:lookup(Tab, Key).

delete(Tab, Key) ->
    ets:delete(Tab, Key).

role_is_shutup(RoleId) ->
    member(?TAB_FORBID_TALK, RoleId).

role_is_forbid(RoleId) ->
    member(?TAB_FORBID_LOGIN, RoleId).

ip_is_forbid(Ip) ->
    member(?TAB_FORBID_IP, Ip).

do_shutup(RoleId, Enable, TimeSec) ->
    case Enable of
        true ->
            TimeEnd = 
            case TimeSec of
                0 -> 0;
                _ ->
                    util:unixtime() + TimeSec
            end,
            insert(?TAB_FORBID_TALK, {RoleId, TimeEnd}),
            save_forbid_role_to_db(RoleId, ?PERM_TP_SHUTUP, TimeEnd);
        false ->
            delete(?TAB_FORBID_TALK, RoleId),
            delete_forbid_role_from_db(RoleId, ?PERM_TP_SHUTUP)
    end,
    case mod_account:get_pid_by_roleid(RoleId) of
        {true, Pid} ->
            mod_role:shutup(Pid, Enable);
        _ -> 
            ok
    end,
    ok.

do_forbid_role(RoleId, Enable, TimeSec) ->
    case Enable of
        true ->
            TimeEnd = 
            case TimeSec of
                0 -> 0;
                _ ->
                    util:unixtime() + TimeSec
            end,
            insert(?TAB_FORBID_LOGIN, {RoleId, TimeEnd}),
            save_forbid_role_to_db(RoleId, ?PERM_TP_FORBID_LOGIN, TimeEnd);
        false ->
            delete(?TAB_FORBID_LOGIN, RoleId),
            delete_forbid_role_from_db(RoleId, ?PERM_TP_FORBID_LOGIN)
    end,
    ok.

do_forbid_ip(Ip, Enable, TimeSec) ->
    insert(?TAB_FORBID_IP, {Ip, TimeSec}),
    case Enable of
        true ->
            TimeEnd = 
                case TimeSec of
                    0 -> 0;
                    _ ->
                        util:unixtime() + TimeSec
                end,
            insert(?TAB_FORBID_IP, {Ip, TimeEnd}),
            save_forbid_ip_to_db(Ip, TimeEnd);
        false ->
            delete(?TAB_FORBID_IP, Ip),
            delete_forbid_ip_from_db(Ip)
    end,
    ok.

do_kick(RolePid, Reason) ->
    ?INFO("do_kick,~p,~s", [RolePid, Reason]),
    mod_role:kick_off(RolePid, Reason), 
    ok.

do_role_login(RoleId, Ip)->
    IpIsForbid = ip_is_forbid(Ip),
    RoleIsForbid =  role_is_forbid(RoleId),
    RoleIsShutup = role_is_shutup(RoleId),
    case {IpIsForbid, RoleIsForbid, RoleIsShutup} of
        {true, _, _} ->
            {forbid_login, "ip is forbid"};
        {_, true, _} ->
            {forbid_login, "role is forbid"};
        {_, _, true} ->
            shutup;
        _ ->
            ok
    end.

%% 启动定时器
start_timer(TimeOut) ->  
    _Ref = mh_simple_timer:start_timer(?MODULE, TimeOut*1000, {}).

%% 检测刷新一次权限表
refresh_perm_tab()->
    NowTime = util:unixtime(),
    Ms = [{{'$1','$2'},[{'and',{'<','$2',NowTime},{'>','$2',0}}],['$1']}],

    delete_out_of_date(?TAB_FORBID_LOGIN, Ms),
    delete_out_of_date(?TAB_FORBID_IP, Ms),  
    delete_out_of_date(?TAB_FORBID_TALK, Ms),  
    ok.

delete_out_of_date(Tab, Ms)->
    KeyList = ets:select(Tab, Ms),
    %?INFO("out of date:~p, ~p", [Tab, KeyList]),
    F = fun(XKey)->
            case Tab of
                ?TAB_FORBID_LOGIN ->
                    do_forbid_role(XKey, false, undefined);
                ?TAB_FORBID_TALK ->
                    do_shutup(XKey, false, undefined);
                ?TAB_FORBID_IP ->
                    do_forbid_ip(XKey, false, undefined)
            end
    end,
    [F(XKey) || XKey <- KeyList].



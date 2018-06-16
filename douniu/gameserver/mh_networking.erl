%%%-----------------------------------
%%% @Module  : mh_networking
%%% @Author  : xyao
%%% @Email   : jiexiaowen@gmail.com
%%% @Created : 2010.06.1
%%% @Description: network
%%%-----------------------------------
-module(mh_networking).
%% -export([start/1, start_hire/0]).
-export([start/1]).

-include("common.hrl").
-include("record.hrl").

start([Port]) ->
    ok = start_timer(),             %%初始化定时器
	ok = start_account(),			%%初始化账号信息管理模块
	ok = init_mysql(),				%%初始化mysql
	ok = start_db_server(),			%%初始化异步存储模块
%    mh_env:load_open_server_time(), %开服时间	
	ok = start_log(),				%初始化日志系统
%	ok = start_random(),			%%初始化随机数生成进程
	ok = start_client(),			%%初始化客户端处理模块
	ok = start_login_server(),		%%所有账号管理
	ok = start_gameid(),			%%游戏id分配模块
%    ok = start_code_refresh(),  	%%自动热更新
%    ok = start_safe(),              %%GM管理进程
%    ok = start_recharge(),          %% 充值管理进程
%    ok = start_admin(),             %%后台管理进程
	ok = mod_role_ets:init(),		%%启动全局进程管理
	ok = start_tcp(Port),			%%初始化TCP网络监听
	ok = start_douniu(),			%%开启斗牛
	ok.

check_config()->
 	ok = lib_cfg_check:check_monster_skill_exist(),		%% 检查cfg_monster_test表怪物身上的技能是否在cfg_skill中存在
	
	ok = lib_cfg_check:check_all_task_battle_exist(), 	%% 检查所有任务的 战斗配置是否存在
	ok.

%%账号管理模块
start_account() ->
	{ok, _} = supervisor:start_child(
				dn_sup,
				{mod_account,
				 {mod_account, start_link, []},
				 permanent, 10000, worker, [mod_account]}),
	ok.

%%startup client supervision tree
start_client() ->
    {ok,_} = supervisor:start_child(
               dn_sup,
               {mh_tcp_client_sup,
                {mh_tcp_client_sup, start_link,[]},
                transient, infinity, supervisor, [mh_tcp_client_sup]}),
    ok.

%%startup tcp listener supervision tree
%% start_tcp(Port) ->
%%     {ok,_} = supervisor:start_child(
%%                mh_sup,
%%                {mh_tcp_listener_sup,
%%                 {mh_tcp_listener_sup, start_link, [Port]},
%%                 transient, infinity, supervisor, [mh_tcp_listener_sup]}),
%%     ok.
start_tcp(Port) ->
    {ok,_} = supervisor:start_child(
               dn_sup,
               {mh_tcp_listener_sup,
                {mh_tcp_listener_sup, start_link, [Port]},
                transient, infinity, supervisor, [mh_tcp_listener_sup]}),
    ok.

%% start db queue server
start_db_server() ->
	{ok,_} = supervisor:start_child(
               dn_sup,
               {mod_db_server,
                {mod_db_server, start_link, []},
                permanent, 10000, supervisor, [mod_db_server]}),
    ok.

init_mysql() ->
	{ok, _MysqlPid} = 
		supervisor:start_child
		(
			dn_sup, 
			{
				mysql,
				{mysql, start_link, 
					[?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, fun(_, _, _, _) -> ok end, ?DB_ENCODE]},
				permanent, 10000, worker, [mysql]
			}
		),	
     {ok, _} = mysql:connect(?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, ?DB_ENCODE, true),

     %建立从库连接，仅用于后台数据查询
%	 {ok, _} = mysql:connect(?DB_SLAVE,?DB_HOST_SLAVE, ?DB_PORT_SLAVE, ?DB_USER_SLAVE, 
%        ?DB_PASS_SLAVE, ?DB_NAME, ?DB_ENCODE, true),
	%建立日志库连接
%	{ok , _} = mysql:connect(?DB_LOG_CONN, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_LOG, ?DB_ENCODE, true),
	 ok.

%%随机数生成进程
start_random()->
	{ok, _} = supervisor:start_child(
				dn_sup,
				{mod_rand,
				 {mod_rand, start_link, []},
				 permanent, 10000, worker, [mod_rand]}),
	ok.
	
%%启动场景模块
start_scene()->
	mod_scene_mgr:scene_pre_proc(),
	{ok, _} = supervisor:start_child(
				dn_sup,
				{mod_scene_mgr,
				 {mod_scene_mgr, start_link, []},
				 permanent, 10000, worker, [mod_scene_mgr]}),
	ok.


start_douniu() ->
	{ok, _} = supervisor:start_child(
				dn_sup,
				{mod_douniu_mgr,
				 {mod_douniu_mgr, start_link, []},
				 permanent, 10000, worker, [mod_douniu_mgr]}),
	ok.

%%初始化定时器
start_timer() ->
    % mh_simple_timer:init(),
    % util:sleep(1000),
    {ok, _} = supervisor:start_child(
                dn_sup,
                {mh_simple_timer,
                 {mh_simple_timer, start_link, []},
                 permanent, 10000, worker, [mh_simple_timer]}),
    ok.


%%启动延迟发送进程
start_slowsend()->
    {ok, _} = supervisor:start_child(
                dn_sup,
                {mod_slowsend,
                 {mod_slowsend, start, []},
                 permanent, 10000, worker, [mod_slowsend]}),
	ok.

%%启动系统监控进程
start_sysmon()->
	{ok, _} = supervisor:start_child(
				dn_sup,
				{mod_sys_monitor,
				{mod_sys_monitor, start_link, []},
				 permanent, 10000, worker, [mod_sys_monitor]
				}),
	ok.


%%启动离线消息管理进程
start_msg() ->
	{ok, _} = supervisor:start_child(
				dn_sup,
				{mod_msg_mgr,
				{mod_msg_mgr, start_link, []},
				 permanent, 10000, worker, [mod_msg_mgr]
				}),
	ok.

%%自动热更新
start_code_refresh() ->
    {ok, _} = supervisor:start_child(
                dn_sup,
                {mod_refresh,
                {mod_refresh, start_link, []},
                 permanent, 10000, worker, [mod_sys_monitor]
                }),
    ok.

   
start_admin()->
    {ok,_} = supervisor:start_child(
               dn_sup,
               {admin_sup,
                {admin_sup, start_link,[admin_sup, undefined, undefined, undefined]},
                transient, infinity, supervisor, [admin_sup]}),
	 {ok, _} = supervisor:start_child(
                dn_sup,
                {admin_server,
                {admin_server, start_link, []},
                 permanent, 10000, worker, [admin_server]
                }),
     ok.    


start_login_server()->
	{ok, _Pid} = supervisor:start_child(
				   dn_sup,
				   {login_server, {login_server, start_link, []}, 
					permanent, 1000, worker, [login_server]}),
	ok.
	
start_gameid()->
	{ok, _Pid} = supervisor:start_child(
				   dn_sup, 
				   {game_id, {game_id, start_link, []},
					permanent,1000,worker,[game_id]}),
	ok.

start_log()->
	{ok, _Pid} = supervisor:start_child(
				   dn_sup, 
				   {mod_log_db, {mod_log_db, start_link, []},
					permanent,1000,worker,[mod_log_db]}),
	
	{ok, _Pid2} = supervisor:start_child(
				   dn_sup, 
				   {mod_log_print, {mod_log_print, start_link, []},
					permanent,1000,worker,[mod_log_print]}),	
	ok.


start_log_statistics()->
	{ok, _} = supervisor:start_child(
                dn_sup,
                {mod_log_statistics,
                {mod_log_statistics, start_link, []},
                 permanent, 10000, worker, [mod_log_statistics]
                }),
	ok.

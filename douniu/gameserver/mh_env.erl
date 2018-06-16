%% Author: LiuYaohua
%% Created: 2012-1-6
%% Description: sever端的全局环境变量模块
-module(mh_env).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([init_env/0, get_env/1,get_env_atom/1,add_env/2,reload/0, load_open_server_time/0]).

%%
%% API Functions
%%

%% 在此初始化server上的全局变量，如登录时用到的server key
%% 这些全局变量都插入到一个命名的ets表：ets_server_variable中，
%% 这个表的第一个字段为一个唯一的原子，第二个为对应的值
init_env() ->
	ets:new(ets_server_env, 
			[named_table, public, set, {read_concurrency, true}]),
	
%	{ok,[Config_list]} = file:consult(get_config_file()),
	Con = get_config_file(),
	io:format("Con = ~p~n", [Con]),
	Consult = file:consult(Con),
	io:format("Consult = ~p~n", [Consult]),
	case Consult of
		{ok,[Config_list]} ->
			{ok,[Config_list]};
		Other ->
			io:format("Other = ~p~n", [Other]),
			Config_list = [],
			{error, Config_list}
	end,
	
	Fun = fun({Key, Val}) ->
		ets:insert(ets_server_env, {Key, Val})
	end,
	lists:foreach(Fun, Config_list).

reload()->
	{ok,[Config_list]} = file:consult(get_config_file()),
	
	Fun = fun({Key, Val}) ->
		ets:insert(ets_server_env, {Key, Val})
	end,
	lists:foreach(Fun, Config_list).
%% 	ServerKey = mod_configure:read(server_key, CfgFile),
%% 	DB = 		mod_configure:read(db, CfgFile),
%% 	DB_HOST = 	mod_configure:read(db_host, CfgFile),
%% 	DB_PORT = 	mod_configure:read(db_port, CfgFile),
%% 	DB_USER = 	mod_configure:read(db_user, CfgFile),
%% 	DB_PASS = 	mod_configure:read(db_pass, CfgFile),
%% 	DB_NAME = 	mod_configure:read(db_name, CfgFile),
%% 	DB_ENCODE = mod_configure:read(db_encode, CfgFile),
%% 	%% 在次插入全局变量
%% 	ets:insert(ets_server_env, {server_key, ServerKey}),
%% 	ets:insert(ets_server_env, {db, DB}),
%% 	ets:insert(ets_server_env, {db_host, DB_HOST}),
%% 	ets:insert(ets_server_env, {db_port, DB_PORT}),
%% 	ets:insert(ets_server_env, {db_user, DB_USER}),
%% 	ets:insert(ets_server_env, {db_pass, DB_PASS}),
%% 	ets:insert(ets_server_env, {db_name, DB_NAME}),
%% 	ets:insert(ets_server_env, {db_encode, DB_ENCODE}),
%% 	ok.

%% 根据key来获取对应的值
%% 前提是这个key存在并正常初始化了，否则将抛异常
get_env(Key) ->
	try	ets:lookup_element(ets_server_env, Key, 2)
	catch 
		error:badarg-> undefined 
	end.

%% 根据key来获取对应的值，并转化为atom
%% 前提是这个key存在并正常初始化了，否则将抛异常
get_env_atom(Key) ->
	A = get_env(Key),
	io:format("AAAAAAAAAAAAAAAAAAAAAAAAAAAAA=~p~n~n~n", [A]),
	case is_list(A) of
		true -> list_to_atom(A);
		false -> undefined
	end.

%除了从config表内读取配置，还要额外添加配置的，调用此接口
add_env(Key, Val)->
	ets:insert(ets_server_env, {Key,Val}).
%%
%% Local Functions
%%

get_config_file()->
	case init:get_argument(gameconfig) of
		error-> "server.config"; %命令行无配置，则使用默认路径下的server.config
		{ok, CfgFile}-> CfgFile %%从命令行配置读取
	end.
%% 开服时间  第一个玩家注册时间
load_open_server_time()->
	TimeSql = io_lib:format("SELECT UNIX_TIMESTAMP(gd_activetime) FROM gd_role ORDER BY gd_accountid LIMIT 1;", []),
	Timelst = db_sql:get_all(TimeSql),
	CurTime = case length(Timelst) of
		0->
			 calendar:local_time();
		_->
			[[UnixTime]|_Relist] = Timelst,
			util:unixtime_to_datetime(UnixTime)
	end,
	ets:insert(ets_server_env, {open_server, CurTime}).
	
	


%%% -------------------------------------------------------------------
%%% Author  : LiuYaohua
%%% Description :测试客户端管理
%%%
%%% Created : 2012-7-28
%%% -------------------------------------------------------------------
-module(clientmgr).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("clientdef.hrl").
-include("testdef.hrl").
-include("common.hrl").
-include("record.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start/1,handle_timeout/1, start/4, stop/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%-define(SERVERIP,"113.105.250.80").
%-define(SERVERIP,"192.168.106.89").
-define(SERVERIP,"127.0.0.1").
-define(SERVERPORT,333).

%%数据库连接

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================

start(ClientCnt)->
	gen_server:start({local,?MODULE},?MODULE, [ClientCnt], []).

start(TestType, PerSec, Min, Max) ->
	gen_server:start({local,?MODULE}, ?MODULE, [TestType, PerSec, Min, Max], []).

stop(Pid) ->
	gen_server:cast(Pid, {stop}).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
% 初始化配置，环境，等等。
init_clientmgr_env() ->
	%%初始化配置
	mh_env:init_env(),
	%%初始化测试配置
	{ok, [TestConfigList]} = file:consult("test.config"),
	Fun = fun({Key, Val}) ->
		%ets:insert(ets_server_env, {Key, Val})
		mh_env:add_env(Key, Val)
	end,
	lists:foreach(Fun, TestConfigList),
	%%在模拟客户端启动计时器进程
	 mh_simple_timer:start_link(),
	
	mod_rand:start_link(),

	%%初始化地图信息
	MapId = ?TEST_MAPID, MapWidth=?TEST_MAP_WIDTH, MapHeight=?TEST_MAP_HEIGHT,
%	MapCellWidth = MapWidth div ?CELL_POINT_WIDTH + 1,
	MapCellWidth = MapWidth div 10 + 1,
%	MapCellHeight = MapHeight div ?CELL_POINT_HEIGHT + 1,
	MapCellHeight = MapHeight div 10 + 1,
	TerrName = lib_map:new_TerrainEtsName(MapId),
	LTerrain = ?TEST_TERRAIN,
	
	ets:new(TerrName, [public, named_table,{read_concurrency,true}]),
	ok = init_terrain(TerrName, LTerrain, MapWidth * MapHeight, MapWidth),
	
	ets:new(?ETS_CLIENTMAPCFG,[public, named_table,{keypos, #mapcfg.mapid},{read_concurrency,true}]),
	ets:insert(?ETS_CLIENTMAPCFG, #mapcfg{mapid=MapId, pointwidth=MapWidth, pointheight=MapHeight, 
				cellwidth = MapCellWidth, cellheight = MapCellHeight}),
	ok.

get_all_account(Min, Max) ->
	_MysqlPid = mysql:start_link(?DB, mh_env:get_env(db_host), 
		mh_env:get_env(db_port), 
		mh_env:get_env(db_user), 
		mh_env:get_env(db_pass), 
		mh_env:get_env(db_name), fun(_, _, _, _) -> ok end, mh_env:get_env(db_encode)),
	Sql = "SELECT gd_Account FROM gd_account order by gd_Accountid ASC;",
	%% 加载帐号信息
	AccRes = db_sql:get_all(Sql),
	[binary_to_list(Account) || [Account]<-AccRes, 
	begin
		A = util:string_to_term(binary_to_list(Account)),
		((A >= Min) and (A =< Max))
	end].

insert_account_ets(List) ->
	io:format("get all account list length: ~p ~n", [length(List)]),
	[ets:insert(?ETS_CLIENTINFO, #clientinfo{account = A, pid = undefined}) || A <- List],
	ok.

init([TestType, PerSec, Min, Max]) ->
	init_clientmgr_env(),
	ets:new(?ETS_CLIENTINFO, [public, named_table, ordered_set, {keypos, #clientinfo.account}]),
	List = get_all_account(Min, Max),
	insert_account_ets(List),
	case TestType of
		login_presit ->
			do_login_persit(PerSec, Min, Max);
		talk ->
			TalkSec = mh_env:get_env(talk),
			gen_server:cast(self(), {talk, TalkSec, Max - Min + 1});
		guild ->
			gen_server:cast(self(), {guild, Max - Min + 1});
		scene ->
			gen_server:cast(self(), {scene, Max - Min + 1});
		battle ->
			gen_server:cast(self(), {battle, Max - Min + 1});
		_ ->
			ok
	end,
	{ok, []};

init([_ClientCnt]) ->
	io:format("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! This command is not used !!!!!!!!!!!!!!!!!!!!!!!!!!~n"),
    {ok, []}.


%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(_Request, _From, PidList) ->
    Reply = ok,
    {reply, Reply, PidList}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_cast({start_client,Num},_PidList)->
	PidList2 = start_client(Num),
	{noreply, PidList2};

handle_cast({stop}, PidList) ->
	io:format("clientmgr stop..~n", []),
	cast_clients(PidList,{stop}),
	{stop, 'STOP', PidList};

handle_cast({login_presit, PerSec}, PidList) ->
	AccList = ets:match_object(?ETS_CLIENTINFO, #clientinfo{pid = undefined, _ = '_'}, PerSec),
	case AccList of
		'$end_of_table' ->
			PidList1 = PidList;
		_ ->
			{L, _} = AccList,
			AccountList = [
							begin 
								ets:delete(?ETS_CLIENTINFO, A#clientinfo.account),
								A#clientinfo.account 
							end 
							|| A <- L],
			PidList1 = start_client_list(AccountList, PidList)
	end,
	{noreply, PidList1};

handle_cast({talk, TalkSec, _Num}, PidList) ->
	AccList = ets:match_object(?ETS_CLIENTINFO, #clientinfo{pid = undefined, _ = '_'}),
	case AccList of
		[] ->
			PidList1 = PidList;
		_ ->
			L = AccList,
			AccountList = [
							begin 
								ets:delete(?ETS_CLIENTINFO, A#clientinfo.account),
								A#clientinfo.account 
							end 
							|| A <- L],
			PidList1 = start_client_list(AccountList, PidList),
			cast_clients(PidList1,{talk, TalkSec})
	end,
	{noreply, PidList1};

handle_cast({guild, _Num}, PidList) ->
	AccList = ets:match_object(?ETS_CLIENTINFO, #clientinfo{pid = undefined, _ = '_'}),
	case AccList of
		[] ->
			PidList1 = PidList;
		_ ->
			L = AccList,
			PidList1 = [
							begin 
								ets:delete(?ETS_CLIENTINFO, A#clientinfo.account),
								Pid = start_client_list([A#clientinfo.account], []),
								cast_clients([Pid],{guild, A#clientinfo.account})
							end 
							|| A <- L]
	end,
	{noreply, PidList1};

handle_cast({scene, _Num}, PidList) ->
	AccList = ets:match_object(?ETS_CLIENTINFO, #clientinfo{pid = undefined, _ = '_'}),
	case AccList of
		[] ->
			PidList1 = PidList;
		_ ->
			L = AccList,
			AccountList = [
							begin 
								ets:delete(?ETS_CLIENTINFO, A#clientinfo.account),
								A#clientinfo.account 
							end 
							|| A <- L],
			PidList1 = start_client_list(AccountList, PidList)
	end,
	cast_clients(PidList1,{scene_run}),
	Time = (mh_env:get_env(test_time))*1000,
	io:format("Time = ~p~n", [Time]),
	mh_simple_timer:start_timer(?MODULE, Time, stop_test),
	{noreply, PidList1};

handle_cast({battle, _Num}, PidList) ->
	AccList = ets:match_object(?ETS_CLIENTINFO, #clientinfo{pid = undefined, _ = '_'}),
	case AccList of
		[] ->
			PidList1 = PidList;
		_ ->
			L = AccList,
			AccountList = [
							begin 
								ets:delete(?ETS_CLIENTINFO, A#clientinfo.account),
								A#clientinfo.account 
							end 
							|| A <- L],
			PidList1 = start_client_list(AccountList, PidList)
	end,
	cast_clients(PidList1,{start_battle}),
	Time = (mh_env:get_env(test_time))*1000,
	io:format("Time = ~p~n", [Time]),
	mh_simple_timer:start_timer(?MODULE, Time, stop_test),
	{noreply, PidList1};

handle_cast(_Msg, PidList) ->
	io:format("bad msg ~p ~n", [_Msg]),
    {noreply, PidList}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
start_client(Num)->
	AccList = init_account_info(Num),
	PidList = start_client_list(AccList,[]),
	PidList.

%%初始化地图地形
init_terrain(TerrName, L, MaxSize, MapWidth) ->
	init_terrain(TerrName,L,0,MaxSize, MapWidth).

init_terrain(_TerrName, _L, MaxSize, MaxSize, _MapWidth) ->
	ok;
init_terrain(TerrName, [T|Rest], Id, MaxSize, MapWidth)->
	case T of
		%%$0为可走，$1为障碍，$2为遮罩
		$0 -> XY = lib_map:pointid_to_pointxy(Id, MapWidth),
			  ets:insert(TerrName,{XY, Id}),
			  init_terrain(TerrName, Rest, Id+1, MaxSize, MapWidth);
		
		$2 -> XY = lib_map:pointid_to_pointxy(Id, MapWidth),
			  ets:insert(TerrName,{XY, Id}),
			  init_terrain(TerrName, Rest, Id+1, MaxSize, MapWidth);
		
		$1 -> init_terrain(TerrName, Rest, Id+1, MaxSize, MapWidth)
	end.

cast_clients([Pid|Rest], Msg)->
	gen_server:cast(Pid, Msg),
	cast_clients(Rest, Msg);
cast_clients([],_Msg)->
	ok.

init_account_info(Num) ->
	%_MysqlPid = mysql:start_link(?DB, ?SERVERIP, 14399, ?DB_USER, "youlongxd4399", ?DB_NAME, fun(_, _, _, _) -> ok end, ?DB_ENCODE),
	%_MysqlPid = mysql:start_link(?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, fun(_, _, _, _) -> ok end, ?DB_ENCODE),
	Sql = io_lib:format("SELECT gd_Account FROM gd_account order by gd_Accountid ASC limit 0,~p; ", [Num]),
	%% 加载帐号信息
	AccRes = db_sql:get_all(Sql),
	[binary_to_list(Account) || [Account]<-AccRes].

start_client_list([], PidList)->PidList;
start_client_list([Acc|List], PidList)->
	timer:sleep(200),
	{ok,Pid} = client:start(Acc,
		mh_env:get_env(ip), 
		mh_env:get_env(port)),
	start_client_list(List, [Pid|PidList]).

%handle_timeout({_Pid, stop_test}) ->
handle_timeout(stop_test) ->
	%terminate([], []),
	gen_server:cast(?MODULE, {stop}),%%TODO：向所有客户端进程发送停止进程的消息
	 ok;

handle_timeout({Pid, login_presit, DestSec, PerSec}) ->
	NowSec = util:get_now_second(),
	case NowSec =< DestSec of
		true ->
			mh_simple_timer:start_timer(?MODULE, 1000, {Pid, login_presit, DestSec, PerSec}),		
			gen_server:cast(Pid, {login_presit, PerSec});
		false ->
			io:format("~nlogin_presit times up ...~n"),
			ok
	end,
	ok;	 
handle_timeout(_) ->
     ok.
%% %% 停止队伍进程
%% 	{stop, 'DISSOLVE', TeamStatus}.	
	

do_login_persit(PerSec, Min, Max) ->
	% {PerSec, LastSec} = Args,
	LastSec = util:ceil((Max - Min + 1)/PerSec),
	NowSec = util:get_now_second(),
	io:format("~nstart login_presit test ...~n"),
	mh_simple_timer:start_timer(?MODULE, 1000, {self(), login_presit, NowSec + LastSec + 1, PerSec}),	
	ok.

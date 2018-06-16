%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2012-7-26
%%% -------------------------------------------------------------------
-module(clientscene).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("testdef.hrl").
-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").
-include("clientdef.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3,
		 handle/3,gen_path/6]).

-record(cliscene, {mapid = 100, pointpos={22,14}, path=[], mapwidth=1,mapheight=1,socket=undefined,clientpid=undefined}).

%% ====================================================================
%% External functions
%% ====================================================================

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([ClientStatus]) ->
	CliScene = #cliscene{mapid=?TEST_MAPID,mapwidth=?TEST_MAP_WIDTH,mapheight=?TEST_MAP_HEIGHT,
		socket=ClientStatus#clientstatus.socket,clientpid=ClientStatus#clientstatus.pid},
	random:seed(now()),
    {ok, CliScene}.

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
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({login, [MapId,Pos]}, SceneStatus)->
%% 	NewStatus = SceneStatus#cliscene{mapid = MapId, pointpos = Pos},
%% 	{noreply, NewStatus};
	{noreply, SceneStatus};

handle_cast({info}, SceneStatus) ->
	io:format("~n SceneStatus: ~p ~n",[SceneStatus]),
    {noreply, SceneStatus};

handle_cast({run},SceneStatus)->
	NewScene = run(SceneStatus),
	%io:format("~n run NewScene: ~p ~n",[NewScene]),
	{noreply, NewScene};

handle_cast({stop}, ClientStatus)->
	io:format("clientscene stop..~n", []),
	{stop, 'STOP', ClientStatus};
	
handle_cast(_Msg, SceneStatus) ->
    {noreply, SceneStatus}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({run_test}, SceneStatus)->
	NewSceneStatus = run(SceneStatus),
%%	io:format("Info:NewSceneStatus: ~p ~n",[NewSceneStatus]),
	{noreply, NewSceneStatus};

handle_info(_Info, SceneStatus) ->
%%	io:format("Info:~p ~n",[Info]),
    {noreply, SceneStatus}.

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


handle(?PP_ACCOUNT_ROLE_DETAIL, Pos, ClientStatus)->
	gen_server:cast(ClientStatus#clientstatus.scene_pid, {login, Pos}),
	{ok,ClientStatus};
handle(_Cmd, _Data, ClientStatus)->
%%	io:format("clientscene handle Cmd ~p ~n", [Cmd]),
	{ok,ClientStatus}.


gen_path(MapId, Pos, Width, Height,Path,Cnt)->
	case Cnt of
		0 -> lists:reverse(Path);
		_ ->
			Neighbor_Pos_List = get_neighbor_pos(Pos),
			%io:format("Neighbor_Pos_List:~p~n",[Neighbor_Pos_List]),
			%%过滤边界
			PosList1 = [{X,Y} || {X,Y}<-Neighbor_Pos_List, X>=0,X<Width,Y>=0,Y<Height],
			%io:format(" PosList1 :~p~n",[PosList1]),
			%%过滤非法地形
			PosList2 = filter_terrain(PosList1, MapId),
			%io:format(" PosList2 :~p~n",[PosList2]),
			%%过滤掉已有路点
			PosList3 = PosList2--Path,
			%io:format(" PosList3 :~p~n",[PosList3]),
			%%过滤掉cell外
			%PosList4 = [{X,Y} || {X,Y}<-PosList3,X >= 14, X =< 31, Y >= 7, Y =< 24],
			%io:format(" PosList4 :~p~n",[PosList4]),
			PosList4Size = length(PosList3),
			case PosList4Size of
				0 -> lists:reverse(Path);
				_-> Nth = mod_rand:int(PosList4Size),
					NextPos = lists:nth(Nth, PosList3),
					gen_path(MapId, NextPos, Width, Height,[NextPos|Path],Cnt-1)
			end
	end.
	
check_point_terrain(Point, MapId)->
	TerrName = get_TerrainEtsName(MapId),
	case ets:lookup(TerrName, Point) of
		[] -> false;
		[_]-> true
	end.	
	
get_TerrainEtsName(MapId) ->
%	list_to_atom(atom_to_list(?ETS_TERRAIN) ++ integer_to_list(MapId)).
	list_to_atom(atom_to_list(ets_terrain) ++ integer_to_list(MapId)).
	
filter_terrain(PosList,MapId)->
	[X || X<-PosList, check_point_terrain(X,MapId)].

get_neighbor_pos({X,Y})->
	[{X-1,Y-1}, {X,Y-1},{X+1,Y-1},
	 {X-1,Y},           {X+1,Y},
	 {X-1,Y+1},{X,Y+1},{X+1,Y+1}].
	
run(SceneStatus)->	
	NewScene = case SceneStatus#cliscene.path of
		[] -> NewPath = gen_path(SceneStatus#cliscene.mapid,
					   SceneStatus#cliscene.pointpos,
					   SceneStatus#cliscene.mapwidth,
					   SceneStatus#cliscene.mapheight,
					   [SceneStatus#cliscene.pointpos],
					   ?CLI_PATH_SIZE - 1),
			   
			  {ok,PathBin} = pt_12:write(?PP_SECENE_MOVE_PATH, NewPath),
			  %gen_tcp:send(SceneStatus#cliscene.socket, client:pack_seq(PathBin)),
				client:send(SceneStatus#cliscene.clientpid, PathBin),
			  erlang:send_after(?TEST_SCENE_RUN_INT, self(), {run_test}),
			  %clientmgr:battle_test(),%%跑图机器人跑完一次之后战斗机器人交替进行
			  SceneStatus#cliscene{path = NewPath};
		[Step|RestSteps]-> 
			{ok, StepBin} = pt_12:write(?PP_SCENE_MOVE_STEP, Step),
			%gen_tcp:send(SceneStatus#cliscene.socket, client:pack_seq(StepBin)),
			client:send(SceneStatus#cliscene.clientpid, StepBin),
			erlang:send_after(?TEST_SCENE_RUN_INT, self(),{run_test}),
			SceneStatus#cliscene{path=RestSteps, pointpos=Step}
	end,
	NewScene.
	
	










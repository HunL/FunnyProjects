%% @author j
%% @doc @todo Add description to mod_douniu_mgr.

% 180.88.50.233

-module(mod_douniu_mgr).

-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([create_room/1, join_room/2, dissolve_room/1, quit_room/1, qiang_zhuang/1, ya_zhu/2, ready_for_game/1, 
		tanpai/1, zhanji/1]).
-export([is_zhuang/2, room_num/1, tanpai_num/1]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([fapai/1]).
-export([start_link/0]).

start_link() ->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

create_room(RoleInfo)->
	io:format("create_roomcreate_roomcreate_room~n~n~n", []),
	gen_server:call(?MODULE, {create_room, RoleInfo}, ?RPC_TIMEOUT).

zhanji(RoleId)->
	io:format("zhanjizhanjizhanji~n~n~n", []),
	gen_server:call(?MODULE, {zhanji, RoleId}, ?RPC_TIMEOUT).


join_room(RoleInfo, Data)->
	io:format("join_roomjoin_roomjoin_room~n~n~n", []),
	gen_server:call(?MODULE, {join_room, RoleInfo, Data}, ?RPC_TIMEOUT).

dissolve_room(RoleInfo)->
	io:format("dissolve_roomdissolve_roomdissolve_room~n~n~n", []),
	gen_server:call(?MODULE, {dissolve_room, RoleInfo}, ?RPC_TIMEOUT).

quit_room(RoleInfo)->	
	io:format("quit_roomquit_roomquit_room~n~n~n", []),
	gen_server:call(?MODULE, {quit_room, RoleInfo}, ?RPC_TIMEOUT).
	
%is_in_room(RoleId)->
%	io:format("is_in_roomis_in_roomis_in_room~n~n~n", []),
%	gen_server:call(?MODULE, {is_in_room, RoleId}, ?RPC_TIMEOUT).

ready_for_game(RoleInfo)->	
	io:format("ready_for_gameready_for_gameready_for_game~n~n~n", []),
	gen_server:call(?MODULE, {ready_for_game, RoleInfo}, ?RPC_TIMEOUT).
	
tanpai(RoomId)->	
	io:format("tanpaitanpaitanpaitanpai~n~n~n", []),
	gen_server:call(?MODULE, {tanpai, RoomId}, ?RPC_TIMEOUT).
	
tanpai_num(RoomId)->	
	io:format("tanpai_num~n~n~n", []),
	gen_server:call(?MODULE, {tanpai_num, RoomId}, ?RPC_TIMEOUT).
	
fapai(RoomId) ->
%	io:format("jjjjjjjjjjjjjjjjjjjjjjjjjjjj~n~n~n", []),
	?INFO("jjjjjjjjjjjjjjjjjjjjjjjjjjjj~n~n~n", []),
	gen_server:cast(?MODULE, {fapai, RoomId}).

qiang_zhuang(RoomId)->
	io:format("qiang_zhuangqiang_zhuangqiang_zhuang~n~n~n", []),
	gen_server:call(?MODULE, {qiang_zhuang, RoomId}, ?RPC_TIMEOUT).
	
ya_zhu(RoleInfo, Data)->
	io:format("ya_zhuya_zhuya_zhuya_zhu~n~n~n", []),
	gen_server:call(?MODULE, {ya_zhu, RoleInfo, Data}, ?RPC_TIMEOUT).
	
is_zhuang(RoleId, RoomId) ->
	io:format("is_zhuangis_zhuangis_zhuang~n~n~n", []),
	gen_server:call(?MODULE, {is_zhuang, RoleId, RoomId}, ?RPC_TIMEOUT).

room_num(RoomId) ->
	io:format("room_numroom_numroom_num~n~n~n", []),
	gen_server:call(?MODULE, {room_num, RoomId}, ?RPC_TIMEOUT).
	

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {
				pai_list = undefined
			   }).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
	Result :: {ok, State}
			| {ok, State, Timeout}
			| {ok, State, hibernate}
			| {stop, Reason :: term()}
			| ignore,
	State :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([]) ->
%	io:format("~n~n~n~n~pdouniu started!!!!!!!!!!!!!!!!!!!!!!!!!!!~n~n~n", [1]),
	?INFO("~n~n~n~n~p~n~n~ndouniu started!!!!!!!!!!!!!!!!!!!!!!!!!!!~n~n~n", [1]),
	init_ets(),
	%%洗牌
	PaiList = xipai(),
	
    {ok, #state{pai_list = PaiList}}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
	Result :: {reply, Reply, NewState}
			| {reply, Reply, NewState, Timeout}
			| {reply, Reply, NewState, hibernate}
			| {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason, Reply, NewState}
			| {stop, Reason, NewState},
	Reply :: term(),
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================

handle_call({create_room, RoleInfo}, _From, State)->
	io:format("handle_call create_room~n~n~n", []),
	L = create_room(RoleInfo, State),
	{reply, L, State};
	
handle_call({zhanji, RoleId}, _From, State)->
	io:format("handle_call zhanji~n~n~n", []),
	EtsLook = ets:lookup(?DOUNIU_ZHANJI, RoleId),
	io:format("EtsLook =~p~n~n~n", [EtsLook]),
	Reply = case EtsLook of
		false ->
			?INFO("err here ~n", []),
			false;
		EtsZhanji = #douniu_zhanji{zhanji_list = ZhanjiList} ->
			?INFO("here   EtsZhanji :~p ~n", [EtsZhanji]),
			{true, ZhanjiList};
		Err ->
			?INFO("err here : ~p~n", [Err]),
			{true, []}
	end,
	{reply, Reply, State};
	
%handle_call({is_in_room, RoleId}, _From, State)->
%	io:format("handle_call is_in_room, RoleId=~p~n~n~n", [RoleId]),
%	L = is_in_room(RoleId, State),
%	{reply, L, State};

handle_call({join_room, RoleInfo, Data}, _From, State)->
	io:format("handle_call join_room~n~n~n", []),
	L = join_room(RoleInfo, Data, State),
	{reply, L, State};

handle_call({dissolve_room, RoleInfo}, _From, State) ->
	io:format("handle_call dissolve_room~n~n~n", []),
	L = do_dissolve_room(RoleInfo),
	{reply, L, State};


handle_call({quit_room, RoleInfo}, _From, State)->
	io:format("handle_call quit_room~n~n~n", []),
	L = do_quit_room(RoleInfo),
	{reply, L, State};

handle_call({ready_for_game, RoleInfo}, _From, State)->
	io:format("handle_call ready_for_game~n~n~n", []),
	L = do_ready_for_game(RoleInfo, State),
	{reply, L, State};

handle_call({qiang_zhuang, RoomId}, _From, State)->%TODO:to complete
	?INFO("call call call...qiang_zhuang~n~n~n", []),
%	{RoomId, _Flag} = Data,
	?INFO("~nRoomId = ~p~n~n", [RoomId]),
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	?INFO("~n~nlookup=~p~n~n", [LookUp]),
	Reply = case LookUp of
		false ->
			false;
		EtsRoom = #douniu_room{memberlist = MemberList, zhuang_num = ZhuangNum} ->
			if ZhuangNum + 1 < length(MemberList) ->
				   NewEtsRoom = EtsRoom#douniu_room{zhuang_num = ZhuangNum + 1},
				   ets:update_element(?DOUNIU_ROOM, RoomId, NewEtsRoom),
				   false;
			   true ->
				   Rand = mod_rand:int(length(MemberList)),
				   ZhuangId = lists:nth(Rand, MemberList),
				   NewEtsRoom = EtsRoom#douniu_room{zhuang_num = 0, zhuang_id = ZhuangId},
				   ets:update_element(?DOUNIU_ROOM, RoomId, NewEtsRoom),
				   {true, ZhuangId}
			end
	end,
	?INFO("REply=~p~n", [Reply]),
	{reply, Reply, State};

handle_call({ya_zhu, RoleInfo, Beishu}, _From, State) ->
	?INFO("~n~nBeishu=~p~n~n", [Beishu]),
	NewRoleInfo = RoleInfo#mhrole{beishu = Beishu},
	mod_role:set_mhrole(NewRoleInfo),
    Reply = ok,%TODO:role status
    {reply, Reply, State};

handle_call({is_zhuang, RoleId, RoomId}, _From, State) ->
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	io:format("~n~nlookup=~p~n~n", [LookUp]),
	Reply = case LookUp of
		false ->
			?INFO("false~n", []),
			false;
		EtsRoom = #douniu_room{owner_id = OwnerId} ->
			?INFO("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			OwnerId == RoleId;
		Err ->
			?INFO("Err=~p~n", [Err]),
			false
	end,
    {reply, Reply, State};

handle_call({room_num, RoomId}, _From, State) ->
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	?INFO("~n~nlookup=~p~n~n", [LookUp]),
	Reply = case LookUp of
		false ->
			false;
		_EtsRoom = #douniu_room{memberlist = MemberList} ->
			{true, length(MemberList)}
	end,
	{reply, Reply, State};


handle_call({tanpai_num, RoomId}, _From, State) ->
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	?INFO("~n~nlookup=~p~n~n", [LookUp]),
	Reply = case LookUp of
		false ->
			false;
		_EtsRoom = #douniu_room{tanpai_num = TanpaiNum} ->
			{true, TanpaiNum}
	end,
	{reply, Reply, State};

handle_call({tanpai, RoomId}, _From, State) ->
	Reply = do_tanpai(RoomId),
	%%TODO:return compare result
	%%TODO:write zhanji history
	{reply, Reply, State};

handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
%handle_cast({fapai, N}, State)->
%	io:format("fapaifapaiiiiiiiiiiiiiii~n~n~n", []),
%	L = fapai(N, State),
%	{noreply, State};
handle_cast({fapai, RoomId}, State)->
%	io:format("fapaifapaiiiiiiiiiiiiiii~n~n~n", []),
	?INFO("fapaifapaiiiiiiiiiiiiiii~n~n~n", []),
	do_fapai(RoomId, State),
	{noreply, State};
	

handle_cast(Msg, State) ->
	io:format("MsgMsgMsgMsgMsgMsgMsgMsgMsgMsgMsgMsg=~p~n~n~n", [Msg]),
    {noreply, State}.


%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info(Info, State) ->
    {noreply, State}.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
	Reason :: normal
			| shutdown
			| {shutdown, term()}
			| term().
%% ====================================================================
terminate(Reason, State) ->
    ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
	Result :: {ok, NewState :: term()} | {error, Reason :: term()},
	OldVsn :: Vsn | {down, Vsn},
	Vsn :: term().
%% ====================================================================
code_change(OldVsn, State, Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================
init_ets() ->
 	ets:new(?DOUNIU_ROOM, [public, set, named_table, {keypos, #douniu_room.room_id}]),
	ets:new(?DOUNIU_ZHANJI, [public, set, named_table, {keypos, #douniu_zhanji.roleid}]).
	
xipai() ->
	OrderList = lists:seq(1, ?MAX_PAI_NUM),
	%?INFO("L=~p,len=~p~n", [OrderList,length(OrderList)]),
	io:format("L=~p,len=~p~n", [OrderList,length(OrderList)]),
	ShuffleList = util:shuffle(OrderList),
	%?INFO("L2=~p,len=~p~n", [ShuffleList, length(ShuffleList)]),
	io:format("L2=~p,len=~p~n", [ShuffleList, length(ShuffleList)]),
	ShuffleList.

%fapai(N, State) ->
%	io:format("fapaiiiiiiiiiiiiiiii,N=~p~n", [N]),
%	if N > ?MAX_PLAYER ->
%		   [];
%	   N < ?MIN_PLAYER ->
%		   [];
%	   true ->
%		   
%		   F = fun(_X, {Acc, RestList}) ->
%					   {L1, L2} = lists:split(?HAND_CARD_NUM, RestList),
%					   {[L1|Acc], L2}
%			   end,
%		   {List, _} = lists:foldl(F, {[], State#state.pai_list}, lists:seq(1, N)),
%		   io:format("List=~p~n", [List]),
%		   List
%	end.

do_fapai(RoomId, State) ->
%	io:format("fapaiiiiiiiiiiiiiiii~n", []),
	?INFO("fapaiiiiiiiiiiiiiiii~n", []),
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	io:format("~n~nlookup=~p~n~n", [LookUp]),
	case LookUp of
		false ->
			false;
		EtsRoom = #douniu_room{memberlist = MemList} ->
%			io:format("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			?INFO("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			F = fun({X, _}, {Acc, RestList}) ->
						{L1, L2} = lists:split(?HAND_CARD_NUM, RestList),
					   	{[{X, L1}|Acc], L2}
			   	end,
			{NewMemList, _} = lists:foldl(F, {[], State#state.pai_list}, MemList),
			?INFO("NewMemList=~p~n", [NewMemList]),
%			io:format("NMList=~p~n", [NMList]),
			NewEtsRoom = EtsRoom#douniu_room{memberlist = NewMemList},
			ets:update_element(?DOUNIU_ROOM, RoomId, NewEtsRoom),
			[begin
				 {ok, Bin} = pt_50:write(?PP_DOUNIU_FAPAI_ACK, [List]), 
				 lib_send:send_to_roleid(Id, Bin)
			 end || {Id, List} <- NewMemList]
	end.


%tanpai(N, State) ->
%	L = [2,5,7,8,6],
%	ok.

do_tanpai(RoomId) ->
	?INFO("tanpaitanpaitanpaitanpai~n", []),
%	io:format("tanpaitanpaitanpaitanpai~n", []),
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	?INFO("~n~nlookup=~p~n~n", [LookUp]),
%	io:format("~n~nlookup=~p~n~n", [LookUp]),
	case LookUp of
		false ->
			false;
		EtsRoom = #douniu_room{owner_id = OwnerId, memberlist = MList} ->
%			io:format("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			?INFO("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			KeyFind = lists:keyfind(OwnerId, 1, MList),
			case KeyFind of
				false ->
					false;
				{OwnerId, OwnerPaiL} ->
					KeyDelete = lists:keydelete(OwnerId, 1, MList),
					F = fun({X, L}, Acc) ->
								CompareRes = compare(OwnerPaiL, L),
%								send_tanpai_pkg(X, CompareRes)
								[{X, CompareRes}|Acc]%TODO:send ack pkg
						end,
					Res = lists:foldl(F, [], KeyDelete),
					io:format("Res=~p~n~n", [Res]),
					{ok, Res}
			end
	end.

send_tanpai_pkg(X, CompareRes)->
	
	ok.

create_room(RoleInfo, _State)->
	{ok, RoomId} = game_id:get_new_douniuroomId(),
	io:format("~n~nRoomId=~p~n~n", [RoomId]),
	%?INFO("~n~nRoomId=~p~n~n", [RoomId]),
	RecRoom = #douniu_room{room_id = RoomId, 
						   owner_id = RoleInfo#mhrole.roleid, 
						   memberlist = [RoleInfo#mhrole.roleid]},
	ets:insert(?DOUNIU_ROOM, RecRoom),
	{ok, RoomId}.

%is_in_room(RoleId, State)->
%	RoomList = ets:tab2list(?DOUNIU_ROOM),
%	io:format("~n~nRoomList=~p~n~n", [RoomList]),
%	%Res = lists:keyfind(RoleId, #douniu_room.owner_id, RoomList),
%	
%	Fun = fun(X, Acc) ->
%		B = lists:member(RoleId, X#douniu_room.memberlist),
%		io:format("~n~nRoleId=~p, X#douniu_room.memberlist=~p, B=~p~n~n", [RoleId, X#douniu_room.memberlist, B]),
%		B or Acc
%	end,
%	Res = lists:foldl(Fun, false, RoomList),
%	io:format("~n~nRes=~p~n~n", [Res]),
%	Res.

join_room(RoleInfo, Data, _State)->
	RoomId = Data,
	io:format("~nRoomId = ~p~n~n", [RoomId]),
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	io:format("~n~nlookup=~p~n~n", [LookUp]),
	case LookUp of
		false ->
			false;
		EtsRoom = #douniu_room{} ->
			NewEtsRoom = EtsRoom#douniu_room{memberlist = EtsRoom#douniu_room.memberlist++[RoleInfo#mhrole.roleid]},
			ets:update_element(?DOUNIU_ROOM, RoomId, NewEtsRoom),
			true
	end.

do_dissolve_room(RoleInfo)->
	RoomId = RoleInfo#mhrole.douniu_roomid,
	io:format("~nRoomId = ~p~n~n", [RoomId]),
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	io:format("~n~nlookup=~p~n~n", [LookUp]),
	case LookUp of
		false ->
			fail;
		EtsRoom = #douniu_room{owner_id = OwnerId} ->
			io:format("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			case OwnerId == RoleInfo#mhrole.roleid of
				true ->
					ets:delete(?DOUNIU_ROOM, RoomId),
					NewRole = RoleInfo#mhrole{douniu_roomid = 0},%TODO,update other role roomid info
					mod_role:set_mhrole(NewRole),
					ok;
				false ->
					fail
			end
	end.

do_quit_room(RoleInfo)->
	RoomId = RoleInfo#mhrole.douniu_roomid,
	io:format("~nRoomId = ~p~n~n", [RoomId]),
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	io:format("~n~nlookup=~p~n~n", [LookUp]),
	case LookUp of
		false ->
			fail;
		EtsRoom = #douniu_room{owner_id = OwnerId, memberlist = MemberList} ->
			io:format("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			case OwnerId /= RoleInfo#mhrole.roleid of
				true ->
					NewMemberList = lists:delete(RoleInfo#mhrole.roleid, MemberList),
					NewEtsRoom = EtsRoom#douniu_room{memberlist = NewMemberList},
					ets:update_element(?DOUNIU_ROOM, RoomId, NewEtsRoom),
					NewRole = RoleInfo#mhrole{douniu_roomid = 0},
					mod_role:set_mhrole(NewRole),
					ok;
				false ->
					fail
			end
	end.

do_ready_for_game(RoleInfo, State)->
	RoomId = RoleInfo#mhrole.douniu_roomid,
	io:format("~nRoomId = ~p~n~n", [RoomId]),
	LookUp = ets:lookup(?DOUNIU_ROOM, RoomId),
	io:format("~n~nlookup=~p~n~n", [LookUp]),
	case LookUp of
		false ->
			fail;
		EtsRoom = #douniu_room{ready_num = ReadyNum} ->
			io:format("~n~nEtsRoom=~p~n~n", [EtsRoom]),
			if ReadyNum < ?MAX_PLAYER - 1 ->
					NewReadyNum = ReadyNum + 1,
					NewEtsRoom = EtsRoom#douniu_room{ready_num = NewReadyNum},
					ets:update_element(?DOUNIU_ROOM, RoomId, NewEtsRoom),
					NewRole = RoleInfo#mhrole{status = ?STATUS_READY},
					mod_role:set_mhrole(NewRole),
					ok;
			   ReadyNum == ?MAX_PLAYER - 1 ->
				    NewReadyNum = ReadyNum + 1,
					NewEtsRoom = EtsRoom#douniu_room{ready_num = NewReadyNum},
					ets:update_element(?DOUNIU_ROOM, RoomId, NewEtsRoom),
					NewRole = RoleInfo#mhrole{status = ?STATUS_READY},
					mod_role:set_mhrole(NewRole),
					fapai(RoomId),
					ok;
				true ->
					fail
			end
	end.

%% 判断手上的牌是否有牛
is_niu(List) when length(List) == ?HAND_CARD_NUM ->
	List = [10, 2, 9, 8, 6],
	io:format("~n~nList=~p~n~n", [List]),
	
	S1 = lists:nth(1, List) + lists:nth(2, List) + lists:nth(3, List), 
	io:format("~nS1=~p~n", [S1]),
	S2 = lists:nth(1, List) + lists:nth(2, List) + lists:nth(4, List),
	io:format("~nS2=~p~n", [S2]),
	S3 = lists:nth(1, List) + lists:nth(2, List) + lists:nth(5, List),
	io:format("~nS3=~p~n", [S3]),

	S4 = lists:nth(1, List) + lists:nth(3, List) + lists:nth(4, List), 
	io:format("~nS4=~p~n", [S4]),
	S5 = lists:nth(1, List) + lists:nth(3, List) + lists:nth(5, List),
	io:format("~nS5=~p~n", [S5]),
	S6 = lists:nth(1, List) + lists:nth(4, List) + lists:nth(5, List),
	io:format("~nS6=~p~n", [S6]),

	S7 = lists:nth(2, List) + lists:nth(3, List) + lists:nth(4, List), 
	io:format("~nS7=~p~n", [S7]),
	S8 = lists:nth(2, List) + lists:nth(3, List) + lists:nth(5, List),
	io:format("~nS8=~p~n", [S8]),
	S9 = lists:nth(2, List) + lists:nth(4, List) + lists:nth(5, List),
	io:format("~nS9=~p~n", [S9]),
	S10 = lists:nth(3, List) + lists:nth(4, List) + lists:nth(5, List),
	io:format("~nS10=~p~n", [S10]),

	case (S1 rem 10 == 0) or (S2 rem 10 == 0) or (S3 rem 10 == 0) or (S4 rem 10 == 0) or (S5 rem 10 == 0) or 
			 (S6 rem 10 == 0) or (S7 rem 10 == 0) or (S8 rem 10 == 0) or (S9 rem 10 == 0) or (S10 rem 10 == 0) of
		true ->
			true;
		false ->
			false
	end;
is_niu(_) ->
	false.

%% 转化成点数
trans_to_num(N) ->
	if 
		(N >= 1) and (N =< 4) ->
			1;
		(N >= 5) and (N =< 8) ->
			2;
		(N >= 9) and (N =< 13) ->
			3;
		(N >= 14) and (N =< 17) ->
			4;
		(N >= 18) and (N =< 21) ->
			5;
		(N >= 22) and (N =< 25) ->
			6;
		(N >= 26) and (N =< 29) ->
			7;
		(N >= 30) and (N =< 33) ->
			8;
		(N >= 34) and (N =< 37) ->
			9;
		(N >= 38) and (N =< 41) ->
			10;
		(N >= 42) and (N =< 45) ->
			10;
		(N >= 46) and (N =< 49) ->
			10;
		(N >= 50) and (N =< 52) ->
			10
	end.


niu_res(List) when length(List) == ?HAND_CARD_NUM ->
%	List = [10, 1, 3, 4, 6],
	io:format("~n~nList=~p~n~n", [List]),
	
	S1 = lists:nth(1, List) + lists:nth(2, List) + lists:nth(3, List), 
	io:format("~nS1=~p~n", [S1]),
	S11 = lists:nth(4, List) + lists:nth(5, List), 
	io:format("~nS11=~p~n", [S11]),
	S2 = lists:nth(1, List) + lists:nth(2, List) + lists:nth(4, List),
	io:format("~nS2=~p~n", [S2]),
	S21 = lists:nth(3, List) + lists:nth(5, List),
	io:format("~nS21=~p~n", [S21]),
	S3 = lists:nth(1, List) + lists:nth(2, List) + lists:nth(5, List),
	io:format("~nS3=~p~n", [S3]),
	S31 = lists:nth(3, List) + lists:nth(4, List),
	io:format("~nS31=~p~n", [S31]),
	
	S4 = lists:nth(1, List) + lists:nth(3, List) + lists:nth(4, List), 
	io:format("~nS4=~p~n", [S4]),
	S41 = lists:nth(2, List) + lists:nth(5, List), 
	io:format("~nS41=~p~n", [S41]),
	S5 = lists:nth(1, List) + lists:nth(3, List) + lists:nth(5, List),
	io:format("~nS5=~p~n", [S5]),
	S51 = lists:nth(2, List) + lists:nth(4, List),
	io:format("~nS51=~p~n", [S51]),
	S6 = lists:nth(1, List) + lists:nth(4, List) + lists:nth(5, List),
	io:format("~nS6=~p~n", [S6]),
	S61 = lists:nth(2, List) + lists:nth(3, List),
	io:format("~nS61=~p~n", [S61]),

	S7 = lists:nth(2, List) + lists:nth(3, List) + lists:nth(4, List), 
	io:format("~nS7=~p~n", [S7]),
	S71 = lists:nth(1, List) + lists:nth(5, List), 
	io:format("~nS71=~p~n", [S71]),
	S8 = lists:nth(2, List) + lists:nth(3, List) + lists:nth(5, List),
	io:format("~nS8=~p~n", [S8]),
	S81 = lists:nth(1, List) + lists:nth(4, List),
	io:format("~nS81=~p~n", [S81]),
	S9 = lists:nth(2, List) + lists:nth(4, List) + lists:nth(5, List),
	io:format("~nS9=~p~n", [S9]),
	S91 = lists:nth(1, List) + lists:nth(3, List),
	io:format("~nS91=~p~n", [S91]),
	S10 = lists:nth(3, List) + lists:nth(4, List) + lists:nth(5, List),
	io:format("~nS10=~p~n", [S10]),
	S101 = lists:nth(1, List) + lists:nth(2, List),
	io:format("~nS101=~p~n", [S101]),

	case (S1 rem 10 == 0) or (S2 rem 10 == 0) or (S3 rem 10 == 0) or (S4 rem 10 == 0) or (S5 rem 10 == 0) or 
			 (S6 rem 10 == 0) or (S7 rem 10 == 0) or (S8 rem 10 == 0) or (S9 rem 10 == 0) or (S10 rem 10 == 0) of
		true ->
			L = [{S1, S11}, {S2, S21}, {S3, S31}, {S4, S41}, {S5, S51}, {S6, S61}, {S7, S71}, {S8, S81}, {S9, S91}, {S10, S101}],
			F = fun({X, XX} = A, Acc) ->
						if (X rem 10 == 0) and (Acc =< 0) ->
							   io:format("A=~p~n", [A]),
							   Rem = XX rem 10,
							   Rem + Acc;
						   true ->
							   io:format("not A=~p~n", [A]),
							   Acc
						end
				end,
			Res = lists:foldl(F, 0, L),
			io:format("Res = ~p~n", [Res]),
			{true, Res};
		false ->
			false
	end;
niu_res(_) ->
	false.


compare(L1, L2) ->
%	L1 = [1,2,6,10,5], 
%	L2 = [4,1,3,7,5],
	ResL1 = niu_res(L1),
	io:format("ResL1 = ~p~n", [ResL1]),
	ResL2 = niu_res(L2),
	io:format("ResL2 = ~p~n", [ResL2]),
	   
	case ResL1 of
		{true, N1} ->
			case ResL2 of
				{true, N2} ->
				   if N1 > N2 ->
						  big;
					  N1 == N2 ->
						  same;%TODO
					  true ->
						  small
				   end;
				false ->
					big
			end;
		false ->
			case ResL2 of
				{true, N2} ->
					small;
				false ->
					same%TODO
			end
	end.









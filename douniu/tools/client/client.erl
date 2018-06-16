%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2012-7-10
%%% -------------------------------------------------------------------
-module(client).
-behaviour(gen_server).
-compile(export_all).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("testdef.hrl").
-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").
-include("clientdef.hrl").

-define(TCP_TIMEOUT, 60*1000).      %% 解析协议超时时间

%% --------------------------------------------------------------------
%% External exports
%%-export([]).

%% gen_server callbacks
%%-export([start/1,init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%%-export([send/2,flash/1,info_scene/1,scene_test/1,start/1,init/1]).

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
init([Account, Ip, Port]) ->
	put(seq,0),
	random:seed(now()),
	{ok, Socket} = gen_tcp:connect(Ip, Port, [binary,{packet, 0},{active,false}]),

	Self_Pid = self(),

	ClientStatus = #clientstatus{pid=self(),socket=Socket},

%	case mh_env:get_env(scene_test) > 0 of
%		true ->
%			{ok,Scene_Pid} = gen_server:start(clientscene, [ClientStatus], []);
%		false ->
%			Scene_Pid = undefined
%	end,
	
%	case mh_env:get_env(battle_test) of
%		1 ->
%			{ok, BattlePid} = gen_server:start(clientbattle, [ClientStatus], []);
%		_ ->
%			BattlePid = undefined
%	end,
	%ClientStatu2 = ClientStatus#clientstatus{scene_pid=Scene_Pid},
%	ClientStatu2 = ClientStatus#clientstatus{scene_pid=Scene_Pid,
%											 battle_pid = BattlePid},
	clientlogin(Account, Socket),
	dtest2(ClientStatus),
	Rcv_Pid = spawn_link(fun() -> rcv_loop(Socket, Self_Pid) end),
	gen_tcp:controlling_process(Socket, Rcv_Pid),
	io:format("Client:~p login.client_pid:~p~n",[Account, ClientStatus#clientstatus.pid]),
%    {ok, ClientStatu2}.
    {ok, ClientStatus}.

start(Account, Ip, Port)->
	gen_server:start(?MODULE, [Account, Ip, Port], []).

send(Pid, BinData)->
	gen_server:cast(Pid,{send, BinData}).

testsend(Pid)->
	gen_server:cast(Pid, {testsend}).

info_scene(Pid)->
	gen_server:cast(Pid,{info_scene}).

scene_test(Pid)->
	gen_server:cast(Pid,{scene_run}).

flash(Pid)->
	gen_server:cast(Pid,{flash}).
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
handle_call(_Request, _From, ClientStatus) ->
    Reply = ok,
    {reply, Reply, ClientStatus}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({send, Bindata}, ClientStatus) ->
	ok = gen_tcp:send(ClientStatus#clientstatus.socket, pack_seq(Bindata)),
	% io:format("sent.~n"),
    {noreply, ClientStatus};

handle_cast({flash}, ClientStatus) ->
	Bin = list_to_binary("<policy-file-request/>\0"),
	ok = gen_tcp:send(ClientStatus#clientstatus.socket, Bin),
	io:format("flash sent.~n"),
    {noreply, ClientStatus};

handle_cast({rcv,{Cmd,Bin}}, ClientStatus)->
	ClientStatus2 = handle_rcvcmd(Cmd, Bin, ClientStatus),
	{noreply, ClientStatus2};

handle_cast({info_scene}, ClientStatus)->
	gen_server:cast(ClientStatus#clientstatus.scene_pid, {info}),
	{noreply, ClientStatus};

handle_cast({scene_run}, ClientStatus)->
	gen_server:cast(ClientStatus#clientstatus.scene_pid, {run}),
	{noreply, ClientStatus};

handle_cast({start_battle}, ClientStatus)->
	gen_server:cast(ClientStatus#clientstatus.battle_pid, {start}),
	{noreply, ClientStatus};

handle_cast({talk, TalkSec}, ClientStatus) ->
	mh_simple_timer:start_timer(?MODULE, TalkSec*1000, {self(), auto_talk, TalkSec}),
	{noreply, ClientStatus};

handle_cast({auto_talk, TalkSec}, ClientStatus) ->
	List = ["B2轰炸机曾炸中国大使馆部署韩国被指对中朝发信号",
"习近平访俄时获赠习仲勋当年访苏联照片册",
"彭丽媛赠坦蜀绣《梅花双熊》 创作于1999年(图)",
"彭丽媛参观德班音乐学校 与师生交流音乐教育",
"不动产登记条例明年出台 潘石屹：若今年实施房价立跌",
"北京计划3个月内拆除140万平米违建 包括别墅豪宅",
"最年轻中央候补委员刘剑任新疆哈密地委书记(图/简历)",
"梁振英：\“不爱国不爱港”怎么能当香港特首\",",
"普京凌晨4点回国飞机上下令军演 俄军向黑海集结",
"加拿大一60岁华裔男子迷奸21名妓女并拍摄视频",
"李嘉诚旗下码头爆发罢工潮 员工举牌还钱啊李老板",
"台北副市长批台湾楼市调控太温和：你看大陆多猛",
"人民日报连续五天质疑苹果：维修条款修改换汤不换药",
"江苏游客云南杀妻后到玉龙雪山跳崖自杀",
"河南农民拒每亩800元承包价被开发商铲车碾死(图)",
"武汉：女子地铁内进食 网友拍照遭热干面砸头(图)",
"凤凰视频《全民相对论》2周年 张曙光谈经济改革得失"],
	ChatMode = 1,
	ToName = "",
	ChatContent = lists:nth(mod_rand:int(length(List)), List),
	{ok,RoleDetailBin} = pt_11:write(?PP_CHAT_CLIENT_TO_SERVER, [ChatMode, ToName, ChatContent]),
	gen_tcp:send(ClientStatus#clientstatus.socket,pack_seq(RoleDetailBin)),
	mh_simple_timer:start_timer(?MODULE, TalkSec*1000, {self(), auto_talk, TalkSec}),
	{noreply, ClientStatus};


handle_cast({stop}, ClientStatus)->
	gen_server:cast(ClientStatus#clientstatus.scene_pid, {stop}),
	gen_server:cast(ClientStatus#clientstatus.battle_pid, {stop}),
	
	io:format("client stop..~n", []),
	{stop, 'STOP', ClientStatus};

handle_cast({testsend}, ClientStatus)->
	L = lists:duplicate(10000, "m"),
	B1 = list_to_binary(L),
	B2 = <<10004:16,55555:16,B1/binary>>,
	ok = gen_tcp:send(ClientStatus#clientstatus.socket, B2),
	{noreply, ClientStatus};

handle_cast({dtest}, ClientStatus)->
	io:format("~n~ndddddddddddddddddddddddtest~n~n", []),
	Bin = pt:pack(?PP_DOUNIU_FAPAI_REQ, <<>>),
	gen_tcp:send(ClientStatus#clientstatus.socket, pack_seq(Bin)),
	{noreply, ClientStatus};


handle_cast({dtest1}, ClientStatus)->
	io:format("~n~ndddddddddddddddddddddddtest1~n~n", []),
	StringBin = pt:write_string(integer_to_list(1)),
	TestStrBin = pt:write_string("teststring"),
%	Bin = pt:pack(?PP_DOUNIU_CREATE_ROOM_REQ, <<StringBin/binary, TestStrBin/binary>>),
	Bin = pt:pack(?PP_DOUNIU_JOIN_ROOM_REQ, <<StringBin/binary, TestStrBin/binary>>),
	gen_tcp:send(ClientStatus#clientstatus.socket, pack_seq(Bin)),
	{noreply, ClientStatus};


handle_cast({dtest2}, ClientStatus)->
	io:format("~n~ndddddddddddddddddddddddtest2~n~n", []),
	
	AccName = "",
	AccNameStrBin = pt:write_string(AccName),
	RoleName = "",
	RoleNameStrBin = pt:write_string(RoleName),
	Sex = 1,
	StringSexBin = pt:write_string(integer_to_list(Sex)),
	Career = 1,
	StringCareerBin = pt:write_string(integer_to_list(Career)),
	Time = 1,
	StringTimeBin = pt:write_string(integer_to_list(Time)),
	CheckCode = 1,
	StringChkCodeBin = pt:write_string(integer_to_list(CheckCode)),
	Bin = pt:pack(?PP_ACCOUNT_CREATE_ROLE, <<AccNameStrBin/binary, RoleNameStrBin/binary, 
											 StringSexBin/binary, StringCareerBin/binary,
											 StringTimeBin/binary, StringChkCodeBin/binary>>),
	gen_tcp:send(ClientStatus#clientstatus.socket, pack_seq(Bin)),
	{noreply, ClientStatus};


handle_cast(Msg, ClientStatus)->
	io:format("handle_cast Msg:~p",[Msg]),
	{noreply, ClientStatus}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
	io:format("Info:~p ~n",[Info]),
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

%%接收消息
%%rcv_loop(Socket, Pid) ->
%% 	receive
%% 		{tcp, Socket, Data} -> 
%% 			socket_data(Data, Pid),
%% 			rcv_loop(Socket,Pid);
%% 		{tcp_closed, Socket} ->
%% 			io:format("Rcv-Socket:~p closed ~n",[Socket]);
%% 		{_} -> io:format("none:~n")
%% 	end.
rcv_loop(Socket, Pid) ->
	{ok, <<Len:16,Cmd:16>>} = gen_tcp:recv(Socket, 4),%%先接收4字节头部
	{ok, Data} = gen_tcp:recv(Socket, Len-4),%%再接收数据部
%	io:format("rcv len:~p,cmd:~p,data:~p~n",[Len,Cmd,Data]),
	%socket_data(Cmd,Data,Pid),
	rcv_loop(Socket, Pid).
	
clientlogin(Account, Socket)->
	{ok,LoginBin} = pt_10:write(?PP_ACCOUNT_LOGIN, Account),
	gen_tcp:send(Socket, pack_seq(LoginBin)),
	{ok,RoleDetailBin} = pt_10:write(?PP_ACCOUNT_GET_ROLE_DETAIL, []),
	gen_tcp:send(Socket,pack_seq(RoleDetailBin)).
%	{ok, GetViewBin}= pt_12:write(?PP_SCENE_GET_VIEW, []),
%	gen_tcp:send(Socket,pack_seq(GetViewBin)),
	%%enter goldisland
%	case mh_env:get_env(goldisland) > 0 of
%		true ->
%			{ok, EnterGoldislandBin} = pt_12:write(?PP_SCENE_ENTER_GOLD_ISLAND, 0),
%			gen_tcp:send(Socket,pack_seq(EnterGoldislandBin));
%		false ->
%			ok
%	end.
	

socket_data(Cmd, Bin, Pid )->
	% io:format("~nsocket_data: Cmd: ~p. Bin:~w~n",[Cmd,Bin]),
	gen_server:cast(Pid, {rcv, {Cmd, Bin}}).

handle_rcvcmd(Cmd, Binary, RoleInfo)->
	[H1,H2,_,_,_] = integer_to_list(Cmd),
	ModId = [H1,H2],
	try
		Module = list_to_atom("pt_" ++ ModId),
		case Module:read(Cmd, Binary) of 
			{cli, Data}->
				cmd_dispatch(ModId, Cmd, Data, RoleInfo);
			{_,_} ->
				RoleInfo
		end
	catch _:_ -> RoleInfo 
	end.
	

cmd_dispatch(ModId, Cmd, Data, ClientInfo)->
	{ok, ClientInfo2} = case ModId of
		"10"-> clientscene:handle(Cmd, Data, ClientInfo);
		"16"-> clientbattle:handle(Cmd, Data, ClientInfo);
		_ -> {ok,ClientInfo}
	end,
	ClientInfo2.
	
%% 接受信息
async_recv(Sock, Length, Timeout) when is_port(Sock) ->
    case prim_inet:async_recv(Sock, Length, Timeout) of
        {error, Reason} -> Reason;
        {ok, Res}       -> Res;
        Res             -> Res
    end.	
	
	
handle_timeout({Pid, auto_talk, TalkSec}) ->
	gen_server:cast(Pid, {auto_talk, TalkSec}),
	ok.

pack_seq(Bin)->%%在发往服务端的数据包插入32位0序列号
	<<Len:16,Data/binary>> = Bin,
	Seq = get(seq),
	put(seq,Seq+1),
	Mask = Seq rem 256,
	MaskBin = mask_binary(Mask,<<Seq:32,Data/binary>>),
	NewBin = <<(Len+4):16,MaskBin/binary>>,
	NewBin.

%%对二进制数据作掩码/异或操作
mask_binary(Mask, Binary) ->
    _RtBin = mask_binary(Mask, Binary, <<>>).
mask_binary(_Mask, <<>>, RtBin) ->
    RtBin;
mask_binary(Mask, <<Byte:8, RestBin/binary>>, RtBin) ->
    NRtBin = <<RtBin/binary, (Mask bxor Byte):8>>,
    mask_binary(Mask, RestBin, NRtBin).

%%==========================douniu test============================

dtest(Pid)->
%	{ok,LoginBin} = pt_50:write(?PP_ACCOUNT_LOGIN, Account),
%	gen_tcp:send(Socket, pack_seq(LoginBin)).
	gen_server:cast(Pid, {dtest}).


dtest1(Pid)->
	gen_server:cast(Pid, {dtest1}).

dtest2(C)->
	?INFO("~n~ndddddddddddddddddddddddtest2~n~n", []),
	
	String = integer_to_list(10),
	Bin = pt:pack(?PP_DOUNIU_YAZHU_REQ, pt:write_string(String)),
%	Bin = pt:pack(?PP_DOUNIU_YAZHU_REQ, pt:write_string([])),
%	Bin = pt:pack(?PP_DOUNIU_YAZHU_REQ, pt:write_string([])),
	?INFO("~n~ndddddddddddddddddddddddBin=~p~n~n", [Bin]),
	gen_tcp:send(C#clientstatus.socket, pack_seq(Bin)).

autosend()->
	{ok, Pid} = clientmgr:start(2),
	gen_server:cast(Pid, {start_client, 2}).




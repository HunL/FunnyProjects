%% @author j
%% @doc @todo Add description to pp_douniu.


-module(pp_douniu).

-include("record.hrl").
-include("common.hrl").
-include("proto.hrl").
-include("log.hrl").


%% ====================================================================
%% API functions
%% ====================================================================
-export([handle/3]).



%% ====================================================================
%% Internal functions
%% ====================================================================

handle(?PP_DOUNIU_CREATE_ROOM_REQ, RoleInfo, Data) ->
	?INFO("~n~ndouniu create room, Data=~p~n~n", [Data]),
	Res = mod_douniu:create_room(RoleInfo, Data),
	?INFO("~n~ndouniu create room, Res=~p~n~n", [Res]),
	case Res of
		{ok, RoomId} ->
			?INFO("~n~ndouniu create room, RoomId=~p~n~n", [RoomId]),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_CREATE_ROOM_ACK,	[0, RoomId]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		Err ->
			?INFO("~n~ndouniu create room, Err=~p~n~n", [Err]),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_CREATE_ROOM_ACK,	[1]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end,
	ok;

%zhanjilist = [{rivalid, res}...]
handle(?PP_DOUNIU_ZHANJI_REQ, RoleInfo, Data) ->
	?INFO("~n~ndouniu zhanji, Data=~p~n~n", [Data]),
	Res = mod_douniu:zhanji(RoleInfo, Data),
	case Res of
		{ok, ZhanjiList} ->
			?INFO("~n~ndouniu Zhanji, ZhanjiList=~p~n~n", [ZhanjiList]),
			ZhanjiResStr = ZhanjiList,%TODO,to trans
			{ok, Bin} = pt_50:write(?PP_DOUNIU_ZHANJI_ACK,	ZhanjiResStr),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		Err ->
			?INFO("~n~ndouniu create room, Err=~p~n~n", [Err]),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_CREATE_ROOM_ACK,	[]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end,
	ok;

handle(?PP_DOUNIU_JOIN_ROOM_REQ, RoleInfo, RoomId) ->
	?INFO("~n~ndouniu join room, Data=~p~n~n", [RoomId]),
	Res = mod_douniu:join_room(RoleInfo, RoomId),
	?INFO("~n~ndouniu join room, Res=~p~n~n", [Res]),
	case Res of
		ok ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_JOIN_ROOM_ACK,	[0, RoomId]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		fail ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_JOIN_ROOM_ACK,	[1, RoomId]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end,
		
	ok;


handle(?PP_DOUNIU_QUIT_ROOM_REQ, RoleInfo, Data) ->
	RoomId = RoleInfo#mhrole.douniu_roomid,
	?INFO("~n~ndouniu quit room, RoomId=~p~n~n", [RoomId]),
	?INFO("~n~ndouniu quit room, Data=~p~n~n", [Data]),
	Res = mod_douniu:quit_room(RoleInfo, Data),
	case Res of
		{ok, dis} ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_QUIT_ROOM_ACK, [0, RoomId]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		{ok, quit} ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_QUIT_ROOM_ACK, [0, RoomId]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		fail ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_QUIT_ROOM_ACK, [1, RoomId]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end,
	ok;

handle(?PP_DOUNIU_READY_REQ, RoleInfo, Data) ->
%	?INFO("~n~ndouniu ready for game, Data=~p~n~n", [Data]),
	?INFO("~n~ndouniu ready for game, Data=~p~n~n", [Data]),
	RoomId = RoleInfo#mhrole.douniu_roomid,
%	?INFO("~n~ndouniu ready_for_game, RoomId=~p~n~n", [RoomId]),
	?INFO("~n~ndouniu ready_for_game, RoomId=~p~n~n", [RoomId]),
	Readyres = mod_douniu:ready_for_game(RoleInfo, Data),
	?INFO("~n~nReadyres =~p~n~n", [Readyres]),
	case Readyres of
		ok ->
			?INFO("~n~nready ok~n~n", []),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_READY_ACK, [0]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		fail ->
			?INFO("~n~nready fail~n~n", []),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_READY_ACK, [1]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end;

handle(?PP_DOUNIU_QIANGZHUANG_REQ, RoleInfo, Data) ->
	?INFO("~n~ndouniu qiang zhuang, Data=~p~n~n", [Data]),
	Res = mod_douniu:qiang_zhuang(RoleInfo, Data),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of
		{ok, Other} ->
			?INFO("~n~nok, ~p~n~n", [Other]),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_QIANGZHUANG_ACK, [0]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		fail ->
			?INFO("~n~nfail~n~n", []),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_QIANGZHUANG_ACK, [1]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end,
	ok;

handle(?PP_DOUNIU_YAZHU_REQ, RoleInfo, Data) ->
	[BeiShu] = Data,
	?INFO("~n~ndouniu yazhu, Data=~p, BeiShu=~p~n~n", [Data, BeiShu]),
	YazhuRes = mod_douniu:yazhu(RoleInfo, BeiShu),
	?INFO("~n~ndouniu yazhu, YazhuRes=~p~n~n", [YazhuRes]),
	case YazhuRes of
		ok ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_YAZHU_ACK, [0]), 
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		fail ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_YAZHU_ACK, [1]), 
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end;

handle(?PP_DOUNIU_CHONGZHI_REQ, RoleInfo, Data) ->
	?INFO("~n~ndouniu chongzhi, Data=~p~n~n", [Data]),
	[Num] = Data,
	ChongzhiRes = mod_douniu:chongzhi(RoleInfo, Num),
	case ChongzhiRes of
		{ok, CurNum} ->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_CHONGZHI_ACK, [0, CurNum]), 
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin);
		{Err, GoldNum} ->
			?INFO("~n~ndouniu chongzhi, Err=~p, GoldNum=~p~n~n", [Err, GoldNum]),
			{ok, Bin} = pt_50:write(?PP_DOUNIU_CHONGZHI_ACK, [1, GoldNum]), 
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end,
	ok;

handle(?PP_DOUNIU_FAPAI_REQ, RoleInfo, Data) ->
	?INFO("~n~ndouniu fapai, Data=~p~n~n", [Data]),
	mod_douniu:fapai(RoleInfo, Data),
	ok;

handle(?PP_DOUNIU_TANPAI_REQ, RoleInfo, Data) ->
	RoomId = RoleInfo#mhrole.douniu_roomid,
	?INFO("~n~ndouniu tanpai, RoomId=~p~n~n", [RoomId]),
	?INFO("~n~ndouniu tanpai, Data=~p~n~n", [Data]),
	TanpaiRes = mod_douniu:tanpai(RoleInfo, Data),
	?INFO("~n~ndouniu tanpai, TanpaiRes=~p~n~n", [TanpaiRes]),
	case TanpaiRes of
		{ok, CompareRes} ->
			[
			 begin
				 {ok, Bin} = pt_50:write(?PP_DOUNIU_TANPAI_ACK, [0, R]),%TODO:check 
				 lib_send:send_to_roleid(Id, Bin) 
			 end || {Id,R} <- CompareRes
			];
		false->
			{ok, Bin} = pt_50:write(?PP_DOUNIU_TANPAI_ACK, [1]),
			lib_send:send_to_roleid(RoleInfo#mhrole.roleid, Bin)
	end,
	ok.





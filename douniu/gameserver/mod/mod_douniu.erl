%% @author j
%% @doc @todo Add description to mod_douniu.


-module(mod_douniu).
-include("record.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([create_room/2, join_room/2, quit_room/2, ready_for_game/2, 
		 yazhu/2, tanpai/2, zhanji/2, chongzhi/2, qiang_zhuang/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================
create_room(RoleInfo, _Data)->
	Res = mod_role:is_in_room(RoleInfo),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of 
		true ->
			fail;
		false ->
			%TODO:is luoji ok?
			Gold = RoleInfo#mhrole.gold,
			?INFO("Gold=~p~n~n", [Gold]),
			case Gold >= 1 of
				true ->
					case mod_douniu_mgr:create_room(RoleInfo) of
						{ok, RoomId} ->
							NewRoleInfo = RoleInfo#mhrole{gold = RoleInfo#mhrole.gold - 1},
							mod_role:set_mhrole(NewRoleInfo),
							{ok, RoomId};
						ERR ->
							?INFO("ERR=~p~n~n", [ERR]),
							fail
					end;
				false ->
					fail
			end
	end.

%TODO:new database table
zhanji(RoleInfo, Data)->
	?INFO("~n~nData=~p~n~n", [Data]),
	Res = mod_douniu_mgr:zhanji(RoleInfo#mhrole.roleid),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of
		{true, ZhanjiList} ->
			{ok, ZhanjiList};
		false ->
			fail
	end.

chongzhi(RoleInfo, Data) ->
	ChongzhiNum = Data,
	?INFO("~n~nChongzhiNum=~p~n~n", [ChongzhiNum]),
	CurNum = RoleInfo#mhrole.gold + ChongzhiNum,
	CurGoldSum = RoleInfo#mhrole.goldsum + ChongzhiNum,
	?INFO("~n~nCurNum=~p~n~n", [CurNum]),
	?INFO("~n~nCurGoldsum=~p~n~n", [CurGoldSum]),
	NewRoleInfo = RoleInfo#mhrole{gold = CurNum, goldsum = CurGoldSum},
	mod_role:set_mhrole(NewRoleInfo),
	WriteDb = lib_role:update_gold_to_db(NewRoleInfo#mhrole.roleid, CurNum, CurGoldSum),
	case WriteDb of
		ok ->
			{ok, CurNum};
		Err ->
			?INFO("err=~p~n~n", [Err]),
			{false, RoleInfo#mhrole.gold}
	end.
	

join_room(RoleInfo, Data)->
	RoomId = Data,
	?INFO("~n~nRoomId=~p~n~n", [RoomId]),
	Res = mod_role:is_in_room(RoleInfo),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of 
		true ->
			fail;
		false ->
			case mod_douniu_mgr:room_num(RoomId) of
				{true, Num} ->
					if Num < ?MAX_PLAYER ->
						   case mod_douniu_mgr:join_room(RoleInfo, Data) of
							   true ->
								   ok;
							   false ->
								   fail
						   end;
					   true ->
						   fail
  					end;
				false ->
					fail
			end
	end.

quit_room(RoleInfo, _Data)->
	Res = mod_role:is_in_room(RoleInfo),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of 
		true ->
			ResZh = mod_douniu_mgr:is_zhuang(RoleInfo#mhrole.roleid, RoleInfo#mhrole.douniu_roomid),
			?INFO("~n~nResZh=~p~n~n", [ResZh]),
			case ResZh of 
				true ->
					ResDis = mod_douniu_mgr:dissolve_room(RoleInfo),
					?INFO("~n~nResDis=~p~n~n", [ResDis]),
					case ResDis of
						ok ->
							{ok, dis};
						fail ->
							fail
					end;
				false ->
					ResQuit = mod_douniu_mgr:quit_room(RoleInfo),
					?INFO("~n~nResQuit=~p~n~n", [ResQuit]),
					case ResQuit of
						ok ->
							{ok, quit};
						fail ->
							fail
					end
			end;
		false ->
			fail
	end.

ready_for_game(RoleInfo, _Data)->
	Res = mod_role:is_in_room(RoleInfo),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of 
		true ->
			mod_douniu_mgr:ready_for_game(RoleInfo);
		false ->
			fail
	end.

qiang_zhuang(RoleInfo, _Data) ->
%	Res = mod_douniu_mgr:is_in_room(RoleInfo#mhrole.roleid),
	Res = mod_role:is_in_room(RoleInfo),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of 
		true ->
			mod_douniu_mgr:qiang_zhuang(RoleInfo#mhrole.douniu_roomid);
		false ->
			fail
	end.

yazhu(RoleInfo, BeiShu)->
	Res = mod_douniu_mgr:is_zhuang(RoleInfo#mhrole.roleid, RoleInfo#mhrole.douniu_roomid),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of 
		true ->
			fail;
		false ->
			mod_douniu_mgr:ya_zhu(RoleInfo, BeiShu)
	end.

tanpai(RoleInfo, _Data)->
	RoomId = RoleInfo#mhrole.douniu_roomid,
	?INFO("~nRoomId = ~p~n~n", [RoomId]),
	Res = mod_role:is_in_room(RoleInfo),
	?INFO("~n~nRes=~p~n~n", [Res]),
	case Res of 
		true ->
			case mod_douniu_mgr:tanpai_num(RoomId) of
				{true, Num} ->
					if Num < ?MAX_PLAYER ->
						   case mod_douniu_mgr:tanpai(RoomId) of
							   {ok, ResCompare} ->
								   {ok, ResCompare};
							   false ->
								   fail
						   end;
					   true ->
						   fail
  					end;
				false ->
					fail
			end;
		false ->
			fail
	end.


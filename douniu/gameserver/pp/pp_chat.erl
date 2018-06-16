%% Author: L-jiehui
%% Created: 2012-7-16
-module(pp_chat).

%%
%% Include files
%%
-include("record.hrl").
-include("common.hrl").
-include("proto.hrl").
-include("log.hrl").
-include("counter.hrl").

-define(CONTENT_LEN, 1500).

-define(WORLD_CHAT_GAP, 8).%%世界聊天发包间隔
-define(GUILD_CHAT_GAP, 2).%%帮派聊天发包间隔
-define(NEIGH_CHAT_GAP, 1).%%附近聊天发包间隔
-define(TEAM_CHAT_GAP,  1).%%队伍聊天发包间隔

-define(WORLD_CHAT_LEVEL, 15).%世界聊天等级
%%
%% Exported Functions
%%
-export([handle/3,
         handle/4,
		 filter_gm_cmd/2,
		 send_to_neighbors_by_pos/3,
         send_to_neighbors_by_pos/4,
		 npc_world_chat/2,
		 send_msg_to_sys/1, 	%发送消息到系统频道
         send_msg_win/1, 		%发送系统弹窗提示
		 send_msg_win_by_roleid/2,
		 send_info_to_guild/2,  %%帮派系统通知
		 send_chat_info/1,
		 send_chat_info/2,
		 send_chat_society/2
%		 send_chat_team/2          %% 队伍通知
    	]).

%%
%% API Functions
%%
%% 聊天类型（1：世界；2：私人；3：喇叭；4：队伍；5：附近；6：帮会；7：系统）
handle(?PP_CHAT_CLIENT_TO_SERVER, RoleInfo, Data, System) ->
	[ChatMode, ToName, ChatContent] = Data,
	case filter_gm_cmd(RoleInfo, ChatContent) or RoleInfo#mhrole.shutup of
		true ->
			ok;
		false ->
			FromId = RoleInfo#mhrole.roleid,
			FromName = RoleInfo#mhrole.rolename,
			Sex = RoleInfo#mhrole.sex,
			Lvl = RoleInfo#mhrole.level,
			Career = RoleInfo#mhrole.career,
			VipLvl = RoleInfo#mhrole.vip,
			RoleType = RoleInfo#mhrole.role_type,
			?INFO("length of ChatContent=~p",[length(ChatContent)]),
			SplitChatContent = case length(ChatContent) > ?CONTENT_LEN of
				true ->
					{L1, _L2} = lists:split(?CONTENT_LEN, ChatContent),
					L1;
				false ->
					ChatContent
			end,
			%% 屏蔽字过滤
			FilteredContent = 
				lib_word_filter:filter_prohibited_words(SplitChatContent),
			?INFO("FilteredContent=~p",[FilteredContent]),
									
			{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT, [ChatMode, FromId, 
							FromName, Sex, Lvl, Career, VipLvl, RoleType, ToName, FilteredContent]),
			case ChatMode of
				?CHAT_WORLD ->
					world_chat(RoleInfo, Bin, ChatContent, System);
				?CHAT_PRIVATE ->
					send_private_msg(FromId, FromName, Sex, Lvl, Career, ToName, FilteredContent);
%				?CHAT_HORN ->%% 喇叭聊天
%					mod_vip:add_guide_oper_times(?VIP_GUILDE_STONE),
%					horn_chat(RoleInfo, Bin);
%				?CHAT_TEAM ->%% 队伍聊天
%					team_chat(RoleInfo, Bin);
				?CHAT_NEIGHBOR ->%% 附近聊天
					neighbor_chat(RoleInfo, Bin);
				?CHAT_SOCIETY ->%% 帮会聊天
					guild_chat(RoleInfo, Bin);
%% 				?CHAT_SYSTEM ->%% 系统聊天
%% 					lib_send:send_to_all(Bin);
				?CHAT_ARENA ->%% 擂台聊天
					mod_arena_mgr:send_chat_to_room(RoleInfo#mhrole.roleid, Bin);
				_ -> ok
			end
			
%			GameName= mh_env:get_env(game),
%			ServerNo= mh_env:get_env(serverid),
%			LogItem = #plat_log{plat_game    = GameName,			
%								plat_servno  = ServerNo,			
%								plat_account = RoleInfo#mhrole.account,		
%								plat_rolename= unicode:characters_to_list(list_to_binary(RoleInfo#mhrole.rolename)),	
%								plat_address = RoleInfo#mhrole.login_ip, 		
%								plat_content = unicode:characters_to_list(list_to_binary(FilteredContent))},
%			mod_chatlog_mgr:handle_write_log(LogItem)
		
	end,
	ok.

handle(?PP_CHAT_CLIENT_TO_SERVER, RoleInfo, Data) ->
	case RoleInfo#mhrole.role_type of
		?ROLE_TYPE_GUIDER ->
    		handle(?PP_CHAT_CLIENT_TO_SERVER, RoleInfo, Data, true);
		_ ->
			handle(?PP_CHAT_CLIENT_TO_SERVER, RoleInfo, Data, false)
	end;

handle(?PP_CHAT_CLIENT_TO_SERVER_PRIVATE, RoleInfo, _Data) ->
	mod_role:check_and_send_offline_msg(RoleInfo#mhrole.roleid),
	ok.

%%过滤GM命令
%%return: true 是GM命令
%%return: false 是不是GM命令
filter_gm_cmd(RoleInfo,Data)->
	case get(gm_chat) of
		true->
			StringList = string:tokens(Data, " "),
			Res = case length(StringList) >= 2 of
				true ->[Cmd|Param] = StringList,
					mod_gm:handle_cmd(RoleInfo, {Cmd,Param});
				false-> false
			  	end,
			Res;
		_ -> false
	end.

world_chat(RoleInfo, Bin, ChatContent, System)->
	case RoleInfo#mhrole.level >= ?WORLD_CHAT_LEVEL of
		true ->
			String = cfg_string:get_string(worldspeak),
			case ChatContent == String of
				true ->
					mod_period:do_period_task_action_worldspeak(RoleInfo#mhrole.pid, 
						{worldspeak, {0}});
				false ->
					ok
			end,
			%%时间间隔后发包
		    case System of
		        true ->
		            lib_send:send_to_all(Bin);
		        false ->
		            case check_chat_time(RoleInfo, ?CHAT_WORLD) of
		                true ->
		                    lib_send:send_to_all(Bin),
		                    set_chat_time(RoleInfo, ?CHAT_WORLD);
		                false ->
		                    ok
		            end
			end;
		false ->
			ok
	end.



%% 检查聊天间隔时间
check_chat_time(RoleInfo, Type) ->
    case get_chat_time(RoleInfo, Type) of
        {true, Secs}->
            LocalTime = calendar:local_time(),
            NowSecs = calendar:datetime_to_gregorian_seconds(LocalTime),

            CDTime =
                case Type of
                    ?CHAT_WORLD 	->	?WORLD_CHAT_GAP;
					?CHAT_SOCIETY	->	?GUILD_CHAT_GAP;
					?CHAT_TEAM		->	?TEAM_CHAT_GAP;
					?CHAT_NEIGHBOR	->	?NEIGH_CHAT_GAP;
                    _ -> 0
                end,

            (NowSecs - Secs >= CDTime);
        {false} -> true
    end.

send_private_msg(FromRoleId, FromName, Sex, Lvl, Career, ToName, SplitFilteredContent) ->
	{MegaSecs, Secs, _MicroSecs} = erlang:now(),%%since year 1970
    NowSec = MegaSecs*1000*1000 + Secs,
	%% 修改后的发送消息协议
	{ok, PrivateBin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT_PRIVATE, 
					       [FromRoleId, FromName, Sex, Lvl, Career, NowSec, SplitFilteredContent]),
	case mod_account:get_send_pid_by_name(ToName) of
		{true, _} ->%% 该玩家在线
			lib_send:send_to_name(ToName, PrivateBin);
		{false} ->%% 该玩家不在线，保存离线消息
			ToRoleId = mod_loginserver:get_roleid_by_rolename(ToName),
			mod_msg_mgr:update_q(ToRoleId, PrivateBin)
	end.

%horn_chat(RoleInfo, Bin) when RoleInfo#mhrole.role_type =:= ?ROLE_TYPE_GUIDER ->
%	lib_send:send_to_all(Bin);
%horn_chat(RoleInfo, Bin)->
%	case RoleInfo#mhrole.vip of
%		0 ->
%			horn_chat2(RoleInfo, Bin);
%		1 ->
%			case ?DAILY_COUNTER(RoleInfo#mhrole.roleid, ?VIP_HORN) of
%				undefined ->
%					VipHorn = 5;
%				X ->
%					VipHorn = X
%			end,
%			case VipHorn > 0 of
%				true ->
%					?DAILY_COUNTER(RoleInfo#mhrole.roleid, ?VIP_HORN, VipHorn - 1),
%					lib_send:send_to_all(Bin),
%					mod_vip:pp_vip_info();
%				false ->
%					horn_chat2(RoleInfo, Bin)
%			end
%	end.

%horn_chat2(RoleInfo, Bin) ->
%	%% 检查背包里喇叭道具数量是否足够
%	IsEnough = mod_item:check_item(RoleInfo#mhrole.pid, 
%								   {?ITEM_MODULE_HORN, ?ITEM_MODULE_HORN, 1}),
%	case IsEnough of
%		{true, true, _Num} ->%% 数量足够，在进行一次喇叭聊天时扣除一个喇叭道具
%			mod_item:del_item(RoleInfo#mhrole.pid, {?ITEM_MODULE_HORN,
%													?ITEM_MODULE_HORN,
%													1,
%													?LOG_ITEM_DEC_HORN_CHAT}),
%			lib_send:send_to_all(Bin);
%		_ ->
%			ok
%	end.

neighbor_chat(RoleInfo, Bin)->
	case check_chat_time(RoleInfo, ?CHAT_NEIGHBOR) of
        true ->
			mod_scene_mgr:send_to_neighbors(RoleInfo#mhrole.roleid, Bin),
            set_chat_time(RoleInfo, ?CHAT_NEIGHBOR);
        false ->
            ok
	end.

guild_chat(RoleInfo, Bin)->
	case check_chat_time(RoleInfo, ?CHAT_SOCIETY) of
        true ->
			mod_guild:send_to_guilds(RoleInfo#mhrole.roleid, Bin),
			set_chat_time(RoleInfo, ?CHAT_SOCIETY);
        false ->
            ok
	end.

get_chat_time(RoleInfo, ChatType)->
	ChatTimeList = RoleInfo#mhrole.chat_time,
	KeyFind = lists:keyfind(ChatType, 1, ChatTimeList),
	case KeyFind of
		false -> {false};
		{ChatType, Secs} ->	{true, Secs}
	end.
			
set_chat_time(RoleInfo, ChatType)->
	Secs = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	ChatTimeList = RoleInfo#mhrole.chat_time,
	NewChatTimeList = case ChatTimeList of
		[]->
			lists:append([], [{ChatType, Secs}]);
		_ ->
		 	lists:keyreplace(ChatType, 1, ChatTimeList,	{ChatType, Secs})
	end,
	NewRoleInfo = RoleInfo#mhrole{chat_time = NewChatTimeList},
	mod_role:set_mhrole(NewRoleInfo).
	
%%Pos->{X,Y}
%%Content->[]，消息内容
send_to_neighbors_by_pos(MapId, Pos, Content) ->
    send_to_neighbors_by_pos(MapId, Pos, 0, Content).
send_to_neighbors_by_pos(MapId, Pos, RoleInfo, Content) ->
    case is_record(RoleInfo, mhrole) of
        true ->
            FromId = RoleInfo#mhrole.roleid,
            FromName = RoleInfo#mhrole.rolename,
            Sex = RoleInfo#mhrole.sex,
            Lvl = RoleInfo#mhrole.level,
            Career = RoleInfo#mhrole.career,
            VipLvl = RoleInfo#mhrole.vip,
            RoleType = RoleInfo#mhrole.role_type;
        false ->
            FromId = 0,
            FromName = [],
            Sex = 0,
            Lvl = 0,
            Career = 0,
            VipLvl = 0,
            RoleType = 0
    end,
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT, 
							[?CHAT_NEIGHBOR, FromId, FromName, Sex, Lvl, Career, VipLvl, RoleType, [], Content]),
	mod_scene_mgr:send_to_neighbors_by_pos(MapId, Pos, Bin).

npc_world_chat(NpcName, ChatContent) ->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT, 
							[?CHAT_WORLD, 0, NpcName, 0, 0, 0, 0, 0, [], ChatContent]),
	lib_send:send_to_all(Bin).

%%发送消息到系统频道
send_msg_to_sys(Content)->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT, 
							[?CHAT_SYSTEM, 0, [], 0, 0, 0, 0, 0, [], Content]),
	lib_send:send_to_all(Bin).


%%发送系统弹窗提示
send_msg_win(Content)->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_WIN_NOTICE,[Content]),
	lib_send:send_to_all(Bin).

%%根据角色ID发送弹窗提示
send_msg_win_by_roleid(Content, RoleId)->
	case mod_account:get_send_pid_by_roleid(RoleId) of
		{false}->
			ok;
		{true, Pid}->
			{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_WIN_NOTICE,[Content]),
			lib_send:send_slow_to_send_pid(Pid, Bin)
	end.

%%帮会系统信息通知
send_info_to_guild(GuildId, Sms)->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT, 
							[?CHAT_GUILDBATTLE, 0, "", 0, 0, 0, 0, 0, "", Sms]),
	mod_guild:send_info_to_guilds(GuildId, Bin).
	
send_chat_info(Content)->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT,
							[?CHAT_INFO, 0, "", 0, 0, 0, 0, 0, "", Content]),
	lib_send:send_to_all(Bin).

send_chat_info(SendPid, Content)->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT,
							[?CHAT_INFO, 0, "", 0, 0, 0, 0, 0, "", Content]),
	lib_send:send_to_send_pid(SendPid, Bin).

send_chat_society(RoleId, String)->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT, 
							[?CHAT_SOCIETY, 0, "", 0, 0, 0, 0, 0, "", String]),
	lib_send:send_to_roleid(RoleId, Bin).

%send_chat_team(RoleInfo, String) ->
%	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_TO_CLIENT, 
%							[?CHAT_TEAM, 0, "", 0, 0, 0, 0, 0, "", String]),
%	team_chat(RoleInfo, Bin).




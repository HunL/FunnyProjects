%% Author: L-jiehui
%% Created: 2012-7-17
%% Description:聊天协议处理
-module(pt_11).

%%
%% Include files
%%
-include("proto.hrl").
%%
%% Exported Functions
%%
-export([read/2, write/2]).

%% ------chat 1------
%% Client -> Server
%% 11000   客户端发往服务端的消息包（c >> s）
%% int32   聊天类型（1：世界，2：私聊，3：喇叭）
%% string  To玩家昵称
%% string  消息
read(?PP_CHAT_CLIENT_TO_SERVER, BinContent) ->
	<<ChatMode:32, Rest1/binary>> = BinContent,
	{ToName, Rest2}        = pt:read_string(Rest1),
	{ChatContent, _}       = pt:read_string(Rest2),
    {ok, [ChatMode, ToName, ChatContent]};
%% ------End chat 1------

%%------chat config 1-------
%% Client -> Server:unpack chat channel config package
%% 11002 服务端保存客户端更新的聊天频道配置（c >> s）
%% int32 世界频道（1：选中该频道；0：不选该频道）
%% int32 帮派频道
%% int32 队伍频道
%% int32 附近频道
read(?PP_CHAT_SAVE_CHAT_CHANNELS, BinContent) ->
	<<WorldChannel:32, GuildChannel:32, TeamChannel:32, NearbyChannel:32>> = BinContent,
	{ok, [WorldChannel, GuildChannel, TeamChannel, NearbyChannel]};

%% Client -> Server:unpack chat channel config package
%% 11004 客户端向服务端获取聊天频道配置（c >> s）
%% （无参数）
read(?PP_CHAT_GET_CHAT_CHANNELS, _BinContent) ->
	{ok, []};

read(?PP_CHAT_CLIENT_TO_SERVER_PRIVATE, _) ->
	{ok, []}.
%%------End chat config 1-------

%%------chat 2--------
%% Server -> Client
%% 11001  服务端发往客户端的消息包（s >> c）
%% int32  聊天类型（1：世界，2：私聊，3：喇叭）
%% string From玩家昵称
%% string To玩家昵称
%% string 消息
write(?PP_CHAT_SERVER_TO_CLIENT, [ChatMode, FromId, FromName, Sex, Lvl, Career, 
								  VipLvl, RoleType, ToName, ChatContent]) ->
%%	BinChatMode = pt:write_string(ChatMode),
	BinName     = pt:write_string(FromName),
	BinToName   = pt:write_string(ToName),
	BinContent  = pt:write_string(ChatContent),
	Data = <<ChatMode:32,
			 FromId:64, 
			 BinName/binary,
			 Sex:32,
			 Lvl:32,
			 Career:32,
			 VipLvl:32,
			 RoleType:32,
			 BinToName/binary,
			 BinContent/binary>>,
    {ok, pt:pack(?PP_CHAT_SERVER_TO_CLIENT, Data)};
 %%------End chat 2-------

%%------chat config 2-------
%% Server -> Client:return save result
%% 11003 向客户端返回保存在服务端的聊天频道配置的结果（s >> c）
%% int32 是否保存成功（1：成功；0：失败）
write(?PP_CHAT_SAVE_CHAT_CHANNELS_RESULT, [_WorldChannel, _GuildChannel, _TeamChannel, _NearbyChannel]) ->
	%% 先不进行各种异常判断，统一发送保存成功的标志：1。
	Flag = 1,
	Data = <<Flag:32>>,	
	{ok, pt:pack(?PP_CHAT_SAVE_CHAT_CHANNELS_RESULT, Data)};
 
%% %% Server -> Client:return get result
%% write(?PP_CHAT_GET_CHAT_CHANNELS_RESULT, )
%%------End chat config 2------

%% 110006 系统公告 CHAT_SYS_ANNOUNCEMENT (S>>C)
%% String 公告信息 
write(?PP_CHAT_SYS_ANNOUNCEMENT, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_CHAT_SYS_ANNOUNCEMENT, BinStr)};

%% 11007  私人聊天服务端发往客户端的消息包（s >> c）
%% uint64 From角色唯一ID号
%% string From玩家昵称
%% int32  发送时间（秒数）
%% string 消息
write(?PP_CHAT_SERVER_TO_CLIENT_PRIVATE, [FromRoleId, FromName, Sex, Lvl, Career, Secs, ChatContent]) ->
	BinName     = pt:write_string(FromName),
	BinContent  = pt:write_string(ChatContent),
	Data = <<FromRoleId:64,
			 BinName/binary,
			 Sex:32, 
			 Lvl:32, 
			 Career:32,
			 Secs:32,
			 BinContent/binary>>,
    {ok, pt:pack(?PP_CHAT_SERVER_TO_CLIENT_PRIVATE, Data)};

%% 11009 全服系统提示 CHAT_SERVER_NOTICE (S>>C)
%% String 提示信息
write(?PP_CHAT_SERVER_NOTICE, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_CHAT_SERVER_NOTICE, BinStr)};

%% 11010 全服系统提示 CHAT_SERVER_NOTICE (S>>C)
%% String 提示信息
write(?PP_CHAT_SERVER_WIN_NOTICE, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_CHAT_SERVER_WIN_NOTICE, BinStr)};

%%------测试用-----
write(?PP_CHAT_CLIENT_TO_SERVER, [ChatMode, ToName, ChatContent]) ->
%%	BinChatMode = pt:write_string(ChatMode),
	BinToName   = pt:write_string(ToName),
	BinContent  = pt:write_string(ChatContent),
	Data = <<ChatMode:32,
			 BinToName/binary,
			 BinContent/binary>>,
	{ok, pt:pack(?PP_CHAT_CLIENT_TO_SERVER, Data)}.

%%%-----------------------------------
%%% @Module  : lib_send
%%% @Author  : LiuYaohua
%%% @Created : 2012.07.10
%%% @Description: 发送消息
%%%-----------------------------------

%%=============================================================================
%% IMPORTANT:
%%		这里封装了发送数据包的函数，所有要通过tcp socket发送的数据包都应该调用这里的函数来发送。
%%		目前数据包的发送没有实现队列发送模式，不过在将来可能会要分离计算和通信IO，因此会对发送数据包做一些处理，
%%		比如合并数据包一起发送，并设置一起发送数据包的最大长度和发送的最大等待时间等。
%%		注意：包的合并只能是针对同一个玩家的包!
%%=============================================================================
-module(lib_send).
-include("record.hrl").
-include("common.hrl").
-include("proto.hrl").

-export([
		 send_to_roleid/2,
		 send_to_name/2,
		 send_to_all/1,
		 send_to_send_pid_list/2,
		 do_broadcast/2,
		 send_to_send_pid/2,
		 send_slow_to_send_pid_list/2,
		 send_slow_to_send_pid/2,
		 sys_announce/1,
		 server_notice/1,
         server_notice/2
       ]).



%% 发送信息给指定玩家名.
%% Param:RoleName:玩家角色名称
%% 		Bin:发送内容二进制数据.
%% return 	{ok} 成功
%% 			{error}失败
send_to_name(RoleName, Bin) ->
	?INFO( "send_to_name: ~p Bin:~p", [RoleName, Bin]),
	%%获取目标玩家角色的消息发送pid
	case mod_account:get_send_pid_by_name(RoleName) of
		{true, Send_Pid}->%%获得send_pid成功
			try
				Send_Pid ! {send_now, Bin}
			catch _:_ -> ok end,
			{ok};
		{false} -> %%获取失败
			{error}
	end.

%% 发送信息给指定玩家ID.
%% RoleId:玩家ID
%% Bin:二进制数据.
%% return：
%%           {ok}:成功
%%           {error}:失败
send_to_roleid(RoleId, Bin) ->
    case mod_account:get_send_pid_by_roleid(RoleId) of
		{true, Send_Pid} -> %%获取send_pid成功
			try
				Send_Pid ! {send_now, Bin}
			catch _:_ -> ok end,
			{ok};
		{false} -> %%获取失败
			{error}
    end.


%% 发送给所有玩家
send_to_all(Bin) ->
    L = mod_account:get_online_send_pid_list(),
    do_broadcast(L, Bin).


%% 对列表中的所有socket进行广播
do_broadcast([Send_Pid | Rest], Bin) ->
	try
		Send_Pid ! {send_now, Bin}
	catch
		_:_ -> ok
	end,
	do_broadcast(Rest, Bin);

do_broadcast([], _Bin)->
	{ok}.

%%发送给Pid列表
%%Send_PidList: 接收数据的玩家发送pid列表
%%Bin：消息
send_to_send_pid_list([], _Bin)-> ok;
send_to_send_pid_list(Send_PidList, Bin) ->
	do_broadcast(Send_PidList, Bin).
	
send_to_send_pid(Send_Pid, Bin)->
	try
		Send_Pid ! {send_now, Bin}
	catch
		_:_->ok
	end.

send_slow_to_send_pid_list([], _Bin)->ok;
send_slow_to_send_pid_list(Send_PidList,Bin)->
	mod_slowsend:send_to_list(Send_PidList, Bin).

send_slow_to_send_pid(Send_Pid, Bin)->
	mod_slowsend:send(Send_Pid, Bin).

%%发送系统广播
sys_announce(Msg)->
	{ok,Bin} = pt_11:write(?PP_CHAT_SYS_ANNOUNCEMENT, Msg),
	send_to_all(Bin).

%%发送全服系统广播
server_notice(Msg)->
	{ok, Bin} = pt_11:write(?PP_CHAT_SERVER_NOTICE, Msg),
	send_to_all(Bin).

server_notice(RoleId, Msg)->
    {ok, Bin} = pt_11:write(?PP_CHAT_SERVER_NOTICE, Msg),
    send_to_roleid(RoleId, Bin).

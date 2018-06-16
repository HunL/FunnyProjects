%%%-----------------------------------
%%% @Module  : mh_reader
%%% @Email   : LiuYaohua
%%% @Created : 2011.08.1
%%% @Description: 读取客户端
%%%-----------------------------------
-module(mh_reader).
-export([start_link/0, init/0]).
-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").
-define(TCP_TIMEOUT, 60*1000).      %% 解析协议超时时间
-define(HEART_TIMEOUT,  ?SYN_TIME_GAP * 2). %% 心跳包超时时间
-define(HEART_TIMEOUT_TIME, 2).  %% 心跳包超时次数
-define(HEADER_LENGTH, 8).       %% 消息头长度
-define(MAX_PACKET_SEQ, 16#FFFF). %%最大包序号

%%记录客户端进程
-record(client, {
            pid = none,	  %% 玩家进程pid
            login  = 0,   %% 是否已登录
            roleid  = 0,  %% 已选用的角色ID
			accountid = 0,%% 账号id
			fcm = 0,      %% 默认不防沉迷
			timeout = 0,  %% 超时次数
			trace_pkg = false	%%是否记录包
     }).

start_link() ->
	Pid = proc_lib:spawn_link(?MODULE, init, []),
    {ok, Pid}.

%%gen_server init
%%Host:主机IP
%%Port:端口
init() ->
    process_flag(trap_exit, true),
	?INFO("creating new process: Pid:~p~n",[self()]),
    Client = #client{
                pid = none,
                login  = 0
            },
    receive
        {go, Socket} ->
			?INFO("Socket: ~p~n",[Socket]),
            login_parse_packet(Socket, Client);
		
		{'EXIT',From,Reason}->
			?INFO("EXIT from ~p, reason ~p",[From,Reason]);
		Other->
			?INFO("unknown message ~p",[Other])
    end.

%%登录前消息处理 
%%Socket：socket id
%%Client: client记录
login_parse_packet(Socket, Client) ->
    Ref = async_recv(Socket, ?HEADER_LENGTH, ?HEART_TIMEOUT),
    receive
        %运营平台后台管理
        {inet_async, Socket, Ref, {ok, <<"GET ", Pre/binary>>}} ->
            Ref1 = async_recv(Socket, 0, ?TCP_TIMEOUT),
            receive 
                {inet_async, Socket, Ref1, {ok, Binary}} ->
                    %?INFO("Socket:~p, Pre:~p Get MsgBody: ~p.~n", [Socket, Pre, Binary]),
                    admin_mod:admin_request(Socket, <<Pre/binary, Binary/binary>>);
                _Other ->
                    gen_tcp:close(Socket)
            end;
        %%flash安全沙箱
        {inet_async, Socket, Ref, {ok, ?FL_POLICY_REQ}} ->
			?INFO("policy reuest "),
            Len = 23 - ?HEADER_LENGTH,
            async_recv(Socket, Len, ?TCP_TIMEOUT),
            gen_tcp:send(Socket, ?FL_POLICY_FILE),
			%%login_parse_packet(Socket,Client),
			gen_tcp:close(Socket);
        %%登陆处理
        {inet_async, Socket, Ref, {ok, <<Len:16, _Seq:32, Cmd:16>>}} ->
            BodyLen = Len - ?HEADER_LENGTH,
			io:format("~n~nreader inet_async cmd=~p~~~~~~~~~~~~~~~~~~**~n~n", [Cmd]),
%			?INFO("~n~nreader inet_async cmd=~p~~~~~~~~~~~~~~~~~~**~n~n", [Cmd]),
            case BodyLen > 0 of				
                true -> %%消息长度大于0，正常
                    Ref1 = async_recv(Socket, BodyLen, ?TCP_TIMEOUT),
                    receive
                       {inet_async, Socket, Ref1, {ok, Binary}} ->
						    Key = mh_env:get_env(key),
							case ((Cmd == ?PP_ACCOUNT_LOGIN) or (Cmd == ?PP_ACCOUNT_CREATE_ROLE)) of 
								false -> login_lost(Socket,Client, bad_login_pkt);
								true ->
									io:format("~n~nreader routing~~~~~~~~~~~~~~~~~~**~n~n", []),
%									?INFO("~n~nreader routing~~~~~~~~~~~~~~~~~~**~n~n", []),
		                            case routing(Cmd, Binary) of								
        			                       %% 登陆验证包
                    		            {ok, [login, Accname, Time, CheckCode]} ->
                            		        case login_check(false, Accname, Time, Key, CheckCode) of
                                    		    true ->
                                            		role_login(Socket, Client, Accname,CheckCode);
                                        		false ->
                                            		login_lost(Socket, Client, "md5 check failure")
                   		                 end;
		                                %% 创建角色
		                                {ok, [create, Account, RoleName, Sex, Career, Time, CheckCode]} ->
		                                    case login_check(false, Account, Time, Key, CheckCode) of
		                                        true ->
		                                            role_create(Socket, Client, Account, RoleName, Sex, Career, CheckCode);
		                                        false ->
		                                            login_lost(Socket, Client, "md5 check failure")
		                                    end;
										{ok, [login_tourist, Tourist, Time, CheckCode]} ->
											case login_check(true, Tourist, Time, Key, CheckCode) of
												true ->
		                                            tourist_login(Socket, Client, CheckCode);
												false ->
		                                            login_lost(Socket, Client, "md5 check failure")
											end
		                            end
							end;
						Other ->
                            login_lost(Socket, Client, Other)
                    end;
                false -> %%消息长度小于0
                      login_lost(Socket, Client, "login fail...")
            end;	
        %%用户断开连接或出错
        Other ->
            login_lost(Socket, Client, Other)
    end.

%%用户登录
role_login(Socket, Client, Accname, CheckCode)->
    ?INFO("Acc:~p login",[Accname]),
    case pp_account:handle(?PP_ACCOUNT_LOGIN, Socket, [Accname]) of
        {true,{Pid,AccountId,RoleId}} ->
            Client1 = Client#client{
                login = 1,
                roleid = RoleId,
                accountid = AccountId,
                pid = Pid
            },
            monitor(process, Pid),
            %%登录完成
            do_parse_packet(Socket, Client1, CheckCode);
        {no_account} ->
            %%玩家无账号，断开连接
            ?INFO("Close: no_account Socket:~p. ~n", [Socket]),
            %%gen_tcp:close(Socket)
            login_parse_packet(Socket, Client)
    end.

%%用户注册
role_create(Socket,Client,Account, RoleName, Sex, Career, CheckCode) ->
%    Mask = get_mask_from_checkcode(CheckCode),
	io:format("~n~n~nrole_create**************~n~n~n", []),
%	?INFO("~n~n~nrole_create**************~n~n~n", []),
    case Client#client.login == 0 of
        true ->
            Res = pp_account:handle(?PP_ACCOUNT_CREATE_ROLE, Socket, [Account,RoleName,Sex,Career]),
            case Res of
                {true,{Pid,AccountId,RoleId}} ->%%注册成功
                    Client1 = Client#client{login = 1, roleid = RoleId, 
                        accountid = AccountId, pid = Pid},
                    monitor(process, Pid),
                    do_parse_packet(Socket, Client1, CheckCode);
                {false} ->%%注册失败
                    gen_tcp:close(Socket)
            end;
        false -> %% 玩家已经有自己的角色了，并且应该是进入游戏的，结果却发了一个创建角色的请求
            login_lost(Socket, Client,  "you already exist a role... ")
    end.

%%游客登录
tourist_login(Socket, Client, CheckCode) ->
    AccountPrefix = cfg_string:get_string(tourist),
    case mod_loginserver:register_guest(AccountPrefix) of
        {true, RoleInfo} ->
            do_tourlist_ack(RoleInfo, Socket),
            case do_new_tourist(RoleInfo, Socket) of
                {true,{Pid,AccountId,RoleId}} ->%%注册成功
                    Client1 = Client#client{login = 1, roleid = RoleId, 
                        accountid = AccountId, pid = Pid},
                    monitor(process, Pid),
                    do_parse_packet(Socket, Client1, CheckCode);
                {false} ->%%注册失败
                    gen_tcp:close(Socket)
            end;
        {false} ->
            gen_tcp:close(Socket)
    end.

%%掩码使用检验码的最后一个字符，这是与客户端约定的
get_mask_from_checkcode(Seq) ->
    Seq rem 256.

%%登录后的消息处理
do_parse_packet(Socket, Client, CheckCode) ->
    ?INFO("Socket:~p, Client:~p, CheckCode:~p", [Socket, Client, CheckCode]),
    Seq = 1, %初始序号，与客户端约定
    do_parse_packet(Socket, Client, CheckCode, Seq).
do_parse_packet(Socket, Client, CheckCode, Seq) ->
    Mask = get_mask_from_checkcode(Seq), %找一个掩码，用于异或运算
    %?INFO("Mask:~p", [Mask]),
    Ref = async_recv(Socket, ?HEADER_LENGTH, ?HEART_TIMEOUT), %%接收头部
    receive
        {inet_async, Socket, _Ref, {ok, <<Len:16, HeadBin/binary>>}} -> 
            <<RealSeq:32, Cmd:16>> = mask_binary(Mask, HeadBin), %掩码
            case RealSeq of
                Seq ->
                    mod_monitor:recv_packet(Client#client.pid, Len),
                    BodyLen = Len - ?HEADER_LENGTH,
                    RecvData = 
                    case BodyLen > 0 of
                        true ->%%内容长度不为0
                            Ref1 = async_recv(Socket, BodyLen, ?TCP_TIMEOUT), %%根据头部长度接收内容
                            receive
                                {inet_async, Socket, Ref1, {ok, Binary}} ->
                                    {ok, Binary};
                                Other ->
									?INFO("fail, Other:~p",[Other]),
                                    {fail, Other}
                            end;
                        false ->%%只有命令没有内容
                            {ok, <<>>}
                    end,
                    case RecvData of
                        {ok, OBinData} ->%%数据完整接收成功 
                            BinData = mask_binary(Mask, OBinData),
% 							?INFO("socket recv cmd~p, data:~p",[Cmd,BinData]),
							io:format("socket recv cmd~p, data:~p",[Cmd,BinData]),
                            case routing(Cmd, BinData) of	
                                {ok, Data} ->%%数据解析成功，发往角色进程处理
                                    gen_server:cast(Client#client.pid, {'SOCKET_EVENT', Cmd, Data});
%									mod_pkg_trace:receive_pkg(Client#client.roleid, Cmd, Data, Client#client.trace_pkg, received);
                                {error,_Other2} ->
                                    mod_monitor:recv_error_packet(Client#client.pid),
                                    ?INFO("Other2 cmd:~p~n",[Cmd])
                            end,
                            NextSeq = get_next_seq(Seq),
                            do_parse_packet(Socket,  Client#client{timeout = 0}, CheckCode, NextSeq);
                        {fail, Other3} ->
							?INFO("fail, Other3:~p",[Other3,Seq,BodyLen]),
                            do_lost(Socket, Client, Cmd, Other3, 3)			
                    end;
                _ ->
					?INFO("fail, Len:~p, Seq:~p,RealSeq:~p",[Len,Seq,RealSeq]),
                    do_lost(Socket, Client, Cmd, "seq error", 5)
            end;
        %%超时处理
        {inet_async, Socket, Ref, {error,etimedout}} ->	
			io:format("heart_timeout~n"),
            case Client#client.timeout >= ?HEART_TIMEOUT_TIME of
                true ->
					?INFO("timeout->do_lost",[]),
                    do_lost(Socket, Client, 0, {error,heart_timeout}, 4);
                false -> 
					?INFO("Client#client.timeout:~p",[Client#client.timeout]),
                    do_parse_packet(Socket, Client#client{timeout = Client#client.timeout+1}, CheckCode, Seq)            
            end;
		
		{start_trace} ->
			NewClient = Client#client{trace_pkg = true},
            do_parse_packet(Socket, NewClient, CheckCode, Seq);
		{stop_trace} ->
			NewClient = Client#client{trace_pkg = false},
            do_parse_packet(Socket, NewClient, CheckCode, Seq);
		
        %%用户断开连接或出错
        Other ->
            do_lost(Socket, Client, 0, Other, 6)
    end.

%% 登录连接断开
login_lost(Socket, _Client, _Reason) ->
	gen_tcp:close(Socket).

%%断开连接
do_lost(Socket, Client, Cmd, Reason, Location) ->
    ?INFO("do_lost:~p", [{Socket, Client, Cmd, Reason, Location}]),
	mod_role:socket_close(Client#client.pid, {Socket,{Reason, Location}}).

%%路由
%%组成如:pt_10:read
routing(Cmd, Binary) ->
    %%取前面二位区分功能类型
    %?INFO("read- Cmd:~p, Binary:~p. ~n",[Cmd,Binary]),
    %?INFO("read- Cmd:~p", [Cmd]),
    case integer_to_list(Cmd) of
		[H1, H2, _, _, _] ->
		    Module = list_to_atom("pt_"++[H1,H2]),
		    %% 添加这个避免客户端的错误协议导致服务端的异常
		    %%case catch Module:read(Cmd, Binary) of
		    %%	{'EXIT', Error} -> Error;
		    %%	Data -> Data
		    %%end;
			try
				Data = Module:read(Cmd, Binary),
				io:format("~n~nreader routing,,,Data=~p~n~n~n", [Data]),
				Data
			catch
				ExType:ExPattern ->
%				?INFO("Module:~p read catch Ex ~p:~p",[Module,ExType,ExPattern]),
				io:format("Module:~p read catch Ex ~p:~p",[Module,ExType,ExPattern]),
				{error, Module}
			end;
		_ ->
			protocal_error
	end.  		

%% 接受信息
async_recv(Sock, Length, Timeout) when is_port(Sock) ->
    case prim_inet:async_recv(Sock, Length, Timeout) of
        {error, Reason} -> Reason;
        {ok, Res}       -> Res;
        Res             -> Res
    end.


%do_tourist_check([_Tourist, Time, Key, CheckCode]) ->
	%Check = mh_env:get_env(login_md5_check_switch),                  
	%case Check of
		%?TOURIST_CHECK_CODE ->
			%Str = "1" ++ erlang:integer_to_list(Time) ++ Key,
			%Md5 = admin_mod:md5(Str),
			%Md5 == CheckCode;
		%_ ->
			%true
	%end.

login_check(IsTourist, UserName, Time, Key, CheckCode) ->
	Check = mh_env:get_env(login_md5_check_switch),                  
    Type = 
    case IsTourist of
        true -> "1";
        false -> "0"
    end,
	case Check of
		?TOURIST_CHECK_CODE ->
            ?INFO("UserName:~p,Time:~p,Key:~p, CheckCode:~p ",
                [UserName, Time, Key, CheckCode]),
			Str = UserName ++ Type ++ erlang:integer_to_list(Time) ++ Key,
			Md5 = admin_mod:md5(Str),
            if 
                Md5 == CheckCode -> true;
                true ->
                    ?INFO("MD5 check failure:~p",[Md5]),
                    false
            end;
		_ ->
			true
	end.


do_new_tourist(RoleInfo, Socket) ->
	{ok,Pid} = pp_account:new_role(RoleInfo#mhrolebaseinfo.accountid,
						 RoleInfo#mhrolebaseinfo.rolename,
						 RoleInfo#mhrolebaseinfo.roleid,
						 RoleInfo#mhrolebaseinfo.rolename,
						 RoleInfo#mhrolebaseinfo.sex,
						 RoleInfo#mhrolebaseinfo.career,
						 Socket,
						 ?ROLE_TYPE_TOURIST, 
						 self()),
	{true, {Pid, RoleInfo#mhrolebaseinfo.accountid,RoleInfo#mhrolebaseinfo.roleid}}.


do_tourlist_ack(RoleInfo, Socket) ->
	{ok, BinDataOk} = pt_10:write(?PP_ACCOUNT_LOGIN_ACK, RoleInfo),
	gen_tcp:send(Socket, BinDataOk).

%%对二进制数据作掩码/异或操作
mask_binary(Mask, Binary) ->
    _RtBin = mask_binary(Mask, Binary, <<>>).
mask_binary(_Mask, <<>>, RtBin) ->
    RtBin;
mask_binary(Mask, <<Byte:8, RestBin/binary>>, RtBin) ->
    NRtBin = <<RtBin/binary, (Mask bxor Byte):8>>,
    mask_binary(Mask, RestBin, NRtBin).

get_next_seq(Seq) ->
    if
        ?MAX_PACKET_SEQ == Seq ->
            0;
        true -> 
            Seq+1
    end.



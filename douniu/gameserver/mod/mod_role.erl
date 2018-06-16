%%% -------------------------------------------------------------------
%%% Author  : LiuYaohua
%%% Description : 角色信息管理进程
%%%
%%% Created : 2012-7-9
%%% -------------------------------------------------------------------
-module(mod_role).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").
%-include("battle.hrl").
-include("counter.hrl").
-include("log.hrl").
%-include("vitality.hrl").
%-include("buff.hrl").
%-include("fb.hrl").
%% --------------------------------------------------------------------


%% External exports

%% gen_server callbacks
-export([start/1, init/1, handle_call/3, handle_cast/2, 
         handle_info/2, terminate/2, code_change/3]).

-export([call_logout/2, get_roleinfo/2, add_exp/3, update_scene/2, do_start/2]).

-export([init_log_sql/0]).

%% 定时器超时处理
-export([do_syn_time/1, 
		 handle_timeout/1]). 	%进入帮战保护 3分钟

-export([del_specialItem/4, add_specialItem/2]). %% 添加删除特殊物品

%% 更新经济值
-export([get_gold/1, get_goldcoin/1]).

-export([is_in_room/1]).

-export([update_role_attr/1 ,  %%更新人物属性
		update_role_title/2,		%人物称号
		del_activity_title/2	%%删除活动称号
        ]).

-export([get_mhrole/0,  %%获取角色信息
         set_mhrole/1  %%设置角色信息
        ]).

-export([look_role_detail/2, look_role_detail_reply/2]).%%查看角色信息 

-export([routing/3 %仅用于GM命令测试协议
        ]).

-export([dispose/2, update_socket/3, socket_close/2, kick_off/2]).

-export([shutup/2 %禁言
    ]).


-export([test/3]). %only for test

-record(state,{}).

-define(MAX_PK_VALUE, 9000). %PK值上限
%% ====================================================================
%% External functions
%% ====================================================================

%% return {ok, [ModuleName, OperaterType, ArgsNumber, Sql], 
%%              [ModuleName, OperaterType, ArgsNumber, Sql],
%%              ... }
init_log_sql() ->
    {ok, [
          [?MODULE, login, 4, 
           "INSERT INTO log_login(log_time,gd_accountid,gd_roleid,log_IP,gd_rolelv) 
            VALUES(NOW(),'~p','~p','~p','~p');"], 
          [?MODULE, logout, 3,
           "INSERT INTO log_logout (log_time,gd_accountid,gd_roleid,log_reason,log_duration,log_login_level,log_logout_level,log_ip) 
            VALUES(NOW(),'~p','~p','~s', '~p', '~p', '~p', '~s');"],
          [?MODULE, addexp, 5,
           "INSERT INTO log_exp(gd_roleid,log_type,log_oldexp,log_change,log_newlevel,log_oldlevel,log_time) 
            VALUES('~p','~p','~p','~p','~p','~p',NOW());"],
          [?MODULE, update_fearies_gas, 4,
           "insert into log_fearies_gas (gd_roleid, log_type, log_var, 
            log_cur, log_time) values('~p', '~p', '~p', '~p', now());"]
          ]}.

%% ====================================================================
%% Server functions
%% ====================================================================
%% 创建角色管理进程
start(Param) ->
	gen_server:start(?MODULE, Param, []).

%===============================================
%mhrole保留两份：本身进程字典一份，全局ets表一份
%当调用get_mhrole()时由本进程字典读出；
%当调用get_roleinfo(Pid)时由全局ets表读出
%当调用set_mhrole()时同时写入本进程字典与全局ets表
get_mhrole()->
	MhRole = get(mhrole),

	case is_record(MhRole, mhrole) of
		true -> ok;
		false->   1=2 %%进程字典内数据错误
	end,
	MhRole.

set_mhrole(MhRole)->%TODO:write ets to db at given time
	true = is_record(MhRole, mhrole),
	put(mhrole,MhRole),
	mod_role_ets:set_mhrole(MhRole),
	MhRole.

%%获取角色信息,返回#mhrole
get_roleinfo(Pid,_P)->
	mod_role_ets:get_mhrole(Pid).
%===============================================

%子模块进程出现异常
mod_proc_exception(RolePid, Module, Reason)->
	gen_server:cast(RolePid, {mod_proc_exception, Module, Reason}).
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init({Op, RoleId, ParamList})->
	process_flag(trap_exit, true),
	mod_role:set_mhrole(#mhrole{roleid = RoleId}),
	gen_server:cast(self(),{?MODULE,do_start,{Op, RoleId, ParamList}}),
	{ok,#state{}}.

%%加载角色
do_start(_Pid, {load, RoleId, [AccountId, Socket,Account, ReaderPid]}) ->
	ok = do_load(RoleId, AccountId, Socket,Account, ReaderPid),
    mod_safe:role_login(RoleId, Socket, self()),
	{noreply, #state{}};

%%新建角色		  
do_start(_Pid, {new, RoleId, [AccountId, AccName, RoleName, Sex, Career, Socket, RoleType, ReaderPid]}) ->
	ok = do_new(AccountId, AccName, RoleId, RoleName, Sex, Career, Socket, RoleType, ReaderPid),
    mod_safe:role_login(RoleId, Socket, self()),
	{noreply, #state{}}.

%%下线
call_logout(Pid, Reason)->
	gen_server:call(Pid, {call_logout,Reason}).

%% 报错接口
inf_send_error(Pid,ErrorString) ->
	case self() =:= Pid of
		true ->
			?S2CERRS(ErrorString);
		false ->
			gen_server:call(Pid, {?MODULE, inf_send_error, [ErrorString]})
	end.

%%增加经验
add_exp(Pid, Exp, Operate)->
	gen_server:cast(Pid, {add_exp, Exp, Operate}).
%%增加攻击力
add_att(Pid, Val)->
	?INFO("add_att:~n ~p,~n ~p", [Pid, Val]),
	gen_server:cast(Pid,{add_att,Val}).
%% 更改防御力 
add_def(Pid, Val)->
	gen_server:cast(Pid,{add_def, Val}).
add_hp_mp(Pid, {Hp, Mp, Dao}) ->
    gen_server:cast(Pid, {add_hp_mp_dao, Hp, Mp, Dao}).

update_role_title(Pid, {TitleId, Flag})->
	gen_server:cast(Pid, {update_title,TitleId, Flag}).

del_activity_title(Pid, TitleIdlst)->
	gen_server:cast(Pid, {del_act_title,TitleIdlst}).

%%更新场景信息
update_scene(Pid,{MapId, PointPos, Status, MapType})->
	gen_server:cast(Pid, {msg_update_scene, {MapId, PointPos, Status, MapType}}).

%% 加特殊物品
add_specialItem(Pid, {Type, Cnt, Operate})->
	gen_server:cast(Pid,{add_specialItem, Type, Cnt, Operate}).

%% 减特殊物品
del_specialItem(Pid, Type, Cnt, Operate) ->
    gen_server:cast(Pid,{del_specialItem, Type, Cnt, Operate}).

%获取金元宝数量
get_gold(Pid) ->
	gen_server:call(Pid, {get_ecnomic, ?ITEM_GOLD}).

% 获取银元宝数量
%get_silver(Pid) ->
%	gen_server:call(Pid, {get_ecnomic, ?ITEM_SILVER}).
 
%% 获取金币数量
get_goldcoin(Pid) ->
	gen_server:call(Pid, {get_ecnomic, ?ITEM_GOLDCOIN}).

% 获取银币数量
%get_silvercoin(Pid) ->
%	gen_server:call(Pid, {get_ecnomic, ?ITEM_SILVERCOIN}).

dispose(Pid, Reason)->
	gen_server:cast(Pid,{dispose, Reason}).

%%更新socket，用于玩家重连
update_socket(Pid, Socket, ReaderPid)->
	gen_server:cast(Pid, {update_socket, Socket, ReaderPid}).

socket_close(Pid, {Socket, Reason})->
	gen_server:cast(Pid,{socket_close, {Socket, Reason}}).

kick_off(Pid, Reason)->
	gen_server:cast(Pid, {kick_off, Reason}).

is_in_room(RoleInfo)->
	RoleInfo#mhrole.douniu_roomid > 0.
		
%%更新人物属性
%%MhItemList 角色已穿戴的装备信息列表[#mhitem]
%%SuitAttrList 装备套装属性列表[{Type, Value},..]
update_role_attr(RolePid)->
    gen_server:cast(RolePid, {update_role_attr}).

    
%%查看角色信息
look_role_detail(Pid, {LookerPid}) ->
    LookRole = get_mhrole(),
    EquipList = mod_item:get_equiped_item_attr_list(Pid, {}),
    gen_server:cast(LookerPid, 
                    {?MODULE, look_role_detail_reply, {LookRole, EquipList}}).

%% 处理来自被查看的玩家进程发来的角色信息和装备信息,发送给前端
look_role_detail_reply(_LookerPid, {LookRole, EquipList}) ->
    LookerRole = get_mhrole(),
    {ok, Bin} = pt_10:write(?PP_AACOUNT_LOOK_ROLE_ACK, {0, LookRole, EquipList}),
    lib_send:send_slow_to_send_pid(LookerRole#mhrole.send_pid, Bin).

%%禁言
%%Enable true|false
shutup(Pid, Enable) ->
    gen_server:cast(Pid, {shutup, Enable}).

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
handle_call({call_logout, Reason}, _From, State)->
	?INFO("call_Logout Reason: ~p",[Reason]),
	{stop,{shutdown,Reason}, State};

handle_call(Request, _From, State) ->
	Mhrole = get_mhrole(),
    %%匹配出M,F,A
	{Module, Func, Arg} = Request,
	%%按照 M:F(self(),A)格式调用
	%?INFO("mod_role:handle_call M:~p, F:~p, A:~p",[Module, Func, Arg]),
	Reply = Module:Func(self(), Arg),
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State)->
	Ret = do_cast(Msg, State),
	Ret.


%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({'EXIT', Pid, Reason},State)->
	?ERR("handle_info receive EXIT, Pid:~p, Reason:~p",[Pid,Reason]),
	{stop, {shutdown, Reason}, State};
handle_info(Info, State) ->
	?ERR("handle_info unexpeted msg: ~p~n", [Info]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, _State) ->
%% 	?INFO("RoleId:~p Pid:~p terminated",[State#mhrole.roleid, State#mhrole.pid]),
    ?INFO("terminate Reason ~p", [Reason]),
	MhRole = get_mhrole(),
	try
		do_final(Reason, MhRole)
	catch
		ExType:ExPattern ->
			?ERR("ExType: ~p, ExPattern: ~p, RoleId:~p",[ExType,ExPattern,MhRole#mhrole.roleid]),
			?ERR("StackTrace:~p",[erlang:get_stacktrace()])
	end,
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

%%加载角色信息
%%return {true, #mhrole}
do_load(RoleId, AccountId, Socket, Account, ReaderPid) ->
	%%从数据库读取role信息
	{true,RoleInfo1} = lib_role:load_db_role_by_id(AccountId,RoleId),
	io:format("~n~n~nRoleInfo1=~p~n~n~n", [RoleInfo1]),
	RoleInfo2 = RoleInfo1#mhrole{account = Account},
    io:format("~n~n~nRoleInfo2=~p~n~n~n", [RoleInfo2]),
	
    %% 读取师门信息
%    RoleInfo3 = mod_school:do_load_school(RoleInfo2),
	
%	RoleInfo4 = do_guild_info(RoleId, RoleInfo3),
%% 
%% 	%% 读取称号信息
%% 	RoleInfo5 = mod_title:load_title_info(RoleInfo4),
    
	%%角色avatar
	
	%%读取完后初始
%	ok = do_init(RoleInfo4, AccountId, Socket, ReaderPid),
	ok = do_init(RoleInfo2, AccountId, Socket, ReaderPid),
	
	ok.


%%创建原始角色
%%reurn {true, #mhrole}
do_new(AccountId, AccName, RoleId, RoleName, Sex, Career, Socket, RoleType, ReaderPid) ->
    
	%%构造默认角色信息
	RoleInfo1 = #mhrole{accountid = AccountId, roleid = RoleId, 
                        rolename=RoleName,sex=Sex,career=Career,
						account=AccName,
						role_type = RoleType},
	%%设置原始avatar形象
	RoleInfo2 = lib_role:set_role_avatar(RoleInfo1),
	%%插入到数据库
	{ok} = lib_role:insert_db_account_info(AccountId, AccName), 
	{ok} = lib_role:insert_db_role_info(RoleInfo2),
    
	%%初始化
	ok = do_init(RoleInfo2, AccountId, Socket, ReaderPid),
	
	ok.
													 
%%数据包发送进程	
send_msg(Socket, RoleId, TraceFlag) ->
	util:sleep(5),  %%发往客户端的数据包间隔
	receive
	   {stop} ->
			stop;
	   
	   {send_now, Bin} ->
 		   <<_Len:16, Cmd:16, Data/binary>> = Bin,
            % io:format("send_now Cmd:~p data: ~p~n",[Cmd, DATA]),
            %?INFO("send_now Cmd:~p data",[Cmd, DATA]),
			case Socket of
				undefined-> ok;
				_->   
					gen_tcp:send(Socket, Bin)
%					mod_pkg_trace:receive_pkg(RoleId, Cmd, Data, TraceFlag, send)
				end,
	       send_msg(Socket, RoleId, TraceFlag);
	   
	   {update_socket, NewSocket}->
		   case Socket of
			   undefined-> ok;
				_->gen_tcp:close(Socket)
		   end,
		   send_msg(NewSocket, RoleId, TraceFlag);
	   		
		{start_trace}->
			send_msg(Socket, RoleId, true);
		
		{stop_trace}->
			send_msg(Socket, RoleId, false);
		
		_Other ->
			% ?ERR("send_msg_Error:~p", [Other]),
			send_msg(Socket, RoleId, TraceFlag)
	end.

%%初始化
%% Param: #mhrole
%% return:{true,#mhrle}|{false}
do_init(RoleInfo,_AccountId,Socket, ReaderPid) ->
	%初始化随机种子
	random:seed(now()),

	%%启动数据包发送进程
	Send_Pid = spawn_link(fun() -> send_msg(Socket, RoleInfo#mhrole.roleid, false) end),
%	mod_slowsend:add(Send_Pid, Socket),
	io:format("RoleId = ~p, RolePid = ~p, SendPid = ~p.~n",
            [RoleInfo#mhrole.roleid, self(),Send_Pid]),
	
	%%登录日志
	{ok,{Addr,_Port}} = inet:peername(Socket),
	StrIp = inet_parse:ntoa(Addr),
	
	RoleInfo2 = RoleInfo#mhrole{send_pid = Send_Pid, socket = Socket,pid=self(), login_ip = StrIp, reader_pid = ReaderPid},	
    ?DBLOG(?MODULE, login, [RoleInfo#mhrole.accountid,RoleInfo#mhrole.roleid,StrIp,RoleInfo#mhrole.level]),
	%%更新登录ip
%	lib_role:update_last_ip(RoleInfo#mhrole.roleid, StrIp),
	
	%%更新online account信息
%	mod_account:update(RoleInfo#mhrole.roleid, [{pid,self()},{send_pid, Send_Pid},{socket,Socket}], role_init),
    
    %% 同步时间初始化
%    init_syn_time(RoleInfo#mhrole.pid,0),
	%%记录登录时间
%	lib_role:update_login_time(RoleInfo#mhrole.roleid),
	

	%%记录是否可在聊天栏中输入GM命令
%	put(gm_chat,mh_env:get_env(gm_chat)),

%	update_role_attr(self()), %更新角色属性 
	set_mhrole(RoleInfo2), 
	ok.


%%---------------------do_cast--------------------------------
%%处理socket协议 (cmd：命令号; data：协议数据)
do_cast({'SOCKET_EVENT', Cmd, Data}, State) ->
	RoleInfo = get_mhrole(),
	io:format("~n~n'SOCKET_EVENT', Cmd=~p, Data=~p~n~n", [Cmd, Data]),
	io:format("~n~nSocket event RoleInfo=~p~n~n", [RoleInfo]),
	socket_event(Cmd, Data, RoleInfo),
	{noreply, State};

%%处理GM命令
do_cast({gm_transfer_point, TransferPoint}, State)->
	pp_scene:handle(?PP_SCENE_ENTER_MAP, get_mhrole(), TransferPoint),
	{noreply, State};


%%刷新角色体力
do_cast({reset_energy}, State) ->
	mod_energy:reset_energy(),
    {noreply, State};



do_cast({dispose, Reason}, State)->
	{stop, {shutdown,{dispose, Reason}}, State};

do_cast({update_socket, Socket, NewReaderPid}, State)->
	MhRole = get_mhrole(),
	MySocket = MhRole#mhrole.socket,
	case MySocket =:= Socket of
		false->
			SendPid = MhRole#mhrole.send_pid,
			mod_account:update(MhRole#mhrole.roleid, [{socket,Socket}],update_socket),
			SendPid ! {update_socket, Socket},
			mod_slowsend:add(SendPid, Socket),
			Relogin_time = util:unixtime(),
			%更新登录ip
			{ok,{Addr,_Port}} = inet:peername(Socket),
			StrIp = inet_parse:ntoa(Addr),
			MhRoleSocket = MhRole#mhrole{socket = Socket, login_ip = StrIp, reader_pid = NewReaderPid},
			
			%% 登录检测，退出材料副本
%			{FuBenId, FbRcdId, StTime, Sec, _Ref} = MhRole#mhrole.fb_count_down,
%			Now = util:get_now_second(),
%			Left = Sec - (Now - StTime),
%			if
%				(Left < 0 andalso FuBenId /= 0) ->
%					gen_server:cast(self(), {fuben_timer_end, FuBenId, FbRcdId, -1});
%				true ->
%					ok
%			end,
	
            % 顶号清除密码标记
            NewMhRole = mod_lock:do_when_reconnected(MhRoleSocket),
			
            %在线游戏时间秒 
            %GameTime = util:unixtime() - MhRole#mhrole.login_time,
            GameTime = 0,
			%上线日志
			?DBLOG(?MODULE, login, [MhRole#mhrole.accountid,MhRole#mhrole.roleid,StrIp,MhRole#mhrole.level]),
			%%下线日志
		    ?DBLOG(?MODULE,logout,[MhRole#mhrole.accountid,MhRole#mhrole.roleid,util:term_to_string({relogin}),GameTime,MhRole#mhrole.login_level,MhRole#mhrole.level,MhRole#mhrole.login_ip]),
			
			%%更新登陆等级
			NewMhRole2 = NewMhRole#mhrole{login_level = NewMhRole#mhrole.login_level},
			set_mhrole(NewMhRole2),
			lib_role:update_last_ip(MhRole#mhrole.roleid, StrIp);
		true->ok
	end,
	
	{noreply, State};

do_cast({socket_close, {Socket, Reason}}, State)->
	MhRole = get_mhrole(),
	MySocket = MhRole#mhrole.socket,
	case MySocket =:= Socket of
		true->
			SendPid = MhRole#mhrole.send_pid,
			SendPid ! {update_socket, undefined},
%			mod_slowsend:del(SendPid),
			NewMhRole = MhRole#mhrole{socket = undefined},
			mod_account:update(MhRole#mhrole.roleid, [{socket, undefined}],Reason),
			set_mhrole(NewMhRole);

		false->
			ok
	end,
	
	{noreply, State};

do_cast({kick_off, Reason}, State)->
	MhRole = get_mhrole(),
	{stop, {shutdown,kick_off}, State};

do_cast({shutup, Enable}, State) ->
    MhRole = get_mhrole(),
    NMhRole = MhRole#mhrole{shutup = Enable},
    set_mhrole(NMhRole),
    {noreply, State};

do_cast({recv_packet, PktLen}, State) ->
%    MhRole = get_mhrole(),
%    {ok, NMhRole} = mod_monitor:recv_packet(MhRole, PktLen, false),
%    set_mhrole(MhRole),
    {noreply, State};

do_cast(recv_error_packet, State) ->
    MhRole = get_mhrole(),
    {ok, NMhRole} = mod_monitor:recv_packet(MhRole, 0, true),
    set_mhrole(NMhRole),
    {noreply, State};


do_cast(Msg , State) ->
	io:format("~n~nMsg=~p~n~n", [Msg]),
    %%匹配出M,F,A
	{Module, Func, Arg} = Msg,
	%%按照 M:F(self(),A)格式调用
	Module:Func(self(), Arg),
	{noreply, State}.          
   
%% 接受client事件
socket_event(Cmd, Data, RoleInfo) ->
    routing(Cmd, RoleInfo, Data).
	

%% 路由
%%cmd:命令号
%%Socket:socket id
%%data:消息体
routing(Cmd, RoleInfo, Data) ->
    %%取前面二位区分功能类型
    [H1, H2, _, _, _] = integer_to_list(Cmd),
%    ?ERR("read cmd: ~p ", [Cmd]),
    case list_to_integer([H1, H2]) of
        %%以下添加模块id映射
        %% 各种pp_xxx文件的handle参数个数必须统一，严禁搞特殊，目前为3个
	   	?PP_ACCOUNT -> %% 账号管理功能
			pp_role:handle(Cmd, RoleInfo, Data); 
		?PP_CHAT -> %% 聊天功能
			pp_chat:handle(Cmd, RoleInfo, Data); 
		?PP_SCENE -> %% 场景功能
			pp_scene:handle(Cmd, RoleInfo, Data);
		?PP_DOUNIU -> %% 斗牛功能
			pp_douniu:handle(Cmd, RoleInfo, Data);
		_ -> %% 错误处理
            {error, "Routing failure H1:~p H2:~p",[H1,H2]}
    end.

%%下线处理
do_final(Reason, RoleInfo)->
	%%设置下线
	mod_account:role_terminate(RoleInfo#mhrole.roleid),
	%在线游戏时间秒 
    GameTime = util:unixtime() - RoleInfo#mhrole.login_time,
	%%下线日志
    ?DBLOG(?MODULE, 
           logout,
			[RoleInfo#mhrole.accountid,RoleInfo#mhrole.roleid,util:term_to_string(Reason),GameTime,RoleInfo#mhrole.login_level,RoleInfo#mhrole.level,RoleInfo#mhrole.login_ip]),
	
	%从全局mhrole表中删除
	mod_role_ets:del_mhrole(self()),
	io:format("Role logout:~p,Pid:~p~n",[RoleInfo#mhrole.roleid,RoleInfo#mhrole.pid]),
    % 清空计数器
    ?DAILY_CLEAR(RoleInfo#mhrole.roleid).



%% ----------------------------- 时间同步接口 --------------------------------------

%% 时间同步接口
syn_time(RolePid,Tag) ->
    gen_server:cast(RolePid, {?MODULE,handle_syn_time,[Tag]}).

%% 初始化时间同步接口
%% Tag = 0 | 1 (0:奇周期，1:偶周期)
init_syn_time(RolePid,Tag) ->
    mh_simple_timer:start_timer(?MODULE, ?SYN_TIME_GAP, 
                                {syn_time, RolePid,Tag}),
    ok.

do_syn_time(RoleSendPid) ->
    {MegaSecs, Secs, _MicroSecs} = erlang:now(),
    NowSec = MegaSecs*1000*1000 + Secs,
    {ok, Bin} = pt_10:write(?ACCOUNT_ROLE_SYN_TIME, [NowSec]),
    lib_send:send_to_send_pid(RoleSendPid, Bin),
    ok.

handle_timeout({syn_time, RolePid,Tag}) ->
    syn_time(RolePid,Tag),
    ok;
handle_timeout(_) ->
    ok.
	
%%warning：仅用于服务端测试协议用，项目中请勿调用
test(Account, Cmd, Params) ->
    {true, AccountId, [MhRoleBase]} = mod_loginserver:get_account(Account),
    RoleId = MhRoleBase#mhrolebaseinfo.roleid,
    {true, Pid} = mod_account:get_pid_by_roleid(RoleId),
    gen_server:cast(Pid, {'SOCKET_EVENT', Cmd, Params}).

	

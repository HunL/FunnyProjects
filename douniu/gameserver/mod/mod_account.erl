%%% -------------------------------------------------------------------
%%% Author  : LiuYaohua
%%% Description :
%%%账号管理模块
%%% Created : 2012-7-9
%%% -------------------------------------------------------------------
-module(mod_account).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
-include("record.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([]).

%% gen_server callbacks
-export([start_link/0,init/1, handle_call/3, handle_cast/2, handle_info/2, 
		 terminate/2, code_change/3]).
-export([is_online/1, sync_is_online/1, is_list_online/1, set_online/1, set_offline/1,
		 get_send_pid_by_name/1, get_send_pid_by_roleid/1, get_pid_by_roleid/1, 
		 get_online_send_pid_list/0, get_online_roleid_list/0,get_onlinecnt/0,
         get_online_pid_list/0,send_to_all_online/1,
		 update/3,role_terminate/1, get_pidlist_by_roleidlist/1,
		init_log_sql/0]).

-record(state, {}).

init_log_sql() ->
    {ok, [
          [?MODULE, log_ref, 4, "INSERT INTO log_ref(gd_roleid,log_pid,log_send_pid,log_socket,log_battle,log_time) VALUES
			('~p','~p','~p','~p','~p',NOW()	);"]
		 ]}.

%% ====================================================================
%% External functions
%% ====================================================================
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% 该角色是否在线
%% @param RoleId 角色Id
%% @return {true, pid} 在线
%% 		   false 不在线 
is_online(RoleId) ->
    Reply =  case ets:lookup(?ETS_ONLINE, RoleId) of
				 [] ->    {false};
				 [Role] -> {true, Role#ets_online.pid}
			 end,
	Reply.

%%同步检测玩家是否在线，用于对同步性要求较高，如上线时检测顶号，防止重复登陆的场合
%% @return {true, pid} 在线
%% 		   false 不在线 
sync_is_online(RoleId)->
	gen_server:call(?MODULE, {sync_is_online, RoleId}).

%% 该列表所有角色在线状态
%% @param RoleId 角色Id
%% @return [0] 在线
%% 		   [1] 不在线 
is_list_online(RoleIdList) ->
	ReplyList = online_status_list(RoleIdList, []),
	ReplyList.

%% 设置角色在线
%% @param 	RoleId：角色id
%%			RoleName:角色名
%%			AccId：账号Id
%%			Account:账号名
set_online([RoleId,RoleName,AccId, Account])->
	gen_server:cast(?MODULE, {set_online, RoleId,RoleName,AccId, Account}).

%% 设置角色离线
%% @param 	RoleId：角色id
%%			RoleName:角色名
set_offline(RoleId) ->
	gen_server:cast(?MODULE, {set_offline, RoleId}).

%% 根据角色名获取其发送pid
%% @param 	RoleName:角色名
%% return	{true,pid}|{false}.
get_send_pid_by_name(RoleName) ->
	case ets:lookup(?ETS_NAME_ID_MAP, RoleName) of
		[]->{false};%%账号未登录
		[R] -> %% 账号已登录
			case ets:lookup(?ETS_ONLINE, R#ets_name_id_map.roleid) of
				[] -> {false};
				[R2] -> {true, R2#ets_online.send_pid}
			end
	end.

%% 根据角色id获取其发送pid
%% @param 	RoleId:角色ID
%% return	{true,pid}|{false}.
get_send_pid_by_roleid(RoleId)->
	case ets:lookup(?ETS_ONLINE, RoleId) of
		[] -> {false};
		[R] -> {true, R#ets_online.send_pid}
	end.

%% 根据角色id获取其pid
%% @param 	RoleId:角色ID
%% return	{true, pid} | {false}.
get_pid_by_roleid(RoleId)->
	case ets:lookup(?ETS_ONLINE, RoleId) of
		[] -> 
			{false};
		[R] -> 
			{true, R#ets_online.pid}
	end.

%% 根据角色id获取其pid
%% @param 	RoleIdList:角色ID
%% return	{true, roleid, pid} | {false, roleid}.
get_pidlist_by_roleidlist(RoleIdList) ->
	Fun = fun(RoleId) ->
		case ets:lookup(?ETS_ONLINE, RoleId) of
			[] ->
				{false, RoleId};
			[R] ->
				{true, RoleId, R#ets_online.pid}
		end
	end,
	L = [Fun(X) || X <- RoleIdList],
	L.

%% 获取所有在线玩家的发送pid
%% return	List[Send_Pids]
get_online_send_pid_list()->
	L = ets:match(?ETS_ONLINE, #ets_online{send_pid='$1', _='_'}),
	L2 = lists:flatten(L),
	L2.

%% 获取所有在线玩家的roleid
%% return	List[RoleIds]
get_online_roleid_list()->
	L = ets:match(?ETS_ONLINE, #ets_online{roleid = '$1', _ = '_'}),
	L2 = lists:flatten(L),
	L2.

%% 获取所有在线玩家的pid
%% return   List[Pids]
get_online_pid_list() ->
    L = ets:match(?ETS_ONLINE, #ets_online{pid = '$1', _ = '_'}),
    L2 = lists:flatten(L),
    L2.

%%获取当前在线人数
%%return Value:integer
get_onlinecnt()->
	Value = ets:info(?ETS_ONLINE, size),
	Value.

%%给所有在线玩家发送一个消息
send_to_all_online(Msg)->
    L = get_online_pid_list(),
    [gen_server:cast(XPid, Msg) || XPid <- L],
    ok.

update(RoleId, ValueList,Reason)->
	gen_server:cast(?MODULE, {update, RoleId, ValueList, Reason}).

role_terminate(RoleId)->
	gen_server:cast(?MODULE, {role_terminate, RoleId}).
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
init([]) ->
	init_ets(),
    {ok, #state{}}.

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
%% 查询该角色是否在线
%% @param RoleId 角色Id
%% @return {true, pid} 在线
%% 		   false 不在线
handle_call(Cmd, From, State)->
	try 
		Reply = do_call(Cmd, From, State),
		Reply
	catch
		ExType:ExPattern ->
		?ERR("ExType: ~p, ExPattern: ~p",[ExType,ExPattern]),
		?ERR("StackTrace:~p",[erlang:get_stacktrace()]),
		{reply, {error}, State}
	end.

do_call({sync_is_online, RoleId}, _From, State)->
    Reply =  case ets:lookup(?ETS_ONLINE, RoleId) of
				 [] ->    {false};
				 [Role] -> {true, Role#ets_online.pid}
			 end,
	{reply, Reply, State}.

%% 查询好友id列表里所有好友的在线状态
%% @param RoleIdList 角色Id列表；List 构造列表，为空列表，接收输出结果 
%% @return List 好友在线状态列表
online_status_list([], List) ->
	List;
online_status_list(RoleIdList, List) ->
	[RoleId | Tail] = RoleIdList,
	ResultList = case RoleId of
					0 -> [0];
					_ ->
						case ets:lookup(?ETS_ONLINE, RoleId) of
							[] -> [1];
							[_Role] -> [0]
				 		end
				end,
	ReplyList = List ++ ResultList,
	online_status_list(Tail, ReplyList).


%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(Msg, State)->
	try
		Ret = do_cast(Msg,State),
		Ret
	catch 
		ExType:ExPattern ->
			?ERR("ExType: ~p, ExPattern: ~p",[ExType,ExPattern]),
			?ERR("StackTrace:~p",[erlang:get_stacktrace()]),
			{noreply, State}
	end.

%% 设置角色在线
%% @param 	RoleId：角色id
%%			RoleName:角色名
%%			AccountId：账号Id
%%			Account：账号名
do_cast({set_online, RoleId, RoleName, AccountId, Account},State)->
	case ets:lookup(?ETS_ONLINE, RoleId) of
		[] -> %%online表中无记录
				ets:insert(?ETS_NAME_ID_MAP, #ets_name_id_map{rolename = RoleName,roleid = RoleId}),%%加入角色名字-id对应表
				ets:insert(?ETS_ONLINE, #ets_online{roleid = RoleId, rolename = RoleName, account = Account, accountid = AccountId});	%%加入ONLINE表
		_ -> %% 表中已有记录，则不处理
				ok
		end,
	log(RoleId),
	{noreply, State};
			
%% 角色进程结束，直接从ets中删除
%% @param 	RoleId：角色id
do_cast({role_terminate, RoleId},State)->
	do_role_terminate(RoleId),
	{noreply, State};

%%更新在线信息
%%ValueList：[{Key,Value}] - Key:send_pid, pid, 
do_cast({update, RoleId, ValueList, Reason}, State)->
	R = ets:lookup(?ETS_ONLINE, RoleId),
	case R of
		[OnlineInfo]-> OnlineInfo2 = update_elem(OnlineInfo, ValueList),
					   case ((OnlineInfo2#ets_online.socket =:= undefined)
						   and (OnlineInfo2#ets_online.battle =:= undefined)
							and (Reason =/= login)) of
						   true -> %%socket断开，且不在战斗中，则通知role进程结束
								case OnlineInfo2#ets_online.pid of
									undefined ->
										io:format("~n~n~n11111111111111~n~n", []),
										do_role_terminate(OnlineInfo2#ets_online.roleid);
									_->	
										io:format("~n~n~n22222222222222~n~n", []),
										mod_role:dispose(OnlineInfo2#ets_online.pid, Reason)
								end;
						   false ->
							   io:format("~n~n~n33333333333333333~n~n", []),
							   ets:insert(?ETS_ONLINE, OnlineInfo2),
							   log(RoleId)
					   end;
		[]->ok
	end,
	{noreply, State}.
		
		
%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
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

%%初始化账号管理ETS表
init_ets() ->
	ets:new(?ETS_ONLINE,[public, named_table, set, {keypos, #ets_online.roleid}]),%%在线账号列表
	ets:new(?ETS_NAME_ID_MAP, [public, named_table, set, {keypos, #ets_name_id_map.rolename}]).%%角色姓名-角色ID对应表


update_elem(OnlineInfo, [{pid, Pid}|Elem2])->
	OnlineInfo2 = OnlineInfo#ets_online{pid = Pid},
	update_elem(OnlineInfo2, Elem2);

update_elem(OnlineInfo, [{send_pid, Send_Pid}|Elem2])->
	OnlineInfo2 = OnlineInfo#ets_online{send_pid = Send_Pid},
	update_elem(OnlineInfo2, Elem2);

update_elem(OnlineInfo, [{socket, Socket}|Elem2])->
	OnlineInfo2 = OnlineInfo#ets_online{socket = Socket},
	update_elem(OnlineInfo2, Elem2);

update_elem(OnlineInfo, [{battle, Battle}|Elem2])->
	OnlineInfo2 = OnlineInfo#ets_online{battle = Battle},
	update_elem(OnlineInfo2, Elem2);

update_elem(OnlineInfo, [])->
	OnlineInfo.

log(RoleId)->
	case ets:lookup(?ETS_ONLINE, RoleId) of
		[R] -> ?DBLOG(?MODULE, log_ref,[RoleId,R#ets_online.pid,R#ets_online.send_pid,R#ets_online.socket,R#ets_online.battle]);
		[] -> ?DBLOG(?MODULE, log_ref,[RoleId,0,0,0,0])
			  end.

do_role_terminate(RoleId)->
	R = ets:lookup(?ETS_ONLINE, RoleId),
	case R of
		[RoleOnline]-> ets:delete(?ETS_ONLINE, RoleId),%%删除记录，
			 		ets:delete(?ETS_NAME_ID_MAP,RoleOnline#ets_online.rolename);%%删除角色名字-id对应表
		[]->ok
	end,
	log(RoleId).

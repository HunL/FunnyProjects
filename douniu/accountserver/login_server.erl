%%% -------------------------------------------------------------------
%%% Author  : liaoxiaobo
%%% Description : 登录模块
%%% 记录已创建帐号 包括 ets:insert(?ETS_ACCOUNT,Val) Val #account
%%% Created : 2011-11-4
%%% -------------------------------------------------------------------
-module(login_server).
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common.hrl").
-include("record.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%这里维护三张表
%ets_account: #accountinfo,以账号名为键，记录了账号id，以及名下的角色id
%ets_rolename:{RoleName,RoleId},以角色名为键，记录对应的角色id
%ets_rolebase:#mhrolebaseinfo,已角色id为键，记录角色基础信息

%% ====================================================================
%% External functions
%% ====================================================================

start_link() ->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: 初始化
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	init_account_info(),
	init_role_name(),
	%% 初始化完成之后给gameserver发送开始启动的命令
	{ok,{}}.

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
%% 获取帐号信息
%% @param Account 帐号
%% @return {true,AccountId,[#mhrolebaseinfo]} 已经注册帐号 AccountId,账号所创建的角色列表
%% 		   {no_account} 没有注册帐号 
%%
handle_call(Msg, From, State)->
	Res = do_call(Msg, From, State),
	Res.

do_call({get_account,Account},_From,State) ->
	case ets:lookup(?ETS_MHACCOUNT,Account) of
		[] -> %% 不存在
			{reply, {no_account} , State};
		Ets_AccountList -> 
			RoleIdList = [Ets_Account#accountinfo.roleid||Ets_Account<-Ets_AccountList],
			%%获取账号所创建的角色列表
			RoleBaseList = get_base_info_by_roleid_list(RoleIdList),
			Ets_Account1 = lists:nth(1, Ets_AccountList),
			{reply, {true,Ets_Account1#accountinfo.accountid,RoleBaseList}, State}
	end;

%% 注册帐号
%% @param Account 帐号 AccountName 角色名称
%% @return {true,#mhrolebaseinfo} 注册完成
%% 		   {false ,role_exist} 角色名称已经存在
%%		   {false ,account_exist}帐号已经存在
%%			{false, already_bind}账号已绑定角色
do_call({register_role,Account,RoleName,Sex,Career},_From,State) ->
	case ets:lookup(?ETS_MHROLE_NAME, RoleName) of
		[] -> %% 角色名不冲突
			case get_account_id(Account) of
				false ->%%账号不存在,则分配新账号ID
						{ok,NewAccountId} = game_id:get_new_accountId(),
						{ok,RoleId} = game_id:get_new_roleId(),%%分配角色ID
						ets:insert(?ETS_MHACCOUNT,#accountinfo{account=Account,accountid=NewAccountId,roleid=RoleId}),%%加入账号列表
						ets:insert(?ETS_MHROLE_NAME, {RoleName,RoleId}),%%加入角色名列表
						RoleBaseInfo = #mhrolebaseinfo{accountid=NewAccountId,account=Account,roleid=RoleId,rolename=RoleName,sex=Sex,career=Career},
						ets:insert(?ETS_MHROLE_INFO,RoleBaseInfo),%%加入角色信息列表
						{reply, {true, RoleBaseInfo} , State};
				{true,_AccountInfo} ->  %%账号已存在
						{reply, {false, already_bind},State}
			end;
		_ -> %%角色名已被占用
			{reply, {false, role_name_exist}, State}
		end;

do_call({register_guest, AccnamePrefix},_From,State) ->
	{ok,AccountId} = game_id:get_new_accountId(),
	{ok,RoleId} = game_id:get_new_roleId(),%%分配角色ID
	Intlist = erlang:integer_to_list(AccountId),
	Len = length(Intlist),
	NewIntlist = lists:nthtail(Len - ?TOURIST_ACCOUNT_SUFFIX, Intlist),
	Account = AccnamePrefix ++ erlang:integer_to_list(list_to_integer(NewIntlist)),

	ets:insert(?ETS_MHACCOUNT,#accountinfo{account=Account,accountid=AccountId,roleid=RoleId}),%%加入账号列表
	?INFO("Alloc AccountId: ~p. ~n",[AccountId]),

	?INFO("Alloc RoleId: ~p. ~n",[RoleId]),				
	ets:insert(?ETS_MHROLE_NAME, {Account,RoleId}),%%加入角色名列表
	{Career} = lib_random:get_random_fr_weight_list_int([
%													  {?METAL, 1},
%													  {?WOOD, 1},
%													  {?WATER, 1},
%													  {?FIRE, 1},
%													  {?EARTH, 1}
													  {1, 1},
													  {2, 1},
													  {3, 1},
													  {4, 1},
													  {5, 1}
														]),
	{Sex} = lib_random:get_random_fr_weight_list_int([
													{?MALE, 1},
													{?FEMALE, 1} ]),
	RoleInfo = #mhrolebaseinfo{accountid=AccountId,roleid=RoleId,rolename=Account,sex=Sex,career=Career},
	ets:insert(?ETS_MHROLE_INFO,RoleInfo),%%加入角色信息列表
	{reply, {true, RoleInfo} , State};


%% 玩家选择登陆角色
%% @param AccountID 账号ID，RoleID 角色ID 
%% @return {true, #mhrolebaseinfo} 角色基本信息
%%			false 角色不存在
%% handle_call({select_role,AccountId,_RoleId},_From,State) ->
%% 	try
%% 		Result = case ets:lookup(?ETS_MHROLE_INFO,AccountId) of
%% 					[] -> false;
%% 					[RoleBaseInfo] -> {true,RoleBaseInfo}
%% 				end,
%% 		{reply, {Result}, State}
%% 	catch
%% 		_:_ ->
%% 			{reply, false, State}
%% 	end;

%% 根据玩家姓名获取玩家id
%% @param	rolename
%% @return	roleid
do_call({get_roleid_by_rolename, RoleName}, _From, State) ->
	try
		EtsRoleName = ets:lookup(?ETS_MHROLE_NAME, RoleName),
		case EtsRoleName of
			[] ->
				RoleId = [],
				?INFO("RoleId = ~w~n", [RoleId]),
				{reply, RoleId, State};
			[{_RoleName1, RoleId}] ->
				{reply, RoleId, State}
		end
	catch _:_ ->
		{reply, [], State}
	end;

%% 用roleid列表获取角色基本信息列表
do_call({get_base_info_by_roleid_list, RoleidList}, _From, State) ->
	try
		R = get_base_info_by_roleid_list(RoleidList),
		{reply, R, State}
	catch
		_:_ ->
			{reply, [], State}
	end.
		
handle_cast({poweroff}, State) ->
	init:stop(),
	{noreply,State};				

handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({'EXIT', _, Reason}, State) ->
	{stop, Reason, State};


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


%% --------------------------------------------------------------------
%% Function: init_account_info/0
%% Description: 初始化帐号列表
%% Returns: ok
%% --------------------------------------------------------------------
init_account_info() ->
	ets:new(?ETS_MHACCOUNT,[named_table,public,bag,{keypos,#accountinfo.account}]),
	%% 加载帐号信息
	F = fun([Account,AccountId,RoleId]) ->
			StrAccount = binary_to_list(Account),	
			ets:insert(?ETS_MHACCOUNT,#accountinfo{account=StrAccount,accountid=AccountId,roleid=RoleId})
		end,
	lists:foreach(F, db_sql:get_all("SELECT gd_account.gd_Account, gd_account.gd_AccountID,gd_role.gd_roleid 
						FROM gd_account, gd_role WHERE gd_account.gd_accountid=gd_role.gd_accountid")).

%% --------------------------------------------------------------------
%% Function: init_role_name/0
%% Description: 初始化角色信息与角色名称列表
%% Returns: ok
%% --------------------------------------------------------------------
init_role_name() ->
	ets:new(?ETS_MHROLE_NAME,[named_table,public,set]),
	ets:new(?ETS_MHROLE_INFO,[named_table,public,bag,{keypos,#mhrolebaseinfo.roleid}]),
	%% 加载角色信息
	F = fun([AccountId,Account,RoleId,Sex,Career,RoleName]) ->
			StrRoleName = binary_to_list(RoleName),
			%%加入角色名列表
			ets:insert(?ETS_MHROLE_NAME,{StrRoleName, RoleId}),
			%%加入角色信息列表
			ets:insert(?ETS_MHROLE_INFO, #mhrolebaseinfo{roleid=RoleId,accountid=AccountId,account = binary_to_list(Account),
				rolename=StrRoleName,sex=Sex,career=Career})
		end,
	lists:foreach(F, db_sql:get_all("SELECT gd_role.gd_AccountId,gd_account,gd_RoleId,gd_Sex,gd_career,gd_RoleName FROM gd_role,gd_account 
					WHERE gd_role.gd_accountid = gd_account.gd_accountid; ")).

%% --------------------------------------------------------------------
%% Function: get_account_id/0
%% Description: 获取账号ID
%% param Account 账号名 
%% Returns: {true,账号ID}
%%			false
%% --------------------------------------------------------------------
get_account_id(Account) ->
	case ets:lookup(?ETS_MHACCOUNT,Account) of
		[] -> false;%% 不存在
		[AccountInfo] -> {true,AccountInfo} 
	end.


get_base_info_by_roleid_list([]) ->
	[];
get_base_info_by_roleid_list([Roleid|Rest]) ->
	try
%%		[R] = ets:match_object(?ETS_MHROLE_INFO,#mhrolebaseinfo{roleid=Roleid,_='_'}),  %%match_object性能比较慢需要使用lookup,只暂用
 		[R] = ets:lookup(?ETS_MHROLE_INFO, Roleid),
		[R|get_base_info_by_roleid_list(Rest)]
	catch
		_:_ ->
			get_base_info_by_roleid_list(Rest)
	end.
			
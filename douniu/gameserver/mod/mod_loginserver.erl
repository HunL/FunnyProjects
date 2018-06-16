%% Author: LiuYaohua
%% Created: 2012-7-5
%% Description: LoginServer接口
-module(mod_loginserver).

%%
%% Include files
%%
-include("common.hrl").
-include("record.hrl").
%%
%% Exported Functions
%%
-export([get_account/1,register/4,select_role/2,get_roleid_by_rolename/1,
	 	get_base_info_by_roleid_list/1,safe_poweroff/0,
		 register_guest/1]).

%%
%% API Functions
%%

%% 获取帐号信息
%% @param Account 帐号
%% @return {true,AccountId,[#mhrolebaseinfo]} 已经注册帐号 AccountId,账号所创建的角色列表
%% 		   false 没有注册帐号 
get_account(Account)->
	gen_server:call(?MH_LOGIN_SERVER, {get_account, Account},?RPC_TIMEOUT).

	
	
%% 注册帐号
%% @param Account 帐号 AccountName 角色名称
%% @return {true,#mhrolebaseinfo} 注册完成
%% 		   {false ,role_exist} 角色名称已经存在
%%		   {false ,account_exist}帐号已经存在
%%			{false, already_bind}账号已绑定角色
register(Account,RoleName,Sex,Career)->
	gen_server:call(?MH_LOGIN_SERVER, {register_role, Account,RoleName,Sex,Career},?RPC_TIMEOUT).

%% 注册帐号
%% 无任何指定信息，系别、性别随机，帐号名与角色名与帐号相关
%% 当前用于游客模式
register_guest(AccnamePrefix) ->
	gen_server:call(?MH_LOGIN_SERVER,{register_guest, AccnamePrefix},?RPC_TIMEOUT).

%% 玩家选择登陆角色
%% @param AccountID 账号ID，RoleID 角色ID 
%% @return {true, #mhrolebaseinfo} 角色基本信息
%%			false 角色不存在
select_role(AccountId, RoleId) ->
	gen_server:call(?MH_LOGIN_SERVER,{select_role, AccountId,RoleId},?RPC_TIMEOUT).


%% 根据玩家姓名获取玩家id
%% @param   RoleName 角色姓名
%% @return	RoleId|[]   角色Id
get_roleid_by_rolename(RoleName) ->
	gen_server:call(?MH_LOGIN_SERVER,{get_roleid_by_rolename, RoleName}, ?RPC_TIMEOUT).


%%查询角色基本信息
%% @param Roleidlist 角色ID列表
%% @return 角色基本信息列表[#mhrolebaseinfo{}]|[]
get_base_info_by_roleid_list(Roleidlist) ->
	gen_server:call(?MH_LOGIN_SERVER, {get_base_info_by_roleid_list, Roleidlist}, ?RPC_TIMEOUT).

safe_poweroff() ->
	gen_server:cast(?MH_LOGIN_SERVER, {poweroff}).
%%
%% Local Functions
%%


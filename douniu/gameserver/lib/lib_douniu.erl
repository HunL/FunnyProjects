-module(lib_douniu).

%%
%% Include files
%%
-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").

%%
%% Exported Functions
%%
-export([load_db_role_by_id/2,insert_db_account_info/2,insert_db_role_info/1]).


%%
%% API Functions
%%


%%从数据库加载玩家角色信息
%% Param: RoleId 玩家角色ID
%% return: {false} 数据错误
%%			{true,#mhrole} 成功
load_db_role_by_id(AccountId,RoleId)->
	RoleSql = io_lib:format("SELECT gd_RoleId,gd_Sex,gd_career,gd_RoleName
		FROM gd_role where gd_RoleId = ~p;",[RoleId]),
	[RoleId,Sex,Career,RoleName]
		= db_sql:get_row(RoleSql),
		
	RoleInfo = #mhrole{accountid = AccountId, roleid = RoleId, rolename=binary_to_list(RoleName),sex=Sex,career=Career
		},
	{true,RoleInfo}.
	

%% 插入账号信息
%% Param: mhrole 角色信息
%% return: {ok} 成功
insert_db_account_info(AccountId,AccountName)->
	%%插入账号信息
	SqlAccount = db_sql:make_insert_sql("gd_account", 
										["gd_AccountId","gd_Account"], 
										[AccountId,AccountName]),
	mod_db_server:execute_one(0, SqlAccount),
	{ok}.


%% 插入角色信息
%% Param: mhrole 角色信息
%% return: {ok}
insert_db_role_info(RInf)->
	%%插入角色信息
	{Y, M, _} = date(),
	String = util:term_to_string({{Y, M}, []}),
	SqlRole = db_sql:make_insert_sql("gd_role", 
									 ["gd_AccountId","gd_RoleId","gd_Sex",
									  "gd_Career","gd_RoleName",
									  "gd_gold","gd_goldsum"],
									 [RInf#mhrole.accountid,
									  RInf#mhrole.roleid,
									  RInf#mhrole.sex,
									  RInf#mhrole.career,
									  RInf#mhrole.rolename,
									  RInf#mhrole.gold,
									  RInf#mhrole.goldsum]),

	%%时间SQL语句要另外写，因为db_sql:make_insert_sql函数无法封装函数
	SqlTime = "UPDATE gd_role SET gd_ActiveTime = NOW() WHERE gd_RoleId = " ++ integer_to_list(RInf#mhrole.roleid),
	mod_db_server:execute_one(0, SqlRole),
	mod_db_server:execute_one(0, SqlTime),
	
	{ok}.

get_role_name(RoleId) ->
    case mod_loginserver:get_base_info_by_roleid_list([RoleId]) of
        [] -> error;
        [#mhrolebaseinfo{rolename = RoleName}] ->
            RoleName
    end.





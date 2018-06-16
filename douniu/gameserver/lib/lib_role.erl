% Author: Administrator
%% Created: 2012-7-9
%% Description: TODO: Add description to lib_role
-module(lib_role).

%%
%% Include files
%%
-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").

%%
%% Exported Functions
%%
-export([load_db_role_by_id/2,insert_db_account_info/2,insert_db_role_info/1,save_offline_time/1,
		 update_login_time/1,update_economic/3,
		 update_exp_level_db/3]).

-export([get_login_time/1,get_logout_time/1,update_acc_online_time/2,
		get_last_acc_time/1,get_last_acc_off_time/1,update_acc_offline_time/2,
		replace_acc_online_and_offline_time/3]).

-export([update_gold_to_db/3]).

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
%									  "gd_Bag","gd_pet_items",
%									  "gd_sign_in",
%									  "gd_role_type"], 
									 [RInf#mhrole.accountid,
									  RInf#mhrole.roleid,
									  RInf#mhrole.sex,
									  RInf#mhrole.career,
									  RInf#mhrole.rolename,
									  RInf#mhrole.gold,
									  RInf#mhrole.goldsum]),
%									  RInf#mhrole.bag,
%									  RInf#mhrole.pet_items,
%									  String,
%									  RInf#mhrole.role_type]),
	%%时间SQL语句要另外写，因为db_sql:make_insert_sql函数无法封装函数
	SqlTime = "UPDATE gd_role SET gd_ActiveTime = NOW() WHERE gd_RoleId = " ++ integer_to_list(RInf#mhrole.roleid),
	mod_db_server:execute_one(0, SqlRole),
	mod_db_server:execute_one(0, SqlTime),
	
	%%插入otherinfo
%	Other_Sql = io_lib:format("insert into gd_role_otherinfo 
%								(gd_roleId,gd_hang_up,
%								gd_chip,gd_mine_0,gd_mine_1,gd_mine_2,gd_mine_type,gd_avatarid,gd_weaponavatar)
%								values (~p,~p,~p,~p,~p,~p,~p,~p,~p);", 
%								 [RInf#mhrole.roleid,?HANG_UP_RESET_NUM,0,0,0,0,?MINE_0, RInf#mhrole.avatarid, RInf#mhrole.weaponavatar]),
%	mod_db_server:execute_one(0, Other_Sql),
	
	{ok}.

get_role_name(RoleId) ->
    case mod_loginserver:get_base_info_by_roleid_list([RoleId]) of
        [] -> error;
        [#mhrolebaseinfo{rolename = RoleName}] ->
            RoleName
    end.

save_offline_time(RoleId)->
	Sql = "UPDATE gd_role SET gd_LastLogoutTime = NOW() WHERE gd_RoleId = " ++ integer_to_list(RoleId),
	mod_db_server:execute_one(0, Sql).

%%
update_login_time(RoleId)->
	SqlTime = "UPDATE gd_role SET gd_LastLoginTime = NOW() WHERE gd_RoleId = " ++ integer_to_list(RoleId),
	mod_db_server:execute_one(0, SqlTime).

%%更新经济数值
%%Param Type atom()-> 经济类型:gold/silver/goldcoin/silvercoin
%%Param Value interger()->变动值
update_economic(RoleId, Type, Value)->
	Sql = db_sql:make_update_sql("gd_role", ["gd_" ++ atom_to_list(Type)], [Value], "gd_roleid", RoleId),
	mod_db_server:execute_one(0, Sql).

%%更新玩家类型
update_role_type(RoleId, RoleType) ->
    Sql = db_sql:make_update_sql(gd_role, ["gd_role_type"],[RoleType], "gd_roleid", RoleId),
    mod_db_server:execute_one(0, Sql).

%更新玩家vip剩余时间
updata_vip_time(RoleId, Time, Type) ->
    Sql = db_sql:make_update_sql(gd_role, ["gd_vip_time"], 
                                [Time], "gd_roleid", RoleId),
    Sql2 = db_sql:make_update_sql("gd_role_otherinfo", ["gd_vip_type"], 
                                    [Type], "gd_roleid", RoleId),
    mod_db_server:execute_one(0, Sql),
    mod_db_server:execute_one(0, Sql2).

	

%%更新数据库角色经验与等级
update_exp_level_db(RoleId, Exp, Level)->
	Sql = db_sql:make_update_sql(gd_role, 
								 ["gd_exp","gd_level"], 
								 [Exp,Level], 
								 "gd_roleid", RoleId),
	mod_db_server:execute_one(0, Sql).

%% 更新战绩值
update_zhan_ji_to_db(RoleId,Value) ->
	Sql = db_sql:make_update_sql(gd_role_otherinfo, ["gd_zhan_ji"], [Value],"gd_roleid", RoleId),
	mod_db_server:execute_one(0, Sql).

%% 更新战绩值
update_gold_to_db(RoleId, Gold, GoldSum) ->
%	Sql = db_sql:make_update_sql(gd_role, 
%								 ["gd_gold, gd_gold_sum"], [Gold, GoldSum],
%								 "gd_roleid", RoleId),
	Sql = io_lib:format("update gd_role set gd_gold = ~p, gd_goldsum = ~p where gd_roleid = ~p", 
						[Gold, GoldSum, RoleId]),
	?INFO("~n~nSql=~p~n~n~n", [Sql]),
	mod_db_server:execute_one(0, Sql).

%% 取登录时间
%% @param RoleId 玩家角色ID
get_login_time(RoleId) ->
	Sql = io_lib:format("SELECT gd_lastlogintime FROM gd_role 
                         where gd_roleid = ~p;", [RoleId]),
    db_sql:get_row(Sql).

%% 取下线时间
%% @param RoleId 玩家角色ID
get_logout_time(RoleId) ->
	Sql = io_lib:format("SELECT gd_lastlogouttime FROM gd_role 
						 where gd_roleid = ~p;", [RoleId]),
    db_sql:get_row(Sql).

%% 取给定玩家之前的累积在线时间
%% @param RoleId 给定玩家的ID
%% @return [Time] 该玩家之前的累积在线时间
get_last_acc_time(RoleId) ->
	Sql = io_lib:format("SELECT gd_acc_online_time FROM gd_acc_online_time 
						 where gd_roleid = ~p;", [RoleId]),
	db_sql:get_row(Sql).

%% 取之前的累积离线时间
%% @param RoleId 玩家角色ID
get_last_acc_off_time(RoleId) ->
	Sql = io_lib:format("SELECT gd_acc_offline_time FROM gd_acc_online_time 
						 where gd_roleid = ~p;", [RoleId]),
    db_sql:get_row(Sql).

%% 更新在线时间
%% @param RoleId 玩家角色ID
%%        AccTime 累积在线时间
update_acc_online_time(RoleId, AccTime) ->
	UpdateSql = db_sql:make_update_sql(gd_acc_online_time, 
									   ["gd_acc_online_time"], [AccTime], 
                           				"gd_roleid", RoleId),
    mod_db_server:execute_one(0, UpdateSql).

%% 更新离线时间
%% @param RoleId 玩家角色ID
%%        AccTime 累积离线时间
update_acc_offline_time(RoleId, AccTime) ->
	UpdateSql = db_sql:make_update_sql(gd_acc_online_time, 
									   ["gd_acc_offline_time"], [AccTime], 
                           			    "gd_roleid", RoleId),
	mod_db_server:execute_one(0, UpdateSql).

%% 插入累积在线时间和累积离线时间
%% @param RoleId 玩家角色ID
%%        OnlineAccTime  累积在线时间
%%        OffLineAccTime 累积离线时间
replace_acc_online_and_offline_time(RoleId, OnlineAccTime, OffLineAccTime) ->
	ReplaceSql = db_sql:make_replace_sql(gd_acc_online_time, 
					["gd_roleid", "gd_acc_online_time", "gd_acc_offline_time"],
 					[RoleId, OnlineAccTime, OffLineAccTime]),
	mod_db_server:execute_one(0, ReplaceSql).


do_check_money(RoleInfo) ->
%    Boundary = cfg_boundary:get_cfg_boundary(RoleInfo#mhrole.boundary),
    Boundary = 1,
%    MoneyBoundary = Boundary#cfg_boundary.cfg_money,
    MoneyBoundary = 1,
    {A, G} = ?IF(MoneyBoundary < RoleInfo#mhrole.gold, 
            {1, MoneyBoundary}, 
            {0, RoleInfo#mhrole.gold}),
    %%需求修改,去掉了金币的上限
    B = 0,
    % {B, GC} = ?IF(MoneyBoundary < RoleInfo#mhrole.goldcoin, 
    %         {1, MoneyBoundary}, 
    %         {0, RoleInfo#mhrole.goldcoin}),
    {C, S} = ?IF(MoneyBoundary < RoleInfo#mhrole.silver, 
            {1, MoneyBoundary}, 
            {0, RoleInfo#mhrole.silver}),
    {D, SC} = ?IF(MoneyBoundary < RoleInfo#mhrole.silvercoin, 
            {1, MoneyBoundary},
            {0, RoleInfo#mhrole.silvercoin}),
    case {A, B, C, D} of
        {0, 0, 0, 0} ->
            RoleInfo;
        _ ->
            update_economic(RoleInfo#mhrole.roleid, gold, G),
            update_economic(RoleInfo#mhrole.roleid, silver, S),
            % update_economic(RoleInfo#mhrole.roleid, goldcoin, GC),
            update_economic(RoleInfo#mhrole.roleid, silvercoin, SC),
            RoleInfo#mhrole{gold = G, 
                            silver = S,
                            % goldcoin = GC,
                            silvercoin = SC}
    end.

do_check_money_by_boundary(RoleInfo) ->
%    Boundary = cfg_boundary:get_cfg_boundary(RoleInfo#mhrole.boundary),
    Boundary = 1,
%    MoneyBoundary = Boundary#cfg_boundary.cfg_money,
    MoneyBoundary = 1,
    A = ?IF(MoneyBoundary =< RoleInfo#mhrole.gold, 
            0, 
            1),
    B = ?IF(MoneyBoundary =< RoleInfo#mhrole.goldcoin, 
            0, 
            1),
    C = ?IF(MoneyBoundary =< RoleInfo#mhrole.silver, 
            0, 
            1),
    D = ?IF(MoneyBoundary =< RoleInfo#mhrole.silvercoin, 
            0, 
            1),
    case {A, B, C, D} of
        {0, 0, 0, 0} ->
            true;
        _ ->
            false 
    end.
    

%% 1.10~30级分身为该等级普通标准怪物4.0倍属性；
%% 2.31~50级分身为该等级普通标准怪物3.93倍属性；
%% 3.51~70级分身为该等级普通标准怪物3.87倍属性；
%% 4.71~80级分身为该等级普通标准怪物3.84倍属性；
%% 5.81~90级分身为该等级普通标准怪物3.8倍属性；
%% 6.91~100级分身为该等级普通标准怪物3.76倍属性；
%% 7.101~110级分身为该等级普通标准怪物3.73倍属性；
%% 8.111~120级分身为该等级普通标准怪物3.69倍属性
get_employee_param_A(Level) when Level =< 30 -> 4.0;
get_employee_param_A(Level) when Level =< 50 -> 3.93;
get_employee_param_A(Level) when Level =< 70 -> 3.87;
get_employee_param_A(Level) when Level =< 80 -> 3.84;
get_employee_param_A(Level) when Level =< 90 -> 3.8;
get_employee_param_A(Level) when Level =< 100 -> 3.76;
get_employee_param_A(Level) when Level =< 110 -> 3.73;
get_employee_param_A(Level) when Level =< 120 -> 3.69;
get_employee_param_A(_Level) -> 0.0.


	
s2c_err(ErrorCode) ->
	RoleInfo = mod_role:get_mhrole(),
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_ERR, ErrorCode),
	lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin),
	ok.	

s2c_err(ErrorCode, Roleid) ->
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_ERR, ErrorCode),
	lib_send:send_to_roleid(Roleid, Bin),
	ok.

s2c_err_pid(ErrorCode, Send_pid) ->
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_ERR, ErrorCode),
	lib_send:send_to_send_pid(Send_pid, Bin),
	ok.
	
s2c_err2(String) ->
	RoleInfo = mod_role:get_mhrole(),
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_ERR2, String),
	lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin),
	ok.	

s2c_err2(Roleid, String) ->
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_ERR2, String),
	lib_send:send_to_roleid(Roleid, Bin),
	ok.

s2c_err2_pid(RolePid, String) ->
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_ERR2, String),
	Mhrole = mod_role:get_roleinfo(RolePid, undefined),
    case is_record(Mhrole, mhrole) of
        true ->
	       lib_send:send_to_roleid(Mhrole#mhrole.roleid, Bin);
        false ->
            ok
    end,
	ok.

s2c_tip(RoleId,ShowType,TipId)->
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_TIP, {ShowType,TipId}),
	lib_send:send_to_roleid(RoleId, Bin).

%%向客户端发送有浮动提示
send_float_tips_pid(RolePid, String) ->
    s2c_err2_pid(RolePid, String).

send_float_tips(RoleId, String) ->
    s2c_err2(RoleId, String).

s2cinfo(SendPid, Msg) ->
	pp_chat:send_chat_info(SendPid, Msg).


update_last_ip(RoleId, Ip)->
	Sql = db_sql:make_update_sql(gd_role, ["gd_lastip"], [Ip], "gd_roleid", RoleId),
	mod_db_server:execute_one(0, Sql).

%更新累计充值元宝数
update_goldsum_and_gfslv(RoleId, GoldSum,Gfs_goldsum,Gfs_lv)->
	Sql = io_lib:format("update gd_role set gd_goldsum = ~p,gd_gfs_goldsum=~p,gd_gfs_lv=~p
							where gd_roleid = ~p",
						[GoldSum,Gfs_goldsum,Gfs_lv, RoleId]),
	mod_db_server:execute_one(0, Sql).



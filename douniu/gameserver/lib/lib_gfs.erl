%% Author: linchuansong
%% Created: 2013-6-6

%% Description: 高富帅 及 充值礼包

-module(lib_gfs).

%%
%% Include files
%% -include("record.hrl").
%% -include("log.hrl").
%% -include("proto.hrl").
%
-export([get_gfs_lv_by_goldsum/1,
		 get_gfs_lv_by_roleid/1, 
		 get_gfs_lv_list/1]).


%% 根据充值额计算gfs等级
%% return = Gfs_lv (当前充值额可达到的高富帅等级)
get_gfs_lv_by_goldsum(GoldSum) ->
	Gfs_list = cfg_gaofushuai_gift:get_cfg_gfs_info(),
	%% Gfs_list = [{格子ID，礼包ID，最少充值额，是否有宠物，gfs钻石等级 }]
	List = [Gfs_lv || {_Id,_ItemId,NeedCharge,_HavePet,Gfs_lv} <- Gfs_list,NeedCharge=<GoldSum],
	Gfs_lv = case List of
				 []->
					 0;
				 _ ->
				 	lists:max(List)
			end,
	Gfs_lv.

%% %% 根据充值额计算gfs可达最高档次信息
%% %% return = {格子ID，礼包ID，最少充值额，是否有宠物，gfs钻石等级 }
%% get_gfs_info_by_goldsum(GoldSum) ->
%% 	Gfs_list = cfg_gaofushuai_gift:get_cfg_gfs_info(),
%% 	%% Gfs_list = [{格子ID，礼包ID，最少充值额，是否有宠物，gfs钻石等级 }]
%% 	List = [{Id,NeedCharge} || {Id,_ItemId,NeedCharge,_HavePet,_Gfs_lv} <- Gfs_list,NeedCharge=<GoldSum],
%% 	Gfs_id = case List of
%% 				 []->
%% 					 0;
%% 				 _ ->
%% 				 	lists:max(List)
%% 			end,
%% 	ok.

%% 根据roleId 查 gfs钻石等级
get_gfs_lv_by_roleid(RoleId)->
	Sql1 = io_lib:format("Select gd_gfs_lv from gd_role where gd_roleid = ~p;",[RoleId]),
	[Gfs_lv] = db_sql:get_row(Sql1),
	Gfs_lv.

get_gfs_lv_list(RoleIdList)->
	String = lists:flatten((util:implode(",", RoleIdList))),
	Sql = io_lib:format("Select gd_gfs_lv from gd_role where gd_roleid IN (~s);",[String]),
	Res = db_sql:get_all(Sql),
	lists:flatten(Res).
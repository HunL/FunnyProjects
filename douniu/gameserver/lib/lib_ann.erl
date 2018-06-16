%% Author: Administrator
%% Created: 2013-8-14
%% Description: TODO: Add description to lib_ai
-module(lib_ann).
%% 公用模块代码 公告类

-include("common.hrl").

-include("cfg_record.hrl").
-include("record.hrl").


-export([
		 annonce_pet_egg/3
]).

%% 获得宠物蛋公告，使用RoleInfo
%% ModuleType = lottery(幸运轮盘抽奖)|gfs(高富帅)
annonce_pet_egg(RoleInfo, ItemId, ModuleType)->
	RoleName=RoleInfo#mhrole.rolename,
	%获取物品id
	CfgItem = cfg_item:get_cfg_item(ItemId),
	ItemName = CfgItem#rcd_item.cfg_itemname,
	%构造字符串
	CfgStr = cfg_string:get_string(get_egg_notice),
	ModuleName = 
		case ModuleType of
			lottery ->
				cfg_string:get_string(sys_name_lottery);
			gfs ->
				case RoleInfo#mhrole.sex of
					0 ->	%% 男
						cfg_string:get_string(sys_name_gfs_male);
					1 ->	%% 女
						cfg_string:get_string(sys_name_gfs_female)
				end
		end,
		Msg = io_lib:format(CfgStr,[RoleName, ModuleName,ItemName, ItemId]),
	lib_send:sys_announce(Msg),
	ok.

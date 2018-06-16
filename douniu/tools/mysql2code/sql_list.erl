%% Author: Austin
%% Created: 2012-12-11
%% Description: TODO: Add description to sql_list
-module(sql_list).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-compile(export_all).

%%
%% API Functions
%%


%%
%% Local Functions
%%
%% 确保SQL语句执行顺序

get_sql_list()->
	Sql_list = [
"TRUNCATE erl_cfg_code;",
%% cfg_object 表
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_object',CONCAT('get_cfg_object(',cfg_objid,')->#rcd_object{',
'cfg_objid =',		cfg_objid,
', cfg_name = \"',	cfg_name,
'\",cfg_Nature = ',cfg_Nature,
',cfg_stage = ',	cfg_stage,
',cfg_min_smart = ', cfg_min_smart,
',cfg_min_endurance = ', cfg_min_endurance,
',cfg_min_phy = ', cfg_min_phy,
',cfg_min_agile = ', cfg_min_agile,
',cfg_max_smart = ', cfg_max_smart,
',cfg_max_endurance = ', cfg_max_endurance,
',cfg_max_phy = ', cfg_max_phy,
',cfg_max_agile = ', cfg_max_agile,
',cfg_str_smart = ', cfg_str_smart,
',cfg_str_endurance = ', cfg_str_endurance,
',cfg_str_phy = ', cfg_str_phy,
',cfg_str_agile = ', cfg_str_agile,
',cfg_Avatarid = ',	cfg_Avatarid,
',cfg_itemId = ',	cfg_itemId,
',cfg_roleLv = ',	cfg_roleLv,
'};')
FROM cfg_object;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_object','get_cfg_object( _ ) -> {error}.' ;",
%% 传送点记录
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_transfer',CONCAT('get_cfg_transfer(',cfg_TransferID,')->#rcd_transfer{',
'cfg_TransferID =',	cfg_TransferID,
', cfg_FrMapID = ',	cfg_FrMapID,
',cfg_ToMapID = ',	cfg_ToMapID,
',cfg_ToPos = ',	cfg_ToPos,
',cfg_direction = ',	cfg_ToDirect,
'};')
FROM cfg_transfer;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_transfer','get_cfg_transfer( _ ) -> {error}.' ;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map',CONCAT('get_cfg_map(',cfg_MapId,')->#rcd_map{',
'cfg_MapId =',	cfg_MapId,
', cfg_Width = ',	cfg_Width,
',cfg_Height = ',	cfg_Height,
',cfg_MapType = ',	cfg_MapType,
',cfg_MapName = \"',	cfg_MapName,'\"',
',cfg_areaType = ',cfg_areaType,
',cfg_can_transfer_in = ',cfg_can_transfer_in,
',cfg_level = ',cfg_level,
',cfg_line_limit = ',cfg_line_limit,
',cfg_role_limit = ',cfg_role_limit,
'};')
FROM cfg_map;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map','get_cfg_map( _ ) -> {error}.' ;",

%% "地形配置"
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map',CONCAT('get_cfg_terrain(',cfg_MapId,')->\"',cfg_Terrain,'\";')
FROM cfg_map;
# get_cfg_map( _ ) -> {error};",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map','get_cfg_terrain( _ ) -> error.' ;",

%% 获取整个map id 列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map',CONCAT( 'get_cfg_map_idList()->[',GROUP_CONCAT(cfg_MapId),'].')
FROM cfg_map;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_item',CONCAT('get_cfg_item(',cfg_itemID,')->#rcd_item{',
'cfg_itemID =',		cfg_itemID,
',cfg_itemname = \"',    cfg_itemName,
'\", cfg_itemBigType = ',cfg_itemBigType,
',cfg_itemType = ',	cfg_itemType,
',cfg_effect = ',	cfg_effect,
',cfg_lastingType = ',	cfg_lastingType,
',cfg_lastingNum = ',	cfg_lastingNum,
',cfg_quality = ',	cfg_quality,
',cfg_stackType = ',	cfg_stackType,
',cfg_stackMax = ',	cfg_stackMax,
',cfg_Bind = ',	cfg_Bind,
',cfg_buySilver = ',	cfg_buySilver,
',cfg_SellSilver = ',	cfg_SellSilver,
',cfg_ItemLvl = ',	cfg_ItemLvl,
',cfg_LvMin = ',	cfg_LvMin,
',cfg_timeLimit = ',	cfg_timeLimit,
',cfg_IconID = ',	cfg_IconID,
',cfg_Destruction = ',	cfg_Destruction,
',cfg_useType = ',  cfg_useType,
',cfg_market_type = ',  cfg_market_type,
',cfg_vendue_type = ',  cfg_vendue_type,
',cfg_min_vendue_bid_price = ',  cfg_min_vendue_bid_price,
',cfg_min_vendue_price = ',  cfg_min_vendue_price,
'};')
FROM cfg_item;",

% get_cfg_map( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_item','get_cfg_item(_) -> {error}.' ;",

%% 静态npc的坐标


%%获取公共地图等级列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map', CONCAT('get_level_map()->','[',GROUP_CONCAT(
 CONCAT('{',cfg_level,',',cfg_MapId,'}')
),'].')
FROM cfg_map WHERE cfg_MapType=0 OR cfg_MapType=2;",

% 根据玲珑丹等级返回玲珑丹原型ID
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_item',CONCAT('get_lld_id_by_lv(',cfg_LvMin,')->',cfg_itemID ,';')
FROM cfg_item
WHERE cfg_itemType = 12;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_item','get_lld_id_by_lv(_) -> {error}.' ;",
%获取新手礼包列表
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_item',CONCAT('get_newer_gift()-> [',GROUP_CONCAT(cfg_itemID) ,'].')
FROM cfg_item WHERE cfg_itemType = 40;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip',CONCAT('get_cfg_equip(',a.cfg_itemID,')->#rcd_equip{',
'cfg_itemID =',	a.cfg_itemID,
',cfg_itemType =', b.cfg_itemType,
',cfg_level=', b.cfg_LvMin,
',cfg_white_attr=', a.cfg_white_attr,
',cfg_Career = ',	a.cfg_Career,
'};')
FROM cfg_equip a,cfg_item b
WHERE a.cfg_itemid = b.cfg_itemid;",
% get_cfg_equip( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip','get_cfg_equip( _ ) -> {error}.' ;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet',CONCAT('get_cfg_pet(',cfg_petId,')->#rcd_pet{',
'cfg_petid =',		cfg_petid,
', cfg_objectid = ',cfg_objectid,
', cfg_bloodid =  ',cfg_bloodId,
',cfg_petname = \"',	cfg_petname,
'\",cfg_skill = ',	cfg_skill,
',cfg_initskill = ',	cfg_initskill,
',cfg_initgift = ',	cfg_initgift,
',cfg_Avatarid = ',	cfg_Avatarid,
',cfg_icon = ',	cfg_icon,
',cfg_evolution = ',	cfg_evolution,
',cfg_devil_inside_id = ', cfg_devil_inside_id,
',cfg_evolve_npcid = ', cfg_evolve_npcid,
',cfg_vendue_type = ',  cfg_vendue_type,
',cfg_min_vendue_bid_price = ',  cfg_min_vendue_bid_price,
',cfg_min_vendue_price = ',  cfg_min_vendue_price,
',cfg_pet_orgid=', cfg_pet_original_id,
',cfg_att = ', cfg_evolve_add1,
',cfg_type = ', cfg_type,
'};')
FROM cfg_pet;",
% get_cfg_map( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet','get_cfg_pet(_) -> {error}.' ;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_exp',CONCAT('get_cfg_exp(',cfg_level,')->#rcd_exp{',
'cfg_level =',	cfg_level,
',cfg_exp =', cfg_exp,
'};')
FROM cfg_exp;",
% get_cfg_exp( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_exp','get_cfg_exp( _ ) -> {error}.' ;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_exp',CONCAT('get_cfg_pet_exp(',cfg_pet_level,')->#rcd_pet_exp{',
'cfg_pet_level =',	cfg_pet_level,
',cfg_pet_exp =', cfg_pet_exp,
'};')
FROM cfg_pet_exp;",
% get_cfg_pet_exp( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_exp','get_cfg_pet_exp( _ ) -> {error}.' ;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gold_island',CONCAT('get_cfg_gold_island(',cfg_level,')->#rcd_gold_island{',
'cfg_level = ',	cfg_level,
',cfg_mapid = ',	cfg_mapid,
',cfg_enter_point = ',	cfg_enter_point,
',cfg_next_point = ',	cfg_next_point,
',cfg_awards = ',	cfg_awards,
',cfg_monsterid = ',	cfg_monsterid,
'};')
FROM cfg_gold_island;",
% get_cfg_gold_island( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gold_island','get_cfg_gold_island( _ ) -> {error}.' ;",

%获取最大金银岛等级
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gold_island',CONCAT( 'get_max_level()->',MAX(cfg_level),'.')
FROM cfg_gold_island;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc',CONCAT('get_cfg_npc(',cfg_npcid,')->#rcd_npc{',
'cfg_npcid = ',		cfg_npcid,
',cfg_level = ',        cfg_level,
',cfg_color = ',		cfg_color,
',cfg_npcType = ',	cfg_npcType,
',cfg_npcBattle = ',	cfg_npcBattle,
',cfg_item = ',		cfg_item,
',cfg_NpcName = \"',		cfg_NpcName,
'\"',
',cfg_collect_time = ',  cfg_collectTime,
'};')
FROM cfg_npc;",
% get_cfg_npc( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc','get_cfg_npc( _ ) -> {error}.' ;",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%所有属性类型
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_attr', CONCAT('get_attr_list()->[',
GROUP_CONCAT(CONCAT('{',attr_type,',',attr_type_en,'}')),
    '].') 
from cfg_attr_type;",

%属性类型atom转为数字类型
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip',CONCAT('get_cfg_attr_type(',attr_type_en,')->',
attr_type,
';')
FROM cfg_attr_type;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip','get_cfg_attr_type(_)->{cfg_error}.';",

%装备洗炼星级概率
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_baptize', CONCAT('get_cfg_baptize_prob()->[', 
GROUP_CONCAT(CONCAT ('{',cfg_baptize_star, ',',cfg_baptize_star_rate, '}')),'].')
FROM cfg_baptize_star;",

%装备洗炼属性
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_baptize', CONCAT('get_cfg_baptize_attr(',cfg_equip_type,',',cfg_attr_type,',Star, Lv)->',
 cfg_attr_value,
';')
FROM cfg_baptize_attr;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_baptize','get_cfg_baptize_attr(_,_,_,_)->{error}.';",


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%装备强化攻击力计算公式erl_cfg_code

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen', CONCAT('get_cfg_strenthen_att(',cfg_equip_level,',',cfg_strenthen_level,')->',
        cfg_strenthen_att,';')
FROM cfg_strenthen_attr;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen','get_cfg_strenthen_att(_,_)->{error}.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%装备强化完美度正向概率

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen', CONCAT('get_cfg_strenthen_perfect(',cfg_strenthen_level,')->',
        cfg_probability,';')
FROM cfg_equip_strenthen;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen','get_cfg_strenthen_perfect(_)->{error}.';",

%强化时各装备部位灵气消耗系数

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen', CONCAT('get_cfg_smartgas_factor(',cfg_equip_type,')->',
        cfg_str_smartgas,';')
FROM cfg_equip_type;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen','get_cfg_smartgas_factor(_)->{error}.';",

%强化时灵气消耗
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen', CONCAT('get_cfg_strenthen_smartgas(',cfg_strenthen_level,')->',
        cfg_smartgas,';')
FROM cfg_equip_strenthen;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen','get_cfg_strenthen_smartgas(_)->{cfg_error}.';",

%全身强化加成
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen', CONCAT('get_cfg_strenthen_full(',cfg_strenthen_level,')->',
        cfg_full,';')
FROM cfg_equip_strenthen;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen','get_cfg_strenthen_full(_)->{cfg_error}.';",

%强化进程随机范围
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen', CONCAT('get_cfg_range(',cfg_strenthen_level,')->',
        cfg_range,';')
FROM cfg_equip_strenthen;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen','get_cfg_range(_)->{cfg_error}.';",


%%最大属性值 
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_attr_type', CONCAT('get_cfg_max_value(',attr_type_en,')->',cfg_max_value,';')
FROM cfg_attr_type;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_attr_type','get_cfg_max_value(_)->{cfg_error=0}.';",

%% 装备的套装可选属性列表
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_suit', CONCAT('get_cfg_attrlist(',cfg_nature,')->',cfg_suit_attr_type,';')
FROM cfg_nature;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_suit','get_cfg_attrlist(_)->{cfg_error=0}.';",

%%灵珠属性表类型
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_inlay', CONCAT('get_cfg_jewel_attr_type(',cfg_equip_type,',',cfg_jewel_type,')->',cfg_attr_type,';')
FROM cfg_equip_inlay;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_inlay','get_cfg_jewel_attr_type(_,_)->{cfg_error}.';",

%%灵珠属性值
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_inlay', CONCAT('get_cfg_jewel_attr(',cfg_equip_type,',', cfg_jewel_type,',N)->',cfg_attr,';')
FROM cfg_equip_inlay;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_inlay','get_cfg_jewel_attr(_,_,_)->{cfg_error}.';",

%装备等级对应的最大灵珠等级
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_inlay', CONCAT('get_cfg_max_jewel_lv(',cfg_equip_lv,')->',
        cfg_max_jewel_lv,';')
FROM cfg_equip_lv;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_inlay','get_cfg_max_jewel_lv(_)->{cfg_error}.';",

%装备等级对应的最大强化等级
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen', CONCAT('get_cfg_max_str_lv(',cfg_equip_lv,')->',
        cfg_max_str_lv,';')
FROM cfg_equip_lv;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_strenthen','get_cfg_max_str_lv(_)->{cfg_error}.';",


%%装备改造可选属性及权重
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_remake', CONCAT('get_cfg_remake(',cfg_equip_type,')->',cfg_remake,';')
FROM cfg_equip_type;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_remake','get_cfg_remake(_)->{cfg_error}.';",

%%通过装备类型，装备等级，装备职业来查询装备id
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip', CONCAT('get_cfg_equip_id(',cfg_itemtype,',', cfg_lvmin, ',', if(cfg_Career=0,'_',cfg_Career), ')->',cfg_item.cfg_itemid,';') 
FROM cfg_item, cfg_equip WHERE cfg_itemtype>=1 AND cfg_itemtype<=8 AND cfg_equip.cfg_itemid = cfg_item.cfg_itemid;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip','get_cfg_equip_id(_,_,_)->{cfg_error}.';",

%%装备极品属性预览洗炼属性类型
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_best', CONCAT('get_cfg_bap_attrtype(',cfg_equip_type,')->',cfg_best_bap,';')
FROM cfg_equip_type;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_best','get_cfg_bap_attrtype(_)->{cfg_error}.';",

%%装备极品属性预览灵珠类型
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_best', CONCAT('get_cfg_jewel_type(',cfg_equip_type,')->',cfg_best_inlay,';')
FROM cfg_equip_type;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_best','get_cfg_jewel_type(_)->{cfg_error}.';",

%%
%%合成系统
%%

%%合成材料 
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material', CONCAT('get_cfg_comp_material(',cfg_itemid,')->',cfg_material,';') 
FROM cfg_comp_material;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material','get_cfg_comp_material(_)->{cfg_error}.';",

%%合成成功率 
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material', CONCAT('get_cfg_comp_suc(',cfg_itemid,')->',cfg_succ_rate,';') 
FROM cfg_comp_material;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material','get_cfg_comp_suc(_)->{cfg_error}.';",


%%合成消耗仙气 
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material', CONCAT('get_cfg_comp_godgas(',cfg_itemid,')->',cfg_godgas,';') 
FROM cfg_comp_material;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material','get_cfg_comp_godgas(_)->{cfg_error}.';",

%%合成消耗银币
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material', CONCAT('get_cfg_comp_silvercoin(',cfg_itemid,')->',cfg_silvercoin,';') 
FROM cfg_comp_material;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_comp_material','get_cfg_comp_silvercoin(_)->{cfg_error}.';",

%
%
%%
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 宠物内丹售价等基本配置信息

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_item_base', CONCAT('get_cfg_pet_item_base(',cfg_color,', Lv)->#rcd_pet_itembase{',
'cfg_color = ',	cfg_color,
', cfg_price = ',	cfg_price,
', cfg_experience = ',  cfg_experience,
',cfg_upgrade = ',	cfg_upgrade,
'};')
FROM cfg_pet_item_base;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_item_base','get_cfg_pet_item_base(_,_)->{error}.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 宠物内丹配置信息

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_item', CONCAT('get_cfg_pet_item(',cfg_id,', Lv)->#rcd_pet_item{',
'cfg_id = ',	cfg_id,
', cfg_name = \"',	cfg_name,
'\",cfg_color = ',	cfg_color,
',cfg_effect = ',      cfg_effect,
',cfg_type = ',        cfg_type,
',cfg_grade = ',        cfg_petitemGrade,
'};')
FROM cfg_pet_item;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_item','get_cfg_pet_item(_,_)->{error}.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_taskstate', CONCAT('get_cfg_taskstate(',cfg_taskid,',',cfg_stateid,')->#rcd_taskstate{',
'cfg_taskid = ',	cfg_taskid,
',cfg_next_stateid = ',  cfg_next_stateid,
',cfg_stateid = ',	cfg_stateid,
',cfg_action = ',	cfg_action,
',cfg_object = ',	cfg_object,
',cfg_times = ',      cfg_times,
',cfg_info = ',        cfg_info,
',cfg_award = ',        cfg_award,
',cfg_resume = ',        cfg_resume,
',cfg_battledata = ',        cfg_battledata,
',cfg_batlledrop = ',        cfg_batlledrop,
',cfg_battletype = ',        cfg_battletype,
'};')
FROM cfg_taskstate;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_taskstate','get_cfg_taskstate(_,_)->{error}.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%任务链

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_taskchain', CONCAT('get_cfg_taskchain(',cfg_taskid,')->#rcd_taskchain{',
'cfg_taskid = ',	cfg_taskid,
', cfg_tasktype = ',	cfg_tasktype,
',cfg_pretask = ',	cfg_pretask,
',cfg_level = ',      	cfg_level,
',cfg_nexttask = ',       cfg_nexttask,
',cfg_award = ',        cfg_award,
'};')
FROM cfg_taskchain;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_taskchain','get_cfg_taskchain(_)->{error}.';",
"SET SESSION  group_concat_max_len = 99000;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_taskchain', CONCAT('get_first_branch()-> [',GROUP_CONCAT('#rcd_taskchain{',
'cfg_taskid = ',    cfg_taskid,
',cfg_pretask = ',  cfg_pretask,
',cfg_level = ',        cfg_level,
'}'),'].')
FROM cfg_taskchain WHERE cfg_pretask = -1 AND cfg_tasktype = 1;",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%技能信息

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill', CONCAT('get_cfg_skill(',cfg_skillID,',Slv)->#rcd_skill{',
'cfg_skillid = ',	cfg_skillID,
', cfg_skillname = \"',	cfg_skillName,
'\",cfg_objtype = ',	cfg_skillType,
',cfg_type = ', cfg_skillClassify,
',cfg_isactive = ',      	cfg_isActive,
',cfg_isremote = ',       cfg_isRemote,
',cfg_nature = ',        cfg_nature,
',cfg_petid = ',		cfg_petid,
',cfg_lvlimit = ',      	cfg_lvLimit,
',cfg_consumeqian = ',      	cfg_consumeQian,
',cfg_consumemp = ',       cfg_consumeMp,
',cfg_bufferid = ',      	cfg_bufferId,
',cfg_class = ',        cfg_class,
',cfg_num=', cfg_num,
',cfg_attackP = ', cfg_attackP,
',cfg_attackM = ', cfg_attackM,
',cfg_control = ', cfg_control,
',cfg_lastround=',cfg_assistLast,
',cfg_skillgrade=',cfg_skillgrade,
',cfg_ConversationID=',cfg_ConversationID,
'};')
FROM cfg_skill;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill','get_cfg_skill(_,_)->{error}.';",

%%快捷键关联
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_hotkey', CONCAT('get_cfg_hotkey(',cfg_hottype, ',', cfg_id,')->'
, cfg_hotkey, ';')
FROM cfg_hotkey",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_hotkey','get_cfg_hotkey(_,_)->{error}.';",


%%获取玩家职业技能列表

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill', CONCAT('get_cfg_skill_list(',cfg_nature,')->[',
GROUP_CONCAT(cfg_skillid),
'];')
FROM cfg_skill WHERE cfg_nature=1 AND cfg_skillType = 1;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill', CONCAT('get_cfg_skill_list(',cfg_nature,')->[',
GROUP_CONCAT(cfg_skillid),
'];')
FROM cfg_skill WHERE cfg_nature=2 AND cfg_skillType = 1;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill', CONCAT('get_cfg_skill_list(',cfg_nature,')->[',
GROUP_CONCAT(cfg_skillid),
'];')
FROM cfg_skill WHERE cfg_nature=3 AND cfg_skillType=1;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill', CONCAT('get_cfg_skill_list(',cfg_nature,')->[',
GROUP_CONCAT(cfg_skillid),
'];')
FROM cfg_skill WHERE cfg_nature=4 AND cfg_skillType = 1;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill', CONCAT('get_cfg_skill_list(',cfg_nature,')->[',
GROUP_CONCAT(cfg_skillid),
'];')
FROM cfg_skill WHERE cfg_nature=5 AND cfg_skillType=1;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skill', 'get_cfg_skill_list(_)->{error}.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%buff信息

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff', CONCAT('get_cfg_buff(',cfg_buffId,', Slv)->#rcd_buff{',
'cfg_buffId = ', cfg_buffId,
',cfg_buffType = ', cfg_buffType,
',cfg_per =(', cfg_per,
')/1000,cfg_num = ' ,cfg_num,
',cfg_debuff =', cfg_debuff,
'};')
FROM cfg_buff;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff','get_cfg_buff(_,_)->{error}.';",

%%buff叠加规则

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff', CONCAT('get_cover_buff_list(',cfg_buff_type,')->',
cfg_cover,';') FROM cfg_buff_type;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff','get_cover_buff_list(_)->[].';",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff', CONCAT('get_repeled_buff_list(',cfg_buff_type,')->',
cfg_repeled,';') FROM cfg_buff_type;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff','get_repeled_buff_list(_)->[].';",

%%按buff产生效果的时间点来分类
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff', CONCAT('get_buff_flag(',cfg_buff_type,')->',
cfg_flag,';') FROM cfg_buff_type;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_buff','get_buff_flag(_)->{error}.';",

%战斗过程中对象的特殊状态
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_spec_state', CONCAT('get_spec_state(',cfg_id,')->{',
    cfg_state_type,',',cfg_prob, ',',cfg_param,'};') FROM cfg_spec_state;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_spec_state','get_spec_state(_)->error.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Npc地图信息
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npcmapinfo', CONCAT('get_cfg_npcmapinfo(',cfg_ID,')->#rcd_npcmapinfo{',
'cfg_ID = ',		cfg_ID,
', cfg_mapid = ',	cfg_mapid,
',cfg_npcid = ',	cfg_npcid,
',cfg_npcpos = ',      	cfg_npcpos,
',cfg_direction = ',    cfg_direction,
'};')
FROM cfg_npcmapinfo;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npcmapinfo','get_cfg_npcmapinfo(_)->{error}.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%% npc挂载战斗配置信息
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_battle_npc' , CONCAT('get_cfg_battle_npc(',cfg_NpcId, ',', cfg_BattleType,', N) ->#rcd_battle_npc{',
'cfg_npcid = ', cfg_NpcId,
', cfg_battletype = ' , cfg_BattleType,
', cfg_guideId=', cfg_guideId,
', cfg_battle = ', cfg_battle,
', cfg_ai=', cfg_ai,
', cfg_promptId=', cfg_promptid,
'};')
FROM cfg_battle_npc;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_battle_npc','get_cfg_battle_npc(A,B,C) -> {error}.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%宠物捕捉
% cfg_pet_catch_suf
% cfg_pet_catch_pre
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_catch', CONCAT('get_cfg_pet_pre(',cfg_typy_id,')->#cfg_pet_pre{',
'typeid = ',cfg_typy_id,
',pre_name =\"', cfg_pre_name,
'\",append_spd =', cfg_spd,
',run_rate =', cfg_run_rate,
',run_succ_rate =', cfg_run_succ_rate,
',weight =', cfg_weight,
'};')
FROM cfg_pet_catch_pre;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_catch','get_cfg_pet_pre(_)->1=2.';",

%%%%%
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_catch', CONCAT('get_cfg_pet_suf(',cfg_typy_id,')->#cfg_pet_suf{',
'typeid = ',cfg_typy_id,
',suf_name =\"', cfg_suf_name,
'\",range =', cfg_range,
',color =\"', cfg_color,
'\",weight =', cfg_weight,
'};')
FROM cfg_pet_catch_suf;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_catch','get_cfg_pet_suf(_)->1=2.';",

%%%%%
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_catch',CONCAT('get_pet_catch_suf_weight()->[',GROUP_CONCAT(CONCAT('{',cfg_typy_id,', ',cfg_weight,'}')),'].')
FROM cfg_pet_catch_suf;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_catch',CONCAT('get_pet_catch_pre_weight()->[',GROUP_CONCAT(CONCAT('{',cfg_typy_id,', ',cfg_weight,'}')),'].')
FROM cfg_pet_catch_pre;",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 怪物修正测试表
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_monster_test', CONCAT('get_cfg_monster_configure(',cfg_id,',Lv)->#rcd_monster{',
'cfg_name = ',cfg_name,
',cfg_id =', cfg_id,
',cfg_color = ', cfg_color,
',cfg_avatarid =', cfg_avatarid,
',cfg_lv = Lv * ', cfg_lv,
',cfg_boundary =', cfg_boundary,
',cfg_hp = ',cfg_hp,
',cfg_nature =', cfg_nature,
',cfg_att =', cfg_att,
',cfg_def =', cfg_def,
',cfg_spd =', cfg_spd,
',cfg_crit = ',cfg_crit,
',cfg_hit=', cfg_hit,
',cfg_dodge =', cfg_dodge,
',cfg_combo =', cfg_combo,
',cfg_break =', cfg_break,
',cfg_resist = ',cfg_resist,
',cfg_counter = ', cfg_counter,
',cfg_dao =', cfg_dao,
',cfg_skill =', cfg_skill,
',cfg_ai =', cfg_ai,
',cfg_keep_body =', cfg_keep_body,
',cfg_type =', cfg_type,
',cfg_lv_correct = ', cfg_lv_correct,
'};')
FROM cfg_monster_test;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_monster_test','get_cfg_monster_configure(_,_)->{error}.';",

%%%
%% 师门商店物品表
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_school_item', CONCAT('get_cfg_school_item() -> [',
GROUP_CONCAT('{',cfg_moduleid, ',', cfg_grade, ',', cfg_career, '}'),
'].')
FROM cfg_school_item;",

%%师门晋升配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_school_grade' , CONCAT('get_cfg_school_grade(',cfg_grade,') ->#cfg_school_grade{',
'cfg_grade = ', cfg_grade,
', cfg_normal_lvl = ' , cfg_normal_lvl,
', cfg_spec_lvl = ', cfg_spec_lvl,
', cfg_spec_credit = ', cfg_spec_credit,
', cfg_grade_name = \"', cfg_grade_name,
'\"};')
FROM cfg_school_grade;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_school_grade','get_cfg_school_grade(_) ->error.';",
%%

%%宠物玄功升级时间
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_gift_lvup' , CONCAT('get_cfg_pet_gift_lvup(',cfg_class,',',cfg_lv,') ->#rcd_pet_gift_lvup{',
'cfg_class = ', cfg_class,
',cfg_cost = ', cfg_cost,
', cfg_lv = ' , cfg_lv,
', cfg_time = ', cfg_time,
'};')
FROM cfg_pet_gift_lvup;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_gift_lvup','get_cfg_pet_gift_lvup(_,_) -> error.';",

%%宠物血脉

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_blood' , CONCAT('get_cfg_blood(',cfg_bloodID,') ->#rcd_blood{',
'cfg_bloodid = ', cfg_bloodID,
', cfg_bloodtype= ' , cfg_bloodType,
', cfg_max = ', cfg_blood_max,
'};')
FROM cfg_blood;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_blood','get_cfg_blood(_) -> error.';",
%-----------------------------------
%%境界
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boundary' , CONCAT('get_cfg_boundary(',cfg_boundaryid,') ->#cfg_boundary{',
'cfg_boundaryid = ', cfg_boundaryid,
', cfg_daoheng= ' , cfg_daoheng,
', cfg_std_dao= ', cfg_std_dao,
', cfg_money= ' , cfg_money,
', cfg_dujie = ', cfg_dujie,
', cfg_level = ', cfg_level,
', cfg_next_boundaryid = ', cfg_next_boundaryid,
', cfg_k = ', cfg_k,
', cfg_num = ',		cfg_num,
'};')
FROM cfg_boundary;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boundary','get_cfg_boundary(_) -> error.';",
%-----------------------------------
%% 宠物师门商店
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_master_shop' , CONCAT('get_cfg_pet_goods(',cfg_npcid,') ->#cfg_pet_master_shop{',
'cfg_npcid = ', cfg_npcid,
', cfg_nature= ' , cfg_nature,
', cfg_skill_items = ', cfg_skill_items,
'};')
FROM cfg_pet_master_shop;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_master_shop','get_cfg_pet_goods(_) -> error.';",

%% -----------------------------------
%% #
%% /*宠物炼体产出规则*/
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_lianti' , CONCAT('get_cfg_pet_lianti(', cfg_type, ') -> ',
 cfg_percents,
 ';')
FROM cfg_pet_lianti;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_lianti','get_cfg_pet_lianti(_) -> error.';",

%-----------------------------------
%% 屏蔽词
"DROP TABLE IF EXISTS tb_word;",

"CREATE TABLE tb_word
    (
	t_first VARCHAR(32),
	t_word TEXT
    ) ;",

"INSERT INTO tb_word
    SELECT CAST(cfg_forbiddenword AS CHAR(1)) ,cfg_forbiddenword
	FROM cfg_forbiddenword;",

"UPDATE tb_word SET t_word = REPLACE(t_word,'\\\\','\\\\\\\\'),
t_first  = REPLACE(t_first,'\\\\','\\\\\\\\');",

"SET SESSION  group_concat_max_len = 99000;",
%
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_forbiddenword', CONCAT( 'get_hashed_word_list(\"',a.t_first,'\")->[\"',
GROUP_CONCAT(a.t_word SEPARATOR '\",\"'),'\"];')
FROM tb_word a
GROUP BY a.t_first;",
%
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_forbiddenword','get_hashed_word_list(_) -> undefined.';",

%%非法字符
"DROP TABLE IF EXISTS illegal_word;",

"CREATE TABLE illegal_word
    (
	t_first VARCHAR(32),
	t_word TEXT
    ) ;",
    
"INSERT INTO illegal_word
    SELECT CAST(cfg_illegalCharacter AS CHAR(1)) ,cfg_illegalCharacter
	FROM cfg_illegal_character;",

"UPDATE illegal_word SET t_word = REPLACE(t_word,'\\\\','\\\\\\\\'),
t_first  = REPLACE(t_first,'\\\\','\\\\\\\\');",

"SET SESSION  group_concat_max_len = 99000;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_illegal_character', CONCAT( 'get_illegal_character(\"',a.t_first,'\")->[\"',
GROUP_CONCAT(a.t_word SEPARATOR '\",\"'),'\"];')
FROM illegal_word a
GROUP BY a.t_first;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_illegal_character','get_illegal_character(_) -> undefined.';",

%-------------------
%% log.hrl
"DELETE FROM erl_log_code;",

"INSERT INTO  erl_log_code(erl_table,erl_colde)
SELECT 'log', CONCAT('-define(', tp_code, ', ' ,tp_type,  '). 		%%', tp_name)
FROM tp_item ORDER BY tp_type;",
%-----------------------------------
% 练功区装备掉落配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_battle_drop',CONCAT( 'get_battle_drop(',cfg_Level,')->',cfg_drop,';')
FROM cfg_battle_drop;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_battle_drop', 'get_battle_drop(_)->1=2.';",

%-----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%商城商品列表
% 获取整个map id 列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop', 
CONCAT('get_cfg_shop_list()->[', GROUP_CONCAT( CONCAT('[',cfg_shop_item,'\,',cfg_hot,',',cfg_price,',',cfg_shop_id,']') ) ,'].')
FROM cfg_shop order by cfg_orderby;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop_limit', 
CONCAT('get_cfg_shop_limit_list()->[', GROUP_CONCAT( CONCAT('[',cfg_itemid,'\,',cfg_groupid,',',cfg_looptype,',',cfg_time,',',cfg_oldprice,',',cfg_oldpricetype,',',cfg_price,',',cfg_pricetype,',',cfg_totalnum,',',cfg_limitnum,']') ) ,'].')
FROM cfg_shop_limit;",

%生成物品价格对应表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop',CONCAT( 'get_price(',cfg_shop_item,')->',cfg_price,';')
FROM cfg_shop;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop', 'get_price(_)->error.';",

%生成可以购买并使用的物品列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop',CONCAT( 'get_buy_and_use_list()-> [',GROUP_CONCAT(cfg_shop_item),'].')
FROM cfg_shop where cfg_shop_id < 6 and cfg_buy_and_use = 1;",

%生成可以购买并使用的使用后获得物品列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop', CONCAT('get_buy_use_get(', cfg_shop_item, ') ->{', cfg_use_get_item, ',',cfg_use_get_item_num, '};')
FROM cfg_shop where cfg_shop_id < 6 and cfg_use_get_item <> 0",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop', 'get_buy_use_get(Item) ->{Item,1}.'",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT DISTINCT 'cfg_shop', CONCAT('get_buy_use_get_use(', cfg_use_get_item, ') ->{', cfg_shop_item, ',',cfg_use_get_item_num, '};')
FROM cfg_shop WHERE cfg_shop_id < 6 AND cfg_use_get_item <> 0",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_shop', 'get_buy_use_get_use(Item) ->{Item,1}.'",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NPC商店商品列表
% 获取5个map id 列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_shop',
CONCAT('get_cfg_shop_list(',cfg_npc_shop_tag,')->[', 
GROUP_CONCAT(CONCAT('{',cfg_npc_shop_item,',',cfg_price,',',cfg_open_level,'}') 
ORDER BY cfg_orderby ASC) ,'];')  
FROM cfg_npc_shop GROUP BY cfg_npc_shop_tag;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_shop', 'get_cfg_shop_list(_)->error.';",

%生成物品价格对应表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_shop',CONCAT( 'get_price(',cfg_npc_shop_item,')->',cfg_price,';')
FROM cfg_npc_shop;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_shop', 'get_price(_)->error.';",

%生成物品NPC对应表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_shop',CONCAT( 'get_npcid(',cfg_npc_shop_item,')->',cfg_npc_id,';')
FROM cfg_npc_shop;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_shop', 'get_npcid(_)->error.';",

%师门任务配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_school' , 
CONCAT(
'get_cfg_task_school(',
cfg_sc_taskid,
'\,',
cfg_sc_task_stateid,
')->#cfg_task_school{',
'cfg_sc_taskid = ', cfg_sc_taskid,
', cfg_sc_task_stateid= ' , cfg_sc_task_stateid,
', cfg_sc_task_next= ' , cfg_sc_task_next,
', cfg_sc_action = ', cfg_sc_action,
', cfg_sc_object = ', cfg_sc_object,
', cfg_sc_object2 = ', cfg_sc_object2,
', cfg_sc_gather = ', cfg_sc_gather,
', cfg_sc_times = ', cfg_sc_times,
', cfg_sc_difficulty = ', cfg_sc_difficulty,
', cfg_sc_random = ', cfg_sc_random,
', cfg_sc_dig = ', cfg_sc_dig,
', cfg_sc_acc_dig = ', cfg_sc_acc_dig,
', cfg_sc_award = ', cfg_sc_award,
', cfg_sc_battle = ', cfg_sc_battle,
', cfg_sc_choice = ', cfg_sc_choice,
', cfg_sc_item = ', cfg_sc_item,
'};')
FROM cfg_task_school;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_school','get_cfg_task_school(_, _) -> error.';",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_school_quality', CONCAT('get_cfg_task_school_quality() -> ',
cfg_task_school_quality,'.') 
FROM cfg_task_school_quality;",

%师门任务难度配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_school_difficulty' , CONCAT('get_cfg_task_school_difficulty(Num) when Num =< ', cfg_num, ' -> lists:flatten(',
'[',
cfg_grade1,',',cfg_grade2,',',cfg_grade3,',',cfg_grade4,',',cfg_grade5,',',cfg_grade6,
']);')
FROM cfg_task_school_difficulty;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_school_difficulty','get_cfg_task_school_difficulty(_) -> error.';",
%--
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_task_school_difficulty' ,  CONCAT ( 'get_task_school_list()-> sets:to_list(sets:from_list([',
GROUP_CONCAT('{',cfg_sc_taskid,',',cfg_sc_difficulty,'}'),
'])).')
FROM cfg_task_school where cfg_sc_task_stateid = 1;",
%--------------------------
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_exp', CONCAT('get_cfg_task_school_exp(',cfg_school_grade, ', Num', ', Qua', ') ->round(',
cfg_school_exp, '* (math:pow(1.1, (Num-1))) * Qua);'
)
FROM cfg_task_school_exp;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_exp', 'get_cfg_task_school_exp(_, _, _) -> error.';",
%% -----宠物经验
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_exp', CONCAT('get_cfg_task_school_exp_pet(',cfg_school_grade, ', Num', ', Qua', ') ->round(',
cfg_school_exp_pet, '* (math:pow(1.1, (Num-1))) * Qua);'
)
FROM cfg_task_school_exp;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_exp', 'get_cfg_task_school_exp_pet(_, _, _) -> error.';",

%% 师门任务刷品质配置
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_rand', CONCAT('get_rand(',cfg_task_num,') -> ',
'{[{1,',cfg_white_rate,'},',
'{2,',cfg_blue_rate,'},',
'{3,',cfg_purple_rate,'},',
'{5,',cfg_gold_rate,'}],',
cfg_fee,'};'
)
FROM cfg_task_school_rand;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_rand', 'get_rand(_) -> error.';",

%--------------------------
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 10 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 10 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 20 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 20 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 30 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 30 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 40 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 40 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 50 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 50 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 60 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 60 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 70 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 70 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 80 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 80 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 90 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 90 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 100 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 100 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 110 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 110 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', CONCAT('get_cfg_task_school_equip(Lvl) when Lvl =< 120 -> [',
GROUP_CONCAT(cfg_itemId),
 '];'
)
FROM cfg_item WHERE cfg_itemBigType=0 AND cfg_LvMin <= 120 and 
(select count(1) from cfg_npc_shop where cfg_npc_shop_item=cfg_itemId)>0;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_equip', 'get_cfg_task_school_equip(_) -> [].';",

%%%%%%%%%%%师门贡献奖励
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_difficulty', CONCAT('get_cfg_task_school_contr(',cfg_sc_num,')  -> ',
cfg_sc_contribution,
 ';'
)
FROM cfg_task_school_contr ;",

"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_task_school_difficulty', 'get_cfg_task_school_contr(_) -> 0.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%刷道任务
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao' , CONCAT('get_cfg_task_dao(',cfg_dao_level,') ->#cfg_task_dao{',
'cfg_dao_taskid = ', cfg_dao_taskid,
', cfg_dao_object= ' , cfg_dao_object,
', cfg_dao_equip_lvl_award=', cfg_dao_equip_lvl_award,
', cfg_dao_equip_quality_rate=', cfg_dao_equip_quality_rate,
', cfg_dao_level=', cfg_dao_level,
', cfg_dao_battle_max_lvl=', cfg_dao_battle_max_lvl,
', cfg_dao_accnpc=', cfg_dao_accnpc, 
', cfg_dao_boundaryid=', cfg_boundaryid, 
', cfg_acc_need_coin=', cfg_acc_need_coin,
', cfg_function_id=', cfg_function_id,
', cfg_function_id2=', cfg_function_id2,
', cfg_accepte_notice=\"', cfg_accepte_notice,
'\"','};')
FROM cfg_task_dao;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao','get_cfg_task_dao(_) -> error.';",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao' , CONCAT('get_cfg_task_dao_npc(',cfg_dao_accnpc,') ->#cfg_task_dao{',
'cfg_dao_taskid = ', cfg_dao_taskid,
', cfg_dao_object= ' , cfg_dao_object,
', cfg_dao_equip_lvl_award=', cfg_dao_equip_lvl_award,
', cfg_dao_equip_quality_rate=', cfg_dao_equip_quality_rate,
', cfg_dao_level=', cfg_dao_level,
', cfg_dao_battle_max_lvl=', cfg_dao_battle_max_lvl,
', cfg_dao_accnpc=', cfg_dao_accnpc, 
', cfg_dao_boundaryid=', cfg_boundaryid,
', cfg_acc_need_coin=', cfg_acc_need_coin,
', cfg_function_id=', cfg_function_id,
', cfg_function_id2=', cfg_function_id2,
', cfg_accepte_notice=\"', cfg_accepte_notice,
'\"','};')
FROM cfg_task_dao;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao','get_cfg_task_dao_npc(_) -> error.';",

%% 
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao' , CONCAT('get_cfg_task_dao_id(',cfg_dao_taskid ,')->#cfg_task_dao{',
'cfg_dao_taskid = ', cfg_dao_taskid,
', cfg_dao_object= ' , cfg_dao_object,
', cfg_dao_equip_lvl_award=', cfg_dao_equip_lvl_award,
', cfg_dao_equip_quality_rate=', cfg_dao_equip_quality_rate,
', cfg_dao_level=', cfg_dao_level,
', cfg_dao_battle_max_lvl=', cfg_dao_battle_max_lvl,
', cfg_dao_boundaryid=', cfg_boundaryid,
', cfg_function_id=', cfg_function_id,
', cfg_function_id2=', cfg_function_id2,
', cfg_accepte_notice=\"', cfg_accepte_notice,
'\"','};')
FROM cfg_task_dao;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao','get_cfg_task_dao_id(_) -> error.';",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao' , CONCAT('get_cfg_task_dao_npc_by_monsterid(MonsterId)-> 
',
'    ObjectList =  [', GROUP_CONCAT('{',cfg_dao_object,',', cfg_dao_accnpc,'}'),'],
',
'    E = [ N || {L,N} <- ObjectList, lists:member(MonsterId, L)],
    case E of
        [] -> error; 
        [NpcId] -> NpcId 
    end',
'.')
FROM cfg_task_dao;",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%装备奖励
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(1)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 1 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(10)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 10 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(20)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 20 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(30)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 30 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(40)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 40 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(50)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 50 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(60)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 60 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(70)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 70 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(80)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 80 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(90)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 90 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(100)-> ',
'[', GROUP_CONCAT(cfg_itemId),'];'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 100 AND cfg_itemType < 5;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_equip_lvl' , CONCAT('get_cfg_equip_lvl(110)-> ',
'[', GROUP_CONCAT(cfg_itemId),'].'
)
FROM cfg_item WHERE cfg_itemBigType = 0 AND cfg_LvMin = 110 AND cfg_itemType < 5;",


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao' , CONCAT('get_cfg_task_dao_lvl_npc(',cfg_dao_accnpc,')-> ',
cfg_dao_level,
';')
FROM cfg_task_dao;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao','get_cfg_task_dao_lvl_npc(_) -> error.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao' , CONCAT('get_cfg_task_dao_boundary_npc(',cfg_dao_accnpc,')-> ',
cfg_boundaryid,
';')
FROM cfg_task_dao;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_task_dao','get_cfg_task_dao_boundary_npc(_) -> error.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%宠物进化场景npc地图刷新点
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_evolve_scene_npc' , CONCAT('get_cfg_evolve_scene_npc() -> ',
'[', GROUP_CONCAT('{',cfg_mapid,',{', cfg_x,',', cfg_y,'}}'),'].'
)
FROM cfg_evolve_scene_npc;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_dujie' , CONCAT('get_cfg_dujie(',cfg_id,', N )->#cfg_dujie{',
'cfg_id = ', cfg_id,
', cfg_battle = ', cfg_battle,
'};')
FROM cfg_dujie;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_dujie','get_cfg_dujie(_, N) -> error.';",


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%称号信息

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_title', CONCAT('get_cfg_title(',cfg_titleID, ') ->#rcd_title{',
'cfg_titleId = ',cfg_titleID,
', cfg_titleName = \"',cfg_titleName,'\"',
', cfg_titleType = ',cfg_titleType,
', cfg_titlePos = ',cfg_titlePos,
', cfg_titlePro = \"',cfg_titlePro,
'\", cfg_titleAttr = ',cfg_titleAttr,
'};')
FROM cfg_title;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_title','get_cfg_title( _ ) -> {error}.' ;",


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%普通公式
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_function', CONCAT('get_cfg_fun(',cfg_id, ',', cfg_param,') ->',
cfg_fun,';')
FROM cfg_function;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code) 
SELECT 'cfg_function', 'get_cfg_fun(_,_)->1=2.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 战斗模板
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_battle_template',CONCAT('get_cfg_bt_template(',cfg_id,')->#rcd_bt_template{',
'cfg_bt_name=\"',	cfg_bt_name,	'\",',
'cfg_have_pet =',	cfg_have_pet,	',',
'cfg_have_team =',	cfg_have_team,	',',
'cfg_order_limit =',	cfg_order_limit,',',
'cfg_event_id =',	cfg_event_id,	',',
'cfg_bt_end =',		cfg_bt_end,	',',
'cfg_role_result=',	cfg_role_result,',',
'cfg_award_id=',	cfg_award_id,	'};' )
FROM cfg_battle_template;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_battle_template','get_cfg_bt_template(_)-> {error}.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 智力仙官
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_question',CONCAT('get_cfg_question()-> [',
GROUP_CONCAT('{',cfg_questionId,',',cfg_answer,',',cfg_err_dialogId,'}'),
'].')
FROM cfg_qa;",               

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%层级划分，新手、精英...
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_layer',CONCAT('get_cfg_layer_param(',cfg_layer_type,')->',
cfg_layer_param,
';')
FROM cfg_layer;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_layer','get_cfg_layer_param(_)->{1=2}.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%生成体力消耗对应表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_energy',CONCAT( 'get_lost_energy(',cfg_id,')->',cfg_value,';')
FROM cfg_energy;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_energy', 'get_lost_energy(_)->error.';",


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 藏宝图挖宝奖励
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_treasure_map_award', CONCAT('get_treasure_map_award(', cfg_item, ', Lv)->','[',GROUP_CONCAT(
 CONCAT('{ {',cfg_award,', ', cfg_num, '},' , cfg_weitht, '}')
),'];')
FROM cfg_treasure_map
GROUP BY cfg_item;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_treasure_map_award', 'get_treasure_map_award(_, _)->error.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 世界boss随机选取范围
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_call_boss', CONCAT('get_boss(', cfg_type, ')->','[',GROUP_CONCAT(
 CONCAT(cfg_bossid)
),'];')
FROM cfg_call_boss
GROUP BY cfg_type;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_call_boss', 'get_boss(_)->error.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%生成坐骑原型ID和等级对应表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount',CONCAT( 'get_mount_level(',cfg_moduleid,')->',cfg_level,';')
FROM cfg_mount;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount', 'get_mount_level(_)->error.';",

%随机生成各种类的坐骑的概率列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount',CONCAT( 'get_mounttype_rand_list()-> [',
GROUP_CONCAT(CONCAT('{',cfg_moduleid,', ', cfg_rand_perc, '}')), 
'].')
FROM cfg_mount;",

%生成坐骑原型ID和其他信息对应表
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount',CONCAT('get_mount_info(',cfg_moduleid,')->#rcd_mountinfo{',
'cfg_name = \"',    cfg_name,
'\",cfg_addpro = ',   cfg_addpro,
',cfg_deadline = ',   cfg_deadline,
',cfg_perc = ',   cfg_rand_perc,
'};')
FROM cfg_mount;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount','get_mount_info( _ ) -> {error}.' ;",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%生成坐骑品质和体力对应表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount_quality',CONCAT( 'get_quality_info(', cfg_quality, ')->#rcd_mount_qualityinfo{',
'energy_limit = ',cfg_energy_limit,
',ride_cost = ',cfg_ride_cost,
',fly_cost = ',cfg_fly_cost,
',expadd = ',cfg_exp_eat,
',perc = ',cfg_rand_perc,
',rare_weight = ',cfg_rare_weight,
'};')
FROM cfg_mount_quality;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount_quality', 'get_quality_info(_)->error.';",

%随机生成各品质的坐骑的概率列表
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount_quality',CONCAT( 'get_mountqulty_rand_list()-> [',
GROUP_CONCAT(CONCAT('{',cfg_quality,', ', cfg_rand_perc, '}')), 
'].')
FROM cfg_mount_quality;",

%坐骑升级经验，升到下一等级需要的经验
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount_exp',CONCAT( 'get_cfg_mount_exp(', cfg_mount_level, ')-> ', cfg_mount_exp, ';')
FROM cfg_mount_exp;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount_exp', 'get_cfg_mount_exp(_)->error.';",

% 坐骑升级经验，升到指定等级总共需要的经验
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
select 'cfg_mount_exp', CONCAT('get_total_mount_exp(', level, ')-> ', sum(cfg_mount_exp), ';')
from (select cfg_mount_level as level from cfg_mount_exp) as b, cfg_mount_exp
where cfg_mount_level <= b.level GROUP BY b.level",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mount_exp', 'get_total_mount_exp(_)->0.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%取通用字符串标志
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_sys_inform',CONCAT( 'get_string_tag(',cfg_type, ',',cfg_level,')->',cfg_stringtag,';')
FROM cfg_sys_inform;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_sys_inform', 'get_string_tag(_,_)->error.';",
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%生成通用字符串
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_string',CONCAT( 'get_string(',cfg_stringtag,')->\"',cfg_chn_utf8,'\";')
FROM cfg_string;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_string', 'get_string(_)->error.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%矿洞怪跑动路径
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_moving_npc', CONCAT('get_pathlist(', cfg_moving_npcid, ',', 
cfg_npcid, ') -> ', cfg_pathlist, ';')
FROM cfg_moving_npc;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_moving_npc', 'get_pathlist(_, _)->error.';",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_moving_npc', CONCAT('get_monsters_number() -> ', COUNT(*), '.')
FROM cfg_moving_npc;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_moving_npc', CONCAT('get_monsterid_list() -> [', 
GROUP_CONCAT(CONCAT('{',cfg_moving_npcid,', ', cfg_npcid, '}')), 
'].')
FROM cfg_moving_npc order by cfg_moving_npcid;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_moving_npc_path', CONCAT('get_single_path(', cfg_pathid, ') -> ', 
cfg_single_path, ';')
FROM cfg_moving_npc_path;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_moving_npc_path', 'get_single_path(_)->error.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 世界boss随机刷出地点范围
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_pos', CONCAT('get_boss_pos(', cfg_bossid, ',', cfg_type, ') -> [',
GROUP_CONCAT( cfg_range),'];')
FROM cfg_boss_pos
GROUP BY cfg_bossid , cfg_type;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_pos', 'get_boss_pos(_, _)->error.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 世界boss掉落奖励
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_item', CONCAT('get_boss_award_item(', cfg_bossid, ',', cfg_type, ') -> [',
GROUP_CONCAT(CONCAT('{',cfg_award,', ', cfg_count, ',' , cfg_weight,'}')),
'];')
FROM cfg_boss_award_item
GROUP BY cfg_bossid , cfg_type;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_item', 'get_boss_award_item(_, _)->error.';",

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_online_gift',CONCAT('get_cfg_online_gift(Lvl, ',cfg_ol_gift_id,')->{',
cfg_ol_gift_time,
',',
cfg_ol_gift_gift,
'};')
FROM cfg_online_gift;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_online_gift','get_cfg_online_gift(_,_)->error.';",

"SET SESSION  group_concat_max_len = 999990;",
			   

%% 静态npc位置表

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_pos', CONCAT('get_npc_pos(1)->','[',GROUP_CONCAT(
 CONCAT('{',cfg_MapID,',',cfg_NpcPos,'}')
),'];')
FROM cfg_npcmapinfo;",
%% 传送点坐标
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_pos', CONCAT('get_npc_pos(2)->','[',GROUP_CONCAT(
 CONCAT('{',cfg_FrMapID,',',cfg_FrPos,'}')
),'];')
FROM cfg_transfer;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_npc_pos','get_npc_pos(_)->error.';",

			   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%游戏目标

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gametarget',CONCAT('get_target(',cfg_targetid,')->#rcd_gametarget{',
'cfg_targetid = ',	cfg_targetid,
',cfg_action = ',	cfg_action,
',cfg_param = ',	cfg_param,
',cfg_times = ',	cfg_times,
',cfg_award = ',	cfg_award,
'};')
FROM cfg_gametarget;",
% get_cfg_gold_island( _ ) -> {error};
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gametarget','get_target( _ ) -> {error}.' ;",

%%目标动作列表
"INSERT INTO  erl_cfg_code(erl_table,erl_code)			   
SELECT 'cfg_gametarget', CONCAT('get_action(',cfg_action,')->','[',GROUP_CONCAT(cfg_targetid),'];')
FROM cfg_gametarget
GROUP BY cfg_action;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gametarget','get_action( _ ) -> {error}.' ;",
			   
%%野区白色野怪信息
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_wild', CONCAT('get_wild_info(',cfg_npc.cfg_NpcID, ')->{',
cfg_npcmapinfo.cfg_MapID, ',[',
GROUP_CONCAT(cfg_npcmapinfo.cfg_NpcPos), ']};') 
FROM cfg_npc INNER JOIN cfg_npcmapinfo ON cfg_npc.cfg_NpcID = cfg_npcmapinfo.cfg_NpcID 
WHERE cfg_npcmapinfo.cfg_MapID IN (SELECT cfg_map.cfg_mapid FROM cfg_map 
WHERE cfg_map.cfg_MapType=2 AND cfg_map.cfg_level > 0) GROUP BY cfg_npc.cfg_NpcID,cfg_npcmapinfo.cfg_MapID;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_wild','get_wild_info(_) -> {error}.' ;",

%%野区高级怪与白色怪映射
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mapping', CONCAT('get_wild_mapping(', cfg_advanced_npc.cfg_advanced, ')->',
cfg_advanced_npc.cfg_white, ';') 
FROM cfg_advanced_npc, cfg_npc WHERE cfg_npc.cfg_level >= 10 AND cfg_npc.cfg_NpcID = cfg_advanced_npc.cfg_advanced;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_mapping','get_wild_mapping(_) -> {error}.' ;",

%% 白色30级首饰
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(1) -> [',
GROUP_CONCAT('{',cfg_itemID, ',10}'),
'];')
FROM cfg_item WHERE 
(cfg_item.cfg_itemType < 9 AND 
cfg_item.cfg_itemType > 4 AND 
cfg_item.cfg_quality = 0 AND 
cfg_item.cfg_LvMin = 30);",


%% 一级到6级灵珠
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(8) -> [',
GROUP_CONCAT('{',cfg_itemID, ',10}'),
'];')
FROM cfg_item WHERE (cfg_item.cfg_itemType = 14 AND cfg_item.cfg_ItemLvl = 1)",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(3) -> [',
GROUP_CONCAT('{',cfg_itemID, ',10}'),
'];')
FROM cfg_item WHERE (cfg_item.cfg_itemType = 14 AND cfg_item.cfg_ItemLvl = 2)",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(4) -> [',
GROUP_CONCAT('{',cfg_itemID, ',10}'),
'];')
FROM cfg_item WHERE (cfg_item.cfg_itemType = 14 AND cfg_item.cfg_ItemLvl = 3)",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(5) -> [',
GROUP_CONCAT('{',cfg_itemID, ',10}'),
'];')
FROM cfg_item WHERE (cfg_item.cfg_itemType = 14 AND cfg_item.cfg_ItemLvl = 4)",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(6) -> [',
GROUP_CONCAT('{',cfg_itemID, ',10}'),
'];')
FROM cfg_item WHERE (cfg_item.cfg_itemType = 14 AND cfg_item.cfg_ItemLvl = 5)",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(7) -> [',
GROUP_CONCAT('{',cfg_itemID, ',10}'),
'];')
FROM cfg_item WHERE (cfg_item.cfg_itemType = 14 AND cfg_item.cfg_ItemLvl = 6)",



"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item', CONCAT('get_boss_item(',ABS(cfg_special_award_id),') -> ',
cfg_special_award_list,
';')
FROM cfg_boss_spec_award",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boss_award_spe_item','get_boss_item(_) -> {error}.' ;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skystar', CONCAT('get_skystar() -> [',
GROUP_CONCAT(cfg_npc_id),
'].')
FROM cfg_skystar",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skystar', CONCAT('get_skystar(',cfg_npc_id,') -> {',
cfg_skystar_deblock,
',',
cfg_skystar_fight,
'};')
FROM cfg_skystar",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_skystar','get_skystar(_) -> {error}.'",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_period',CONCAT('get_cfg_period_list()-> [',
GROUP_CONCAT('#cfg_period{',
'cfg_id = ',	cfg_id,
', cfg_childtype = ',	cfg_childtype,
', cfg_name = \"',	cfg_name,
'\", cfg_describ = \"',	cfg_describ,
'\", cfg_type = ',	cfg_type,
', cfg_open = ',	cfg_open,
', cfg_gonggao = \"',	cfg_gonggao,
'\", cfg_end = ',	cfg_end,
', cfg_task = ',	cfg_task,
', cfg_target = \"',	cfg_target,
'\", cfg_award = \"',	cfg_award,
'\", cfg_accpet_npcid = ', cfg_accpet_npcid,
', cfg_consume = ', cfg_consume,
', cfg_task_append_id = ', cfg_task_append_id,
', cfg_team_limit = ', cfg_team_limit,
'}
'
),
'].')
FROM cfg_period where cfg_useable = 1",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_period_task','get_cfg_period_task_list()-> [';",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_period_task',CONCAT(
'#cfg_period_task{',
'id = ',    taskid*100+stateid,
',taskid = ',   taskid,
',stateid = ',  stateid,
',change = ',   `change`,
',next = ', next,
',action = ',   action,
',object = ',   object,
',object2 = ',  object2,
',gather = ',   gather,
',times = ',    times,
',lvl = ',  lvl,
',random = ',   random,
',dig = ',  dig,
',acc_dig = ',  acc_dig,
',battle_res_dig = ',   battle_res_dig,
',award = ',    award,
',target = \"', target,
'\",deploy = \"',   deploy,
'\",obj_map = \"',  obj_map,
'\",battle = ', battle,
',auto_battle = ',  auto_battle,
',choice = ',   choice,
',item = ', item,
',task_item = ', task_item,
',limit = ',    `limit`,
',describ = \"',    describ,
'\",name = \"', name,
'\",transfer = ',    trancefer,
',teamlimit = ', teamlimit,
',gonggao = \"', gonggao,
'\"',
'},'
)
FROM cfg_period_task;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_period_task','#cfg_period_task{}].';",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_sign_in', CONCAT('get_award(',cfg_days,') -> ',
cfg_awards,
';')
FROM cfg_sign_in;",

%% "INSERT INTO erl_cfg_code(erl_table,erl_code)
%% SELECT 'cfg_sign_in', CONCAT('get_award(',26,') -> [',
%% GROUP_CONCAT(cfg_objid),'];') FROM cfg_object WHERE cfg_objid > 1000 AND cfg_stage = 1",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_sign_in','get_award(_) -> {error}.'",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_error_code', CONCAT('get_cfg_error_code(',cfg_error_code_id,') -> ',
'\"', cfg_error_code_string, 
'\"'
';')
FROM cfg_error_code",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_error_code','get_cfg_error_code(_) -> \"\".'",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_hill', CONCAT('get_cfg_hill(',cfg_accept_npc,') -> #cfg_hill{',
'cfg_hill_id=', cfg_task_id, 
',cfg_accept_npc=', cfg_accept_npc, 
',cfg_min_level=', cfg_min_level, 
',cfg_max_level=', cfg_max_level,
',cfg_total_time=', cfg_total_time, 
',cfg_object=', cfg_object, 
',cfg_award_fun_id=', cfg_award_fun_id, 
'};')
FROM cfg_task_exercise;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_hill', CONCAT('get_cfg_hill(_) -> error.');",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_rand_event', CONCAT('get_cfg_rand_event(',cfg_event_id,') -> ',
cfg_event_list, 
';')
FROM cfg_rand_event;",
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_rand_event','get_cfg_rand_event(_) -> [].'",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_baptize_limit', CONCAT('get_pet_baptize_limit(', cfg_level, ') -> ',
cfg_quality, 
';')
FROM cfg_pet_quality;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_baptize_limit','get_pet_baptize_limit(_) -> {error}.' ;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_layer_att', CONCAT('get_layer_att(', cfg_layerType, ', ',cfg_layerStage, ') -> ',
cfg_attr, 
';')
FROM cfg_layer_att;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_layer_att','get_layer_att(_,_) -> {error}.' ;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_layer_att', CONCAT('get_full_layer_attr(', cfg_layerType, ', ',cfg_layerStage, ') -> ',
cfg_full_attr, 
';')
FROM cfg_layer_att;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_layer_att','get_full_layer_attr(_,_) -> {error}.' ;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_column', CONCAT('get_pet_column(', cfg_pet_column, ') -> {',
cfg_lv,
',',
cfg_keys, 
'};')
FROM cfg_pet_column;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_column','get_pet_column(_) -> {error}.' ;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_column', CONCAT('get_pet_columns(', ') -> [',
GROUP_CONCAT(cfg_pet_column), 
'].')
FROM cfg_pet_column;",

%% 野区高级怪战斗掉落诱饵道具掉落
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_bait', CONCAT('get_pet_bait(', cfg_id, ') -> #rcd_pet_bait{cfg_id = ', cfg_id, 
', cfg_rate=' ,cfg_rate,
', cfg_item=' ,cfg_item,
'};')
FROM cfg_pet_bait;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_bait', 'get_pet_bait(_)-> #rcd_pet_bait{cfg_rate = 0}.';",

%% 怪物境界映射
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_monster_test', CONCAT('get_monster_boundary() -> [', GROUP_CONCAT('{',cfg_level, ',',cfg_boundaryid,'}'),'].')
FROM cfg_boundary WHERE cfg_boundaryid > 3000 AND cfg_boundaryid < 3010;",

%% 获取所有的市场类型
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_market_type', CONCAT('get_all_market_type()->[',GROUP_CONCAT(cfg_typeid),'].')
FROM cfg_market_type where cfg_typeid like '1%';",

%% 获取所有拍卖类型
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_market_type', CONCAT('get_all_vendue_type()->[',GROUP_CONCAT(cfg_typeid),'].')
FROM cfg_market_type where cfg_typeid like '2%';",

%% 活跃度配置
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vitality', CONCAT('get_cfg_info(', cfg_id, ') -> #rcd_vitality_info{cfg_id = ', cfg_id, 
', cfg_times_limit=' ,cfg_times_limit,
', cfg_module=' ,cfg_module,
', cfg_delta_value=' ,cfg_delta_value,
', cfg_value_limit=' ,cfg_value_limit,
', cfg_min_show_level=' ,cfg_min_show_level,
', cfg_max_show_level=' ,cfg_max_show_level,
', cfg_level=' ,cfg_level,
', cfg_max_level=' ,cfg_max_level,
'};')
FROM cfg_vitality;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vitality', 'get_cfg_info(_)-> error.';",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vitality', CONCAT('get_all_vitality_id(', cfg_type, ')->[',GROUP_CONCAT(cfg_id),'];')
FROM cfg_vitality group by cfg_type;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vitality', 'get_all_vitality_id(_)-> [].';",

%% 活跃度奖励
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vitality', CONCAT('get_award_info(', cfg_vitality, ') -> #rcd_vitality_award{cfg_vitality = ', cfg_vitality, 
', cfg_award=' ,cfg_award,
'};')
FROM cfg_vitality_award;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vitality', 'get_award_info(_)-> error.';",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vitality', CONCAT('get_all_award_type()->[',GROUP_CONCAT(cfg_vitality ORDER BY cfg_vitality ASC),'].')
FROM cfg_vitality_award;",

%% 天神类型配置
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_god', CONCAT('get_god_info(', cfg_id, ') -> #rcd_god_info{cfg_id = ', cfg_id,
', cfg_level=' ,cfg_level,
', cfg_first_power=' ,cfg_first_power,
', cfg_daily_power=' ,cfg_daily_power,
', cfg_pic_title=' ,cfg_pic_title,
', cfg_male_avatar=' ,cfg_male_avatar,
', cfg_female_avatar=' ,cfg_female_avatar,
', cfg_cover=' ,cfg_cover,
', cfg_mutex=' ,cfg_mutex,
', cfg_demote_type=' ,cfg_demote_type,
'};')
FROM cfg_god;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_god', 'get_god_info(_)-> error.';",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_god', CONCAT('get_all_god()->[',GROUP_CONCAT(cfg_id),'].')
FROM cfg_god where cfg_id <> 0;",

%% 天神子功能配置
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_god', CONCAT('get_function_info(', cfg_id, ') -> #rcd_god_func_info{cfg_id = ', cfg_id,
', cfg_cost_power=' ,cfg_cost,
', cfg_person_limit=' ,cfg_person_limit,
', cfg_global_limit=' ,cfg_global_limit,
'};')
FROM cfg_god_skill;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_god', 'get_function_info(_)-> error.';",

%%天神召唤相关配置
%%唤魔
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_god', CONCAT('get_call_boss_list(', cfg_level, ') -> ',cfg_call_boss,';')
FROM cfg_god_call;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_god', 'get_call_boss_list(_)-> error.';",
%%唤财
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_god', CONCAT('get_call_box_list(', cfg_level, ') -> ',cfg_call_box,';')
FROM cfg_god_call;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_god', 'get_call_box_list(_)-> error.';",

%%唤将
"INSERT INTO erl_cfg_code(erl_table, erl_code)
SELECT 'cfg_god', CONCAT('get_call_jiang_list(', cfg_level, ') -> ',cfg_call_jiang,';')
FROM cfg_god_call;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_god', 'get_call_jiang_list(_)-> error.';",

%% 十四日留存指引
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', CONCAT('get_target_info(', cfg_day, ') -> #rcd_retained_guide_info{cfg_day = ', cfg_day, 
', cfg_check_type=' ,cfg_check_type,
', cfg_top_para=' ,cfg_top_para,
', cfg_check_type_normal=' ,cfg_check_type_normal,
', cfg_normal_para=' ,cfg_normal_para,
', cfg_top_award=' ,cfg_top_award,
', cfg_normal_award=' ,cfg_normal_award,
'};')
FROM cfg_retained_guide;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', 'get_target_info(_)-> undefined.';",

%% 所有留存指引的天数
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', CONCAT('get_all_days()->[',GROUP_CONCAT(cfg_day),'].')
FROM cfg_retained_guide;",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', CONCAT('get_max_day()->',MAX(cfg_day),'.')
FROM cfg_retained_guide;",

%% 留存指引目标对应的天数
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', CONCAT('get_top_target_days(', cfg_check_type, ')-> [', group_concat(cfg_day order by cfg_day asc), '];')
FROM cfg_retained_guide group by cfg_check_type;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', 'get_top_target_days(_)-> [].';",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', CONCAT('get_normal_target_days(', cfg_check_type_normal, ')-> [', group_concat(cfg_day order by cfg_day asc), '];')
FROM cfg_retained_guide group by cfg_check_type_normal;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_retained_guide', 'get_normal_target_days(_)-> [].';",

%% 取活动时间配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_activity_time', CONCAT('get_activity_time(', cfg_id, ') -> [', 
group_concat('#rcd_activity_time{cfg_id =', cfg_id,',cfg_start_time =', cfg_start_time, ',cfg_duration =', cfg_duration, ',cfg_interval =',cfg_interval, ',cfg_end_stage =', cfg_end_stage, ',cfg_para =', cfg_para, '}'), '];') 
from cfg_activity_time group by cfg_id;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_activity_time', 'get_activity_time(_)-> [].';",

%% 规则限制管理配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_rule_permission', CONCAT('get_rule_config(', cfg_rule_id, ') -> #rcd_rule_permission{permission =', 
(pa_team<<0) | (pa_ride<<1) | (pa_fly<<2) | (pa_gold_island<<3) | (pa_hire<<4) | (pa_cloud<<5), '};')
from cfg_rule_permission;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_rule_permission', 'get_rule_config(_)-> #rcd_rule_permission{permission = 0}.';",

%% 角色形象管理配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_change_avatar', CONCAT('get_avatar_priority(', cfg_type, ') -> ', cfg_priority, ';')
from cfg_change_avatar;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_change_avatar', 'get_avatar_priority(_)-> 0.';",

%% admin接口的相关内容
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_admin', CONCAT('get_detail_desc(', cfg_id, ') ->', cfg_desc, ';') 
FROM cfg_admin;",

"INSERT INTO erl_cfg_code(erl_table,erl_code) 
SELECT 'cfg_admin', 'get_detail_desc(_)-> \"\".'",

%%vip
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vip_type', CONCAT('get_vip_type(',cfg_vip_type,') ->
#rcd_vip_type{cfg_vip_type = ', cfg_vip_type, 
', cfg_daily_welfare=' ,cfg_daily_welfare,
', cfg_open_welfare=' ,cfg_open_welfare,
'};')
FROM cfg_vip_type;",
"INSERT INTO erl_cfg_code(erl_table,erl_code) 
SELECT 'cfg_vip_type', 'get_vip_type(_)-> error.'",


%% 押送妖女配置
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort', CONCAT('get_prisoner(', cfg_type, ') -> #rcd_prisoner{cfg_id = ', cfg_type, 
', cfg_silver = ' ,cfg_silver,
', cfg_exp = ' ,cfg_exp,
', cfg_lash = ', cfg_bianta,
', cfg_average = ', cfg_junfu,
', cfg_shackle = ', cfg_jiasuo,
', cfg_npc = ', cfg_npc,
'};')
FROM cfg_press_awards;",

"INSERT INTO  Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort', 'get_prisoner(_)-> error.';",

%% 妖女概率
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort', CONCAT('get_escort() ->[', 
GROUP_CONCAT('{', cfg_type, ', ', cfg_probability, '}'), '].')
FROM cfg_press_awards;",

%% 帮派名字禁止使用列表
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_string', CONCAT('get_guild_forbben_name() ->[', 
GROUP_CONCAT('\"', cfg_chn_utf8, '\"'),'].')
FROM cfg_string where cfg_stringtag like '%guild_forbbing_name%';",

%% 押送妖女随机事件掉落概率
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort_incident', CONCAT('get_escort_random_event() ->[', 
GROUP_CONCAT('{',cfg_type, ',',cfg_percent, '}'),'].')
FROM cfg_escort_incident;",

%% 押送妖女交易事件配置
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort_trade', CONCAT('get_escort_trade(',cfg_id,') ->#escort_trade{
cfg_id = ', cfg_id,
',cfg_idPercent = ', cfg_idPercent,
',cfg_pressGift = ', cfg_pressGift,
',cfg_tradeType = ', cfg_tradeType,
',cfg_pressGiftNum = ', cfg_pressGiftNum,
',cfg_tradelimit = ', cfg_tradelimit,
',cfg_trade = ', CONCAT('[', cfg_tradeNum1, ',', cfg_tradeNum2,',', cfg_tradeNum3,']};'))
FROM cfg_escort_trade;",

"INSERT INTO  Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort_trade', 'get_escort_trade(_)-> error.';",

"INSERT INTO  Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort_trade', CONCAT('get_escort_trade_percent()-> [',
GROUP_CONCAT('{',cfg_id, ',',  cfg_idPercent,'}'), '].')  FROM cfg_escort_trade
WHERE cfg_tradeType != 1;",

"INSERT INTO  Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_escort_trade', CONCAT('get_escort_sell_percent()-> [',
GROUP_CONCAT('{',cfg_id, ',',  cfg_idPercent,'}'), '].')  FROM cfg_escort_trade
WHERE cfg_tradeType = 1;",

%% 天仙试炼奖励配置
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_immortal', CONCAT('get_immortal(',cfg_npcid,') ->#immortal{
cfg_npcid = ', cfg_npcid,
',cfg_immortal_awards1 = ', cfg_immortal_awards1,
',cfg_immortal_awards2 = ', cfg_immortal_awards2,
'};')
FROM cfg_immortal;",

"INSERT INTO  Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_immortal', 'get_immortal(_)-> error.';",

% 锁妖塔配置,所有怪列表
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_all() ->[',
GROUP_CONCAT('{','[',cfg_npcid,',',cfg_battle_npcid,',',cfg_type,']',',',cfg_weight,'}'),
'].')
FROM cfg_tower_monster;",
% 战斗怪列表
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_battle_monster() ->[',
GROUP_CONCAT('{','[',cfg_npcid,',',cfg_battle_npcid,',',cfg_type,']',',',cfg_weight,'}'),
'].')
FROM cfg_tower_monster where cfg_type = 1;",

% "INSERT INTO Erl_cfg_code(erl_table,erl_code)
% SELECT 'cfg_tower_monster', CONCAT('get_trader() ->[',
% GROUP_CONCAT('{','[',cfg_npcid,',',cfg_battle_npcid,',',cfg_type,']',',',cfg_weight,'}'),
% '].')
% FROM cfg_tower_monster where cfg_type = 2;",
% 具体怪
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_monster(',cfg_npcid,') ->[',
cfg_battle_npcid, ',',
cfg_type,    
'];')
FROM cfg_tower_monster;",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_monster(_) -> error.');",

% BOSS奖励
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_monster_award(',cfg_type,') ->',
cfg_award,
';')
FROM cfg_tower_monster where cfg_type <> 1 and cfg_type <> 2 and cfg_type <> 3;",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_monster_award(_) -> [].');",

% 组队锁妖塔配置
% 所有怪列表
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_team_monster', CONCAT('get_all() ->[',
GROUP_CONCAT('{','[',cfg_npcid,',',cfg_battle_npcid,',',cfg_type,']',',',cfg_weight,'}'),
'].')
FROM cfg_tower_team_monster;",

% "INSERT INTO Erl_cfg_code(erl_table,erl_code)
% SELECT 'cfg_tower_team_monster', CONCAT('get_battle_monster() ->[',
% GROUP_CONCAT('{','[',cfg_npcid,',',cfg_battle_npcid,',',cfg_type,']',',',cfg_weight,'}'),
% '].')
% FROM cfg_tower_team_monster;",

% "INSERT INTO Erl_cfg_code(erl_table,erl_code)
% SELECT 'cfg_tower_team_monster', CONCAT('get_trader() ->[',
% GROUP_CONCAT('{','[',cfg_npcid,',',cfg_battle_npcid,',',cfg_type,']',',',cfg_weight,'}'),
% '].')
% FROM cfg_tower_team_monster where cfg_type = 2;",
% 具体怪
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_team_monster', CONCAT('get_monster(',cfg_npcid,') ->[',
cfg_battle_npcid, ',',
cfg_type,    
'];')
FROM cfg_tower_team_monster;",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_team_monster', CONCAT('get_monster(_) -> error.');",

% BOSS奖励
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_team_monster', CONCAT('get_monster_team_award(',cfg_type,') ->',
cfg_award,
';')
FROM cfg_tower_monster where cfg_type <> 1 and cfg_type <> 2 and cfg_type <> 3;",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_team_monster', CONCAT('get_monster_team_award(_) -> [].');",
% ---
%锁妖塔兑换表
"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_exchage(',cfg_exchange_itemId,',',cfg_demon_point_unit,',',cfg_ratio,') -> true;')
FROM cfg_demon_point_exchange;",

"INSERT INTO Erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_tower_monster', CONCAT('get_exchage(_,_,_) -> false.');",

			   
			   
%PK管理-地图场景安全时间
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map_period',CONCAT('get_cfg_map_period(',cfg_periodid,')->#rcd_mapperiod{',
'cfg_periodid =',	cfg_periodid,
',cfg_mapid = ',	cfg_mapid,
',cfg_period_set = ',cfg_period_set,
'};')
FROM cfg_map_period;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map_period','get_cfg_map_period( _ ) -> {error}.' ;",

			   
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_map_period',CONCAT( 'get_cfg_map_periodlst()->[',GROUP_CONCAT(cfg_periodid),'].')
FROM cfg_map_period;",

%神密商人
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config',CONCAT('get_trader_pos(',cfg_id,')->#rcd_position{',
'cfg_mapid =',	cfg_mapid,
',cfg_scene_name =  \"',cfg_scene_name,'\"',
',cfg_pos = ',cfg_pos,
',cfg_derict = ',cfg_derict,
'};')
FROM cfg_trader_position;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config','get_trader_pos( _ ) -> {error}.' ;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config',CONCAT( 'get_trader_map_lst()->[',GROUP_CONCAT(cfg_id),'].')
FROM cfg_trader_position;",


"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config',CONCAT('get_trader_goodrate({',cfg_start_level,',', cfg_end_level, '})->', cfg_shop_rate ,';')
FROM cfg_trader_goodrate;",


"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config','get_trader_goodrate({_,_}) -> [].' ;",


"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config',CONCAT('get_trader_goodprice(',cfg_good_id,')->', cfg_good_price ,';')
FROM cfg_trader_goodprice;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config',CONCAT('get_trader_goodprice(_)->{error}.')",


"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trader_config',CONCAT( 'get_trader_limit()->[',GROUP_CONCAT('{',cfg_good_id, ',',cfg_good_limit,'}'),'].')
from cfg_trader_goodprice;",

%VIP指引
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vip_guide',CONCAT('get_vip_guide(',cfg_target_id,')->#rcd_vipguide{',
' cfg_target_id =',	cfg_target_id,
',cfg_target_type =',cfg_target_type,
',cfg_target_name = \"',cfg_target_name,'\"',
',cfg_target_limit = ', cfg_target_limit,
',cfg_target_reward = ', cfg_target_reward,
'};')
FROM cfg_vip_guide;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vip_guide',CONCAT('get_vip_guide(_)->{error}.')",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_vip_guide',CONCAT( 'get_vip_guide_lst()->[',GROUP_CONCAT(cfg_target_id),'].')
FROM cfg_vip_guide;",


% 攻城怪物配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_monster', 
CONCAT('get_td_monster(',cfg_td_monster_id,',', cfg_td_boci,',',cfg_td_id,') ->#cfg_td_monster{',
'cfg_td_monster_id = ', cfg_td_monster_id,
',cfg_td_monster_type = ', cfg_td_monster_type,
',cfg_td_monster_quality = ', cfg_td_monster_quality,
',cfg_td_id = ', cfg_td_id,
',cfg_td_boci = ', cfg_td_boci,
',cfg_td_lvl = ', cfg_td_lvl,
',cfg_td_award = ', cfg_td_award,
',cfg_td_num = ', cfg_td_num,
',cfg_td_egg = ', cfg_td_egg,
',cfg_td_gold_item = ', cfg_td_gold_item,
',cfg_td_skill_book = ', cfg_td_skill_book,
',cfg_td_xuangong = ', cfg_td_xuangong,
',cfg_td_notify = ', cfg_td_notify,
'};'
)
FROM cfg_td_monster;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_monster', CONCAT('get_td_monster(_, _, _) ->error.');",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_monster', 
CONCAT('get_td_monster_boci() ->[',
GROUP_CONCAT('{',cfg_td_boci,',',cfg_td_monster_id,',',cfg_td_id,'}'),
'].')
FROM cfg_td_monster;",

% 攻城活动管理配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_mgr', 
CONCAT('get_cfg_td_mgr(',cfg_td_id,') ->#cfg_td_mgr{',
'cfg_td_id = ', cfg_td_id,
',cfg_td_time = ', cfg_td_time,
',cfg_td_monster_area = ', cfg_td_monster_area,
',cfg_td_gonggao = ', cfg_td_gonggao,
',cfg_td_vitality_type = ', cfg_td_vitality_type,
',cfg_td_type = ', cfg_td_type,
',cfg_td_first_3day = ', cfg_td_first_3day,
'};'
)
FROM cfg_td_mgr;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_mgr', CONCAT('get_cfg_td_mgr(_) ->error.');",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_mgr', CONCAT('get_all_cfg_td_mgr() -> [',
GROUP_CONCAT(cfg_td_id),
'].')
FROM cfg_td_mgr;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_mgr', CONCAT('get_td_id_by_vitality(', cfg_td_vitality_type, ') -> [',
GROUP_CONCAT(cfg_td_id),
'];')
FROM cfg_td_mgr group by cfg_td_vitality_type;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_td_mgr', 'get_td_id_by_vitality(_) -> [].';",

% 仙灵店铺
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_xl_shop', CONCAT('get_xl_shop() -> [',
GROUP_CONCAT('{',cfg_itemid,',',cfg_price_type,',',cfg_price,',',cfg_order,'}'),
'].')
FROM cfg_xl_shop;",

%-----------------------------------
%%渡劫奖励与下一境界、子阶的配置配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boundary_dujie' , CONCAT('get_cfg_boundary_dujie(',cfg_boundaryid,',', cfg_bank_sub,
') ->#cfg_boundary_dujie{',
'cfg_boundaryid = ', cfg_boundaryid,
', cfg_bank_sub= ' , cfg_bank_sub,
', cfg_dujie = ', cfg_dujie,
', cfg_level = ', cfg_level,
', cfg_next_boundaryid = ', cfg_next_boundaryid,
', cfg_next_bank = ', cfg_next_bank,
', cfg_award_shentong = ', cfg_award_shentong,
'};')
FROM cfg_boundary;",

"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_boundary_dujie','get_cfg_boundary_dujie(_,_) -> error.';",


% 开服活动
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_activity', 
CONCAT('get_activity({',cfg_activity_id ,',', cfg_detail_id,'}) ->#rcd_activity{',
' cfg_activity_id = ', cfg_activity_id,
',cfg_detail_id = ', cfg_detail_id,
',cfg_activity_name = \"', cfg_activity_name, '\"'
',cfg_param1 = ', cfg_param1,
',cfg_param2 = ', cfg_param2,
',cfg_param3 = ', cfg_param3,
',cfg_param4 = ', cfg_param4,
',cfg_reward = ', cfg_reward,
'};')FROM cfg_activity;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_activity', CONCAT('get_activity({_, _}) -> error.');",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_activity', CONCAT('get_activity_lst() -> [',
GROUP_CONCAT('{',cfg_activity_id,',',cfg_detail_id,'}'),'].')
FROM cfg_activity;",

%% 高富帅
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gaofushuai_gift', CONCAT('get_cfg_gfs_info() -> [',
GROUP_CONCAT(CONCAT('{',cfg_id,',',cfg_gift_id,',',cfg_recharge_money,',',cfg_has_pet,',',cfg_gfs_diamondType,'}')),
'].')
FROM cfg_gaofushuai_gift;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gaofushuai_gift', CONCAT('get_cfg_gfs_by_id(',cfg_id,') -> [',
CONCAT('{',cfg_id,',',cfg_gift_id,',',cfg_recharge_money,',',cfg_has_pet,',',cfg_gfs_diamondType,'}'),
'];')
FROM cfg_gaofushuai_gift;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_gaofushuai_gift', 'get_cfg_gfs_by_id(_) -> [].'"	,	

		 
%首充礼包
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_item',CONCAT( 'get_first_charge_gift()->[',GROUP_CONCAT('#rcd_first_recharge_gift{',
	'cfg_itemid = ', cfg_itemid,
	',cfg_itemnum = ',cfg_itemnum,
	',cfg_equip_color = ',cfg_equip_color,
	',cfg_equip_attr = ', cfg_equip_attr, '}'),'].')
FROM cfg_first_charge_gift;",

%%新手目标抽奖   
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_newbie_target',CONCAT('get_cfg(',cfg_targetid,')->#rcd_newbie_target{',
'cfg_targetid =',	cfg_targetid,
',cfg_level = ',	cfg_level,
',cfg_taskid = ',cfg_taskid,
',cfg_taskstate = ',cfg_taskstate,
',cfg_lottery = ',cfg_lottery,
',cfg_exp = ',cfg_exp,
'};')
FROM cfg_newbie_target;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_newbie_target','get_cfg( _ ) -> {error}.' ;",

%% 
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_award_b_box', CONCAT('get_award_b_box_type() -> [',
GROUP_CONCAT(DISTINCT(cfg_mod_id)),
'].')
FROM cfg_award_b_box;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_award_b_box', CONCAT('get_award_b_box_info(',cfg_mod_id,') -> [',
GROUP_CONCAT( CONCAT('{',cfg_mod_id,',',cfg_obj_id,',',cfg_period,',',cfg_num,',',cfg_replace_obj_id,'}'  ) ),
'];')
FROM cfg_award_b_box
GROUP BY cfg_mod_id;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_award_b_box','get_award_b_box_info( _ ) -> [].'",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_award_b_box', CONCAT('get_award_obj_list(',cfg_mod_id,') -> [',
GROUP_CONCAT( cfg_obj_id ),
'];')
FROM cfg_award_b_box
GROUP BY cfg_mod_id;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_award_b_box', 'get_award_obj_list( _ ) -> [].'",


"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_gold_island_task_exchange', CONCAT('get_exchange(',exchange_times,') -> ',
'{{', exchange_item1, ',', exchange_count1,'},{', exchange_item2,',',exchange_count2,'}};' )
FROM cfg_gold_island_task",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_gold_island_task_exchange', 'get_exchange( _ ) -> error.'",
			   
%% 副本配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_fuben', CONCAT('get_fuben(',cfg_fuben_id,') -> #rcd_fuben{',
'mapid = ', cfg_fuben_map,
', nth = ', cfg_fuben_boshu,
', npc = ', cfg_npc,
', team = ', cfg_team_num,
', lv = ', cfg_lv,
', last_time = ', cfg_fuben_time,
', fubenid = ', cfg_fuben_id,
', fuben_type = ', cfg_type,
', cfg_count_limit = ', cfg_count_limit,
', cfg_phy = ', cfg_phy,
', fuben_name = \"', cfg_name,
'\"};')
FROM cfg_fuben",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_fuben', 'get_fuben( _ ) -> error.'",

%% 副本限制
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_fuben', CONCAT('get_fuben_limit(',cfg_fuben_type, ') -> #rcd_fuben_limit{cfg_type = ', cfg_fuben_type,
', cfg_level_limit = ', cfg_level_limit,
', cfg_times_limit = ', cfg_times_limit,
', cfg_fight_limit = ', cfg_fight_limit,
', cfg_team_limit = ', cfg_team_limit,
', cfg_fly_limit = ', cfg_fly_limit,
'};')
FROM cfg_fuben_limit",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_fuben', 'get_fuben_limit( _ ) -> #rcd_fuben_limit{}.'",

%% 副本npc配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_fuben_npc_pos', CONCAT('get_fuben_npc_pos(',cfg_fubenid,', ',cfg_npcid,') -> ',
'{',cfg_pos1,',', cfg_pos2,',', cfg_xp_award_funcid, '}',
';')
FROM cfg_fuben_npc_pos",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_fuben_npc_pos', 'get_fuben_npc_pos(_, _) -> error.'",		


%% 副本npc掉落奖励
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_fuben_npc_award_item', CONCAT('get_fuben_npc_award_item(', cfg_npcid, ',', cfg_fubenid, ') -> [',
GROUP_CONCAT(CONCAT('{',cfg_award,', ', cfg_count, ',' , cfg_weight,'}')),
'];')
FROM cfg_fuben_npc_award
GROUP BY cfg_npcid , cfg_fubenid;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_fuben_npc_award_item', 'get_fuben_npc_award_item(_, _)->[].';",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_killmonster', CONCAT('get_posid_by_npcid(',cfg_npcid,') -> ',cfg_id,
';')
FROM cfg_killmonster",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_killmonster', 'get_posid_by_npcid( _ ) -> error.'",

%%试道大会
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_trydao', CONCAT('get_monster(',cfg_monsterId,') -> #rcd_dao_monster{',
'  cfg_monsterid = ', cfg_monsterid,
', cfg_grade = ', cfg_quality,
', cfg_monstername = \"', cfg_monstername,
'\"};')
FROM cfg_trydao_monster",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_trydao', 'get_monster( _ ) -> error.'",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trydao', CONCAT('get_reward(', cfg_quality,') ->', cfg_reward, ';')
FROM cfg_trydao_reward ;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_trydao', 'get_reward( _ ) ->error.'",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_trydao', CONCAT('get_monster_lst() -> [',
GROUP_CONCAT(DISTINCT(cfg_monsterId)),
'].')
FROM cfg_trydao_monster;",
		   			   
%% 圈圈可刷新配置点
%宠物进化场景npc地图刷新点
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_circle_pos' , CONCAT('get_pos() -> ',
'[', GROUP_CONCAT(cfg_pos),'].'
)
FROM cfg_circle_pos;",

%% 踩圈圈奖励
"INSERT INTO erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_circle_awards', CONCAT('get_awards(', lv, ',', cfg_color, ') -> [',
GROUP_CONCAT(CONCAT('{',cfg_item,', ', cfg_count, '}')),
'];')
FROM cfg_circle_awards
GROUP BY lv , cfg_color;",
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_circle_awards', 'get_awards(_, _)->error.';",   


%% 踩圈圈排行榜奖励
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_circle_ranking_awards', CONCAT('get_awards(',cfg_ranking,') -> [',
GROUP_CONCAT(CONCAT('{',cfg_item,', ', cfg_count, '}')),
'];')
FROM cfg_circle_ranking_awards
GROUP BY cfg_ranking;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_circle_ranking_awards', 'get_awards( _ ) -> error.'",

%% 随机类副本刷出位置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_fuben_random_pos' , CONCAT('get_pos(', cfg_fubenid, ',', cfg_fuben_type, ') -> ',
'[', GROUP_CONCAT(cfg_pos),'];'
)
FROM cfg_fuben_random_pos;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_fuben_random_pos', 'get_pos( _, _ ) -> error.'",

%% 登录奖励配置
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_login_award', CONCAT('get_award_list(', cfg_day, ') ->', cfg_award, ';')
FROM cfg_login_award",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_login_award', 'get_award_list(_) -> [].'",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_login_award', CONCAT('get_day_list() -> [', GROUP_CONCAT(cfg_day), '].')
FROM cfg_login_award",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_login_award', CONCAT('get_max_day() -> ', IFNULL(max(cfg_day),0), '.')
FROM cfg_login_award",

%% 宠物技能权重随机
"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT 'cfg_pet_skill_weight' , CONCAT('get_pet_skill_weight(', cfg_skillid, ') -> ',
'{{', cfg_skillid,', 1}, ', cfg_weight, '};'
)
FROM cfg_pet_skill_weight;",

"INSERT INTO  erl_cfg_code(erl_table,erl_code)
SELECT  'cfg_pet_skill_weight', 'get_pet_skill_weight( _ ) -> error.'"

],
%%
Sql_list.
%%  CONCAT(cfg_action,',',cfg_targetid,'}')  



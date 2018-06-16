%%Author:gavin
%%Create: 2013-04-24
%%Description: 排行榜相关数据结构

%%排行榜最大行数
-define(RANKING_LIMIT, 50). 
-define(PET_RANKING_LIMIT, 200).

%%排行榜类型定义
-define(RANKING_ROLE_TOTAL_GRADE, 1).
-define(RANKING_ROLE_GRADE,   2).
-define(RANKING_ROLE_LV,      3).
-define(RANKING_ROLE_DAO,     4).

-define(RANKING_PET_GRADE,    11).
-define(RANKING_PET_DAO,      12).
-define(RANKING_PET_HP,       13).
-define(RANKING_PET_ATTR,     14).
-define(RANKING_PET_SPD,      15).
-define(RANKING_PET_ZHIZI,    13). %%资质	

-define(RANKING_EQUIP_WEAPON, 31).
-define(RANKING_EQUIP_CLOTHES,32).
-define(RANKING_EQUIP_HAT,	  33).
-define(RANKING_EQUIP_SHOES,  34).
-define(RANKING_EQUIP_RING,   35).
-define(RANKING_EQUIP_AMULET, 36). %护符
-define(RANKING_EQUIP_JEWELRY,37).
-define(RANKING_EQUIP_BANGLE, 38). %手镯

-define(RANKING_MOUNT_GRADE,  41). %坐骑战力榜
-define(RANKING_MOUNT_RARE,   42). %坐骑稀有度




%%人物排行榜
-record(role_ranking,{
        ranking = 0, 			%名次
        roleid = 0, 			%角色ＩＤ
        sex = 0, 				%性别
        career = 0, 			%职业
        dao = 0, 				%道行
        level = 0, 				%等级
        role_grade = 0, 		%人物战斗力
        pet_grade = 0, 			%最大宠物战斗力
        total_grade = 0, 		%总战力
        record = 0, 			%人物战绩
        xianbanexp = 0, 		%仙班经验
        name = "unknown", 		%角色名 
        guild_name = "unknown", %帮派名
		tick_total_grade = 0,	%今日成长
		tick_role_grade = 0,
		tick_level = 0,
		tick_dao = 0,
		god = 0,				%天神
		god_days = 0			%剩余天数
    }).

%%宠物排行榜
-record(pet_ranking, {
        ranking = 0, 			%名次
        roleid = 0,				%角色ＩＤ
        petid = 0, 				%宠物ID
        grade = 0, 				%宠物战力
        dao = 0, 				%道行
        hp = 0, 				%血量
		attr= 0,				%宠物攻击
		spd = 0,				%速度
        master = 0, 			%师傅 改为 原型
        name = "unknown", 		%宠物名
        role_name = "unknown", 	%玩家名
        role_sex = 0, 			%性别
        role_career = 0, 		%角色职业
		tick_grade = 0,			%当日成长
		tick_dao  = 0,
		tick_hp   = 0,
		tick_attr = 0,
		tick_spd  = 0
    }).

%%装备排行榜
-record(equip_ranking, {
        ranking = 0, 			%名次
        itemid = 0, 			%装备ＩＤ
        moduleid= 0,		 	%装备原型ID
        sex = 0, 				%性别
        grade = 0, 				%装备评分
        roleid = 0,
        role_name = "unknown", 	%角色名字
        role_career = 0, 		%角色职业
		tick_grade = 0			%当日成长
    }).



%%宠物排行榜
-record(mount_ranking, {
		ranking = 0,				%名次
		mountid = 0,				%坐骑ID
		roleid  = 0,				%玩家ID
		school  = 0,				%门派
		grade   = 0,				%战力
		zhizi   = 0,				%资质
		rare    = 0,				%稀有度
		quality = 0,				%品质
		level	= 0,				%等级
		mount_name = "unknown",		%坐骑名
		role_name  = "unknown"		%玩家名
		}).

%%排行基本数据，提高排序效率
-record(ranking_base,{
        lowest_score = 0,
        baselist = [] 			%排行的基本数据列表[{角色/宠物/装备的唯一id, 成绩},...]
    }).


%%我的排行
-record(mine_rank, {
		rank_type = 0,
		rank_no = 0,
		rank_value = 0,
		rank_grown = 0			
		}).

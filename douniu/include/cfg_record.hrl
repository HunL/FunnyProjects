%%%------------------------------------------------
%%% File    : cfg_record.hrl
%%% Author  : Linchuansong
%%% Created : 2012-07-31
%%% Description: 数据库配置记录定义

-ifndef(CFG_RECORD_HRL).
-define(CFG_RECORD_HRL,0).

-define(INT, util:floor).
-define(RAND, -1+mod_rand:int).

%%=================== npc信息记录   =====================================
-record(rcd_npc, {
					 cfg_npcid = 0,			%% Npc id
					 cfg_NpcName = "",	%% npc名字
                     cfg_level = 0,     %% 0表示无等级，不显示。
%					 cfg_NpcAvatarID = 1,	%% npc模型
%					 cfg_IconID = 0,		%%
%					 cfg_ConversationID = 0,%%
%					 cfg_FeatureID = 0,		%%功能类型
					 cfg_color = 0,			%%npc颜色
					 cfg_npcType = 0 ,		%%攻击类型（0：不可攻击；1：可攻击）
					 cfg_npcBattle = [],	%%战斗触发(战斗队列ID，触发机率;触发机率总和固定100
%					 cfg_RebornTime = 0,	%%死亡重生规则(0、不重生;非0按照秒来重生)
					 cfg_item = [],			%%对应的采集物品
                     cfg_collect_time = 0    %%采集时间
    }).



%%=================== 地图Npc信息记录  =====================================
-record(rcd_npcmapinfo, {
					 cfg_ID,				%% 唯一id
					 cfg_mapid = 0,			%% 地图id
					 cfg_npcid = 0,			%% Npc id
					 cfg_npcpos = { 0, 0 },	%% npc座标
					 cfg_direction = 1		%% npc朝向	
    }).

	
					
%%=================== 传送点记录 =====================================
-record(rcd_transfer, {
					 cfg_TransferID = 0,	%% 传送点ID
					 cfg_FrMapID = 0,		%% 所在地图ID
					 cfg_npcpos = { 0, 0 },	%% 传送点所在座标
					 cfg_ToMapID = 0,		%% 传送目的地图
  					 cfg_ToPos = { 0, 0 },	%% 传送目的座标
					 cfg_direction = 1		%% npc朝向	
    }).

%%================================================================


%%=================== 物品表记录 =====================================
-record(rcd_item, {
		cfg_itemID		= 0,	%%
		cfg_itemBigType = 0,	%%大类
		cfg_itemType	= 0,	%%细类
		cfg_itemname    = undefined,	%%物品名字
		cfg_lastingType	= 0,	%%耐久类型 (0无耐久 1使用次数消耗 2装备耐久)
		cfg_lastingNum	= 0,	%%耐久数值
		cfg_quality		= 0,	%%品质 (0白，1蓝，2蓝，3金，4绿）
		cfg_stackType	= 0,	%%叠加类型（0不可叠加，1可叠加）
		cfg_stackMax	= 1,	%%叠加上限（不可叠加的填0）
		cfg_Bind		= 0,	%%绑定类型（0不绑定,1绑定）
		cfg_buySilver	= 0,	%%银币购买价格
		cfg_SellSilver	= 0,	%%银币卖出价格
		cfg_LvMin		= 0,	%%使用等级下限
        cfg_effect      = 0,   %%%%效果
		cfg_timeLimit	= 0,	%%时长限制
		cfg_IconID		= 0,	%%图标ID
		cfg_Destruction	= 0,		%%销毁类型(0不可销毁，1可销
		cfg_ItemLvl     = 0,
        cfg_useType     = 0,    %%使用类型(0不可使用，1可直接使用，2可批量直接使用，3可间接使用，不可直接使用)
        cfg_market_type = 0,    %%在寄售市场中的所属类型
        cfg_vendue_type = 0,    %%在拍卖行中的所属类型
        cfg_min_vendue_bid_price = 0,   %% 在拍卖行中最低竞拍价
        cfg_min_vendue_price = 0        %% 在拍卖行中最低一口价
    }).

%%=================== 装备表记录 =====================================
-record(rcd_equip, {
		cfg_itemID		= 0,	%%
		cfg_itemType	= 0,	%%细类(部位)
        cfg_level       = 0,   %%等级
		cfg_Career		= 0,	%%职业
        cfg_white_attr  = 0     %%基础属性,格式：[{att,100}]

    }).
%%================================================================

%%=================== 地图记录 =====================================
-record(rcd_map, {
		cfg_MapId			= 0,	%%地图ID
		cfg_Width			= 0,	%%宽度
		cfg_Height			= 0,	%%高度
		cfg_MapType			= 0,	%%地图类型
		cfg_MapName     	= "",	%%地图名
		cfg_level 			= 0,	%%进入等级
		cfg_areaType		= 0,	%%地图安全区类型
		cfg_can_transfer_in = 0,	%%是否可传送至该地图
		cfg_line_limit		= 0,	%%分线数量
		cfg_role_limit		= 0		%%在线人数
    }).

%%================================================================

%%====================宠物=========================
-record(rcd_pet,{
		cfg_petid = 0,					%% 宠物原型id
		cfg_objectid = 0,				%% object表的主键(理论上与cfg_petid一致)
		cfg_bloodid = 0,				%% 血脉id
		cfg_petname = undefined,		
		cfg_skill = 1001,				%% 必有的天生技能
		cfg_initskill = [],				%% 按权重选取的技能列表
		cfg_initgift = [],
		cfg_Avatarid = 0,				
		cfg_icon = 0,
		cfg_evolution = undefined,		%% 下一阶段的进化id
		cfg_devil_inside_id = undefined,	%% 宠物进化时心魔的场景npc原型id
		cfg_evolve_npcid = undefined,	%% 宠物进化时在进化台上进化的宠物npc原型id
        cfg_vendue_type = 0,            %%在拍卖行中的所属类型
        cfg_min_vendue_bid_price = 0,   %% 在拍卖行中最低竞拍价
        cfg_min_vendue_price = 0,        %% 在拍卖行中最低一口价
        cfg_pet_orgid = 0,               %%宠物原始原型ID，进化之前
        cfg_att = [],                   %% 改宠物可获得的额外属性
		cfg_type = 0                    %% 用于表示强化类型,0为不可强化
}).
%宠物玄功升级时间
-record(rcd_pet_gift_lvup,{
						   cfg_class = 1,	%玄功阶数
						   cfg_cost = 1,	%点击玄功升级时计算所需要的玄丹数量
						   cfg_lv = 1,		%玄功等级
						   cfg_time = 0		%玄功升级时间（从1级到n级）
  }).


%% 宠物血脉
-record(rcd_blood,{
		cfg_bloodid = 0,
		cfg_bloodtype = 0,
		cfg_max = 0
}).	
%%==========================宠物====================

%%===================装备白属性=============================
-record(rcd_equip_attr,{
	cfg_equip_lv,
	cfg_equip_type,
	cfg_white_attr
}).
%%===================装备蓝属性=============================
-record(rcd_equip_blue_attr,{
	cfg_equip_lv,
	cfg_equip_type,
	cfg_blue_attr
}).

%%===================经验等级=============================
-record(rcd_exp,{
	cfg_level,
	cfg_exp			 
}).

%%===================宠物经验等级=============================
-record(rcd_pet_exp,{
	cfg_pet_level,
	cfg_pet_exp			 
}).

%%===================标准NPC（宠物、怪物）对象=================================
-record(rcd_object,{
					cfg_objid = 0,
					cfg_name = undefined,
					cfg_Nature = 0,
					cfg_stage = 0,
					cfg_min_smart = 0,
					cfg_min_endurance = 0,
					cfg_min_phy = 0,
					cfg_min_agile = 0,
					cfg_max_smart = 0,
					cfg_max_endurance = 0,
					cfg_max_phy = 0,
					cfg_max_agile = 0,
                    cfg_str_smart = [],
                    cfg_str_endurance = [],
                    cfg_str_phy = [],
                    cfg_str_agile = [],
					cfg_Avatarid = 0,
					cfg_itemId	= 0,
					cfg_roleLv	= 0
					}).
%%===============================怪物修正数值===============================
%% -record(rcd_monster,{
%% 					 cfg_monsterId = 0,
%% 					 cfg_objid = 0,
%% 					 cfg_name = undefined,
%% 					 cfg_level = 0,
%% 					 cfg_att_correct = 0,
%% 					 cfg_def_correct = 0,
%% 					 cfg_hp_correct = 0,
%% 					 cfg_spd_correct =0,
%% 					 cfg_initskill = []
%% 					 }).
%%===============================怪物修正数值===============================
-record(rcd_monster,{
					 cfg_id = 0,			%怪物id编号
					 cfg_color = 0,			% 怪物颜色
					 cfg_name = undefined,	%名字
					 cfg_avatarid = 0,		%形象
					 cfg_lv = 0,			%等级
					 cfg_boundary = 0, 		%境界
					 cfg_att = 0,	%攻击
					 cfg_def = 0,	%防御
					 cfg_hp = 0,	%血量
					 cfg_spd =0,	%速度
					 cfg_nature = 0,		%相性
					 cfg_crit = 0,  %暴击
					 cfg_hit = 0,	%命中
					 cfg_dodge = 0, %闪避
					 cfg_combo = 0, %连击
					 cfg_break = 0, %破甲
					 cfg_resist = 0,%格挡
					 cfg_counter=0, %反击
					 cfg_dao = 0, 	%道行
					 cfg_skill = [],%技能
					 cfg_ai = [],	%策略
					 cfg_keep_body=1,%死后是否留条尸,0消尸，1留尸
					 cfg_type = 0,	%0普通怪，1BOSS怪
                     cfg_lv_correct = 0   %%怪的等级矫正方式：0根据队长的等级计算，1根据队员最高等级，2最低等级，3平均等级
}).


%% =====================================战斗配置=====================
-record(rcd_battle_npc,{
				cfg_npcid = 0,
				cfg_battletype = 0,
				cfg_battle = [],
				cfg_ai = undefined,	%% 战场策略
				cfg_guideId = 0,	%% 战斗指引ID
				cfg_promptId = 0 	%% 提示信息指引
}).

%%===============================金银岛===============================
-record(rcd_gold_island,{
		cfg_level = 0,				%进入等级
		cfg_mapid = 0,				%地图id
		cfg_enter_point = {0,0},	%进入点
		cfg_next_point = {0,0},		%下一关跳转点
		cfg_awards = [],			%奖励配置[{Npc原型id,数量},...]
		cfg_monsterid = 0			%守岛怪物id
}).

%%===============================洗练星级===============================
-record(rcd_baptize_star,{
		cfg_baptize_star,			%洗练星级
		cfg_baptize_star_rate}		%出现概率
).

%%===============================洗练星级与属性值的对应关系================
-record(rcd_baptize_attr,{
    cfg_equip_type, %%装备类型
    cfg_attr_type,  %%属性类型
    cfg_attr_value  %%属性公式　
}).

%% ======================================内丹================================
-record(rcd_pet_item,{
	cfg_id = 0,				%% 内丹id
	cfg_name = "",			%% 内丹名字
	cfg_color = 0,			%% 内丹品质
	cfg_effect = [],		%% 内丹穿戴后的效果加成
	cfg_type = 0,			%% 内丹类型
 	cfg_grade = 0			%% 内丹评分（用于战斗力评分）
}).


-record(rcd_pet_itembase,{
	cfg_color = 0,
	cfg_price = 0,
	cfg_experience = 0,
	cfg_upgrade = undefine
}).

%%====================任务系统========================
-record(rcd_taskstate,{
	cfg_taskid = 0,
	cfg_stateid = 0,
    cfg_next_stateid = 0,
	cfg_action = undefined,
	cfg_object = undefined,
	cfg_times = 1,
	cfg_info = undefined,
	cfg_award = [],
    cfg_resume = [],
	cfg_battledata = [],
	cfg_batlledrop = [],
    cfg_battletype = -1
}).

-record(rcd_taskchain,{
	cfg_taskid = 0,
	cfg_tasktype = 0,
	cfg_pretask = 0,
	cfg_level = 0,
	cfg_nexttask = 0,
	cfg_award = []
}).



%=============================技能===========================
-record(rcd_skill,{
	cfg_skillid = 0,
	cfg_skillname = "",
    cfg_objtype = 1,  %%拥有对象类型,1人物技能，2宠物技能，3怪物专用技能
    cfg_type = undefined, %效果类型,1攻击，2障碍，3辅助,4其它
	cfg_isactive = 1,  %%0被动,1主动
	cfg_isremote = 1,  %%0近程,1远程
	cfg_nature = 1,  %%系别
    cfg_petid = [],  %%某些宠物的专属技能
	cfg_lvlimit = 10,  %%学习等级
	cfg_consumeqian = "",  %%消耗潜能
	cfg_consumemp = "",  %%消耗MP
	cfg_bufferid = 0,  %%技能触发的BuffID;无则为0
	cfg_class = 1,  %%技能的等阶
	cfg_passtype =  [],
	cfg_passnum = [],
    cfg_num = [],  %%[{技能等级，目标数},...]
    cfg_attackP = 1000, %%伤害的放大系数，底数为1000,即100表示100%
    cfg_attackM = 0, %%伤害的固定部分
    cfg_control = 0, %%碍障技能的基础成功率
    cfg_skillgrade = "", %%技能评分
    cfg_lastround = [], %%人物辅助技能回合数[{技能等级，回合数}]
	cfg_ConversationID = 0	%% 技能前说话
}).

%=============================技能===========================
-record(rcd_buff, {
    cfg_buffId = 0,  %% buff ID
    cfg_buffType = 0,  %%  buff类型
    cfg_per = 0, %%默认情况下为，属性加成的百分比,，实际请以cfg_buff中的备注说明为准
    cfg_num = 0, %%默认情况下为，属性加成的固定值，实际请以cfg_buff中的备注说明为准
    cfg_debuff = 0 %增益｜减益
}).

%============================================战斗===================================
-record(rcd_battle, {
	cfg_battleid = 0,
	cfg_battle_info = []
	}).	

%% 战斗模板
-record(rcd_bt_template,{
	cfg_bt_name="",
	cfg_have_pet = false,
	cfg_have_team = false,
	cfg_order_limit = 1,
	cfg_event_id = 0,
	cfg_bt_end = 1,
	cfg_role_result=1,
	cfg_award_id=0
}).
%============================================捕捉宠物战斗===================================
%% 宠物前缀配置
-record(cfg_pet_pre,
		{
			typeid,
			pre_name,		%% 前缀
			append_spd,		%% 速度效果
			run_rate,		%% 逃跑率
			run_succ_rate,	%% 逃跑成功率
			weight			%% 权重
		 }
	   ).
%% 宠物前缀配置
-record(cfg_pet_suf,
		{
			typeid,
			suf_name,		%% 后缀
			range,			%% 范围
			color,			%% 颜色
			weight			%% 权重
		 }
	   ).
%===============================================================================

%% 师门晋升配置
-record(cfg_school_grade, {
    cfg_grade = 0,          %% 弟子层级
    cfg_normal_lvl = 0,     %% 普通晋升等级
    cfg_spec_lvl = 0,       %% 破格晋升等级
    cfg_spec_credit = 0,    %% 破格晋升所需贡献
    cfg_grade_name = undefine %% 弟子层级称号
    }).

%% 商人配置
-record(cfg_trader, {
    cfg_npcid = 0,          %% 商人
    cfg_trader_type = 0,    %% 商人类型
    cfg_goods_list = []     %% 售卖物品列表       
    }).

%%  境界系统数据配置
-record(cfg_boundary, {
	cfg_boundaryid = 0,		%% 境界id
	cfg_daoheng = 0,		%% 该境界的初始道行值
    cfg_std_dao = 0,        %%该境界的标准道行值
	cfg_dujie = 1,			%% 该境界达到下一境界所需要完成的渡劫
	cfg_level = 1,			%% 该境界达到下一境界所需的最低等级（开启渡劫的最低等级）
	cfg_next_boundaryid = 0, %% 下一境界id
	cfg_money = 0,			%% 该境界可携带的每种钱币上限
    cfg_k = 1,              %% 境界的基准k值
	cfg_num = 0			%% 境界在技能伤害计算时的表示
	}).

%% 宠物师门商店
-record(cfg_pet_master_shop,{
	cfg_npcid = 0,			%% 师门npcid
	cfg_nature = 0,			%% 师门npc职业
	cfg_skill_items = []	%% 师门出售的技能书
	}).

%% 师门任务
-record(cfg_task_school, {
    cfg_sc_taskid = 0,          %% 师门任务ID
    cfg_sc_task_stateid = 0,    %% 任务状态id
    cfg_sc_task_next = [],      %% 任务下一个可能状态
    cfg_sc_action = [],         %% 任务动作配置
    cfg_sc_object = [],         %% 动作对象,采集对象,战斗对象,提交物品时接受NPC等.格式[{最小等级, NPCID}, ...]
    cfg_sc_object2 = [],        %% 辅助对象,如果有,则随机一个,如果没有则忽略,格式 [NPC1,NPC2...]
    cfg_sc_gather = [],         %% 采集对象,采集时获得的物品对象,提交时需要提交的对象格式[{NPCID, 物品ID, 一次采集的数量}, ...]
    cfg_sc_times = 0,           %% 动作执行次数,包括物品需要的数量
    cfg_sc_difficulty = 0,      %% 难度系数
    cfg_sc_random = [],         %% 可能发生的事情概率[概率, [可能发生的事情的ID, ...]]
    cfg_sc_dig = [],            %% 对话内容,[{对象ID,[对话ID, ...]}, ...]
    cfg_sc_acc_dig = [],        %% 接受任务时的推送对话 
    cfg_sc_award = 0,           %% 任务奖励, 条件填写0,表示总是奖励此此物品,[{条件1,[{物品1,数量},...]},...]
    cfg_sc_task_type = 0,       %% 任务类型 1 采集包括挖矿, 3 送信, 4 采购, 5 抓宠, 6 搜集装备, 7 猎杀, 8 入世修行
    cfg_sc_obj_map = [],        %% 目标对象和地图的对应
    cfg_sc_battle = [],         %% 任务战斗数据
    cfg_sc_choice = [],         %% 任务选择和下一个状态关联
    cfg_sc_item = []            %% 切换状态时需要获得或者删除的物品
    }).

%% 刷道任务
-record(cfg_task_dao, {
    cfg_dao_taskid = 0,         %% 刷道任务ID
    cfg_dao_object=[],          %% 刷道任务对象
    cfg_dao_level = 0,            %% 刷道任务所需等级
    cfg_dao_battle_max_lvl = 0, %%刷道战斗的怪物最高等级
    cfg_dao_accnpc = 0,         %% 接任务的NPCID
    cfg_dao_boundaryid = 0,     %% 刷道任务所需境界
    cfg_dao_equip_lvl_award = [],%% 刷道任务的一轮装备等级奖励
    cfg_dao_equip_quality_rate = [], %%刷道任务装备奖励品质概率配置
    cfg_acc_need_coin = 0,       %% 接刷到任务需要的银币数量
    cfg_function_id = 0,            %%道行奖励公式
    cfg_function_id2 = 0,            %%潜能奖励公式
    cfg_accepte_notice = ""     %%接任务提示
    }).

%%===================称号属性=============================
-record(rcd_title,{
	cfg_titleId,
	cfg_titleName,
	cfg_titleType,
	cfg_titlePos,
	cfg_titlePro,
    cfg_titleAttr
}).

%% 境界怪物生成配置
-record(cfg_dujie, {
	cfg_id = 0,					%% 境界id
	cfg_battle = []				%% 境界对应的战斗配置	
}).

%% 世界boss物品掉落
-record(cfg_boss_award, {
	cfg_bossid = 0,
	cfg_award = [],
	cfg_count = 0
	}).	

-record(cfg_period,{
    cfg_id = 0,                 %% 活动id
    cfg_childtype = 1,          %% 活动子类型,1是活动,2是任务
    cfg_name = undefined,       %% 活动名称
    cfg_describ = undefined,    %% 活动描述
    cfg_type = undefined,       %% 活动类型
    cfg_open = undefined,       %% 活动开启条件
    cfg_gonggao = undefined,    %% 活动公告
    cfg_end = undefined,        %% 活动结束条件
    cfg_task = undefined,       %% 活动任务列表
    cfg_target = undefined,     %% 活动追踪
    cfg_award = undefined,      %% 活动奖励
    cfg_accpet_npcid = 0, 		%% 接活动任务的NPCID
    cfg_consume = [],           %% 接任务的消耗
    cfg_task_append_id = 0,     %% 对应cfg_task_append表id
    cfg_team_limit = 0          %% 队伍限制,0无队伍限制,大于0在表示限制队伍中的人数,比如1要求队伍有1个人,2要求队伍中有2个人
    }).

%% 活动子任务
-record(cfg_period_task, {
    id = 0, %% 任务识别ID,自增                      
    taskid = 0, %% '任务ID',
    stateid = 0, %%  '任务状态id',
    change = [], %%  '自动切换状态手段,比如时间',
    next = [], %%  '下一个可能状态,如果下一个状态下默认的+1,则可以留空,否则按 [{状态ID,条件需求ID},...]',
    action = undefined, %%  '任务动作配置',
    object = [], %%  '动作对象,采集对象,战斗对象,提交物品时接受NPC等.格式[{职业,最小等级, NPCID, MapId}, ...]',
    object2 = [], %%  '辅助对象,如果有,则随机一个,如果没有则忽略,格式 [NPC1,NPC2...]',
    gather = [], %%  '收集辅助对象',
    times = 0, %%  '动作执行次数,包括物品需要的数量',
    lvl = 0, %%  '任务所需等级',
    random = [], %%  '可能发生的事情概率[概率, [可能发生的事情的ID, ...]]',
    dig = [], %%  '对话内容,[{对象ID,[对话ID, ...]}, ...]',
    acc_dig = [], %%  '接受任务时发送的对话',
    battle_res_dig = [], %%报告战斗结果[windig,losedig]
    award = 0, %%  '任务额外奖励数值是百分比,比如,10是额外10%奖励 -10 是减少10%奖励',
    target = undefined, %%  '任务追踪, 支持的参数有场景map, 对象object, 次(个)数num, 且map显示场景id, (map)显示场景名称。例如: 107#东海渔村#map#object 显示"东海渔村(下划线)", 107#(map)#map#object则以实际map显示',
    deploy = undefined, %%  '任务引导，当前状态动作',
    obj_map = undefined, %%  '对象所在地图',
    battle = [], %%  '任务战斗数据',
    auto_battle = 0, %%自动进入战斗开关,0,不自动战斗,1自动战斗
    choice = [], %%  '选择和下一个状态关联[{选项,下一个状态ID}]选项从10开始.',
    item = [], %%  '任务需要的道具,[{ITEMID,Num}] 当Num<0时表示需要扣除物品,
    task_item = [], %%任务道具发放
    limit = [], %% 任务限制,比如[{times,10}],10次限制.
    describ = undefined, %% 任务描述
    name = undefined, %%任务名称
    transfer = 0,		%% 是否可以传送
    teamlimit = 0,  	    %% 队伍限制
    gonggao = ""
    }).


%%游戏目标任务
-record(rcd_gametarget, {
	cfg_targetid = 0,		%% 目标唯一id
	cfg_action = 0,			%% 目标动作
	cfg_param = 0,			%% 目标动作参数
	cfg_times = 0,			%% 动作完成次数
	cfg_award = []			%% 奖励列表
}).

%% 野区高级怪战斗掉落诱饵道具
-record(rcd_pet_bait,{
		cfg_id = 0,	%% 怪物ID
		cfg_rate=0, %% 掉落概率
		cfg_item=[]	%% 掉落权重
}).

%% 坐骑信息
-record(rcd_mountinfo,{
        cfg_name = "",      %% 坐骑名字
        cfg_addpro = 0,     %% 使用坐骑增加的原型相关属性值
        cfg_deadline = 0,   %% 使用期限
        cfg_perc = 0		%%   产出比例

}).

-record(rcd_mount_qualityinfo,{
		energy_limit = 0,	%%体力上限
		ride_cost = 0,		%%骑乘消耗的体力
		fly_cost = 0,		%%飞行消耗的体力
		zizhi_limit = 0,	%%资质上限
		exp_limit = 0,		%%经验上限
		expadd = 0,			%%被融合时经验增加值
		addpro = [],		%%增加的属性
		perc  = 0,			%%产出比例
		rare_weight = 0		%%稀有度品质权值
}).

-record(rcd_vip_type, {
        cfg_vip_type = 0,
        cfg_daily_welfare = [],
        cfg_open_welfare = undefined
    }).


%% 押送妖女信息
-record(rcd_prisoner,{
					  cfg_id = 0,          %% 妖女品质
					  cfg_silver = 0,      %% 初始银币奖励
					  cfg_exp = 0,         %% 初始经验奖励
					  cfg_lash = 0,        %% 免费鞭挞次数
					  cfg_average = 0,     %% 免费均富次数
					  cfg_shackle = 0,     %% 免费枷锁次数
					  cfg_npc = 0          %% 映射id
					  }).

-record(escort_trade,{
                      cfg_id = 0,
                      cfg_idPercent = 0,
                      cfg_pressGift = 0,
                      cfg_tradeType = 0,
					  cfg_pressGiftNum = 0,
                      cfg_trade = [],
					  cfg_tradelimit = 0
					 
					 }).


-record(immortal, {
                   cfg_npcid = 0,
                   cfg_immortal_awards1 = [],
                   cfg_immortal_awards2 =[]
}).

%%===================== 地图安全时间 ================================================
-record(rcd_mapperiod, {
						cfg_periodid = 0,		%%配置ID
						cfg_mapid = [],			%%配置地图
						cfg_period_set = []		%%配置时间
						}).

%% 活跃度
-record(rcd_vitality_info, {cfg_id = 0,             % ID
                            cfg_times_limit = -1,   % 次数限制
                            cfg_module = no_mod,    % 相应模块
                            cfg_delta_value = 0,    % 每次增加的活跃度
                            cfg_value_limit = 0,    % 增加活跃度上限
                            cfg_min_show_level = 0, % 最小显示等级
                            cfg_max_show_level = 0, % 最大显示等级
                            cfg_level = 0,          % 等级要求
                            cfg_max_level = 0       % 最大等级要求
}).

%% 活跃度奖励
-record(rcd_vitality_award, {cfg_vitality = 0,      % 领取奖励需要的活跃度
                             cfg_award = []         % 奖励配置
}).


%%		神秘商人
%%==============================================================================
-record(rcd_position, {
						cfg_mapid = 0,		 %%地图ID
						cfg_scene_name = "", %%场景名称
						cfg_pos = undefined,%%坐标
						cfg_derict = 0		 %%朝向
}).

-record(rcd_vipguide,{  cfg_target_id =0,
						cfg_target_type =0,
						cfg_target_name = "",
						cfg_target_limit =0,
						cfg_target_reward = []}).


% 攻城怪物配置
-record(cfg_td_monster, {
                        cfg_td_monster_id = 0,
                        cfg_td_monster_type = undefined,
                        cfg_td_monster_quality = 1,
                        cfg_td_id = 0,
                        cfg_td_boci = 0,
                        cfg_td_lvl = 0,
                        cfg_td_award = [],
                        cfg_td_num = 0,
                        cfg_td_egg = [],
                        cfg_td_gold_item = [],
                        cfg_td_skill_book = [],
                        cfg_td_xuangong = [],
                        cfg_td_notify = 0
                        }).

% 攻城活动管理配置
-record(cfg_td_mgr, {
                    cfg_td_id = 0,
                    cfg_td_time = {0,0,0,0},
                    cfg_td_monster_area = [],
                    cfg_td_gonggao = [],
                    cfg_td_vitality_type = 0,
					cfg_td_type = 0,
                    cfg_td_first_3day = 0
                    }).

                    
%--------开服活动配置----------------------------------------------------------------
-record(rcd_activity, {cfg_activity_id = 0,
					   cfg_detail_id  = 0,
					   cfg_activity_name = "",
					   cfg_param1 = 0,
					   cfg_param2 = 0,
					   cfg_param3 = 0,
					   cfg_param4 = 0,
					   cfg_reward = []
						}).
						

%% 天神类型
-record(rcd_god_info, {cfg_id = 0,                    % 配置ID
                             cfg_level = 0,                 % 天神等级
                             cfg_first_power = 0,           % 第一次得到的时候增加的神力
                             cfg_daily_power = 0,           % 日常得到神力
                             cfg_pic_title = 0,             % 图片称号
                             cfg_male_avatar = 0,           % 男性形象
                             cfg_female_avatar = 0,         % 女性形象
                             cfg_cover = [],                % 覆盖类型
                             cfg_mutex = [],                % 互斥类型
                             cfg_demote_type = 0            % 降级后如果还在排行榜内，需要更换的类型
}).

%% 渡劫奖励与下一境界、子阶的配置配置
-record(cfg_boundary_dujie , {
					cfg_boundaryid = 0,		%% 境界id
					cfg_next_boundaryid = 0, %% 下一境界id
					cfg_bank_sub = 0,        %% 当前子阶        
                    cfg_dujie = 0,           %% 战斗配置
					cfg_next_bank = 0,       %% 渡劫成功后的下一子阶
					cfg_award_shentong = 0,  %% 渡劫成功后奖励的神通点数 
					cfg_level = 0            %% 渡劫时的等级需求
					
					}).


%% 天神子功能
-record(rcd_god_func_info, {cfg_id = 0,               % 配置ID
                                  cfg_cost_power = 0,       % 消耗神力
                                  cfg_module = 0,           % 子模块
                                  cfg_person_limit = [],    % 个人限制
                                  cfg_global_limit = [],    % 全局限制
                                  cfg_para = {}             % 参数
}).

-record(rcd_newbie_target,{
					cfg_targetid = 0,
					cfg_level = 0,
					cfg_taskid = 0,
					cfg_taskstate = 0,
					cfg_lottery = 0,
					cfg_exp = 0
}).

% 留存指引配置
-record(rcd_retained_guide_info, {
                                    cfg_day = 0,                        % 开服天数
                                    cfg_check_type = undefined,         % 顶级检查类型
                                    cfg_top_para = 0,                   % 顶级检查参数
                                    cfg_check_type_normal = undefined,  % 普通检查类型
                                    cfg_normal_para = 0,                % 普通检查参数
                                    cfg_top_award = [],                 % 顶级奖励
                                    cfg_normal_award = []               % 普通奖励
}).

% 活动时间配置
-record(rcd_activity_time, {
                            cfg_id = 0,
                            cfg_start_time = "",
                            cfg_duration = "",
                            cfg_interval = "",
                            cfg_end_stage = "",
                            cfg_para = []
}).

-record(cfg_hill, {
                    cfg_hill_id = 0, % 修行任务ID
                    cfg_accept_npc = 0, % 修行任务接任务NPCID
                    cfg_min_level = 0, 
                    cfg_max_level = 0,
                    cfg_total_time = 0, % 该修行任务总时间
                    cfg_object = [],    %修行任务对象列表
                    cfg_award_fun_id = 0 %修行任务奖励公式ID
                    }).    

%% 副本配置
-record(rcd_fuben, {
					mapid = 0,                             %% 地图id                         
					nth = 0,                               %% 副本要刷多少波怪物
                    npc = [],                              %% 副本怪物刷出配置[{time, n, [{npcid, 怪物类型}]}}] 
                                                           %%    第一个大括号内对应的意思为:第一波怪物在time时间后刷出,
                                                           %%    从中括号内选取n个怪物每个怪物的id为npcid，类型根据怪物类型（0小怪，1bos...）
	                team = 0,                              %% 参与副本队伍人数需求
                    lv = 0,                                %% 参与副本等级需求
                    last_time = undefined,                 %% 副本 持续时间undefined表示无限制
                    fubenid = 0,                           %% 副本id
                    fuben_type = 0,                        %% 副本类型
                    cfg_count_limit = 999,                 %% 副本人数上限
                    cfg_phy = 0,                           %% 体力需求
                    fuben_name = ""                        %% 副本名字


}).

%% 试道大会
-record(rcd_dao_monster, {
						  cfg_monsterid = 0,				%% 怪物ID
						  cfg_grade = 0,					%% 怪物级别
						  cfg_monstername = ""				%% 怪物名称
}).

%% 副本限制
-record(rcd_fuben_limit, {
                          cfg_type = 0,                 % 副本类型
                          cfg_level_limit = 0,          % 副本等级限制
                          cfg_times_limit = 1,          % 副本次数限制
                          cfg_fight_limit = 0,           % 副本战斗力限制
                          cfg_team_limit = 1,           % 组队限制
                          cfg_fly_limit = 1            % 飞行限制
}).

%% 规则限制
-record(rcd_rule_permission, {
                              permission = 0               %% 规则限制标识
}).

%%首充礼包配置
-record(rcd_first_recharge_gift,{
		cfg_itemid = 0,%%物品id
		cfg_itemnum = 0,%物品数量
		cfg_equip_color = 0,%装备品质
		cfg_equip_attr = undefined %装备属性
}).


%% 宠物蛋配置，包含天技设定
-record(rcd_petegg, {
					 petid = 0,                                      %% 宠物原型id
			         skillcount = 0,                                 %% 天技技能数量
			         skills = []                                     %% 天技技能权重列表
}).

-endif.

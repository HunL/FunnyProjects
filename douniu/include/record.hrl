%%%------------------------------------------------
%%% File    : record.hrl
%%% Author  : LiuYaohua
%%% Created : 2011-07-11
%%% Description: record定义
-ifndef(RECORD_HRL).
-define(RECORD_HRL,0).

-include("common.hrl").
%%=================== max ID记录 =====================================
-record(ets_max_id, {
					 maxaccountid = 0,		%% 账号id
					 maxroleid = 0,			%% max角色id
					 maxitemid = 0,			%% max物品id
					 maxteamid = 0,			%% 组队ID
					 maxscenenpcid = 0,     %%场景npc id
					 maxpetitemid = 0,		%%宠物物品id
					 maxmountid = 0,		%%坐骑id
                     maxguildid = 0,	    %% 帮派id
                     maxmarketorderid = 0,  %% 市场货单id
                     maxvendueorderid = 0,  %% 拍卖货单id
                     maxtimeconfigid = 0,   %% 时间配置ID
					 maxfriendfuliid = 0,	%% 好友福利id
					 maxdouniuroomid = 0	%% 斗牛房间id
    }).
%%=================== 玩家在线记录 =====================================
-record(ets_online, {
					 roleid,				%% 角色id
					 accountid = 0,			%% 账号id
					 account = undefined,	%% 平台账号
 					 pid = undefined,		%% 玩家进程id
					 send_pid = undefined,	%% 玩家的数据包发送进程ID
					 rolename = [], 		%% 角色名
					 socket = undefined,	%% socket
					 battle = undefined		%% 战斗进程id
    }).

-record(ets_name_id_map, {
						  rolename,		%% 玩家角色名
						  roleid		%% 玩家角色ID
						 }).

%%=================== 角色信息记录 =====================================

%% accountserver
%%角色基本信息记录
-record(mhrolebaseinfo,{roleid, accountid,account, rolename,sex,career}).
%%账号信息表
-record(accountinfo,{account, accountid, roleid}).

-record(chatchannel, {
	worldchannel = 1,  %% 世界频道
	guildchannel = 1,  %% 帮会频道
	teamchannel = 1,   %% 队伍频道
	nearbychannel = 1  %% 附近频道
	}).

-record(roleattr,{
		phy = 0,		%%体质，初始值5
		smart = 0,		%%灵力，初始值5
		endur = 0,		%%耐力，初始值5
		agile = 0,		%%敏捷，初始值5
		att = 0,		%%攻击，初始值：5灵力*16
		def = 0,		%%防御，初始值：5耐力*4
		spd = 0,		%%速度，初始值：5敏捷*30
		dodge = 0,		%%闪避
		hit = 0,		%%命中
		crit = 0,		%%暴击
		combo = 0,		%%连击
		break = 0,		%%破甲
		resist = 0,		%%格挡
		counter = 0,	%%反击
		metal = 0,		%%金
		wood = 0,		%%木
		water = 0,		%%水
		fire = 0,		%%火
		earth = 0,		%%土
        barrier = 0,   %%强力障碍
        disturbance = 0   %%抗障碍
	}).

%%斗牛房间信息
-record(douniu_room, {
		room_id = 0,		%%房间id
		owner_id = 0,		%%房主角色id
		memberlist = [],	%%玩家角色id列表
		zhuang_id = 0,		%%庄家角色id
		zhuang_num = 0,		%%已确定抢庄人数
		ready_num = 0,		%%准备游戏人数
		tanpai_num = 0		%%摊牌人数
	}).

%%斗牛战绩信息
-record(douniu_zhanji, {
		roleid = 0,			%%角色id
		zhanji_list = []	%%战绩列表
	}).

%%斗牛战绩
-record(rec_zhanji, {
		rivalid = 0,		%%对手角色id
		result = 0			%%胜负（0为己胜，1为己负）
		}).

%%角色信息记录
-record(mhrole, {
	roletype = 0,%%角色类型：0——真身；1——分身
	accountid,	%%账号ID
	account = undefined,%%平台账号
	roleid = 0, %%角色id
	rolename = undefined, %%角色名
	sex=0, %%性别
	career=0, %%职业
	douniu_roomid = 0,%%斗牛房间号
	beishu = 0,%%押注倍数
	
	pid = undefined,%%mode_role进程id
	send_pid = undefined, %%数据发送进程id
	reader_pid = undefined, %%reader进程id
	socket = undefined, %%连接Socket
	login_ip = "",		%登录ip
%	status = 0,%%0：普通，1：飞行，2：战斗，4：组队，8：队长,16:单修,32：双休，64：渡劫,128:挂矿,256:宠物进化
	status = 0,%%0：普通，1：准备
	
	chat = #chatchannel{worldchannel = 1}, %%聊天频道配置
	level = 1,		%%等级
	login_level = 1,%%登陆时该角色的等级，只用于记录下线日志时使用
	vip = 0,		%%vip 1 vip 0 不是VIP
    vip_card_use = 0, %%玩家使用什么卡成为VIP,数字代表了使用的卡的天数,比如7是周卡,30是月卡,180是半年卡
    vip_type = 0,           %%VIP标志0,非VIP或正式VIP,1临时VIP
    vip_time = 0,   %%剩余的vip时间,单位:second
	vip_guide_lst = [], 	%%VIP指引完成情况
    vip_gfs_lvl = 0,  		%%VIP高富帅等级

	goldsum = 0,			%% 充值元宝累计
	gfs_goldsum = 0,		%% gfs进度(类 充值总额)
	roleattr = #roleattr{},%%角色属性
	itemstatus = undefined,
	petstatus = undefined,	%% #petstate

	gold = 5,		%%金元宝，斗牛默认为5
	silver = 0,		%%银元宝
	goldcoin = 0,	%%金币
	silvercoin = 0,	%%银币

	avatarid = 0,				%%外形ID
	sign_in = undefined,		%% 登录签到
    role_type = ?ROLE_TYPE_COMMON, %%角色类型，见宏定义ROLE_TYPE_XXX

	chat_time = [],				%%各频道聊天时间

    shutup = false,              %%禁言
    pkt_monitor = undefined,     %%数据包监控
    login_time = 0,              %登录时间戳
    last_logout_time = 0        %上一次离线时间戳
}).


%%=================== 场景信息记录 =====================================
%%--------------------mod_scene_mgr中使用--------------------
%角色在场景中全局记录
-record(role_lineinfo,{
	roleid = 0,				%%角色id
	lineinfo = undefined	%%相应的地图线信息
}).


%每条线进程信息
-record(lineinfo,{
	mapid = 0,			%地图id
	lineid = 0,			%线id
	playercnt = 0,		%玩家人数
	pid = undefined		%进程id
}).
%地图运行信息
-record(mapinfo, {
	mapid = 0,			%地图id
	playercnt = 0,		%玩家数
	linelist=[]			%线信息列表[#lineinfo]
}).

-endif.



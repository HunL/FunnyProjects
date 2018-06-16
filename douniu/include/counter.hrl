%%%------------------------------------------------
%%% File    : counter.hrl
%%% Author  : Moral
%%% Created : 2012-11-13
%%% Description: 计数器变量定义,请不要重复定义
-ifndef(COUNTER_HRL).
-define(COUNTER_HRL,0).


-define(COUNTER_ITEM_GIFT, 12001).          % 已获取的新手礼包

-define(COUNTER_OL_GIFT_NEXT, 12003).       % 在线礼包
-define(COUNTER_OL_GIFT_LEFT, 12004).       % 在线礼包的剩余时间

-define(COUNTER_LIMIT_DATA, 13001).         % 商城抢购的组ID
-define(COUNTER_SHOP_DATA, 13002).          % 城抢购个人数据记录
-define(COUTNER_SHOP_IGNORE, 13003).		% 抢购里忽略掉的组
-define(COUNTER_SHILIXIANG_NUM, 13004).     % 十里香使用次数

-define(COUNTER_SCHOOL_TASK_CIRCLE, 19000). % 师门任务轮数
-define(COUNTER_SCHOOL_TASK_NUMBER, 19001). % 师门任务次数
-define(COUNTER_SCHOOL_TASK_TOTAL, 19002).  % 师门任务已完成的总次数
-define(COUNTER_SCHOOL_TASK_CMD, 19003).    % 使用师门令增加的次数
-define(COUNTER_SCHOOL_TASK_MAIN, 19004).   % 师门特殊任务次数ID,当主线任务出于2-10的情况下接受的师门任务为特殊的任务

-define(COUNTER_SKYSTAR_FIGHT, 19005).      % 天罡星完成列表
-define(COUNTER_HILL_INFO, 19006).          % 修山任务信息

-define(COUNTER_MAIL_LIST, 21001).          % 邮件列表

-define(COUNTER_PERIOD_TASKLIST, 23001).    % 活动任务列表
-define(COUNTER_GOLD_ISLAND_TASK, 23003).   %% 金银岛日常任务
-define(COUNTER_UNDERSTAND_TRIGGER, 23002). % 午间听道顿悟触发次数

-define(COUTNER_OTHER_GIFT_INFO, 33001).    % 其他礼包信息,[{礼包类型,礼包状态},...] 状态:0未领取, 1领取了
-define(COUTNER_PHONE_TIME, 33002).         % 手机礼包领取时间
-define(COUNTER_GIFT_FIRST_SERVER, 33003).   % 首服至尊礼包领取状态
-define(COUNTER_GIFT_ORDER, 33004).   % 首服预约礼包领取状态
-define(COUNTER_GIFT_HONGYE, 33005).
-define(COUNTER_GIFT_WANGYOU, 33006).
-define(COUNTER_GIFT_YINGYUE, 33007).
-define(COUNTER_GIFT_LVXIA, 33008).

-define(VIP_HORN, 34000).                   % vip免费喇叭
-define(VIP_SILVERCOIN, 34001).             % vip免费银币
-define(VIP_ZHUFU, 34002).                  % vip祝福
-define(VIP_PET_FOOD, 34003).               % vip宠物口粮福利
-define(VIP_PET_LIANDAN, 34004).            % vip宠物炼丹。
-define(VIP_USE_FIRST, 34005).				% 首次使用半年卡奖励
-define(VIP_TIMER_REF, 34006).				% VIP计时器索引
-define(COUNTER_VIP_SCHOOL_FRESH, 34007).           % 师门任务免费刷新次数

-define(COUNTER_KILL_XINMO, 35000). % 击杀心魔
-define(COUNTER_KILL_CIKE,  35001). % 击杀刺客

-define(COUNTER_SINGLE_TOWER_RECORD, 38000). %锁妖塔单人记录{塔层,玩家名字}
-define(COUNTER_SINGLE_TOWER_BEST_RECORD, 38001). %锁妖塔单人最高记录{塔层,玩家名字, 性别, 职业}
-endif.
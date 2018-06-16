%%%------------------------------------------------
%%% File    : proto.hrl
%%% Author  : LiuYahua
%%% Created : 2012-07-07
%%% Description: 协议定义
%%%------------------------------------------------
-ifndef(PROTO_HRL).
-define(PROTO_HRL,0).

%%-------------- 账户信息--------------------------
-define(PP_ACCOUNT, 10).					%% 账户管理协议模块

-define(PP_ACCOUNT_LOGIN,           10000).           %% 登陆
-define(PP_ACCOUNT_LOGIN_ACK,       10001).  		  %% 登录回应
-define(PP_ACCOUNT_SELECT_ROLE,     10002).           %% 选择角色进入游戏
-define(PP_ACCOUNT_ROLE_INFO,       10003).           %% 角色信息
-define(PP_ACCOUNT_CREATE_ROLE,     10004).           %% 创建角色
-define(PP_ACCOUNT_CREATE_ROLE_ACK, 10005).           %% 创建角色回应
-define(PP_ACCOUNT_GET_ROLE_DETAIL, 10006).	          %% 获取角色详细信息
-define(PP_ACCOUNT_ROLE_DETAIL,     10007).		      %% 发送角色详细信息
-define(PP_ACCOUNT_GET_ROLE_ATTR, 10008).	%% 获取角色属性请求
-define(PP_ACCOUNT_ROLE_ATTR, 10009).		%% 角色属性信息
-define(ACCOUNT_ROLE_CHARGE_UPADTE,10010 ).			%%充值信息更新包
-define(ACCOUNT_ROLE_SCHOOL, 10100).                %%门派信息 
-define(ACCOUNT_ROLE_SCHOOL_ACK, 10101).            %% 门派信息应答
-define(ACCOUNT_ROLE_UPGRADES, 10102).              %% 破格晋升
-define(ACCOUNT_ROLE_UPGRADE_ACK, 10103).           %% 破格晋升应答
-define(ACCOUNT_ROLE_CONTRIBUTE, 10104).            %% 门派捐献
-define(ACCOUNT_ROLE_CONTRIBUTE_ACK, 10105).        %% 门派捐献应答
-define(PP_ACCOUNT_SYN_TIME_RE, 10600).				%% 客户端登录请求时间同步
-define(ACCOUNT_ROLE_SYN_TIME, 10106).              %% 同步时间
-define(PP_ACCOUNT_ONLINE_TIME, 10107).			    %% 获取累积在线时长
-define(PP_ACCOUNT_ONLINE_TIME_ACK, 10108).		    %% 发送累积在线时长
-define(PP_ACCOUNT_KICKOFF_ONLINE_3HS, 10109).		%% 剔除在线时长满3小时的防沉迷玩家
-define(PP_ACCOUNT_KICKOFF_ONLINE_3HS_ACK, 10110).	%% 剔除在线时长满3小时的防沉迷玩家响应
-define(PP_ACCOUNT_ROLE_SYN_TIME_ACK, 10111).		%% 时间同步确认
-define(ACCOUNT_ROLE_INFO_CHANGE, 10200).           %% 人物属性变更


-define(PP_AACOUNT_LOOK_ROLE_REQ, 10505).           %%查看角色信息请求
-define(PP_AACOUNT_LOOK_ROLE_ACK, 10506).           %%查看角色信息应答
-define(PP_ACCOUNT_LOOK_ROLE_BY_NAME_REQ, 10507).	%% 查看角色信息请求,通过名字查看 
-define(PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK, 10508).   %% 查看角色信息请求,通过名字查看

-define(PP_ACCOUNT_POS_REQ, 10509).					%% 查看角色坐标信息请求
-define(PP_ACCOUNT_POS_ACK, 10510).   				%% 查看角色坐标信息响应

-define(PP_ACCOUNT_ERR, 10700).						%% 通用错误码
-define(PP_ACCOUNT_ERR2,10701).						%% 通用错误码2
-define(PP_ACCOUNT_TIP, 10702).						%% 通用提示

-define(PP_ACCOUNT_TOURIST, 10999).                 %% 游客模式登录


%%-------------- 账户信息 END-----------------------

%%-------------- 聊天信息--------------------------
-define(PP_CHAT, 11).

-define(PP_CHAT_CLIENT_TO_SERVER,          11000).  %% 客户端发往服务端的消息包
-define(PP_CHAT_SERVER_TO_CLIENT,          11001).  %% 服务端发往客户端的消息包 
-define(PP_CHAT_SAVE_CHAT_CHANNELS,        11002).  %% 保存聊天频道信息
-define(PP_CHAT_SAVE_CHAT_CHANNELS_RESULT, 11003).  %% 返回保存聊天频道信息结果
-define(PP_CHAT_GET_CHAT_CHANNELS,         11004).  %% 获取聊天频道信息
-define(PP_CHAT_GET_CHAT_CHANNELS_RESULT,  11005).  %% 返回获取聊天频道信息结果
-define(PP_CHAT_SYS_ANNOUNCEMENT, 		   11006).  %% 系统公告
-define(PP_CHAT_SERVER_TO_CLIENT_PRIVATE,  11007).  %% 私人聊天服务端发往客户端的消息包
-define(PP_CHAT_CLIENT_TO_SERVER_PRIVATE,  11008).  %% 获取私人聊天离线消息包
-define(PP_CHAT_SERVER_NOTICE, 			   11009).	%% 全服系统提示(S>>C)
-define(PP_CHAT_SERVER_WIN_NOTICE,                11010).  %%全服弹窗提示(S->C)

%%-------------- 聊天信息 END-----------------------

%%-------------- 场景模块--------------------------
-define(PP_SCENE, 12).						%% 账户管理协议模块

-define(PP_SECENE_MOVE_PATH, 12000).        %% 玩家移动路径信息
-define(PP_SCENE_MOVE_PATH_BCAST , 12001). 	%% 玩家路点广播
-define(PP_SCENE_MOVE_STEP, 12002).     	%% 玩家移动验证
-define(PP_SCENE_GET_VIEW, 12003).       	%% 客户端获取当前场景视野信息请求
-define(PP_SCENE_VIEW_IN, 12004).     		%% 玩家进入视野
-define(PP_SCENE_VIEW_OUT, 12005). 			%% 玩家走出视野
-define(PP_SCENE_ENTER_MAP, 12006).			%% 地图跳转请求
-define(PP_SCENE_RESET, 12007).				%% 人物位置重置
-define(PP_SCENE_PET_INFO, 12008).			%% 宠物信息通知
-define(PP_SCENE_FLY, 12009).				%% 人物飞行
-define(PP_SCENE_STATUS_INFO, 12010).		%% 人物飞行状态通知
-define(PP_SCENE_ENTER_GOLD_ISLAND,12011).	%% 进入金银岛请求
-define(PP_SCENE_ENTER_GOLD_ISLAND_RES,12012).%%进入金银岛结果
-define(PP_SCENE_EXIT_GOLD_ISLAND,12013).	%% 退出金银岛
-define(PP_SCENE_ISLAND_COLLECT, 12014).	%% 金银岛物品采集
-define(PP_SCENE_ISLAND_COLLECT_RES,12015).	%% 金银岛物品采集结果
-define(PP_SCENE_NEXT_ISLAND, 12016).		%% 进入金银岛下一关请求 
-define(PP_SCENE_NEXT_ISLAND_RES, 12017).	%% 进入金银岛下一关请求结果
-define(PP_SCENE_POS_CHANGE, 12018).		%% 地图内位置变更
-define(PP_SCENE_ISLAND_BATTLE, 12019).		%% 金银岛守岛怪物挑战请求
-define(PP_SCENE_ISLAND_BATTLE_RES,12020).	%% 金银岛守岛怪物挑战结果
-define(PP_SCENE_ZAZEN_RE, 12021).          %% 单人打坐请求
-define(PP_SCENE_DOUBLE_ZAZEN_RE, 12022).   %% 双修请求
-define(PP_SCENE_ZAZEN_ACK, 12023).         %% 打坐/双修应答
-define(PP_SCENE_ZAZEN_INFO, 12024).        %% 双修场景广播
-define(PP_SCENE_ZAZEN_REWARD, 12025).      %% 打坐奖励
-define(PP_SCENE_COLLECT, 12026).			%% 采集物品
-define(PP_SCENE_COLLECT_RES, 12027).		%% 物品采集结果
-define(PP_SCENE_MOVE_TO_RE, 12040).        %% 传送到目标位置请求
-define(PP_SCENE_MOVE_TO_ACK, 12041).       %% 传送到目标位置应答
-define(PP_SCENE_CLOUD_TO_RE, 12042).       %% 传送到目标位置请求,需要消耗筋斗云
-define(PP_SCENE_CLOUD_TO_ACK, 12043).      %% 传送到目标位置应答,需要消耗筋斗云
-define(PP_SCENE_ESCAPE_RE, 12044).         %% 师门遁术请求
-define(PP_SCENE_ESCAPE_ACK, 12045).        %% 传送到目标位置应答
-define(PP_SCENE_EMPLOY_UPDATE,12046).		%% 分身雇佣信息更新
-define(PP_SCENE_DUJIE_COMPLISH, 12047).	%% 邻近玩家渡劫成功升级通知
-define(PP_SCENE_NPC_VIEW_IN, 12048).		%% 动态NPC进入视野
-define(PP_SCENE_NPC_VIEW_OUT, 12049).		%% 动态NPC移出视野
-define(PP_SCENE_NPC_STATUS_UPDATE, 12050).	%% 动态NPC状态更新
-define(PP_SCENE_MOUNT_STATUS_UPDATE, 12051).%%视野内玩家坐骑状态更新
-define(PP_SCENE_EVENT, 12052).				%% 场景事件通知
-define(PP_SCENE_NPC_MOVE_PATH, 12053).		%% 动态NPC移动路径通知
-define(PP_SCENE_ROLE_AVATAR_UPDATE, 12054).%% 角色Avatar改变通知
-define(PP_SCENE_NPC_FOLLOW_UPDATE,12055).	%% 动态NPC后跟随的队伍更新
-define(PP_SCENE_GOLDISLAND_LVREQ,12056).	%% 获取角色通关金银岛等级请求
-define(PP_SCENE_GOLDISLAND_LVINFO,12057).	%% 角色金银岛通关等级更新通知
-define(SCENE_ROLE_SPEED_UPDATE, 12058).	%% 角色移动速度更新
-define(SCENE_NPC_SPEED_UPDATE, 12059).		%% 动态NPC移动速度更新
-define(PP_SCENE_LEVEL_UPDATE, 12060).		%% 视野内玩家等级更新通知
-define(PP_SCENE_TITLE_UPDATE, 12061).		%% 视野内玩家称号更新通知
-define(PP_SCENE_VIP_UPDATE, 12062).		%% 视野内玩家VIP标志更新
-define(PP_SCENE_ESCORT_UPDATE,12063).		%% 押送妖女信息更新 
-define(PP_SCENE_GUILD_UPDATE,12064).		%% 帮派信息更新 
-define(SCENE_PK_UPDATE,	12065 ).		%% pk值更新
-define(SCENE_SAFE_PERIOD_CAST, 12066).		%% 地图安全时间广播
-define(SCENE_SAFE_PERIOD_RE, 12067).		%% 地图安全时间请求
-define(SCENE_GFS_LV_UPDATE ,12068 ).		%% 视野内玩家gfs等级更新通知
%%-------------- 场景信息 END-----------------------

-define(PP_VIP_INFO_REQ, 13510).                       %% VIP信息请求
-define(PP_VIP_INFO_ACK, 13511).                       %% VIP信息应答
-define(PP_VIP_GET_WELFARE_REQ, 13512).                %% 领取VIP福利请求
-define(PP_VIP_GET_WELFARE_ACK, 13513).                %% 领取VIP福利应答
-define(PP_VIP_NOTIFY, 13514).                         %% 成为VIP提示通知

-define(PP_VIP_GUIDE_OPER_REQ,13515).				   %% 操作同步请求
-define(PP_VIP_GUIDE_OPER_ACK,13516).				   %% 操作响应
-define(PP_VIP_GUIDE_TARGET_GET_REQ, 13517).		   %% 玩家VIP指引目标详情查询
-define(PP_VIP_GUIDE_TARGET_INFO, 13518).			   %% 玩家VIP指引目标详细信息



%%--------------------------------市场系统 start-----------------------------------
-define(PP_MARKET, 35).                         %% 市场系统
-define(PP_REFRESH_MARKET_LIST_REQ, 35001).     %% 请求刷新市场列表
-define(PP_REFRESH_MARKET_LIST_ACK, 35002).     %% 响应刷新市场列表

-define(PP_MARKET_SELL_REQ, 35003).             %% 请求出售物品
-define(PP_MARKET_SELL_ACK, 35004).             %% 响应出售物品

-define(PP_MARKET_BUY_REQ, 35005).              %% 请求购买物品
-define(PP_MARKET_BUY_ACK, 35006).              %% 响应购买物品

-define(PP_MARKET_CANCEL_SALE_REQ, 35007).      %% 请求下架物品
-define(PP_MARKET_CANCEL_SALE_ACK, 35008).      %% 响应下架物品

-define(PP_MARKET_SEND_AD_REQ, 35009).          %% 发送广告
-define(PP_MARKET_SEND_AD_ACK, 35010).          %% 响应发送广告

-define(PP_REFRESH_MY_MARKET_LIST_REQ, 35011).  %% 请求个人出售列表
-define(PP_REFRESH_MY_MARKET_LIST_ACK, 35012).  %% 响应个人出售列表

-define(PP_EXCHANGE_REQ, 35013).                %% 请求兑换
-define(PP_EXCHANGE_ACK, 35014).                %% 响应兑换请求

-define(PP_MARKET_SEARCH, 35015).               %% 搜索物品

-define(PP_MARKET_FETCH_INCOME_REQ, 35017).     %% 请求取回收入
-define(PP_MARKET_FETCH_INCOME_ACK, 35018).     %% 响应取回收入

-define(PP_MARKET_AGAIN_SALE_REQ,   35019).     % 请求重新上架
-define(PP_MARKET_AGAIN_SALE_ACK,   35020).     % 响应重新上架

-define(PP_MARKET_GET_ORDER_REQ,    35021).     %% 请求市场货单当前信息
-define(PP_MARKET_GET_ORDER_ACK,    35022).     %% 响应市场货单当前信息

-define(PP_SELL2ME_MARKET_LIST_REQ, 35023).     %请求指定买家的货单列表
-define(PP_SELL2ME_MARKET_LIST_ACK, 35024).     %响应指定买家的货单列表

-define(PP_REFRESH_VENDUE_LIST_REQ, 35101).     %% 请求刷新拍卖列表
-define(PP_REFRESH_VENDUE_LIST_ACK, 35102).     %% 响应刷新拍卖列表

-define(PP_VENDUE_SELL_REQ, 35103).             %% 请求拍卖物品
-define(PP_VENDUE_SELL_ACK, 35104).             %% 响应拍卖物品

-define(PP_VENDUE_BUY_REQ, 35105).              %% 请求购买拍卖物品
-define(PP_VENDUE_BUY_ACK, 35106).              %% 响应购买拍卖物品

-define(PP_VENDUE_CANCEL_SALE_REQ, 35107).      %% 请求下架自己拍卖行的物品
-define(PP_VENDUE_CANCEL_SALE_ACK, 35108).      %% 响应下架自己拍卖行的物品

-define(PP_VENDUE_SEND_AD_REQ, 35109).          %% 发送拍卖物品广告
-define(PP_VENDUE_SEND_AD_ACK, 35110).          %% 响应发送拍卖物品广告

-define(PP_REFRESH_MY_VENDUE_LIST_REQ, 35111).  %% 请求个人拍卖行出售列表
-define(PP_REFRESH_MY_VENDUE_LIST_ACK, 35112).  %% 响应个人拍卖行出售列表

-define(PP_VENDUE_GOOD_REQ, 35113).             %% 请求单条货物
-define(PP_VENDUE_GOOD_ACK, 35114).             %% 响应单条货物信息

-define(PP_VENDUE_SEARCH, 35115).               %% 搜索物品

-define(PP_VENDUE_BID_REQ, 35117).              %% 请求竞拍
-define(PP_VENDUE_BID_ACK, 35118).              %% 响应竞拍

-define(PP_VENDUE_MY_BID_LIST_REQ,  35119).      %% 请求个人参与竞拍列表
-define(PP_VENDUE_MY_BID_LIST_ACK,  35120).      %% 响应个人参与竞拍列表

-define(PP_VENDUE_GET_ORDER_REQ,    35121).     %% 请求拍卖货单当前信息
-define(PP_VENDUE_GET_ORDER_ACK,    35122).     %% 响应拍卖货单当前信息

-define(PP_MARKET_GET_UNDEAL_REQ,   35200).     %% 查看市场未处理内容请求
-define(PP_MARKET_GET_UNDEAL_ACK,   35201).     %% 市场未处理内容信息响应

-define(PP_TRADER_GET_GOOD_RE,   35051).		%%商品查询
-define(PP_TRADER_GET_GOOD_ACK,  35052).		%%商品查询响应
-define(PP_TRADER_BUY_GOOD_RE,   35053).		%%商品购买请求
-define(PP_TRADER_BUY_GOOD_ACK,  35054).		%%商品购习响应

%%--------------------------------市场系统 end-------------------------------------

%% --------------------------------- 斗牛 -----------------------------
-define(PP_DOUNIU, 50).
-define(PP_DOUNIU_CREATE_ROOM_REQ, 50000).	  		%%创建房间
-define(PP_DOUNIU_CREATE_ROOM_ACK, 50001).   		%%创建房间响应

-define(PP_DOUNIU_JOIN_ROOM_REQ,   50002).	  		%%加入房间
-define(PP_DOUNIU_JOIN_ROOM_ACK,   50003).	   		%%加入房间响应

-define(PP_DOUNIU_ZHANJI_REQ,      50004).			%%查询战绩
-define(PP_DOUNIU_ZHANJI_ACK,      50005).			%%查询战绩响应

-define(PP_DOUNIU_QUIT_ROOM_REQ,   50006).	  		%%退出房间
-define(PP_DOUNIU_QUIT_ROOM_ACK,   50007).	   		%%退出房间响应

-define(PP_DOUNIU_READY_REQ,	   50008).	  		%%准备游戏
-define(PP_DOUNIU_READY_ACK,	   50009).	   		%%准备游戏响应

-define(PP_DOUNIU_FAPAI_REQ,	   50010).	  		%%发牌
-define(PP_DOUNIU_FAPAI_ACK,	   50011).	   		%%发牌响应

-define(PP_DOUNIU_TANPAI_REQ,	   50012).	  		%%摊牌
-define(PP_DOUNIU_TANPAI_ACK, 	   50013).	   		%%摊牌响应

-define(PP_DOUNIU_CHONGZHI_REQ,	   50014).	  		%%充值
-define(PP_DOUNIU_CHONGZHI_ACK,	   50015).	   		%%充值响应

-define(PP_DOUNIU_QIANGZHUANG_REQ, 50016).	  		%%抢庄
-define(PP_DOUNIU_QIANGZHUANG_ACK, 50017).	   		%%抢庄响应

-define(PP_DOUNIU_YAZHU_REQ,	   50018).	  		%%押注
-define(PP_DOUNIU_YAZHU_ACK, 	   50019).	   		%%押注响应


%% --------------------------------- 斗牛end -----------------------------


-endif.


%%%------------------------------------------------
%%% File    : record.hrl
%%% Author  : LiuYaohua
%%% Created : 2012-07-11
%%% Description: 通用常量定义

-ifndef(COMMON_HRL).
-define(COMMON_HRL,0).
%%flash843安全沙箱
-define(FL_POLICY_REQ, <<"<policy-">>).
%-define(FL_POLICY_REQ, <<"<policy-file-request/>\0">>).
-define(FL_POLICY_FILE, 
		<<"<cross-domain-policy>"
		  		"<allow-access-from domain='*' to-ports='*' />"
		  "</cross-domain-policy>"
		>>).

%%tcp_server监听参数
-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, 
					  {reuseaddr, true}, {nodelay, false}, 
					  {delay_send, true}, {send_timeout, 5000}, 
					  {keepalive, true}, {exit_on_close, true},
					  {sndbuf,655350}, {buffer,65535}]).

-ifndef(IF).
-define(IF(C, T, F), (case (C) of true -> (T); false -> (F) end)).
-endif.

-define(VERSION, 'v0.9.0405').

-define(ADDTIMER(Mod, Time, Msg), mh_simple_timer:start_timer(Mod, Time, Msg)).
-define(DELTIMER(Ref), mh_simple_timer:cancel_timer(Ref)).

%-define(INFO_PRINT, 1).
%%打印日志
%-ifdef(INFO_PRINT).
  -define(INFO(Format, Args),
      mod_log_print:print_info(?MODULE,?LINE, Format, Args)).
  -define(INFO(Format),
       mod_log_print:print_info(?MODULE,?LINE, Format, [])).
	-define(HERE(),io:format("Here MODULE:~p, Line:~p.~n",[?MODULE,?LINE])).
	-define(LOG_HERE(),mod_log_print:print_info(?MODULE,?LINE)).
%-else.
%    -define(INFO(Format, Args),ok).
%    -define(INFO(Format), ok).
%	-define(HERE(), ok).
%	-define(LOG_HERE(), ok).
%-endif.

-define(ERR(Format, Args),
	mod_log_print:print_error(?MODULE,?LINE, Format, Args)).
-define(ERR(Format),
 	mod_log_print:print_error(?MODULE,?LINE, Format, [])).

%% -define(ERR(Format, Args),
 %%	ok).
%% -define(ERR(Format),
 %%	ok).

-define(S2CERR(ErrorCode), lib_role:s2c_err(ErrorCode)).
-define(S2CERRS(String), lib_role:s2c_err2(String)).


%% 日志数据库
-define(DBLOG(Mod, Type, Args), 
    mod_log_db:do_log(Mod, Type, Args)).
%%日志数据库
%% -define(DBLOG(Tag,Args),
%% 	mod_logserver:db_log(Tag, Args)).

%%数据库连接
-define(DB, 		mh_mysql_conn).
-define(DB_LOG_CONN, mh_mysql_conn_log).
-define(DB_HOST, 	mh_env:get_env(db_host)).
-define(DB_PORT, 	mh_env:get_env(db_port)).
-define(DB_USER, 	mh_env:get_env(db_user)).
-define(DB_PASS, 	mh_env:get_env(db_pass)).
-define(DB_CFG,		mh_env:get_env(db_cfg)).
-define(DB_NAME, 	mh_env:get_env(db_name)).
-define(DB_ENCODE, 	mh_env:get_env(db_encode)).
-define(DB_LOG, 	mh_env:get_env(db_log)).
-define(DB_HOST_SLAVE, mh_env:get_env(db_host_slave)).
-define(DB_SLAVE, 		mh_mysql_conn_slave).
-define(DB_USER_SLAVE, mh_env:get_env(db_user_slave)).
-define(DB_PASS_SLAVE, mh_env:get_env(db_pass_slave)).
-define(DB_PORT_SLAVE, mh_env:get_env(db_port_slave)).


-define(RPC_TIMEOUT, 1000*50).
%%ETS
-define(ETS_ONLINE, ets_online).

%%{账号,账号ID}列表
-define(ETS_MHACCOUNT, ets_mhaccount).
%%角色基础信息record列表{#mhrolebaseinfo}
-define(ETS_MHROLE_INFO, ets_mhrolebaseinfo).
%%角色名列表 {角色名}
-define(ETS_MHROLE_NAME, ets_mhrolename).
-define(ETS_NAME_ID_MAP, ets_name_id_map).
-define(MAX_ROLE_LEVEL, 	120).%%最高角色等级
-define(MAX_NOW_ROLE_LEVEL,  90).%%当前最高角色等级

%%角色类型
-define(ROLE_TYPE_TOURIST, 0). %游客
-define(ROLE_TYPE_COMMON, 1). %普通玩家
-define(ROLE_TYPE_GM, 2). %GM
-define(ROLE_TYPE_GUIDER, 3). %新手指导员
%%场景

-define(SYN_TIME_GAP, 180*1000). %% 时间同步间隔
-define(PACKET_SEND_INT, 100).%%数据包发送间隔 

-define(SECONDS_PER_MINUTE, 60).
-define(SECONDS_PER_HOUR, 3600).
-define(SECONDS_PER_DAY, 86400).
-define(SECONDS_PER_WEEK, 604800).
-define(DAYS_PER_YEAR, 365).
-define(DAYS_PER_LEAP_YEAR, 366).
-define(DAYS_PER_4YEARS, 1461).
-define(DAYS_PER_100YEARS, 36524).
-define(DAYS_PER_400YEARS, 146097).
-define(DAYS_FROM_0_TO_1970, 719528).
-define(TIME_OFFSET,3). %%午夜时间偏移数，三点重置每日事件

%%rpc
-define(MH_LOGIN_SERVER, login_server).
-define(MH_LOG_SERVER, log_handler).
-define(MH_LOGDB_SERVER, log_db).
-define(MH_GAME_ID, game_id).

%% 计数器
-define(MEM_COUNTER(RoleId, Key, Val), mod_counter_mem:set({RoleId, Key}, Val)).
-define(MEM_COUNTER(RoleId, Key), mod_counter_mem:get({RoleId, Key})).
-define(DAILY_COUNTER(RoleId, Key, Val), mod_counter_daily:set({RoleId, Key}, Val)).
-define(DAILY_COUNTER(RoleId, Key), mod_counter_daily:get({RoleId, Key})).
-define(DB_COUNTER(RoleId, Key,Val), mod_counter_db:set({RoleId, Key}, Val)).
-define(DB_COUNTER(RoleId, Key), mod_counter_db:get({RoleId, Key})).
-define(WEEK_COUNTER(RoleId, Key, Val), mod_counter_week:set({RoleId, Key}, Val)).
-define(WEEK_COUNTER(RoleId, Key), mod_counter_week:get({RoleId, Key})).

-define(DAILY_CLEAR(RoleId), mod_counter_daily:role_clear(RoleId)).


%% 斗牛
-define(DOUNIU_ROOM, douniu_room).
-define(DOUNIU_ZHANJI, douniu_zhanji).
-define(MAX_PLAYER, 6).
-define(MIN_PLAYER, 2).
-define(HAND_CARD_NUM, 5).
-define(MAX_PAI_NUM, 52).

-define(ITEM_GOLD, 1).
-define(ITEM_GOLDCOIN, 3).

%% 离线消息 
-define(ETS_MSG, ets_msg).

%%性别（0：男，1：女）
-define( MALE,  0 ).
-define( FEMALE,1 ).


%% ----------------------------------------------
%% 装备,物品相关, 要添加请在下面写
%% ----------------------------------------------

%%聊天模式
-define(CHAT_WORLD, 1).    %% 世界
-define(CHAT_PRIVATE, 2).  %% 私人
-define(CHAT_HORN, 3).     %% 喇叭
-define(CHAT_TEAM, 4).     %% 队伍
-define(CHAT_NEIGHBOR, 5). %% 附近
-define(CHAT_SOCIETY, 6).  %% 帮会
-define(CHAT_SYSTEM, 7).   %% 系统
-define(CHAT_ARENA, 8).    %% 擂台
-define(CHAT_INFO, 9).     %% 信息
-define(CHAT_GUILDBATTLE, 10). %%帮战

-define(S2CINFO(SendPid, Msg), 
        lib_role:s2cinfo(SendPid, Msg)). 

-define(STATUS_READY,		(1 bsl 0)	).  %% 准备状态

%%
%%公式，对应配置数据库中的cfg_function数据表
%%

-define(SYSMONINT, 5*60*1000). %%收集系统监控数据时间间隔


-define( TOURIST_CHECK_CODE, 1).                   %% 游客登录检验打开
-define( TOURIST_ACCOUNT_SUFFIX, 8).               %% 游客名字后缀从id中取后多少位数


% 数据库中useable的涵义
-define(UNALBE, 0).                         % 不可用
-define(ENABLED, 1).                        % 可用
-define(LOCKED, 2).                         % 锁定
-define(DEPOT, 3).                          % 存储,用于仓库

-define(ITEM_TIANJILING, 22221).               %% 天机令ID


-endif.

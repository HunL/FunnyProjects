%% time_config.hrl
%% Created by geyc May/24/2013
%% 时间配置头文件

-ifndef(TIME_CONFIG_HRL).
-define(TIME_CONFIG_HRL,0).

-define(TIME_CONFIG_LISTEN_LECTURE,             1).                 %% 午时听道
-define(TIME_CONFIG_MELEE,			            2).					%% 仙道大乱斗
-define(TIME_CONFIG_CIRCLE_ACTIVITY,            3).                 %% 踩圈圈活动
-define(TIME_CONFIG_BEAST_HEGEMONY,             4).                 %% 万兽争霸活动

%% 读取时间配置
-define(READ_TIME_CONFIG(Key),              time_config:read_config(?MODULE, Key)).



-record(time_config, {start_time    = 0,                %% 开始时间
                      duration      = 0,                %% 活动期间
                      interval      = 0,                %% 活动周期
                      end_stage     = 0,                %% 阶段结束时间
                      id            = "",               %% 唯一标识
                      para          = []}).             %% 额外参数

-endif.

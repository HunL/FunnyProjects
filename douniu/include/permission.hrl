%% permission.hrl
%% Created by geyc Jul/08/2013
%% 限制管理头文件

-ifndef(PERMISSION_HRL).
-define(PERMISSION_HRL,0).

% 规则宏
-define(RULE_WSZB,              (1)).           % 万兽争霸


% 限制宏
-define(PA_TEAM,                (1 bsl 0)).     % 限制组队操作
-define(PA_RIDE,                (1 bsl 1)).     % 限制启程操作
-define(PA_FLY,                 (1 bsl 2)).     % 限制飞行操作
-define(PA_GOLD_ISLAND,         (1 bsl 3)).     % 限制进入金银岛
-define(PA_HIRE,                (1 bsl 4)).     % 限制雇佣
-define(PA_CLOUD,               (1 bsl 5)).     % 限制筋斗云

-endif.

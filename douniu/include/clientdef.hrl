%% Author: LiuYaohua
%% Created: 2012-7-26
%% Description: 模拟客户端的定义

-record(clientstatus,{
			pid=undefined,
			socket=undefined,
			scene_pid=undefined,
			battle_pid=undefined}).

-record(clientinfo, {
                    account = undefined,
                    pid = undefined
                    }). 

-define(CLI_PATH_SIZE, 6).

-define(TEST_SCENE_RUN_INT,  641).%%跑图压力测试时发包间隔
-define(TEST_BATTLE_RUN_INT, 4000).%%战斗压力测试时发包间隔

-record(mapcfg, {mapid=0, 
			pointwidth=1, 
			pointheight=1, 
			cellwidth = 1, 
			cellheight = 1}).
-define(ETS_CLIENTMAPCFG, ets_clientmapcfg).
-define(ETS_CLIENTINFO, ets_clientinfo).
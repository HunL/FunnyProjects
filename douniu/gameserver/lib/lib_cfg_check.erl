%% Author: Linchuansong
%% Created: 2013-04-03
%% Description: 检测配置
-module(lib_cfg_check).

%%
%% Include files
%%
-include("common.hrl").
-include("cfg_record.hrl").
%%
%% Exported Functions
%%
-export([
		 check_monster_skill_exist/0,	%% 检查cfg_monster_test表怪物身上的技能是否在cfg_skill中存在
		 check_skill_exist/3,			%% 检查怪物身上的技能是否都存在
		 show_monster_skill_list/1		%% 从数据库上查单个怪物身上的技能列表
		%
]).

-export([
		 check_bt_cfg_exist/4,			%% 检测战斗配置是否存在
		 get_task_bt_list/0	,			%% 获取任务战斗配置
		 check_all_task_battle_exist/0	%% 检查所有任务战斗配置是否存在

		 ]).
%%
%% API Functions
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 检查cfg_monster_test表怪物身上的技能是否在cfg_skill中存在
%% return = ok | {error,ErrorList}
check_monster_skill_exist()->
	SkillList = get_monster_skill_list(),
	Fun=fun(H)->
		{Id,List}=H,
		check_skill_exist(Id,List,0)
	end,
	ErrorList=lists:map(Fun, SkillList),
	ErrorNum = lists:sum(ErrorList),
	if ErrorNum > 0->
		   io:format("~n~n***************Error:cfg_monster_test has ~p Error***************~n~n~n",
					 [ErrorNum]),
		   error;
	   true ->	
		   ok
	end.

%% 检查所有任务的 战斗配置是否存在
%% Res = 0 无错； N 有n个错
check_all_task_battle_exist()->
	Task_bt_List=get_task_bt_list(),
	Fun=fun(H)->
		{Cfg_taskid,Cfg_stateid,Bt_cfg_lits,Cfg_battletype}=H,
		check_task_bt_list_exist(Cfg_taskid,Cfg_stateid,Cfg_battletype,Bt_cfg_lits,0)
	end,
	
	ErrorList=lists:map(Fun, Task_bt_List),
	ErrorNum = lists:sum(ErrorList),
	if ErrorNum > 0->
		   io:format("~n~n***************Error:cfg_taskstate has ~p BattleCfg not exist in cfg_battle_npc********~n~n~n",
					 [ErrorNum]),
		   error;
	   true ->		
		   ok
	end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 从数据库中查出所有怪的技能列表
%% return = [{MonsterID,Skill_List}]
get_monster_skill_list()->
	Sql = io_lib:format("SELECT cfg_id,cfg_skill FROM ~s.cfg_monster_test;",[?DB_CFG]),
 	io:format("Sql :~n~s~n~n",[Sql])	,
	{ok,Monstert_Skill_List}=case db_sql:get_all(Sql) of
		null ->
				io:format("Error:cfg_monster_test is empty ~n~n"); %无技能列表
		Res ->
			Fun=fun(H)->
				[Id,StrList]=H,
				Skill_weight_list = util:string_to_term(binary_to_list(StrList)),
				List = [Sid || {Sid,_w} <- Skill_weight_list],
				FlattenList = lists:flatten(List),
				{Id,FlattenList}
			end,
			M_list = lists:map(Fun, Res),
			
%%  			io:format("Sql Res:~n~p~n~n",[M_list]),
			{ok,M_list}
	end,
	Monstert_Skill_List.

%% 检查怪物身上的技能在配置文件中是否都存在
%% Res = 0 无错； N 有n个错
check_skill_exist(_MonsterId,[],Res)->
	Res;
check_skill_exist(MonsterId,[SkillId|T],Res)->
	case cfg_skill:get_cfg_skill(SkillId, 1) of
		#rcd_skill{} ->
			check_skill_exist(MonsterId,T,Res);
		{error} ->
			io:format("cfg_monster_test error:cfg_id:~p,skillId:~p~n",[MonsterId,SkillId]),
			check_skill_exist(MonsterId,T,Res+1)
	end.

%% 从数据库上查单个怪物身上的技能列表
show_monster_skill_list(MonsterId)->
	Sql = io_lib:format("SELECT cfg_id,cfg_skill FROM ~s.cfg_monster_test where cfg_id = ~p;",
						[?DB_CFG,MonsterId]),
	case db_sql:get_all(Sql) of
		null ->
				io:format("Error:cfg_monster_test, Id:~p skilllist is empty ~n~n",[MonsterId]);
		Res ->
			Fun=fun(H)->
				[Id,StrList]=H,
				Skill_weight_list = util:string_to_term(binary_to_list(StrList)),
				List = [Sid || {Sid,_w} <- Skill_weight_list],
				{Id,List}
			end,
			M_list = lists:map(Fun, Res),
			io:format("Sql Res:~n~p~n~n",[M_list])
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 检测战斗配置是否存在
%% return = true | false
check_bt_cfg_exist(Cfg_taskid,Cfg_stateid,BattleType,NpcId)->
	XX=cfg_battle_npc:get_cfg_battle_npc(NpcId,BattleType, 1),
	case XX of
			{error} ->
				io:format("Error cfg_taskstate:taskId:~p,State:~p,npcId:~p,BattleType:~p~n",
						  [Cfg_taskid,Cfg_stateid,NpcId,BattleType]),		
				false;
			#rcd_battle_npc{cfg_npcid=_Id} ->
				true
		end.

%% return = [{Cfg_taskid,Cfg_stateid,Bt_cfg_lits,Cfg_battletype}]
%% 			Bt_cfg_lits = [BattleId] | [{Career,BattleId}]
get_task_bt_list()->
	Sql = io_lib:format("SELECT cfg_taskid,cfg_stateid,cfg_battledata,cfg_battletype
			FROM ~s.cfg_taskstate
			WHERE cfg_battledata <>'[]' and cfg_battletype>0;",[?DB_CFG]),
		io:format("Sql :~n~s~n~n",[Sql])	,
	{ok,Task_bt_List}=case db_sql:get_all(Sql) of
		null ->
				io:format("Error:cfg_taskstate,is empty ~n~n");
		Res ->
			Fun=fun(H)->
				[Cfg_taskid,Cfg_stateid,StrList,Cfg_battletype]=H,
				Bt_cfg_lits = util:string_to_term(binary_to_list(StrList)),
				{Cfg_taskid,Cfg_stateid,Bt_cfg_lits,Cfg_battletype}
			end,
			M_list = lists:map(Fun, Res),
			%% 			io:format("cfg_taskstate Res:~n~p~n~n",[M_list])
			{ok,M_list}
	end,
	Task_bt_List.
%% Res = 0 无错； N 有n个错
check_task_bt_list_exist(_Cfg_taskid,_Cfg_stateid,_Cfg_battletype,[],Res)->
	Res;
check_task_bt_list_exist(Cfg_taskid,Cfg_stateid,Cfg_battletype,[Bt_cfg|T],Res)->
	Result = case Bt_cfg of
		{_Career,BattleId}->
				check_bt_cfg_exist(Cfg_taskid,Cfg_stateid,Cfg_battletype,BattleId);
		BattleId ->
				check_bt_cfg_exist(Cfg_taskid,Cfg_stateid,Cfg_battletype,BattleId)
	end,
	NRes = case Result of
			   false ->
				   Res+1;
			   true ->
				   Res
		   end,
	check_task_bt_list_exist(Cfg_taskid,Cfg_stateid,Cfg_battletype,T,NRes).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

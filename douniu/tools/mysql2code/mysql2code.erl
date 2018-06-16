%% Author: linChuansong
%% Created: 2012-7-25
%% Description: Save the config Code to Erl file 
-module(mysql2code).

%%
%% Include files
%%
%-include("common.hrl").
%-include("cfg_record.hrl").

%生成目录 
-define(DIR_CFG_CODE, "../cfg_gen_code/").
-define(DIR_INC_CODE, "../include/").
%%数据库连接
-define(DB, 		mh_mysql_conn).
-define(DB_LOG, mh_mysql_log_conn).
-define(DB_HOST, 	"192.168.51.215").
-define(DB_PORT, 	3306).
-define(DB_USER, 	"mhxd").
-define(DB_PASS, 	"bear").
-define(DB_NAME, 	"mhxd_cfg").	%% 版署服用 mhxd_cfg_verify
-define(DB_ENCODE, 	'UTF8').
-define(DB_NAME_LOG, "mhxd_log").

%%
%% Exported Functions
%%
%-export([]).
-compile(export_all).
%%
%% API Functions
%%
start()->
	%gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
	init([]).

%Opt log|[], log生成日志头文件
start(_P)->
	init([]).

stop() -> gen_server:call(?MODULE, stop ).

init([])->
	init_mysql(),
    init_log(),
%	process_terrain(),
	{ok, []}.

init_mysql() ->

	_MysqlPid = mysql:start_link(?DB, ?DB_HOST, ?DB_PORT, ?DB_USER, ?DB_PASS, ?DB_NAME, fun(_, _, _, _) -> ok end,
								 ?DB_ENCODE),
	io:format("*******************************************~n"),
	io:format(" ***  Start  Export Config ***~n"),
	io:format(" ***  DB_NAME:    ~s    ***~n",[?DB_NAME]),
	io:format("*******************************************~n~n~n"),
	%% 新方式:直接执行语句列表
	call_sql_file(),
	
%% 	%%老方式:通过执行存储过程
%% 	{ok, updated} = reCallProcedure(),%% 调用存储过程，重新生成代码
%% 	io:format("After reCallProcedure~n"),

	%% 保存成文件
 	save_code_to_file(),%% 删除旧文件，生成新文件保存代码文件

	io:format("*******************************************~n"),
	io:format(" ***  Finish  Export Config ***~n"),
	io:format(" ***  DB_NAME:    ~s    ***~n",[?DB_NAME]),
	io:format("*******************************************~n~n~n"),
	ok.

call_sql_file()->
%% io:format("Sql :~n~p~n",[Sql]),
	Fun = fun(Sql)->				  
		try
		{ ok, _Result } = db_sql:execute(Sql)
		catch
			ExType:ExPatt -> 
				io:format("ERROR,ExType:~p,ExPatt:~p~n,sql:~p~n~n",[ExType,ExPatt,Sql]),
				{error}
		end
	end,
	List = sql_list:get_sql_list(),
	lists:foreach(Fun, List),
	io:format("Config Export Is Finished.~n").
	
	
save_code_to_file() ->
	%% 如果没有结果呢
	F = fun([Table]) ->
%			%根据表名创建对应的erl文件
%			case Table of
%			[] -> error;
%			T  -> 
				FilePath =?DIR_CFG_CODE ++ binary_to_list(Table) ++ ".erl",
				io:format("~s~n~n",[FilePath]),
				%%FilePath = "d:/cfg_code/1.erl",
				file:delete(FilePath),
				{ok,S} = file:open(FilePath,[write,{encoding, utf8}]),
				save_code_head(S,binary_to_list(Table)),
				save_code_body(S,binary_to_list(Table)),
				file:close(S)
%%			end,
		end,
	lists:foreach(F, db_sql:get_all("SELECT distinct(erl_table) FROM Erl_cfg_code ")).

save_code_head(S,Table)->
	io:format(S,"~s~n~n~n~s~n~n",["%% linChuansong: code maker","%% Description: "]),
	io:format(S, "~s~s~s~n", ["-module(", Table, ")\."] ),
	io:format(S, "~s~n~s~n", ["%% Description: ","-include(\"cfg_record.hrl\")."]),
	io:format(S, "~s~n~s~n~n~n", ["%% Exported Functions ","-compile(export_all)."]).

save_code_body(S,Table)->
	Sql = "SELECT erl_code FROM Erl_cfg_code where erl_table= '" ++ Table ++ "';",
	F = fun([Erlcode]) ->
			%根据表名创建对应的erl文件
%			case Erlcode of
%			[] -> error;
%			 _ -> 
				%Scode = binary_to_list(Erlcode),
				%%io:format("ErlCode ~ts", [Erlcode]),
				io:format( S,"~ts~n~n", [Erlcode] )
				%%io:format("****ok****")
				%%io:format("~s~n", [Scode] )
		end,
	lists:foreach(F, db_sql:get_all(Sql)).


reCallProcedure() -> 
	Sql = "call Gen_erl_cfg_code(); ",
	try
	{ ok, updated } = db_sql:execute(Sql)
	catch
		ExType:ExPatt -> 
			io:format("ExType:~p,ExPatt:~p~n",[ExType,ExPatt]),
			{error}
	end.

%%	Sql = io:format("select concat('get_item(~s)->\#ets_cfg_items{cfg_item_id = \~s\' ',''",["cfg_ItemID",""])
%%
%% Local Functions
%%

%% 初始化头文件
init_log() ->
    save_hrl_code_to_file().
%% 保存代码到文件
save_hrl_code_to_file() ->
        %% 如果没有结果呢
    F = fun([Table]) ->
                FilePath =?DIR_INC_CODE ++ binary_to_list(Table) ++ ".hrl",
                io:format("~s~n~n",[FilePath]),
                file:delete(FilePath),
                {ok,S} = file:open(FilePath,[write,{encoding, utf8}]),
                save_hrl_code_head(S,binary_to_list(Table)),
                save_hrl_code_body(S,binary_to_list(Table)),
                file:close(S)
        end,
    lists:foreach(F, db_sql:get_all("SELECT distinct(erl_table) FROM erl_log_code ")).

%% 保存hrl文件头
save_hrl_code_head(S, Table) ->
    io:format(S,"~s~n~s~n~n",
              ["%% Moral: Code maker ","%% Description: Log Macro DO NOT MODIFY ME"]),
    io:format(S, "~s~s~s~n~n~n~n", ["%% FileName: ", Table, ".hrl"] ).

save_hrl_code_body(S,Table)->
    Sql = "SELECT erl_colde FROM erl_log_code where erl_table= '" ++ Table ++ "';",
    F = fun([Erlcode]) ->
                io:format( S,"~ts~n", [Erlcode] )
        end,
    lists:foreach(F, db_sql:get_all(Sql)).
%% 
%% %--------------------处理地图地形配置-------------------
%% %将地形的列表数据转换为 
%% %cfg_terrain:get(MapId, {X,Y})->open/shade/blocked
%% %cfg_terrain:get_all(MapId)->{ok,Size,[{X,Y},...]}/error
%% process_terrain()->
%% 	io:format("start process_terrain.~n"),
%% 	%%动态编译cfg_map模块并加载
%% 	MapCfgFile = ?DIR_CFG_CODE ++ "cfg_map",
%% 	{ok, cfg_map} = compile:file(MapCfgFile,[debug_info, {i,?DIR_INC_CODE}]),
%% 	{module, cfg_map} = (code:soft_purge(cfg_map) andalso code:load_file(cfg_map)),
%% 	
%% 	%%删除并重新生成cfg_terraub.erl文件
%% 	TerrainCfgFile =?DIR_CFG_CODE ++ "cfg_terrain.erl",
%% 	file:delete(TerrainCfgFile),
%% 	{ok,IoDevice} = file:open(TerrainCfgFile, [write,{encoding, utf8},delayed_write]),
%% 	
%% 	make_cfg_terrain_header(IoDevice),
%% 	%写入cfg_terrain:get(MapId, {X,Y})->open/shade/blocked
%% 	{ok,MapPointList} = check_maps(cfg_map:get_cfg_map_idList(),IoDevice,[]),
%% 	%写入cfg_terrain:get_all(MapId)->{ok,Size,[{X,Y},...]}/error
%% 	write_map_pointlist(MapPointList,IoDevice),
%% 	file:close(IoDevice),
%% 	io:format("~nprocess_terrain finished.~n").
%% 
%% check_maps([],IoDevice,MapPointList)->
%% 	io:format(IoDevice, "get(_MapId, _Pos)->blocked.~n~n",[]),  %%其余配置外的点都设为障碍点
%% 	{ok,MapPointList};
%% check_maps([MapId|RestMapIds],IoDevice, MapPointList)->
%% 	io:format("map~p.",[MapId]),
%% 	RcdMap = cfg_map:get_cfg_map(MapId),
%% 	TerrainCfg = cfg_map:get_cfg_terrain(MapId),
%% 	MapWidth = RcdMap#rcd_map.cfg_Width, 
%% 	MapHeight = RcdMap#rcd_map.cfg_Height,
%% 	
%% 	{ok,PointList} = write_terrain(MapId, TerrainCfg, MapWidth * MapHeight, MapWidth,IoDevice),
%% 	check_maps(RestMapIds,IoDevice, [{MapId,PointList}|MapPointList]).

write_terrain(MapId, TerrainList, MaxSize, MapWidth,IoDevice) ->
	write_terrain2(MapId,TerrainList,0,MaxSize, MapWidth,IoDevice, []).

write_terrain2(_MapId, _TerrainList, MaxSize, MaxSize, _MapWidth, _IoDevice, PointList) ->
	{ok, PointList};	
write_terrain2(MapId, [T|TerrainList], PointId, MaxSize, MapWidth, IoDevice, PointList)->
	State = case T of
				$0 -> open;   	%开放可走
				$1-> blocked;	%障碍
				$2-> shade		%阴影遮罩
			end,
	NewPointList = case State of
		blocked -> PointList; %障碍点不写入
		_-> 
			PointXY = lib_map:pointid_to_pointxy(PointId, MapWidth),
			io:format(IoDevice, "get(~p,~p)->~p;~n",[MapId,PointXY,State]),
			[PointXY | PointList]
	end,
	write_terrain2(MapId, TerrainList, PointId + 1, MaxSize, MapWidth, IoDevice, NewPointList).
	
make_cfg_terrain_header(IoDevice)->
	io:format(IoDevice, "%% LiuYaohua: map terrain config file. Auto generated. ~n",[]),
	io:format(IoDevice, "-module(cfg_terrain).~n", []),		
	io:format(IoDevice, "-compile(export_all).~n", []).

write_map_pointlist([],IoDevice)->
	io:format(IoDevice, "get_all(_) -> error.~n~n",[]);
write_map_pointlist([{MapId,PointList}|MapPointList],IoDevice)->
	io:format(IoDevice, "get_all(~p) -> {ok, ~p, ~w};~n",[MapId,length(PointList),PointList]),
	write_map_pointlist(MapPointList, IoDevice).
	
	
	
	
	
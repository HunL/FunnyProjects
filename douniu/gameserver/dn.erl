%%%--------------------------------------
%%% @Module  : game_server
%%% @Description:  start game
%%%--------------------------------------
-module(dn).
-export([stop/0, start/0, info/0,reload/1]).
%-define(SERVER_APPS, [game_server,sasl]).



-include("common.hrl").

%% start game server
start() ->
	io:format("dn start 1~n", []),
	ok = application:start(sasl),
	ok = application:start(crypto),
	ok = application:start(ranch),
	ok = application:start(cowlib),
    ok = application:start(cowboy),
	io:format("dn start 2~n", []),
	ok = application:start(dn).

%% stop game server
stop() ->
	?INFO("===== stop game server ====="),
	application:stop(sasl),
	application:stop(dn).

%% use this function to see runtime information
info() ->
    SchedId      = erlang:system_info(scheduler_id),
    SchedNum     = erlang:system_info(schedulers),
    ProcCount    = erlang:system_info(process_count),
    ProcLimit    = erlang:system_info(process_limit),
    ProcMemUsed  = erlang:memory(processes_used),
    ProcMemAlloc = erlang:memory(processes),
    MemTot       = erlang:memory(total),
    io:format( "runtime information:
                       ~n   Scheduler id:                         ~p
                       ~n   Num scheduler:                        ~p
                       ~n   Process count:                        ~p
                       ~n   Process limit:                        ~p
                       ~n   Memory used by erlang processes:      ~p
                       ~n   Memory allocated by erlang processes: ~p
                       ~n   The total amount of memory allocated: ~p
                       ",
                            [SchedId, SchedNum, ProcCount, ProcLimit,
                             ProcMemUsed, ProcMemAlloc, MemTot]),
      ok.

reload(Module)->
	code:soft_purge(Module) andalso code:load_file(Module).


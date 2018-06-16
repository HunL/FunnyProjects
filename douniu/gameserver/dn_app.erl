%%%-----------------------------------
%%% @Module  : dn_app
%%% @Description: 
%%%-----------------------------------
-module(dn_app).
-behaviour(application).
-export([start/2, stop/1 ,prof/1]).
-include("common.hrl").
-include("record.hrl").

-define(C_ACCEPTORS,  100).

start(_Type, _StartArgs) ->
	io:format("dn app start 2~n", []),
	Routes    = routes(),
    Dispatch  = cowboy_router:compile(Routes),
    Port      = port(),
	io:format("Port = ~p~n", [Port]),
    TransOpts = [{port, Port}],
    ProtoOpts = [{env, [{dispatch, Dispatch}]}],
    {ok, _}   = cowboy:start_http(http, ?C_ACCEPTORS, TransOpts, ProtoOpts),
 
	mh_env:init_env(),

%	prof(start),
	{ok, SupPid} = dn_sup:start_link(dn_sup),%start supervisor process

	TcpPort = mh_env:get_env(port), 
	io:format("Port = ~p~n", [TcpPort]),
    mh_networking:start([TcpPort]),

    {ok, SupPid}.

stop(_State) ->   
    void. 

prof(start)->
	%fprof:trace([start, {procs, [whereis(dn_sup)]}]);
	fprof:trace(start);
prof(stop)->
	fprof:trace(stop),
	fprof:profile(),
	fprof:analyse({dest, "prof.txt"}).

	
%% 
%% prof(start)->
%% 	fprof:trace(start,{procs,[whereis(dn_sup)]});
%% prof(stop)->
%% 	fprof:trace(stop),
%% 	fprof:profile(),
%% 	fprof:analyse({dest, "prof.txt"}).

%% ===================================================================
%% Internal functions
%% ===================================================================
routes() ->
    [
     {'_', [
            {"/", dn_handler, []}
           ]}
    ].
 
port() ->
    case os:getenv("PORT") of
        false ->
            {ok, Port} = application:get_env(http_port),
            Port;
        Other ->
            list_to_integer(Other)
    end.




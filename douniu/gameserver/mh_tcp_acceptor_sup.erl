%%%-----------------------------------
%%% @Module  : mh_tcp_acceptor_sup
%%% @Description: tcp acceptor 监控树
%%%-----------------------------------
-module(mh_tcp_acceptor_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local,?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {{simple_one_for_one, 10, 10},
          [{mh_tcp_acceptor, {mh_tcp_acceptor, start_link, []},
            transient, brutal_kill, worker, [mh_tcp_acceptor]}]}}.

%%%-----------------------------------
%%% @Module  : mh_tcp_listener_sup
%%% @Description: tcp listerner 监控树
%%%-----------------------------------

-module(mh_tcp_listener_sup).

-behaviour(supervisor).

-export([start_link/1]).

-export([init/1]).

start_link(Port) ->
    supervisor:start_link(?MODULE, {10, Port}).

init({AcceptorCount, Port}) ->
    {ok,
        {{one_for_all, 10, 10},
            [
                {
                    mh_tcp_acceptor_sup,
                    {mh_tcp_acceptor_sup, start_link, []},
                    transient,
                    infinity,
                    supervisor,
                    [mh_tcp_acceptor_sup]
                },
                {
                    mh_tcp_listener,
                    {mh_tcp_listener, start_link, [AcceptorCount, Port]},
                    transient,
                    100,
                    worker,
                    [mh_tcp_listener]
                }
            ]
        }
    }.

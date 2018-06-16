%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2012-7-9
%%% -------------------------------------------------------------------
-module(mod_role_sup).

-behaviour(supervisor).
-export([start_link/0, init/1]).

start_link() ->
	supervisor:start_link(?MODULE, []).
	
init([]) -> 
	{
	 ok, 
	 {{one_for_one, 3, 10}, []}
	}. 
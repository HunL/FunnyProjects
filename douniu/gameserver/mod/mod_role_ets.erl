%% @author LiuYaohua
%% 此模块记录全局mhrole的ets表，以role进程pid作为key


-module(mod_role_ets).
-export([init/0, 
		 set_mhrole/1,get_mhrole/1,del_mhrole/1]).

-include("record.hrl").
-include("common.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).

init()->
	ets:new(role_ets, [public, set, named_table, 
					   {keypos,#mhrole.pid}, %%以role进程pid为key
					   {write_concurrency,true}]),%%写操作多于读操作，设置write_concurrency
	ok.

%%更新mhrole到ets表
set_mhrole(MhRole)->
	case MhRole#mhrole.pid of 
		undefined -> ok;
		_->	ets:insert(role_ets, MhRole)
	end.

get_mhrole(Pid)->
	case ets:lookup(role_ets, Pid) of
		[MhRole] -> MhRole;
		[] -> error
	end.

del_mhrole(Pid)->
	ets:delete(role_ets, Pid).

%% ====================================================================
%% Internal functions
%% ====================================================================



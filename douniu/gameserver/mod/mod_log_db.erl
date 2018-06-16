%% Author: LiuYaohua
%% Created: 2012-7-30
%% Description: 日志数据库记录进程
-module(mod_log_db).
-behaviour(gen_server).
%%
%% Include files
%%
-include("common.hrl").

-define(LOG_DB_ETS, ets_log_sql).

%%
%% Exported Functions
%%
-export([init/1, do_log/3, start_link/0, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%
%% API Functions
%%
-record(state, {ets=0}).

-record(mhlogsql, {
			  mod_type = {undefined, undefined},
              num = 0,
              sql = undefined
              }).

start_link()->
	gen_server:start({local,?MODULE}, ?MODULE, [], []).

%% 初始化日志参数
init([]) ->

    Ets = ets:new(?LOG_DB_ETS, [public, set, named_table, {keypos, #mhlogsql.mod_type}]),
    Status = #state{ets = Ets},

    File = filelib:wildcard("*.beam"),
    do_init(File, Ets),
    {ok,Status}.

%% 初始化日志参数
do_init([], _Ets) ->
    ok;
do_init([Head | Tail], Ets) ->
    Mod = list_to_atom(filename:basename(Head, ".beam")),
    try
        case Mod:init_log_sql() of
            {ok, Sql} ->
                [log_init(A, Ets) || A <- Sql, erlang:length(A) > 0];
            _ -> []
        end
    catch 
        _T:_R ->
%%             ?INFO("mod:~p init_log_sql error ~p:~p", [Mod, T, R]),
            []
    end,
    do_init(Tail, Ets).


log_init([Mod, Type, Num, SqlStr], Ets) ->
	Mhlogsql =#mhlogsql{mod_type = {Mod, Type}, num = Num, sql = SqlStr},
	ets:insert(Ets, Mhlogsql).


do_log(Mod, Type, Args) ->
    gen_server:cast(?MODULE, {do_log, [Mod, Type, Args]}).

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({do_log, [Mod, Type, Args]}, State) ->
    try 
        L =ets:lookup(State#state.ets, {Mod, Type}),
        case L of
            [] ->
                ?ERR("Logdb error Type NOT FOUND Mod:~p Type:~p Args~p", 
                     [Mod, Type, Args]);
            [Sql] ->
				Args2 = [ db_sql:sql_format2(Arg) || Arg<-Args], %%对特殊符号进行转义
                Sql2 = io_lib:format(Sql#mhlogsql.sql, Args2),
				db_sql:execute(?DB_LOG_CONN, Sql2)
        end
    catch 
        _:_ ->
            ?ERR("Logdb error Mod:~p Type:~p Args~p", [Mod, Type, Args])
    end,
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.
%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


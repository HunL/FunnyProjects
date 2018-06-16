%% Author: Administrator
%% Created: 2011-7-21
%% Description: TODO: Add description to mod_db_operate
-module(mod_db_server).

-behaviour(gen_server).
%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start_link/0,
		 update/2,
		 execute_batch/2,
		 execute_one/2,
		 execute_log/1]).

-export([init/1, handle_info/2, handle_cast/2, terminate/2,handle_call/3,
		 code_change/3]).
-include ("common.hrl").
%%
%% API Functions
%%

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%=========================================================
%% execute just one sql command
%% parameter:
%%		Id: player account id, used to decide which db to execute this command
%%		SqlCmd: a sql command
execute_one(Id, SqlCmd) ->
	gen_server:cast(?MODULE, {one_sql, Id, SqlCmd}).

%%=========================================================
%% execute batch sql command in the exact order as it in SqlCmdList
%% parameter:
%%		Id: player account id
%%		SqlCmdList: a list of sql command which associate the player id Id
execute_batch(Id, SqlCmdList) ->
	gen_server:cast(?MODULE, {batch_sql, Id, SqlCmdList}).

execute_log(SqlCmd) ->
	gen_server:cast(?MODULE, {log_sql, SqlCmd}).


update(last_login_time, [Time, Id]) -> 
	Sql = io_lib:format(<<"update `GD_Account` "
						  "set `gd_LastLoginTime` = ~p "
						  "where gd_AccountID = ~p ">>, [Time, Id]),
	execute_one(Id, Sql).
%% 	{{Year, Month, Day}, {Hour, Minute, Second}} = Time,
%% 	Sql = io_lib:format(
%% 			<<"update `GD_Account` "
%% 			  "set `gd_LastLoginTime` = \"~p-~p-~p ~p:~p:~p\" "
%% 			  "where gd_AccountID = ~p ">>, 
%% 			[Year, Month, Day, Hour, Minute, Second, Id]),
	

%% Callback Functions	
init([]) ->
   {ok, null}.
%%
%% Local Functions
%%

%% the Id parameter in the first tuple is neccessary,
%% because I need it to decided which database to execute the sql command
%% note: SqlCmdList is a list of sql command which execute from begin to end 
handle_info({sql, Id, SqlCmdList}, State) ->
	try ([_Cmds | _Rest] = SqlCmdList) of
		_ ->
			db_execute(Id, SqlCmdList)
	catch
		_:_ ->
			?INFO("~n!!!!!!!!!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!!!!!!!!: "
					  "Caller past non-list of sqlcmd to mod_db_server"
					  "This is considered as a fatal error!"
					  "Please check you code right now!"
					  "The last in sqlcmd was: "
					  "~p", [SqlCmdList])
	end,
	{noreply, State};

handle_info(_Req, State) ->
    {noreply, State}.

handle_cast(Msg, State)->
	try
		R = do_cast(Msg, State),
		R
	catch
		ExType:ExPattern ->
			?ERR("ExType: ~p, ExPattern: ~p",[ExType,ExPattern]),
			?ERR("StackTrace:~p",[erlang:get_stacktrace()]),
			{noreply, State}
	end.

do_cast({one_sql, Id, SqlCmd}, State) ->
	db_execute(Id, [SqlCmd]),
    {noreply, State};

do_cast({batch_sql, Id, SqlCmdList}, State) ->
	db_execute(Id, SqlCmdList),
    {noreply, State}.

terminate(Reason, _State) ->
	?INFO("~p terminate, reason: ~p", [?MODULE, Reason]),
    ok.

db_execute(_Id, []) -> ok;
db_execute(Id, [SqlCmd | Rest]) ->
%% 	?INFO("Sqlcmd: ~s~n", [SqlCmd]),
	db_sql:execute(SqlCmd),
	db_execute(Id, Rest).

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
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
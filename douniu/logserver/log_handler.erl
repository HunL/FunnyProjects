%%% -------------------------------------------------------------------
%%% Author  : LiuYaohua
%%% Description : Logæå°
%%%
%%% Created : 2012-7-30
%%% -------------------------------------------------------------------
-module(log_handler).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([print/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3,start_link/0]).

%% ====================================================================
%% External functions
%% ====================================================================
print(Node, Str)->
	gen_server:cast({?MODULE, Node}, {print, Str}).

%% ====================================================================
%% Server functions
%% ====================================================================
start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).
	
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
	%%连接server节点
	gen_server:cast(self(),{connect}),
	{ok, 0}.

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
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({print, Str}, State)->
	try	
		io:format(Str)
	catch
		_:_-> ok
	end,
	{noreply, State};

handle_cast({connect}, State)->
	util:sleep(1000),
	S = list_to_atom(mh_env:get_env(server_node)),
	io:format("**Connecting to GameServer: ~p. ~n",[S]),

	util:sleep(5000),
	true = net_kernel:connect_node(S),
	io:format("**node(): ~p. ~n",[node()]),

%	ok = mod_log_print:logserver_connect(node()),
	case mod_log_print:logserver_connect(node()) of
		ok ->
			io:format("log_handler  logserver_connect susseed~n", []);
		Err ->
			io:format("log_handler  logserver_connect fail, Err=~p~n~n~n", [Err])
	end,
	io:format("ok.~n"),
	{noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

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
	mod_log_print:logserver_disconnect(),
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
    

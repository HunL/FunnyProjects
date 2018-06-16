%% @author 4399
%% @doc @todo Add description to mod_log_print.


-module(mod_log_print).
-behaviour(gen_server).
-include("common.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0, print_error/4, print_info/4, logserver_connect/1,logserver_disconnect/0]).

start_link()->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

%% ====================================================================
%% Behavioural functions 
%% ====================================================================
-record(printstate, {iodevice = undefined, 
					logserver_node = undefined}).

print_error(Module, Line, Format, Args)->
	gen_server:cast(?MODULE, {print_error, Module, Line, Format, Args}).

print_info(Module, Line, Format, Args)->
	gen_server:cast(?MODULE, {print_info, Module, Line, Format, Args}).

logserver_connect(Node)->
	gen_server:call({?MODULE, mh_env:get_env_atom(server_node)}, {logserver_connect, Node}, ?RPC_TIMEOUT).
%	gen_server:call(?MODULE, {logserver_connect, Node}, ?RPC_TIMEOUT).

logserver_disconnect()->
	gen_server:cast({?MODULE, mh_env:get_env_atom(server_node)}, logserver_disconnect).
%	gen_server:cast(?MODULE, logserver_disconnect).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
	Result :: {ok, State}
			| {ok, State, Timeout}
			| {ok, State, hibernate}
			| {stop, Reason :: term()}
			| ignore,
	State :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([]) ->
	LogFile = case mh_env:get_env(txtlogfile) of
				undefined -> 
					io:format("~n~nget_env txtlogfile fail~n~n~n", []),
					"log.txt";
			  	CfgLogFile -> 
					io:format("~n~nget_env txtlogfile susseed, CfgLogFile=~p~n~n~n", [CfgLogFile]),
					CfgLogFile
		  end,
	{ok,IoDevice} = file:open(LogFile,[write,{encoding, utf8},append,delayed_write]),
	%打印一行系统启动标识
	?ERR("System Booted"),
	io:format("mod_log_print started!!!! iodevice=~p~n", [IoDevice]),
    {ok, #printstate{iodevice = IoDevice}}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
	Result :: {reply, Reply, NewState}
			| {reply, Reply, NewState, Timeout}
			| {reply, Reply, NewState, hibernate}
			| {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason, Reply, NewState}
			| {stop, Reason, NewState},
	Reply :: term(),
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
handle_call({logserver_connect, Node}, _From, PrintState) ->
    %io:format(PrintState#printstate.iodevice, "nnnnnnnnnnnnnnnnnnmmmmmmmmmm~p~n", [Node]),
%    io:format("mod_log_print   logserver_connect susseed : node=~p~n", [Node]),
    ?INFO("mod_log_print   logserver_connect susseed : node=~p~n", [Node]),
    {reply, ok, PrintState#printstate{logserver_node = Node}};

handle_call(Msg, _From, PrintState)->
	io:format("no handle msg, MsgMsgMsgMsgMsgMsg=~p~n", [Msg]),
% 	?INFO("no handle msg, MsgMsgMsgMsgMsgMsg=~p~n", [Msg]),
    
	{reply, no_handle_call, PrintState}.

%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast({print_error, Module, Line, Format, Args}, PrintState) ->
	try
		{{Year, Month, Day}, {Hour, Min, Sec}} = erlang:localtime(),
		Str = io_lib:format("[ERR] ~p/~p/~p ~p:~p:~p ~p:~p " ++	Format ++ "~n",
				[Year, Month, Day, Hour, Min, Sec, Module, Line | Args]),
		io:format(PrintState#printstate.iodevice, Str,[]),
		print_to_remote(Str, PrintState)
	catch _:_ -> ok end,
	
    {noreply, PrintState};

handle_cast({print_info, Module, Line, Format, Args}, PrintState)->
	io:format("~nprint_info~n~n~n", []),
%	?INFO("~nprint_info~n~n~n", []),
	try
		{{Year, Month, Day}, {Hour, Min, Sec}} = erlang:localtime(),
		Str = io_lib:format("[INFO] ~p/~p/~p ~p:~p:~p ~p:~p " ++	Format ++ "~n",
				[Year, Month, Day, Hour, Min, Sec, Module, Line | Args]),
%		io:format("~nStr =~p~n", [Str]),
		io:format("~nprint_info22222~n~n~n", []),
%		?INFO("~nStr =~p~n", [Str]),%TODO:why crash?
		print_to_remote(Str, PrintState)
	catch _:_ -> ok end,
	
    {noreply, PrintState};

handle_cast(logserver_disconnect, PrintState)->
	?INFO("logserver disconnect handle cast...............~n", []),
%	io:format("logserver disconnect handle cast...............~n", []),
	{noreply, PrintState#printstate{logserver_node = undefined}};

handle_cast(_Msg, PrintState)->
	{noreply, PrintState}.

%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info(_Info, State) ->
    {noreply, State}.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
	Reason :: normal
			| shutdown
			| {shutdown, term()}
			| term().
%% ====================================================================
terminate(_Reason, _State) ->
    ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
	Result :: {ok, NewState :: term()} | {error, Reason :: term()},
	OldVsn :: Vsn | {down, Vsn},
	Vsn :: term().
%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================
print_to_remote(Str, PrintState)->
	io:format("print_to_remote~nPrintState#printstate.logserver_node=~p~n", [PrintState#printstate.logserver_node]),
	case PrintState#printstate.logserver_node of
		undefined -> ok;
		Node-> 
			try
				log_handler:print(Node, Str)
			catch _:_->ok end
	end.
		


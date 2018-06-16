-module(mh_simple_timer).

-include("common.hrl").
-behaviour(gen_server).

-export([start_timer/3, cancel_timer/1, tick/2]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, start_link/0]).

-export([info/1, info/0, add_timer/1, test/1, handle_timeout/1, nowsec/0]).

%% 数据
-record(timer_data, {
        ref,
        mod,        % 回调模块
        % time,       % timer时间
        msg,        % 对应的msg
        invoke_time % 触发时间
        }).

-define(TIME, 1000).
-define(TIMER_KEY_SEC, timer_key_sec).


start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, _Ref} = timer:apply_interval(?TIME, ?MODULE, tick, [self(), tick]),
    register(?MODULE, self()),
    ets:new(?TIMER_KEY_SEC, [named_table, public, bag, {keypos, #timer_data.invoke_time}]),
    NowSec = util:get_now_second(),
    {ok, NowSec}.

handle_call({nowsec},_From,State)->
	{reply,State,State};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast({tick}, State) ->
    NowSec = State + 1,
    List = ets:lookup(?TIMER_KEY_SEC, NowSec),
    do_timeout_msg(List),
    ets:delete(?TIMER_KEY_SEC, NowSec),
%io:format("delete:~p~n",[NowSec]),
    {noreply, NowSec};

handle_cast({start_timer, Ref, Mod, Time, Msg}, State) ->
    NowSec = State,
    TimeSec = util:ceil(Time/1000),
    InvTime = NowSec + TimeSec,
    Timer = #timer_data{
        ref = Ref,
        mod = Mod,
        msg = Msg,
        invoke_time = InvTime
        },
    case TimeSec of
        0 ->
            do_msg(Timer);
        _ ->
            ets:insert(?TIMER_KEY_SEC, Timer),
            put(Ref, InvTime)
    end,
    %io:format("start_timer:~p~n",[{InvTime, Timer}]),
    {noreply, State};

handle_cast({cancel_timer, Ref}, State) ->
    Time = get(Ref),
    case Time of
        undefined ->
            ok;
        _ ->
            case ets:match_object(?TIMER_KEY_SEC, #timer_data{invoke_time = Time, ref = Ref, _ = '_'}) of
                [] ->
                    ok;
                [Timer] ->
                    ets:delete_object(?TIMER_KEY_SEC, Timer)
            end,

            erase(Ref)
    end,
    {noreply, State};

handle_cast({info}, State) ->
    io:format("All List: ~n"),
    Fun = fun(Ele, Num) ->
        case Ele of
            {Ref, Timer} ->
                io:format("Time:~p Mod:~p Ref:~p~n", 
                    [Timer#timer_data.invoke_time, 
                    Timer#timer_data.mod,
                    Timer#timer_data.ref%Timer#timer_data.msg
                    ]);
            {Ref} ->
                io:format("~p ~n", [Ref])
        end,
        Num + 1
    end,
    Size = ets:foldl(Fun, 0, ?TIMER_KEY_SEC), 
    io:format("Size: ~p ~n", [Size]),
    io:format("Cancel List: ~n"),
    % io:format("all : ~p ~n", [Dict]),
    % io:format("all size : ~p ~n", [dict:size(Dict)]),
    {noreply, State};

handle_cast({info, X}, State) ->
    % List = erlang:get(X),
    % io:format("~p This Time have Timee:~p ~n", [X, List]),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

do_msg(Timer) ->
    Mod = Timer#timer_data.mod,
    Msg = Timer#timer_data.msg,
    case catch Mod:handle_timeout(Msg) of
        ok ->
            % io:format("Mod: ~p Msg: ~p ~n", [Mod, Msg]),
            Timer#timer_data.ref;
        _Reason ->
            % io:format("handle_timeout err Mod:~p, Msg:~p~n", [Mod, Msg]),
            Timer#timer_data.ref
    end.

% {ref, error} | {ref, timer} = timerlist
do_timeout_msg([]) ->
    ok;
do_timeout_msg([Timer|T]) ->
    do_msg(Timer),
    erase(Timer#timer_data.ref),
    do_timeout_msg(T).

tick(Pid, tick) ->
    gen_server:cast(Pid, {tick}),
    ok.

start_timer(Mod, Time, Msg) ->
    Ref = erlang:make_ref(),
    gen_server:cast(?MODULE, {start_timer, Ref, Mod, Time, Msg}),
    Ref.

cancel_timer(Ref) ->
    gen_server:cast(?MODULE, {cancel_timer, Ref}),
    ok.

get_today_time(TimeSec) when TimeSec =< ?SECONDS_PER_DAY->
    TimeSec;
get_today_time(TimeSec) when TimeSec > ?SECONDS_PER_DAY->
    get_today_time(TimeSec - ?SECONDS_PER_DAY).

get_today_midnight_sec() ->
    util:get_now_second() - get_now_in_today().

get_now_in_today() ->
    {Hour, Min, Sec} = time(),
    Hour*3600 + Min*60 + Sec.

info() ->
    gen_server:cast(?MODULE, {info}).

info(X) ->
    gen_server:cast(?MODULE, {info, X}).

% --------------------------- test ------------------------------
handle_timeout({N}) ->
    % ?INFO("~p", [N]),
    Pid = erlang:pid(0,0,0),
    gen_server:cast(Pid, {}),
    ok.

test(N) ->
    add_timer(N),
    ok.

add_timer(0) ->
    ok;
add_timer(N) ->
    R = mod_rand:int(180),
    ?ADDTIMER(?MODULE, R*1000, {N}),
    add_timer(N-1).

nowsec()->
	gen_server:call(?MODULE,{nowsec}).
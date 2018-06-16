%%Author: gavin
%%Creat: 2012-3-8
%%Description: 数据监控模块，监控每个在线玩家的数据包情况
%%   数据包异常时将角色踢下线，异常情况有以下几种:
%%1.玩家发包速度异常,每PKT_MAX_CNT个包最少间隔时间为MIN_TIME秒
%%2.收到长度超过一定范围(PKT_MAX_LENGTH)的数据包，超过一定次数(PKT_MAX_LENGTH_CNT);
%%3.当数据包解析或处理出错时，超出一定次数(PKT_MAX_ERR_CNT)

-module(mod_monitor).

-include("common.hrl").
-include("record.hrl").
-include("log.hrl").

-export([init/1, 
        recv_packet/2,
        recv_error_packet/1,
        recv_packet/3, 
        open_monitor/2,
        init_log_sql/0
    ]).

%-compile(export_all).

-define(TAB_PACKET, data_monitor).

%%每PKT_MAX_CNT个包最少间隔时间为MIN_TIME毫秒,否则踢下线
-define(PKT_MAX_CNT, 300). 
-define(MIN_TIME, 10000).  

%%充许的包最大长度
-define(PKT_MAX_LENGTH, 4092).
%%充许超过最大包长度的数据包个数
-define(PKT_MAX_LENGTH_CNT, 1).

%%充许的最大错误包个数
-define(PKT_MAX_ERR_CNT, 10).

-record(pkt_monitor,{
    is_opened = true, 
    start_time = 0,  %counter start time
    pkt_cnt = 0, %packet counter
    big_pkt_cnt = 0, %big packet counte
    err_pkt_cnt = 0 %error packet counte
    }).
    
-define(PKT_EXCE_TOO_FAST,1).
-define(PKT_EXCE_TOO_LARGE, 2).
-define(PKT_EXCE_TOO_MANY_ERROR, 3).

%%
%%API
%%
init_log_sql() ->
    {ok, [
          [?MODULE, log_packet_monitor, 4,
           "INSERT INTO log_packet_monitor(log_time, log_roleid,log_type, log_dsp) 
            VALUES(NOW(),~p,~p,~p);"]
          ]}.

recv_packet(RolePid, PktLen) ->
    gen_server:cast(RolePid, {recv_packet, PktLen}).

recv_error_packet(RolePid) ->
    gen_server:cast(RolePid, recv_error_packet).

init(MhRole)->
    CurTime = get_now_millisecond(),
    PktMon = #pkt_monitor{start_time = CurTime},
    _NMhRole = MhRole#mhrole{pkt_monitor = PktMon}.
   %ets:new(?TAB_PACKET, [public, set, named_table, {keypos,1}]),

recv_packet(MhRole, PktLen, IsErrPkt) ->
    case (MhRole#mhrole.pkt_monitor)#pkt_monitor.is_opened of
        true ->
            recv_packet_1(MhRole, PktLen, IsErrPkt);
        _ ->
            {ok, MhRole}
    end.

%%接收到数据包
%%PktLen 包的长度
%%IsErrPkt true|false,是否错误包
recv_packet_1(MhRole, PktLen, IsErrPkt) ->
    RoleId = MhRole#mhrole.roleid,
    NPktMon = 
    case do_recv_packet(MhRole#mhrole.pkt_monitor, PktLen, IsErrPkt) of
        {ok, PktMon} ->
            PktMon;
        {{kick, ExceType, Reason}, PktMon} ->
            ?INFO("kick role ~p, ~p", [RoleId, Reason]),
            ?DBLOG(?MODULE, log_packet_monitor, [RoleId, ExceType,
                    db_sql:sql_format(Reason)]),
            mod_role:kick_off(MhRole#mhrole.pid, Reason),
            PktMon
    end,
    NMhRole = MhRole#mhrole{pkt_monitor = NPktMon},
    {ok, NMhRole}.

%%打开关闭数据包监控
%%Enable true|false
%%return {ok, #mhrole{}}
open_monitor(MhRole, Enable) ->
    PktMon = MhRole#mhrole.pkt_monitor,
    NPktMon = PktMon#pkt_monitor{is_opened = Enable},
    NMhRole = MhRole#mhrole{pkt_monitor = NPktMon},
    {ok, NMhRole}. 

%%
%%internal functions
%%
%%return {ok, #pkt_monitor} | {{kick, Reason}, #pkt_monitor}
do_recv_packet(PktMon, PktLen, IsErrPkt) ->
    {Rt1, PktMon1} =  check_packet_speed(PktMon),
    {Rt2, PktMon2} = check_big_packet(PktMon1, PktLen),
    {Rt3, PktMon3} = 
    if
        IsErrPkt == true ->
            check_err_packet(PktMon2);
        true ->
            {ok, PktMon2}
    end,

    Rt = 
    if
        Rt1 /= ok ->
            Rt1;
        Rt2 /= ok ->
            Rt2;
        Rt3 /= ok ->
            Rt3;
        true -> ok
    end,
    {Rt, PktMon3}.

%%return {ok, #pkt_monitor} | {kick ,#pkt_monitor}
check_packet_speed(PktMon)->
    Cnt = PktMon#pkt_monitor.pkt_cnt + 1,  
    StartTime = PktMon#pkt_monitor.start_time,
    {Rt, NStartTime, NCnt} =
    case Cnt >= ?PKT_MAX_CNT of
        true ->
            CurTime = get_now_millisecond(), 
            case CurTime - StartTime of
                Time when Time < ?MIN_TIME ->
                  Reason = lists:flatten(io_lib:format("packet send too fast,~ppkt/~pms",
                        [Cnt, Time])),
                  ?INFO("~s", [Reason]),
                  {{kick,?PKT_EXCE_TOO_FAST, Reason}, CurTime, 0};
                 Time ->
                   ?INFO("packet speed: ~ppkt/~pms", [Cnt, Time]),
                   {ok, CurTime, 0}
            end;
        false ->
            {ok, StartTime, Cnt}
    end,
    NPktMon = PktMon#pkt_monitor{start_time = NStartTime, pkt_cnt = NCnt},
    {Rt, NPktMon}.

check_big_packet(PktMon, PktLen) ->
    BigPktCnt1 = PktMon#pkt_monitor.big_pkt_cnt, 
    BigPktCnt2 = BigPktCnt1 + bool2int(PktLen > ?PKT_MAX_LENGTH),
    Rt = 
    case BigPktCnt2 > ?PKT_MAX_LENGTH_CNT of
        true ->
            Reason = lists:flatten(io_lib:format("packet too large, ~p", [PktLen])),
            ?INFO("~s", [Reason]),
            {kick,?PKT_EXCE_TOO_LARGE, Reason};
        _ -> ok
    end,
    NPktMon = PktMon#pkt_monitor{big_pkt_cnt = BigPktCnt2},
    {Rt, NPktMon}.

check_err_packet(PktMon) -> 
    PktCnt = PktMon#pkt_monitor.err_pkt_cnt + 1, 
    Rt = 
    case PktCnt > ?PKT_MAX_ERR_CNT of
        true -> 
            Reason = io_lib:format("too many error packets",[]),
            {kick, ?PKT_EXCE_TOO_MANY_ERROR, Reason};
        _ -> ok
    end,
    NPktMon = PktMon#pkt_monitor{err_pkt_cnt = PktCnt},
    {Rt, NPktMon}.


bool2int(Bool)->
    case Bool of
        true ->1;
        false -> 0
    end.

       
%% 获取当前毫秒数(从1970年0:0:0开始),
get_now_millisecond() ->
    {MegaSecs, Secs, MicroSecs} = erlang:now(),
    %注意，这里为了效率考虑忽略了百万秒
    round(MegaSecs*1000000*1000 + Secs * 1000 + MicroSecs/1000).

%%only for test
pack_big_pkt()->
   Tmp = <<"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz">>,
   Data = <<Tmp/binary, Tmp/binary>>,
   pt:pack(9999, Data).



                        


    

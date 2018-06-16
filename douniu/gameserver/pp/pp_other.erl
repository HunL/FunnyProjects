%% Author: gavin
%% Created: 2013-4-9
%% Description: 其它协议
%%
-module(pp_other).

-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").

-export([handle/3]).

%%联系GM
%handle(?PP_CONTACT_GM, MhRole, [Type, Title, Content]) ->
%    Flag = 
%    case mod_complain:complain(Type, Title, Content) of
%        ok -> 0;
%        too_fast -> 1;
%        _ -> 2
%    end,
%    send_response(MhRole#mhrole.roleid, ?PP_CONTACT_GM_ACK, [Flag]);

%%举报非法信息
%handle(?PP_REPORT, MhRole, [Type, TarRoleName, Content, Reason]) ->
%    RtCode = 
%    case mod_report:report(MhRole, Type, TarRoleName, Content, Reason) of
%       ok -> 
%           %更新一下剩余次数
%           handle(?PP_REPORT_TIMES, mod_role:get_mhrole(), {}), 
%           0;
%        {error, ErrCode} ->
%            ?INFO("report error: ~p", [ErrCode]),
%            ErrCode
%    end,
%    send_response(MhRole#mhrole.roleid, ?PP_REPORT_ACK, [RtCode]);

%%举报剩余次数
%handle(?PP_REPORT_TIMES, MhRole, _Data) ->
%    LeftTimes = mod_report:get_left_report_times(MhRole),
%    send_response(MhRole#mhrole.roleid, ?PP_REPORT_TIMES_ACK, [LeftTimes]);

handle(Cmd, _RoleInfo, Param)->
    ?INFO("unhandle command:~p, param:~p", [Cmd, Param]),
    ok.    

send_response(RoleId, ReCmd, Param) ->
    {ok, Data} = pt_33:write(ReCmd, Param),
    lib_send:send_to_roleid(RoleId, Data),
    ok.


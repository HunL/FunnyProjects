%% Author: Administrator
%% Created: 2012-7-17
%% Description: TODO: Add description to pp_role
-module(pp_role).

%%
%% Include files
%%
-include("proto.hrl").
-include("record.hrl").
-include("common.hrl").
-include("log.hrl").
%%
%% Exported Functions
%%
-export([handle/3]).


%%
%% API Functions
%%
handle(?PP_ACCOUNT_GET_ROLE_DETAIL,RoleInfo,_Data) ->
	?INFO("pp_role PP_ACCOUNT_GET_ROLE_DETAIL~n"),
	{ok,Bin} = pt_10:write(?PP_ACCOUNT_ROLE_DETAIL, RoleInfo),
    %?INFO("#####~p",[RoleInfo]),
	lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin),
	ok;

handle(?PP_ACCOUNT_GET_ROLE_ATTR, RoleInfo, _Data)->
	{ok,Bin} = pt_10:write(?PP_ACCOUNT_ROLE_ATTR, RoleInfo#mhrole.roleattr),
	lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin),
	ok;

handle(?ACCOUNT_ROLE_SCHOOL, RoleInfo, _Data)->
    _RoleInfo2 = mod_school:handle_school(?ACCOUNT_ROLE_SCHOOL, 
                                         RoleInfo, _Data),
    ok;

handle(?ACCOUNT_ROLE_UPGRADES, RoleInfo, _Data)->
    _RoleInfo2 = mod_school:handle_school(?ACCOUNT_ROLE_UPGRADES, 
                                         RoleInfo, _Data),
    ok;

handle(?ACCOUNT_ROLE_CONTRIBUTE, RoleInfo, [Num])->
    case mod_lock:need_input_password(RoleInfo) of
        true ->
            mod_lock:send_input_password(RoleInfo, {?MODULE, ?ACCOUNT_ROLE_CONTRIBUTE, [Num]});
        false ->
            _RoleInfo2 = mod_school:handle_school(?ACCOUNT_ROLE_CONTRIBUTE, 
                                                 RoleInfo, Num)
    end,
    ok;

handle(?PP_ACCOUNT_ONLINE_TIME, RoleInfo, [Flag]) ->
	mod_role:do_syn_time(RoleInfo#mhrole.send_pid),
	case Flag of
		0 ->%%是验证用户
			ok;
		1 ->
			%% 向防沉迷对象发送当天累积在线时间
			mod_role:send_acc_online_time(RoleInfo#mhrole.roleid, 
										  RoleInfo#mhrole.send_pid)
	end,
	ok;

%% 剔除在线时长满3小时的防沉迷玩家
%handle(?PP_ACCOUNT_KICKOFF_ONLINE_3HS, RoleInfo, []) ->
%	try
%		lib_role:replace_acc_online_and_offline_time(RoleInfo#mhrole.roleid, 
%													 ?MAX_ONLINE_SECONDS, 
%													 0),
%		{ok, Bin} = pt_10:write(?PP_ACCOUNT_KICKOFF_ONLINE_3HS_ACK, [0]),
%		lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin)
%	catch
%		_:_ ->
%			erlang:get_stacktrace(),
%			{ok, BinFail} = pt_10:write(?PP_ACCOUNT_KICKOFF_ONLINE_3HS_ACK, [1]),
%			lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, BinFail)
%	end,
%	ok;



handle(?PP_AACOUNT_LOOK_ROLE_REQ, RoleInfo, Data) ->
    [RoleId] = Data,
    mod_role:look_other_role(RoleInfo, RoleId),
    ok;

handle(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_REQ, RoleInfo, RoleName) ->
	case mod_loginserver:get_roleid_by_rolename(RoleName) of
        [] ->
            {ok, Bin} = pt_10:write(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK, [1, 0]),
            lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin);
        RoleId ->
            Res = mod_account:get_pid_by_roleid(RoleId),
            case Res of
                {false} ->
                    {ok, Bin} = pt_10:write(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK, [1, 0]),
                    lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin);
                {true, _Pid} ->
                    {ok, Bin} = pt_10:write(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK, [0, RoleId]),
                    lib_send:send_to_send_pid(RoleInfo#mhrole.send_pid, Bin)
            end
    end,
	ok;


handle(?PP_ACCOUNT_SYN_TIME_RE, RoleInfo, _Data) ->
%% 	Msg = {mod_role, handle_syn_time, [0]},
%% 	gen_server:cast(RoleInfo#mhrole.pid, Msg),
	mod_role:do_syn_time(RoleInfo#mhrole.send_pid),
	ok;

handle(?PP_ACCOUNT_ROLE_SYN_TIME_ACK, _RoleInfo, _Data)->
	ok;

handle(Msg, _RoleInfo, Data)->
	io:format("~n~nMsg=~p, Data=~p~n~n", [Msg, Data]),
	ok.
%%
%% Local Functions
%%

send_pos_ack_pkg(ErrCode, MapId, X, Y, SendPid)->
	{ok, Bin} = pt_10:write(?PP_ACCOUNT_POS_ACK, [ErrCode, MapId, X, Y]),
	lib_send:send_to_send_pid(SendPid, Bin).


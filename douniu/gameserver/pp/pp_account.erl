%%%--------------------------------------
%%% @Module  : pp_account
%%% @Email   : dizengrong@gmail.com
%%% @Created : 2011.08.7
%%% @Description:用户账户管理
%%%--------------------------------------
-module(pp_account).

-export([handle/3,
		 new_role/9]).

-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").

%%登陆验证
%% return: {true, {Pid,AccountId,RoleId}
%%			验证不成功则为{no_account}
handle(?PP_ACCOUNT_LOGIN, Socket, [AccName]) ->
	Res = case mod_loginserver:get_account(AccName) of
			{true,AccountId,[RoleBaseInfo|_]} -> %%账户已注册
				%%发送登录回应
				{ok, BinDataOk} = pt_10:write(?PP_ACCOUNT_LOGIN_ACK, RoleBaseInfo),
%				?INFO("Send Reply Socket:~p, Data:~p ~n",[Socket, BinDataOk]),
				io:format("line 25...Send Reply Socket:~p, Data:~p ~n",[Socket, BinDataOk]),
				gen_tcp:send(Socket, BinDataOk),
				%%启动角色进程，并加载数据
				{ok, Pid} = load_role(RoleBaseInfo#mhrolebaseinfo.roleid, RoleBaseInfo#mhrolebaseinfo.rolename, 
									  AccountId, Socket,AccName),
			  	{true,{Pid,AccountId,RoleBaseInfo#mhrolebaseinfo.roleid}};
			{no_account} -> %%账户未注册
				{ok, BinDataNoAcc} = pt_10:write(?PP_ACCOUNT_LOGIN_ACK, no_account),
%				?INFO("Send Reply Socket:~p, Data:~p ~n",[Socket, BinDataNoAcc]),
				io:format("line 34...Send Reply Socket:~p, Data:~p ~n",[Socket, BinDataNoAcc]),
				gen_tcp:send(Socket, BinDataNoAcc),
				{no_account}
	end,
	
	Res;

%%创建角色
%%return	{true,{Pid,AccountId,RoleId}}-成功
%%			{false}-错误
handle(?PP_ACCOUNT_CREATE_ROLE,Socket,[AccName, RoleName, Sex, Career]) ->
	FilteredRoleName = lib_word_filter:filter_prohibited_words(RoleName), 
	IllegalFilteredName = lib_illegalword_filter:has_illegal_word(RoleName),
%	?INFO("FilteredRoleName = ~p, RoleName = ~p~n", [FilteredRoleName,RoleName]),
	io:format("FilteredRoleName = ~p, RoleName = ~p~n", [FilteredRoleName,RoleName]),
	NotProhibit = (list_to_binary(FilteredRoleName) =:= list_to_binary(RoleName)),
 	NotIllegal 	= (list_to_binary(IllegalFilteredName) =:= list_to_binary(RoleName)),
	case (NotProhibit and NotIllegal) of
		true ->
%			?INFO("FilteredRoleName = RoleName~n"),
			io:format("FilteredRoleName = RoleName~n"),
			register_to_account_server(Socket,AccName,RoleName,Sex,Career);
		false ->%%包含屏蔽字
			%%发送注册回应
%			?INFO("FilteredRoleName /= RoleName~n"),
			io:format("FilteredRoleName /= RoleName~n"),
			{ok,Data} = pt_10:write(?PP_ACCOUNT_CREATE_ROLE_ACK, 2),
			gen_tcp:send(Socket, Data),
			{false}
	end;
			
handle(Cmd, _Status, Data) ->
    ?INFO( "handle_account no match: cmd = ~p, data = ~p", [Cmd, Data]),
    {error, "handle_account no match"}.


register_to_account_server(Socket,AccName,RoleName,Sex,Career) ->
	%%向AccountServer注册账号
	 case mod_loginserver:register(AccName,RoleName,Sex,Career) of
		 {true,RInf} ->%%注册成功
			%%发送注册回应
			{ok,Data} = pt_10:write(?PP_ACCOUNT_CREATE_ROLE_ACK, 0),
			gen_tcp:send(Socket, Data),
			%%启动角色进程，并加载数据
			{ok,Pid} = new_role(RInf#mhrolebaseinfo.accountid, AccName,
								RInf#mhrolebaseinfo.roleid, RoleName, Sex, 
								Career, Socket, ?ROLE_TYPE_COMMON, self()),
%			io:format("register_to_account_server successsuccesssuccess~n"),
			?INFO("register_to_account_server successsuccesssuccess~n"),
			{true, {Pid, RInf#mhrolebaseinfo.accountid,RInf#mhrolebaseinfo.roleid}};
	 	{false ,role_name_exist} -> %%注册失败，名字已占用
			%%发送注册回应
			{ok,Data} = pt_10:write(?PP_ACCOUNT_CREATE_ROLE_ACK, 1),
			gen_tcp:send(Socket, Data),
%			io:format("register_to_account_server failfailfailfail~n"),
			?INFO("register_to_account_server failfailfailfail~n"),
			{false}
	end.

%%加载已有角色
%% return {true} 成功，{false}失败
load_role(RoleId,RoleName,AccountId,Socket,Account) ->
	RoleCache = mod_account:sync_is_online(RoleId),
	case RoleCache of
		{false} -> %%cache中没进程，则建立新进程
				%set account online
			mod_account:set_online([RoleId, RoleName, AccountId, Account]),

			ReaderPid = self(),
			case mod_role:start({load,RoleId,[AccountId,Socket,Account,ReaderPid]}) of
				{ok, Pid} -> mod_account:update(RoleId, [{pid, Pid}], login),
							 {ok,Pid};%%进程启动成功
				ProcErr-> mod_account:role_terminate(RoleId),%%账号进程启动失败
					{error, ProcErr}
			end;
		{true, Pid}->%%已有进程则更新socket
			ReaderPid = self(),
			mod_role:update_socket(Pid, Socket, ReaderPid),
%% 			mod_role_ai:cancel_ai_auto(Pid),
			{ok, Pid}
	end.

%%新创建角色
new_role(AccountId, AccName, RoleId, RoleName, Sex, Career, Socket, Type, ReaderPid)->
	mod_account:set_online([RoleId, RoleName, AccountId, AccName]),
	case mod_role:start({new, RoleId, [AccountId, AccName, RoleName, Sex, Career, Socket, Type, ReaderPid]}) of
		{ok, Pid}->
			io:format("~n~n~naaaaaaaaaaaaaaaaaaa22~n~n", []),
			mod_account:update(RoleId, [{pid, Pid}], login),
			{ok,Pid};
		ProcErr-> 
			io:format("~n~n~nbbbbbbbbbbbb~n~n", []),
			mod_account:role_terminate(RoleId),%%账号进程启动失败
			{error, ProcErr}
	end.

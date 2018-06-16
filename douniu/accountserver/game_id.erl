%% Author: Austin
%% Created: 2012-7-31
%% Description: TODO: Add description to game_id
-module(game_id).

%%
%% Include files
%%
-include("common.hrl").
-include("record.hrl").
%% --------------------------------------------------------------------
%% External exports
-export([start_link/0,get_new_accountId/0,get_new_roleId/0,
		 get_new_douniuroomId/0,
		 get_new_petId/0,get_new_itemId/0,get_new_teamId/0,
		 get_employeeId/1, 
%		 get_new_scene_npcid/0,
		 get_new_petitemId/0, get_new_mountid/0,
		 get_new_guildid/0, get_new_market_order_id/0,
		 get_new_friend_fuli_id/0, get_new_vendue_order_id/0,
         get_new_time_config_id/0]).

%% gen_server callbacks
-export([init/1,handle_call/3]).


%% ====================================================================
%% External functions
%% ====================================================================

start_link() ->
	gen_server:start_link({local,?MODULE}, ?MODULE, [], []).


%%stop() ->
%%	gen_server:cast(?MODULE,stop ).



%% ====================================================================
%% API functions
%% ====================================================================
%% 获取新的帐号ID
%% @return {ok, NewAccountId}  新AccountId
%% 		   
get_new_accountId()->
	gen_server:call(?MH_GAME_ID,{get_new_accountId},?RPC_TIMEOUT).

%% 获取新的角色ID
%% @return {ok, NewRoleId}  新roleId
%% 		   
get_new_roleId()->
	gen_server:call(?MH_GAME_ID,{get_new_roleId},?RPC_TIMEOUT).

%% 获取新的物品ID
%% @return {ok, NewItemId}  新ItemId	   
get_new_itemId()->
	gen_server:call(?MH_GAME_ID, {get_new_itemId},?RPC_TIMEOUT).

%% 获取新的宠物ID
%% @return {ok, NewPetId}  新PetId	   
get_new_petId()->
	gen_server:call(?MH_GAME_ID, {get_new_roleId}, 	%%角色与宠物id统一分配
						 	?RPC_TIMEOUT).

%% 获取新的宠物物品id（内丹）
get_new_petitemId() ->
	gen_server:call(?MH_GAME_ID, {get_new_petitemId},?RPC_TIMEOUT).

%% 获取新的队伍ID
%% @return {ok, NewTeamId} 新的队伍Id
get_new_teamId() ->
	gen_server:call(?MH_GAME_ID,{get_new_teamId},?RPC_TIMEOUT).

get_new_douniuroomId()->
	gen_server:call(?MH_GAME_ID,{get_new_douniuroomId},?RPC_TIMEOUT).

%% 获取分身Id
%% return EmployeeId
get_employeeId(HiredRoleId)->
	%%分身id分配准则：低63位与被雇佣的角色id一致，但最高位为1
	EmployeeId = HiredRoleId bxor (1 bsl 63),
	EmployeeId.

%% 获取新的场景npc唯一id
%get_new_scene_npcid() ->
%	gen_server:call(?MH_GAME_ID, {get_new_scene_npcid}, ?RPC_TIMEOUT).

%% 获取坐骑唯一id
get_new_mountid() ->
	gen_server:call(?MH_GAME_ID,{get_new_mountid}, ?RPC_TIMEOUT).


%% 获取帮派唯一id
get_new_guildid() ->
	gen_server:call(?MH_GAME_ID, {get_new_guildid}, ?RPC_TIMEOUT).

%% 获取市场货单唯一id
get_new_market_order_id() ->
    gen_server:call(?MH_GAME_ID, {get_new_market_order_id}, ?RPC_TIMEOUT).

%% 获取拍卖货单唯一ID
get_new_vendue_order_id() ->
    gen_server:call(?MH_GAME_ID, {get_new_vendue_order_id}, ?RPC_TIMEOUT).

%% 获取好友福利唯一id
get_new_friend_fuli_id()->
	gen_server:call(?MH_GAME_ID, {get_new_friend_fuli_id}, ?RPC_TIMEOUT).

%% 获取活动配置唯一ID
get_new_time_config_id() ->
    gen_server:call(?MH_GAME_ID, {get_new_time_config_id}, ?RPC_TIMEOUT).

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: 初始化
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
%%	init_account_info(),
	%%	init_role_name(),
	{ok,MaxAccountId} 	= get_account_max_id(),
	{ok,MaxRoleId} 		= get_role_max_id(),
%	{ok,MaxItemId}		= get_Item_max_id(),
%	{ok,MaxTeamId}		= get_team_max_id(),
%	{ok,MaxSceneNpcId}	= get_scene_npc_max_id(),
%	{ok,MaxPetItemId}   = get_pet_item_max_id(),
%	{ok,MaxMountId}     = get_mount_max_id(),
%	{ok,MaxGuildId}   = get_guild_id(),
%   {ok,MaxMarketOrderId} = get_market_order_id(),
%  {ok,MaxVendueOrderId} = get_vendue_order_id(),
%	{ok,MaxFriendFuliId}= get_friend_fuli_max_id(),
	MaxId = #ets_max_id{
						maxaccountid = MaxAccountId,		%% 账号id
						maxroleid = MaxRoleId			%% max角色id
%						maxitemid = MaxItemId,			%% max物品id
%						maxteamid = MaxTeamId,			%% max队伍id
%						maxscenenpcid = MaxSceneNpcId,	%% max场景npcid
%						maxpetitemid = MaxPetItemId,	%% max宠物物品id
%						maxmountid = MaxMountId,		%% max坐骑id
%                       maxguildid = MaxGuildId,        %% max帮派id
%                        maxmarketorderid = MaxMarketOrderId,% max市场货单id
%                        maxvendueorderid = MaxVendueOrderId,% max拍卖货单id
%						maxfriendfuliid = MaxFriendFuliId	%% max好友福利id
						},
	{ok,MaxId}.



%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State} 

%% accountId
handle_call({get_new_accountId }, _From, State ) ->
	NewId = State#ets_max_id.maxaccountid +1,
	NewState = State#ets_max_id{maxaccountid = NewId},
	{reply, {ok,NewId},NewState};
%% roleId
handle_call({get_new_roleId }, _From, State ) ->
 	NewId  = State#ets_max_id.maxroleid +1,
%% 	{ok, NewId} = get_role_max_id(),
	NewState = State#ets_max_id{maxroleid = NewId},
	{reply, {ok, NewId},NewState};

%% itemId
handle_call({get_new_itemId}, _From, State ) ->
	NewId = State#ets_max_id.maxitemid +1,
	NewState = State#ets_max_id{maxitemid = NewId },
	{reply, {ok,NewId},NewState };

%% petitemId
handle_call({get_new_petitemId}, _From, State) ->
	NewId = State#ets_max_id.maxpetitemid +1,
	NewState = State#ets_max_id{maxpetitemid = NewId },
	{reply, {ok,NewId},NewState };

%% teamId
handle_call({get_new_teamId}, _From, State ) ->
	NewId = State#ets_max_id.maxteamid +1,
	NewState = State#ets_max_id{maxteamid = NewId },
	{reply, {ok,NewId},NewState };

%% douniu roomId
handle_call({get_new_douniuroomId}, _From, State ) ->
	NewId = State#ets_max_id.maxdouniuroomid +1,
	NewState = State#ets_max_id{maxdouniuroomid = NewId },
	{reply, {ok,NewId},NewState };

%% scene npcid
%handle_call({get_new_scene_npcid}, _From, State) ->
%	NewId = 
%		case State#ets_max_id.maxscenenpcid + 1 >= ?SCENE_NPC_MAX_ID of
%			true ->
%				?SCENE_NPC_MIN_ID;
%			false ->
%				State#ets_max_id.maxscenenpcid + 1
%	end,
%	NewState = State#ets_max_id{maxscenenpcid = NewId},
%	{reply, {ok, State#ets_max_id.maxscenenpcid}, NewState};

%% mountId
handle_call({get_new_mountid}, _From, State) ->
	NewId = State#ets_max_id.maxmountid +1,
	NewState = State#ets_max_id{maxmountid = NewId},
	{reply, {ok, NewId}, NewState};

%% factionid
handle_call({get_new_guildid}, _From, State) ->
	NewId = State#ets_max_id.maxguildid + 1,
	NewState = State#ets_max_id{ maxguildid = NewId},
	{reply, {ok, NewId}, NewState};

handle_call({get_new_market_order_id}, _From, State) ->
    NewId = State#ets_max_id.maxmarketorderid + 1,
    NewState = State#ets_max_id{ maxmarketorderid = NewId},
    {reply, {ok, NewId}, NewState};

handle_call({get_new_vendue_order_id}, _From, State) ->
    NewId = State#ets_max_id.maxvendueorderid + 1,
    NewState = State#ets_max_id{ maxvendueorderid = NewId},
    {reply, {ok, NewId}, NewState};

handle_call({get_new_friend_fuli_id}, _From, State) ->
    NewId = State#ets_max_id.maxfriendfuliid + 1,
    NewState = State#ets_max_id{maxfriendfuliid = NewId},
    {reply, {ok, NewId}, NewState};

handle_call({get_new_time_config_id}, _From, State) ->
    NewId = (State#ets_max_id.maxtimeconfigid + 1) rem 16#FFFF,
    NewState = State#ets_max_id{maxtimeconfigid = NewId},
    {reply, {ok, NewId}, NewState}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: get_account_max_id/0
%% Description: 加载帐号ID的最大值
%% Returns: {ok, MaxAccountId}
%%			|{error,{SvrMaxAccountID,MaxAccountId,SvrMinAccountId}}
%% --------------------------------------------------------------------
get_account_max_id() ->
	%% 服务器AccountId下限
	SvrMinAccountId = mh_env:get_env(serverid) bsl 32,%%原始账号ID为服务器ID左移32位  
	%% 服务器AccountId上限
%%	SvrMaxAccountId = mh_env:get_env(serverid)+1 bsl 32,
%%  保留验证之用	
	%% 加载已有帐号ID的最大值
	MaxAccountId = case db_sql:get_one("SELECT MAX(gd_AccountID) FROM gd_account") of
		undefined ->
			SvrMinAccountId;
		Num ->
			Num
	end,
	
	?INFO("maxaccounid = ~p.~n",[MaxAccountId]),
	{ok, MaxAccountId}.

%% --------------------------------------------------------------------
%% Function: get_account_max_id/0
%% Description: 加载角色ID的最大值
%% Returns: {ok,MaxID}
%% --------------------------------------------------------------------
get_role_max_id()->
	%% 加载帐号ID的最大值
	MaxRoleId = case db_sql:get_one("SELECT MAX(gd_RoleId) FROM gd_role") of
		undefined ->
			mh_env:get_env(serverid) bsl 32;%%原始角色ID为服务器ID左移32位
		Num ->
			Num
	end,
%	MaxPetId = case db_sql:get_one("SELECT MAX(gd_petid) FROM gd_pet") of
%		undefined ->
%			0;
%		Num2 ->
%			Num2	   
%	end,
%	MaxMachineFriendId = case db_sql:get_one("SELECT MAX(gd_FriendId) FROM gd_friend WHERE gd_FriendType=2;") of
%		undefined ->
%			0;
%		Num3 ->
%			Num3
%	end,
%	MaxId = max(max(MaxRoleId,MaxPetId),MaxMachineFriendId),
%	
	MaxId = MaxRoleId,
	?INFO("maxroleid = ~p.~n",[MaxId]),
	{ok, MaxId}.
  
get_Item_max_id() ->
	%%
	MaxItemId = case db_sql:get_one("SELECT MAX(gd_itemid) FROM gd_item") of
		undefined ->
			mh_env:get_env(serverid) bsl 32;%%原始角色ID为服务器ID左移32位
		Num ->
			Num
	end,
	?INFO("maxitemid = ~p.~n",[MaxItemId]),
	{ok, MaxItemId}.

get_pet_item_max_id() ->
	MaxPetItemId = case db_sql:get_one("SELECT MAX(gd_id) FROM gd_pet_item") of
					   undefined ->
						   mh_env:get_env(serverid) bsl 32;%%原始角色ID为服务器ID左移32位
					   Num ->
						   Num
				   end,
	?INFO("maxpetitemid = ~p.~n",[MaxPetItemId]),
	{ok, MaxPetItemId}.

get_team_max_id() ->
	%% 队伍ID 直接生成
	MaxTeamId = mh_env:get_env(serverid) bsl 32,
	{ok,MaxTeamId}.

%get_scene_npc_max_id() ->
%	{ok, ?SCENE_NPC_MIN_ID}.

get_mount_max_id() ->
	MaxMountId = case db_sql:get_one("SELECT MAX(gd_mountid) FROM gd_mount") of
		undefined ->
			mh_env:get_env(serverid) bsl 32;%%原始坐骑ID为服务器ID左移32位
		DBMaxMountId ->
			DBMaxMountId
	end,
	?INFO("maxmountid = ~p.~n",[MaxMountId]),
	{ok, MaxMountId}.
	
get_guild_id() ->
	MaxGuildId = case db_sql:get_one("SELECT MAX(gd_guildid) FROM gd_guild") of
		undefined ->
			mh_env:get_env(serverid) bsl 32;%%原始帮派ID为服务器ID左移32位
		DBMaxGuildId ->
			DBMaxGuildId
	end,
	?INFO("maxguildid = ~p.~n",[MaxGuildId]),
	{ok, MaxGuildId}.

get_market_order_id() ->
    MaxId =
        case db_sql:get_one("SELECT MAX(gd_orderid) FROM gd_market") of
            undefined ->
                mh_env:get_env(serverid) bsl 32;%%原始市场货单ID为服务器ID左移32位
            DBMaxId ->
                DBMaxId
        end,
    ?INFO("maxmarketorderid = ~p.~n",[MaxId]),
    {ok, MaxId}.

get_vendue_order_id() ->
    MaxId =
        case db_sql:get_one("SELECT MAX(gd_orderid) FROM gd_vendue") of
            undefined ->
                mh_env:get_env(serverid) bsl 32;%%原始拍卖货单ID为服务器ID左移32位
            DBMaxId ->
                DBMaxId
        end,
    ?INFO("maxvendueorderid = ~p.~n",[MaxId]),
    {ok, MaxId}.

get_friend_fuli_max_id() ->
	MaxFuliId = case db_sql:get_one("SELECT MAX(gd_fuliid) FROM gd_friend_fuli") of
		undefined ->
			mh_env:get_env(serverid) bsl 32;%%原始 福利ID为服务器ID左移32位
		DBMaxFuliId ->
			DBMaxFuliId
	end,
	?INFO("maxFuliid = ~p.~n",[MaxFuliId]),
	{ok, MaxFuliId}.


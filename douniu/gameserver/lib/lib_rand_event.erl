%% Author: yangxiaowen
%% Created: 2013-3-11
%% Description: 任务触发事件通用模版


-module(lib_rand_event).
-include("record.hrl").
-include("cfg_record.hrl").
-include("common.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("counter.hrl").
%-include("battle.hrl").


-export([do_random_event/3]).

% EventList, [{rate,eventid},...]如果没有触发,则什么也不做,以10000为满
% Args, 事件的一些参数,由调用者提供
do_random_event(RoleInfo, EventList, Args) ->
    Fun = fun(X, Sum) ->
        X + Sum
    end,
    RateAll = [R || {R, _} <- EventList],
    LeftRate = 10000 - lists:foldl(Fun, 0, RateAll),
    EventList2 = EventList ++ [{LeftRate, 0}],
    List = [{E, R} || {R, E} <- EventList2],
    {R} = lib_random:get_random_fr_weight_list_int(List),
    case R of
        0 ->
            ok;
        EventId ->
            do_random_event2(RoleInfo, EventId, Args)
    end,
    ok.

do_random_event2(RoleInfo, EventId, Args) ->
    Event =  cfg_rand_event:get_cfg_rand_event(EventId),
    ChildEventEn = lib_period:search_list(Event, child_event),
    AddItemEn = lib_period:search_list(Event, add_item),
    AddEquipEn = lib_period:search_list(Event, add_equip),
    AddMyItem = lib_period:search_list(Event, add_gather_item),
    AddCons = lib_period:search_list(Event, add_cons),
    do_add_item_event(RoleInfo, AddItemEn, Args),
    do_add_equip_event(RoleInfo, AddEquipEn, Args),
    do_add_my_item(RoleInfo, AddMyItem, Args),
    do_add_cons(RoleInfo, AddCons, Args),
    do_child_event(RoleInfo, ChildEventEn, Args).

% child_event,子触发事件:
% {child_event, [{子事件概率, 子事件ID},...]},此概率总和为10000
do_child_event(_RoleInfo, false, _Args) ->
    ok;
do_child_event(RoleInfo, {child_event, ChildEventList}, Args) ->
    List = [{E, R} || {R, E} <- ChildEventList],
    {EventId} = lib_random:get_random_fr_weight_list_int(List),
    do_random_event2(RoleInfo, EventId, Args).

% add_item,增加物品事件: 物品 = {CfgItemId,Num,Quality}
% {add_item,[{物品,概率,提示语},...]},概率是独立概率,每个物品的获得不会受其他物品影响;
do_add_item_event(_RoleInfo, false, _Args) ->
    ok;
do_add_item_event(RoleInfo, {add_item, AddItemList}, _Args) ->
    Fun = fun(Item) ->
        {M, N, Q, W} = Item,
        case mod_item:pre_add_item_check_bag_full(RoleInfo, [{M, N}]) >= 0 of
            true ->
                mod_item:add_item(RoleInfo#mhrole.pid, {M, N, Q, ?LOG_TASK_EVENT_AWARD}),
                S = io_lib:format(W, [N, (cfg_item:get_cfg_item(M))#rcd_item.cfg_itemname]),
                % ?S2CINFO(RoleInfo#mhrole.send_pid, S),
                ?S2CERRS(S);
            false ->
                S2 = io_lib:format(cfg_string:get_string(rand_event), 
                    [(cfg_item:get_cfg_item(M))#rcd_item.cfg_itemname]),
                ?S2CERRS(S2),
                mod_mail_mgr:send_mail(RoleInfo#mhrole.roleid, 
                    cfg_string:get_string(sys_mail_sysmail_title_4), 
                    cfg_string:get_string(sys_mail_sysmail_content_4), 
                    cfg_string:get_string(sys_mail_sysmail_sender_4), 
                    util:term_to_string([{M, N, Q}]))
        end
    end,
    [Fun({M, N, Q, W}) || {M, N, Q, R, W} <- AddItemList, mod_rand:int(10000) =< R],
    ok.

% add_equip,增加装备事件
% {add_equip,[{品质,数量,概率,等级公式,提示语},...]},此概率总和为10000
do_add_equip_event(_RoleInfo, false, _Args) ->
    ok;
do_add_equip_event(RoleInfo, {add_equip, EquipList}, _Args) ->
    List = [{{Q, L, W}, R} || {Q, R, L, W} <- EquipList],
    {Res} = lib_random:get_random_fr_weight_list_int(List),
    {Qua, Fuc, Word} = Res,
    Lvl = round(cfg_function:get_cfg_fun(Fuc, {RoleInfo#mhrole.level})),
    List2 = cfg_task_school_equip:get_cfg_task_school_equip(Lvl),
    SelectLvlEquip = fun(Id) ->
        RcdItem = cfg_item:get_cfg_item(Id),
        RcdItem#rcd_item.cfg_LvMin == Lvl
    end,
    List3 = [A || A <- List2, SelectLvlEquip(A)],
    Module = lists:nth(mod_rand:int(length(List3)), List3),
    case mod_item:pre_add_item_check_bag_full(RoleInfo, [{Module, 1}]) >= 0 of
        true ->
            mod_item:add_item(RoleInfo#mhrole.pid, {Module, 1, Qua, ?LOG_TASK_EVENT_AWARD}),
            S = io_lib:format(Word, [(cfg_item:get_cfg_item(Module))#rcd_item.cfg_itemname]),
            % ?S2CINFO(RoleInfo#mhrole.send_pid, S),
            ?S2CERRS(S);
        false ->
            ok
    end,
    ok.

do_add_my_item(_RoleInfo, false, _Args) ->
    ok;
do_add_my_item(RoleInfo, {add_gather_item, [Num, W]}, [ModuleId]) ->
    case mod_item:pre_add_item_check_bag_full(RoleInfo, [{ModuleId, Num}]) >= 0 of
        true ->
            mod_item:add_item(RoleInfo#mhrole.pid, {ModuleId, Num, ?LOG_TASK_EVENT_AWARD}),
            S = io_lib:format(W, [(cfg_item:get_cfg_item(ModuleId))#rcd_item.cfg_itemname]),
            % ?S2CINFO(RoleInfo#mhrole.send_pid, S),
            ?S2CERRS(S);
        false ->
            ok
    end,
    ok.

do_add_cons(_RoleInfo, false, _Args) ->
    ok;
do_add_cons(RoleInfo, {add_cons, [Num, W]}, _Args) ->
    mod_school:add_credit(RoleInfo#mhrole.pid, Num),
    S = io_lib:format(W, [Num]),
    % ?S2CINFO(RoleInfo#mhrole.send_pid, S),
    ?S2CERRS(S),
    ok.

%% Author: gavin
%% Created: 2013-1-15
%% Description: 角色属性管理
-module(mod_role_attr).

%%
%% Include files
%%
-include("record.hrl").
%-include("equip.hrl").
%%
%% Exported Functions
%%
-export([init/1,
        update_role_attr/2 %%更新人物的属性
    ]).

%%
%% API Functions
%%

%%角色属性初始化，这里要求，背包及装备初始化在这之前完成
init(MhRole) ->
    MhItemList = lib_equip:get_equiped_equip(MhRole),
    {ok, NMhRole} = update_role_attr(MhRole, MhItemList),
    NMhRole.

%%人物属性计算，包括人物1级属性转化、初始值、装备附加、造化附灵等的加成
%%RoleInfo #mhrole
update_role_attr(MhRole, MhItemList)->
    %%人物等级带来的属性
    Level = MhRole#mhrole.level,
    Roleattr = #roleattr{
        phy = 4 + Level,
        smart = 4 + Level,
        endur = 4 + Level,
        agile = 4 + Level,
        hit = 100
    },

    MhRole1 = MhRole#mhrole{
                roleattr = Roleattr
%                hp = 0,
%                mp = 0
				},

    %装备基础属性，强化、洗炼、造化带来的加成
%    MhItemList2 = [X || X <- MhItemList, X#mhitem.durability > 0],  %%过滤掉耐久为0的装备
    MhItemList2 = [],  
    {ok, MhRoleEquip} = update_equip_attr(MhRole1, MhItemList2),

    %装备全身层级属性
%    EquipFullLayerAttrList = mod_equip_full:get_full_layer_attr(MhRole#mhrole.equipstatus),
    EquipFullLayerAttrList = [],
    {ok, MhRoleEquipLayer} = update_attr(MhRoleEquip, EquipFullLayerAttrList),
    %?INFO("EquipFullLayerAttrList:~p",[EquipFullLayerAttrList]),

    %人物buff属性加成
    BuffAttrList = mod_buff:get_buff_attr(MhRole),
    {ok, MhRoleBuff} = update_attr(MhRoleEquipLayer, BuffAttrList),


    %%全身强化加成,暂时删去
    %%FullStrAttrList = mod_equip_strenthen:get_full_attr(MhRole),
    %%{ok, MhRole4} = update_attr(MhRole2, FullStrAttrList),
    %%坐骑属性加成
    MountAttrList = mod_mount:get_mount_attr(MhRole),
   % ?INFO("MountAttrList:~p", [MountAttrList]),
    {ok, MhRoleMount} = update_attr(MhRoleBuff, MountAttrList),

    %称号属性
    TitleAttrList = mod_title:get_title_attr(MhRole),
    {ok, MhRoleTitle} = update_attr(MhRoleMount,TitleAttrList),
    %?INFO("TitleAttrList:~p",[TitleAttrList]),

    %


   %神通系统带来的属性加成
    ShentongAttrList = mod_shentong:get_attr(MhRole),
    {ok, MhRole5} = update_attr(MhRoleTitle, ShentongAttrList),

    %%一级属性转化而来的部分
    RoleAttr4 = MhRole5#mhrole.roleattr,
    Phy = RoleAttr4#roleattr.phy,
    Smart = RoleAttr4#roleattr.smart,
    Endur = RoleAttr4#roleattr.endur,
    Agile = RoleAttr4#roleattr.agile,
    RoleAttr5 = RoleAttr4#roleattr {
%        att = cfg_function:get_cfg_fun(?FUN_ATTR_SMART_2_ATT, {Smart})
%            + RoleAttr4#roleattr.att,
%        def = cfg_function:get_cfg_fun(?FUN_ATTR_ENDUR_2_DEF, {Endur})
%            + RoleAttr4#roleattr.def,
%        spd = cfg_function:get_cfg_fun(?FUN_ATTR_AGILE_2_SPD, {Agile})
%            + RoleAttr4#roleattr.spd
        },

%    Hp = cfg_function:get_cfg_fun(?FUN_ATTR_PHY_2_HP, {Phy}) + MhRole5#mhrole.hp, %%1点体质=40点血
%    Mp = cfg_function:get_cfg_fun(?FUN_ATTR_OTHERS_2_MP, {Smart, Endur, Agile, Phy}) + MhRole5#mhrole.mp,
    Hp = 0,
    Mp = 0,

    % 取BUFF带来的百分比加成
    AttScaleList = mod_buff:get_buff_attr_scale(MhRole),
    {RoleAttr6, NewHp, NewMp} = update_scale_attr(RoleAttr5, Hp, Mp, AttScaleList),

    MhRoleFin = MhRole5#mhrole{
                roleattr = RoleAttr6
%                hp = NewHp,
%                mp = NewMp
            },

    {ok, MhRoleFin}.

update_scale_attr(RoleAttr, Hp, Mp, []) ->
    {RoleAttr, Hp, Mp};
update_scale_attr(RoleAttr, Hp, Mp, AttScaleList) ->
    [{Attr, Scale}|RemainList] = AttScaleList,
    case Attr of
        att ->
            NewRoleAttr = RoleAttr#roleattr{att = max(1, RoleAttr#roleattr.att * (100 + Scale) div 100)},
            update_scale_attr(NewRoleAttr, Hp, Mp, RemainList);
        def ->
            NewRoleAttr = RoleAttr#roleattr{def = max(1, RoleAttr#roleattr.def * (100 + Scale) div 100)},
            update_scale_attr(NewRoleAttr, Hp, Mp, RemainList);
        spd ->
            NewRoleAttr = RoleAttr#roleattr{spd = max(1, RoleAttr#roleattr.spd * (100 + Scale) div 100)},
            update_scale_attr(NewRoleAttr, Hp, Mp, RemainList);
        hp ->
            NewHp = max(1, Hp * (100 + Scale) div 100),
            update_scale_attr(RoleAttr, NewHp, Mp, RemainList);
        _ ->
            update_scale_attr(RoleAttr, Hp, Mp, RemainList)
    end.

%%穿上装备，属性加成,包括基础属性，强化、洗炼、造化带来的加成
%%return {ok, #mhrole}
update_equip_attr(MhRole, []) ->
    {ok, MhRole};
update_equip_attr(MhRole, [MhItem | RestList])->
%%  ?INFO("MhItem:~p",[MhItem]),

    %%白色属性
%    WhiteAttrs = lib_equip:get_equip_base_attr(MhItem#mhitem.moduleid),
    WhiteAttrs = [],

    %%更新角色白色属性
    {ok, MhRole1} = update_attr(MhRole, WhiteAttrs),

%    EquipAttr = lib_equip:get_equip_attr(MhItem#mhitem.itemid),
    EquipAttr = [],

    %%添加洗炼属性,这时需要对洗煤属性进行造化增幅
    BaptizeAttr = 0,
%    BaptizeAttr = EquipAttr#equipattr.baptize,

    MhRole2 = equip_update_baptize_attr(MhRole1, BaptizeAttr),

    %%添加强化属性
    StrenthenAttr = 0,
%    StrenthenAttr = EquipAttr#equipattr.strenthen,
    MhRole3 = equip_update_strenthen_attr(MhRole2, StrenthenAttr, MhItem),

    %%添加套装色属性
    {ok, MhRole4} =equip_update_suit_attr(MhRole3, MhItem),

    %%镶嵌(附灵)
%    {_, InlayAttrList} = mod_equip_inlay:get_inlay_attr_list(MhItem#mhitem.itemid),
    InlayAttrList = [],
    %?INFO("InlayAttrList:~p",[InlayAttrList]),
    {ok, MhRole5} = update_attr(MhRole4, InlayAttrList),

    %%层级属性附加
%    LayerAttrList = mod_layer:get_equip_layer_attr_list(MhItem#mhitem.moduleid, EquipAttr),
    LayerAttrList = [],
    {ok, MhRoleFin} = update_attr(MhRole5, LayerAttrList),

    update_equip_attr(MhRoleFin, RestList).

%%装备的洗炼属性
equip_update_baptize_attr(MhRole, [])->
    MhRole;
equip_update_baptize_attr(MhRole, [H|Rest])->
    {_Pos, AttrType, Value, _Star} = H,
    {ok,NewMhRole} = update_attr(MhRole, [{AttrType, Value}]),
    equip_update_baptize_attr(NewMhRole, Rest).


%%装备的强化属性
equip_update_strenthen_attr(MhRole, {_StrLevel, Value, _Perfect}, MhItem) ->
    AttrType = mod_equip_strenthen:get_strenthen_attr_type(MhItem),
    {ok, NewMhRole} = update_attr(MhRole, [{AttrType, Value}]),
    NewMhRole.

equip_update_suit_attr(MhRole, MhItem) ->
    case  mod_equip_suit:get_suit_attr(MhItem) of
        {ok, SuitAttr} ->
            {ok, _NewMhRole} = update_attr(MhRole, SuitAttr);
        _ ->
            {ok, MhRole}
    end.


%%
%% Local Functions
%%
%%属性:phy体质,smart灵力,endur耐力,agile敏捷,att攻击,def防御,spd速度,dodge闪避,hit命中,crit暴击,
%%combo连击,break破甲,resist格挡,counter反击,mp魔法,hp血量,metal金,wood木,water水,fire火,earth土
%%return:{ok, NewMhRole}
update_attr(MhRole, [])->
    {ok, MhRole};
update_attr(MhRole, [{Attr, Value} | RestList]) ->
%% update_equip_attr(MhRole, {Attr,Value})->
    NewMhRole = case Attr of
        phy ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{phy =
                (MhRole#mhrole.roleattr)#roleattr.phy + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        smart ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{smart =
                (MhRole#mhrole.roleattr)#roleattr.smart + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        endur ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{endur =
                (MhRole#mhrole.roleattr)#roleattr.endur + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        agile ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{agile =
                (MhRole#mhrole.roleattr)#roleattr.agile + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        att ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{att =
                (MhRole#mhrole.roleattr)#roleattr.att + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        def ->
            NewRoledefr = (MhRole#mhrole.roleattr)#roleattr{def =
                (MhRole#mhrole.roleattr)#roleattr.def + Value},
            MhRole#mhrole{roleattr = NewRoledefr};
        spd -> NewRoleAttr =
            (MhRole#mhrole.roleattr)#roleattr{spd =
                (MhRole#mhrole.roleattr)#roleattr.spd + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        dodge ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{dodge =
                    (MhRole#mhrole.roleattr)#roleattr.dodge + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        hit ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{hit =
                    (MhRole#mhrole.roleattr)#roleattr.hit + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        crit ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{crit =
                    (MhRole#mhrole.roleattr)#roleattr.crit + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        combo ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{combo =
                   (MhRole#mhrole.roleattr)#roleattr.combo + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        break ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                break = (MhRole#mhrole.roleattr)#roleattr.break + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        resist ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{resist =
                           (MhRole#mhrole.roleattr)#roleattr.resist + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        counter ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                counter = (MhRole#mhrole.roleattr)#roleattr.counter + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
%        mp -> MhRole#mhrole{mp = MhRole#mhrole.mp + Value};
%        hp -> MhRole#mhrole{hp = MhRole#mhrole.hp + Value};
        mp -> MhRole;
        hp -> MhRole;

        metal ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                metal = (MhRole#mhrole.roleattr)#roleattr.metal + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        wood ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                wood = (MhRole#mhrole.roleattr)#roleattr.wood + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        water ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                water = (MhRole#mhrole.roleattr)#roleattr.water + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        fire ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
            fire = (MhRole#mhrole.roleattr)#roleattr.fire + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        earth ->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                earth = (MhRole#mhrole.roleattr)#roleattr.earth + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        barrier->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                  barrier = (MhRole#mhrole.roleattr)#roleattr.barrier + Value},
            MhRole#mhrole{roleattr = NewRoleAttr};
        disturbance->
            NewRoleAttr = (MhRole#mhrole.roleattr)#roleattr{
                 disturbance = (MhRole#mhrole.roleattr)#roleattr.disturbance + Value},
            MhRole#mhrole{roleattr = NewRoleAttr}
        end,
    update_attr(NewMhRole, RestList).

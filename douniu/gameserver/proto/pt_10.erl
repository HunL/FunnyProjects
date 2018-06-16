%%%-----------------------------------
%%% @Module  : pt_10
%%% @Email   : dizengrong@gmail.com
%%% @Created : 2012.07.07
%%% @Description: 10 帐户管理协议
%%%-----------------------------------
-module(pt_10).
-export([read/2, write/2]).
-include("common.hrl").
-include("record.hrl").
-include("proto.hrl").

%%10000 客户端登陆请求 ACCOUNT_LOGIN（C>>S）
%%String：平台用户账号
%%登陆
read(?PP_ACCOUNT_LOGIN, BinData) ->
	?INFO("read PP_ACCOUNT_LOGIN Bin:~p ~n.",[BinData]),
	{Accname, Rest1} = pt:read_string(BinData),
    <<Time:32, Rest2/binary>> = Rest1,
    {CheckCode, _} = pt:read_string(Rest2),
    {ok, [login, Accname, Time, CheckCode]};

%%创建角色
%%10004 创建角色请求 ACCOUNT_CREATE_ROLE（C>>S）
%%String 平台用户账号
%%String 角色名
%%int32 性别（0：男，1：女）
%%int32 职业（1：金，2：木，3：水，4：火，5：土）
read(?PP_ACCOUNT_CREATE_ROLE, BinData) ->
	io:format("~n~n~npt10 read create role~n~n~n~n", []),
	{Account, Rest1} = pt:read_string(BinData),
    {RoleName, Rest2} = pt:read_string(Rest1),
	<<Sex:32,Career:32, Rest3/binary>> = Rest2,
    <<Time:32, Rest4/binary>> = Rest3,
    {CheckCode, _} = pt:read_string(Rest4),
    {ok, [create, Account, RoleName, Sex, Career, Time, CheckCode]};

%% 选择角色
%%10002 选择角色 ACCOUNT_SELECT_ROLE（C>>S）
%%uint64 角色ID
read(?PP_ACCOUNT_SELECT_ROLE, <<RoleId:64>>) ->
    {ok, [select, RoleId]};

%%10006 获取角色详细信息 ACCOUNT_GET_ROLE_DETAIL （C >> S）
%%无
read(?PP_ACCOUNT_GET_ROLE_DETAIL, _BinData) ->
	{ok, []};

%%10008 获取角色属性请求  ACCOUNT_GET_ROLE_ATTR （C >> S）
read(?PP_ACCOUNT_GET_ROLE_ATTR, _BinData) ->
	{ok, []};

%%------------测试用-------------

%%10007 角色详细信息 ACCOUNT_ROLE_DETAIL（S >> C）
%%uint64：角色ID
%%String：角色名
%%int32：性别（0：男，1：女）
%%int32：职业（师门，1：金，2：木，3：水，4：火，5：土）
%%int32：等级
%%uint32：地图ID
%%uint32：坐标
%%uint32：坐标Y
read(?PP_ACCOUNT_ROLE_DETAIL, Bindata)->
	<<_RoleId:64,RestBin1/binary>> = Bindata,
	{_RoleName, RestBin2} = pt:read_string(RestBin1),
	<<_Sex:32,_Career:32,_Level:32,MapId:32,X:32,Y:32,_Reset/binary>> = RestBin2,
	{cli, [MapId, {X,Y}]};

%% 10100 门派信息 ACCOUNT_ROLE_SCHOOL（C >> S）
read(?ACCOUNT_ROLE_SCHOOL, _) ->
    {ok, []};
  
%% 10102 破格晋升 ACCOUNT_ROLE_UPGRADE（C >> S）
read(?ACCOUNT_ROLE_UPGRADES, _) ->
    {ok, []};

%% 10104 门派捐献 ACCOUNT_ROLE_CONTRIBUTE（C >> S）
%% int32:捐献的钱币种类
%% int32:捐献的钱币数量
read(?ACCOUNT_ROLE_CONTRIBUTE, Bin) ->
    <<Num:32>> = Bin,
    {ok, [Num]}; 

%% 10107 累积在线时长 PP_ACCOUNT_ONLINE_TIME（C>>S）
%% int32  是否验证用户（0：是；1：否）
read(?PP_ACCOUNT_ONLINE_TIME, BinData)->
	<<Flag:32>> = BinData,
	{ok, [Flag]};

%% 10109 剔除在线时长满3小时的防沉迷玩家 PP_ACCOUNT_KICKOFF_ONLINE_3HS（C>>S）
read(?PP_ACCOUNT_KICKOFF_ONLINE_3HS, _)->
	{ok, []};


%% 10505 查看角色信息请求 PP_AACOUNT_LOOK_ROLE_REQ(C>>S) 
%% int64 角色ID
read(?PP_AACOUNT_LOOK_ROLE_REQ, <<RoleId:64>>) ->
    {ok, [RoleId]};

% 10507 查看角色信息请求,通过名字查看 PP_ACCOUNT_LOOK_ROLE_BY_NAME_REQ(C>>S)
% string:角色名字
read(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_REQ, BinData) ->
    {Accname, _} = pt:read_string(BinData),
    {ok, Accname};

% 10509 查看角色坐标信息请求
read(?PP_ACCOUNT_POS_REQ, BinData) ->
    <<RoleId:64>> = BinData,
    {ok, RoleId};

%% 客户端同步时间请求
read(?PP_ACCOUNT_SYN_TIME_RE, _) ->
	{ok, []};

%% 10111 时间同步确认 ACCOUNT_ROLE_SYN_TIME_ACK（C >> S）
%% 无
read(?PP_ACCOUNT_ROLE_SYN_TIME_ACK, _)->
	{ok,[]};

%% 游客模式登录
read(?PP_ACCOUNT_TOURIST, BinData) ->
	<<Time:32, Binleft/binary>> = BinData,
	{CheckCode, _R} = pt:read_string(Binleft),
	{ok, [login_tourist, 1, Time, CheckCode]};

%%消息错误
read(_Cmd, _R) ->
    {error, no_match}.

%%
%%服务端 -> 客户端 ------------------------------------
%%

%%登陆回应
%%10001 登陆请求回应 ACCOUNT_LOGIN_ACK（S>>C）
%%uint64：用户账号ID（若账号未注册，则为0）
%%uint16：已创建的角色数组长度
%%        uint64：角色ID
%%        String：角色名
%%        int32：性别（0：男，1：女）
%%        int32：职业（师门，1：金，2：木，3：水，4：火，5：土）
%%        int32：等级
write(?PP_ACCOUNT_LOGIN_ACK, #mhrolebaseinfo{accountid=Accid,roleid=Roleid,rolename=RoleName,sex=Sex,career=Career}) ->
	%%登录成功
	Bname = pt:write_string(RoleName),
	%%暂时只处理单角色情况
    Data = << 0:32,Accid:64,1:16,Roleid:64,Bname/binary,Sex:32,Career:32>>,
    {ok, pt:pack(?PP_ACCOUNT_LOGIN_ACK, Data)};

write(?PP_ACCOUNT_LOGIN_ACK, no_account)->
	%%登录失败,无账号
	Data = << 1:32, 0:64, 0:16>>,
	{ok, pt:pack(?PP_ACCOUNT_LOGIN_ACK, Data)};
  

%%10005 创建角色回应 ACCOUNT_CREATE_ROLE_ACK（S>>C）
%%int32 角色创建结果（0：成功，1：名字重复，2：名字非法，3：达到角色上限，4：其余错误）
write(?PP_ACCOUNT_CREATE_ROLE_ACK, Res) ->
	Data = << Res:32 >>,
	{ok, pt:pack(?PP_ACCOUNT_CREATE_ROLE_ACK, Data)};

%%10003 角色信息 ACCOUNT_ROLE_INFO（S>>C）
%%uint64：角色ID
%%String：角色名
%%int32：性别（0：男，1：女）
%%int32：职业（师门，1：金，2：木，3：水，4：火，5：土）
%%int32：等级
write(?PP_ACCOUNT_ROLE_INFO, #mhrole{roleid=Roleid,rolename=RoleName,sex=Sex,career=Career}) ->
	Bname = pt:write_string(RoleName),
	%%以下参数暂时设置为0
	Level = 0,
    Data = << Roleid:64,Bname/binary,Sex:32,Career:32,Level:32 >>,
    {ok, pt:pack(?PP_ACCOUNT_ROLE_INFO, Data)};

%%10007 角色详细信息 ACCOUNT_ROLE_DETAIL（S >> C）
%%uint64：角色ID
%%String：角色名
%%int32：性别（0：男，1：女）
%%int32：职业（师门，1：金，2：木，3：水，4：火，5：土）
%%int32：等级
%%uint32：地图ID
%%uint32：坐标X
%%uint32：坐标Y
%%int32：道行
%%int32：气血
%%int32：法力
%%int32：体力
%%int64：经验
%%int32：VIP等级
%%string：帮派名称
%%int16：帮派职位
%%uint64：帮派Id
%%uint32：称号Id
%%int32：金元宝数
%%int32：银元宝数
%%int32：金币数
%%int32：银币数
%%int32：角色兽魂值
%%int32：战斗力评分
%%int32：角色境界
%%int32: 角色当前所处境界子阶
%%int16:宠物栏已开启的格子数
% int32: vip天数
% int32:gfs等级 
%%int32:pk值
%%int32:妖气
%%int32: 角色类型（0：游客，1：普通玩家，2：GM，3：新手指导员）
%%int32:战绩
%%int32:胜率, 扩大10000倍后的
write(?PP_ACCOUNT_ROLE_DETAIL, RoleInfo) ->
    Data = write_role_detail(RoleInfo),
    {ok, pt:pack(?PP_ACCOUNT_ROLE_DETAIL, Data)};

%%10009 角色属性信息 ACCOUNT_ROLE_ATTR（S >> C）
%%int32：体质
%%int32：灵力
%%int32：耐力
%%int32：敏捷
%%int32：攻击
%%int32：防御
%%int32：速度
%%int32：闪避
%%int32：命中
%%int32：暴击
%%int32：连击
%%int32：破甲
%%int32：格挡
%%int32：反击
%%int32：金性
%%int32：木性
%%int32：水性
%%int32：火性
%%int32：土性
write(?PP_ACCOUNT_ROLE_ATTR, RoleAttr) ->
    Data = write_role_attr(RoleAttr),
	{ok, pt:pack(?PP_ACCOUNT_ROLE_ATTR, Data)};

write(?ACCOUNT_ROLE_CHARGE_UPADTE,{Goldsum,Vip_gfs_lvl}) ->
	Data = <<Goldsum:32,Vip_gfs_lvl:32>>,
	{ok, pt:pack(?ACCOUNT_ROLE_CHARGE_UPADTE, Data)};

%% 10101 门派信息 ACCOUNT_ROLE_SCHOOL_ACK（S >> C）
%% int32: 错误码(0:成功,其他失败)
%% int32:门派贡献度
%% int32:弟子层级
write(?ACCOUNT_ROLE_SCHOOL_ACK, [ErrCode, Credit, Grade]) ->
    Data = << ErrCode:32, Credit:32, Grade:32 >>,
    {ok, pt:pack(?ACCOUNT_ROLE_SCHOOL_ACK, Data)};

%% 10103 破格晋升 ACCOUNT_ROLE_UPGRADE_ACK（S >> C）
%% int32: 错误码(0:成功,其他失败)
%% int32:门派贡献度
%% int32:弟子层级
write(?ACCOUNT_ROLE_UPGRADE_ACK, [ErrCode, Credit, Grade]) ->
    Data = << ErrCode:32, Credit:32, Grade:32 >>,
    {ok, pt:pack(?ACCOUNT_ROLE_UPGRADE_ACK, Data)};

%% 10105 门派捐献 ACCOUNT_ROLE_CONTRIBUTE_ACK（S >> C）
%% int32: 错误码(0:成功,其他失败)
%% int32:门派贡献度
%% int32:弟子层级
% int32:捐献获得的贡献
% int32:捐献花掉的金币
write(?ACCOUNT_ROLE_CONTRIBUTE_ACK, [ErrCode, Credit, Grade, GetCredit, CostMoney]) ->
    Data = << ErrCode:32, Credit:32, Grade:32, GetCredit:32, CostMoney:32>>,
    {ok, pt:pack(?ACCOUNT_ROLE_CONTRIBUTE_ACK, Data)};

%% 10106 时间同步 ACCOUNT_ROLE_SYN_TIME（S >> C）
%% int32: 秒
write(?ACCOUNT_ROLE_SYN_TIME, [Sec]) ->
    Data = << Sec:32>>,
    {ok, pt:pack(?ACCOUNT_ROLE_SYN_TIME, Data)};

%% 10108 累积在线时长 PP_ACCOUNT_ONLINE_TIME_ACK（S>>C）
%% int32  当天累积在线时长 秒数（在否时发送）
write(?PP_ACCOUNT_ONLINE_TIME_ACK, [AccTime]) ->
	Data = <<AccTime:32>>,
	{ok, pt:pack(?PP_ACCOUNT_ONLINE_TIME_ACK, Data)};

%% 10110 剔除在线时长满3小时的防沉迷玩家响应 PP_ACCOUNT_KICKOFF_ONLINE_3HS_ACK（S>>C）
%% int32   是否操作成功（0：成功；1：失败）
write(?PP_ACCOUNT_KICKOFF_ONLINE_3HS_ACK, [Flag]) ->
	Data = <<Flag:32>>,
	{ok, pt:pack(?PP_ACCOUNT_KICKOFF_ONLINE_3HS_ACK, Data)};

%% 10200 人物属性变更 ACCOUNT_ROLE_INFO_CHANGE （S >> C）
%% int32：标识符（0：经验值改变；1：等级改变；2：灵力改变；3：耐力改变；4：敏捷改变；
%%               5：体质改变；6：道行改变 7:潜能改变 8:师门等级改变 9:兽魂变化；
%%               10：金元宝改变；11：银元宝改变；12：金币改变；13：银币改变；
%%               14：灵气改变；15：仙气改变；16:人物战力改变；17：体力改变；
%%               18：攻击改变；19：防御改变；20：血量改变；21：法力改变；
%%               22：速度改变；23：连击改变；24：暴击改变；25：破甲改变；
%%               26：格挡改变；27：闪避改变；28：命中改变；29：反击改变；
%%               30：障碍改变；31：抗障改变；32：金相性改变，33：木相性改变；
%%               34：水相性改变；35：火相性改变；36：土相性;37：妖气改变；38：战绩改变；）
%% int32：操作类型
%% uint64：角色唯一ID号
%%     int64：  角色经验变化值
%%     int32：  变化后角色等级
%%     int32：  角色灵力变化值
%%     int32：  角色耐力变化值
%%     int32：  角色敏捷变化值
%%     int32：  角色体质变化值
%%     int32：  角色道行变化后的值
%%	   int32:	角色兽魂变化值
%%     ...
%% （备注：标识符后面只跟角色唯一ID号和改变的值）
write(?ACCOUNT_ROLE_INFO_CHANGE, [Flag, Operate, RoleId, Change]) ->
    BinData = case Flag of
 		0 ->%% 经验值
 			<<Flag:32, Operate:32, RoleId:64, Change:64>>;
 		_Other ->
%% 			io:format("Flag:~p,Operate:~p,Change:~p~n",[Flag,Operate,Change]),
 			<<Flag:32, Operate:32, RoleId:64, Change:32>>
 	end,
 	{ok, pt:pack(?ACCOUNT_ROLE_INFO_CHANGE, BinData)};

%% 10506 查看角色信息应答 PP_AACOUNT_LOOK_ROLE_ACK (S>>C) 
%% int32: 错误码0成功,其他失败
%% int64 角色ID
%% String：角色名
%% int32：性别（0：男，1：女）
%% int32：职业（师门，1：金，2：木，3：水，4：火，5：土）
%% int32：等级
%% int32：道行
%% int32：气血
%% int32：法力
%% string：帮派名称
%% --uint64：帮派Id
%% uint32：称号Id
%% int32: 角色战力评分 
%% int32：角色境界id
%% int32：体质
%% int32：灵力
%% int32：耐力
%% int32：敏捷
%% int32：攻击
%% int32：防御
%% int32：速度
%% int32：闪避
%% int32：命中
%% ------int32 装备1 - 装备8------(我是分割线)--------
%% int32：物品数组长度
%% 详见装备属性
write(?PP_AACOUNT_LOOK_ROLE_ACK, {ErrorCode, RoleInfo, EquipList}) ->
    case ErrorCode of
        0 ->
            Data1 = write_role_detail(RoleInfo),
			AvatarId = RoleInfo#mhrole.avatarid,
%			WeaponAvatarId = RoleInfo#mhrole.weaponavatar,
			WeaponAvatarId = 0,
            Data2 = write_role_attr(RoleInfo#mhrole.roleattr),
            EquipListLen = length(EquipList),
            Data3 = pack_list(EquipList, <<>>),
            Data = <<ErrorCode:32, Data1/binary, AvatarId:32, WeaponAvatarId:32, Data2/binary, EquipListLen:32, Data3/binary>>;
        _ ->
            Data = <<ErrorCode:32>>
    end,
    {ok, pt:pack(?PP_AACOUNT_LOOK_ROLE_ACK, Data)};

% 10508 查看角色信息请求,通过名字查看 PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK(C>>S)
% int32 errorcode 0 success other failed
% int64 roleid
write(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK, [ErrorId, RoleId]) ->
    case ErrorId > 0 of
        true ->
            {ok, pt:pack(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK, <<ErrorId:32>>)};
        false ->
            {ok, pt:pack(?PP_ACCOUNT_LOOK_ROLE_BY_NAME_ACK, <<ErrorId:32, RoleId:64>>)}
    end;

%% 10510 查看角色坐标信息响应
%% int32: 标识（0：成功，1：不在线）
%% uint32 地图id
%% int32 坐标X
%% int32 坐标Y
write(?PP_ACCOUNT_POS_ACK, [ErrCode, MapId, X, Y])->
	{ok, pt:pack(?PP_ACCOUNT_POS_ACK, <<ErrCode:32, MapId:32, X:32, Y:32>>)};

% 10700 通用错误码 PP_ACCOUNT_ERR(S>>C)
% int32:错误码
write(?PP_ACCOUNT_ERR, Error) ->
    {ok, pt:pack(?PP_ACCOUNT_ERR, <<Error:32>>)};

% 10701 通用错误码2 PP_ACCOUNT_ERR2(S>>C)
% string:错误字符串 
write(?PP_ACCOUNT_ERR2, String) ->
    Bin = pt:write_string(String),
    {ok, pt:pack(?PP_ACCOUNT_ERR2, Bin)};
%% 通用提示	
write(?PP_ACCOUNT_TIP, {ShowType,TipId})->

    {ok, pt:pack(?PP_ACCOUNT_TIP, <<ShowType:16,TipId:32>>)};

%%------测试用-----
write(?PP_ACCOUNT_LOGIN, Account) ->
	BinName = pt:write_string(Account),
	BinCheckcode = pt:write_string(""),
	Data = << BinName/binary, 0:32,BinCheckcode/binary >>,
	{ok, pt:pack(?PP_ACCOUNT_LOGIN, Data)};

write(?PP_ACCOUNT_CREATE_ROLE, [Account,RoleName,Sex,Career]) ->
	BinAccount = pt:write_string(Account),
	BinRoleName = pt:write_string(RoleName),
	Data = << BinAccount/binary, BinRoleName/binary, Sex:32, Career:32 >>,
	{ok, pt:pack(?PP_ACCOUNT_CREATE_ROLE, Data)};

write(?PP_ACCOUNT_GET_ROLE_DETAIL, _R) ->
	{ok, pt:pack(?PP_ACCOUNT_GET_ROLE_DETAIL, <<>> )};

write(?PP_ACCOUNT_GET_ROLE_ATTR, _R)->
	{ok, pt:pack(?PP_ACCOUNT_GET_ROLE_ATTR, <<>>)}.


%% 打包数组
pack_bin([], Bin) ->
    Bin;
pack_bin([H|T], Bin) ->
    TmpBin = 
    if
        is_integer(H) ->
            <<H:32>>;
        is_list(H) -> 
            pt:write_string(H)
    end,

    Bin2 = <<Bin/binary, TmpBin/binary>>,
    pack_bin(T, Bin2).

%% 打包称号和属性列表
pack_title_pro([], _, Bin) ->
	Bin;
pack_title_pro([Title | T], Flag, Bin) ->
	Bin2 = <<Bin/binary, Title:32, Flag:32>>,%%0：已启用，1：未启用
	pack_title_pro(T, Flag, Bin2).

%%找没启用的称号
get_unuse_title([], IdList)->
	IdList;
get_unuse_title(UseList, IdList)->
	[Title | RestList] = UseList,
	NewIdList = case lists:member(Title, IdList) of
					true-> lists:delete(Title, IdList);
					false->IdList
				end,
	get_unuse_title(RestList, NewIdList).
	
pack_32list([], Bin) ->
    Bin;
pack_32list([H | T], Bin) ->
    pack_32list(T, <<Bin/binary, H:32>>).

pack_list([], Bin) ->
    Bin;
pack_list([H|T], Data) ->
%%     [Id|Left] = H,
    [[ItemId, ModuleId, Num, Time, Bind, Dura, Qua, Equiped], Id | Left] = H,
    Bin = pack_32list(Left, 
                   <<ItemId:64, ModuleId:32, Num:32, Time:32, Bind:32, Dura:32, 
      Qua:32, Equiped:32, Id:64>>),
    Data2 = <<Data/binary, Bin/binary>>,
    pack_list(T, Data2).

%write_role_detail(#mhrole{roleid=Roleid,rolename=RoleName,sex=Sex,career=Career,mapid=MapId,pointpos={X,Y},
%            level=Level,dao=Dao,hp=Hp,mp=Mp,energy=Energy,exp=Exp,vip=Vip,vip_type=VipType,guildid = GuildId,titleid = TitleId,gold=Gold,
%            silver=Silver,goldcoin=GoldCoin,silvercoin=SilverCoin, guild_position = GuildPosition,
%        	potential=Potential, smartgas=Smartgas, godgas=Godgas, soul = Soul,fight = Fight, boundary = Boundary, 
%			rank_sub = Rank_sub,						 	  
%			guild_name = GName,	pet_column = PetColumn, vip_time = VipTime, vip_gfs_lvl = VipGfsLvl,
%			gfs_goldsum =Gfs_goldsum,vip_card_use = VipCardUse,
%			pk_value=PkVal,yao_qi=YaoQi, role_type = RoleType,
%			zhan_ji = ZhanJi, pk_win_rate = PkWinRate}) ->
%	
%    Bname = pt:write_string(RoleName),
%    %%todo:根据帮派id获取帮派名称
%    GuildName = pt:write_string(GName),
%    {Rand, Max} = lib_role:get_dao_lv_and_max(Boundary, Dao),
%    NowSec = util:get_now_second(),
%    FullStrLv = 0, %暂不开发这个功能
%    ?IF(VipTime > NowSec, VipDay = util:ceil((VipTime - NowSec)/86400), VipDay = 0),
%    Data = << Roleid:64,Bname/binary,Sex:32,Career:32,Level:32,MapId:32, X:32,Y:32,Dao:32,
%            Hp:32,Mp:32,Energy:32,Exp:64,Vip:32,VipType:32,GuildName/binary,
%            GuildPosition:16, GuildId:64,TitleId:32,Gold:32,Silver:32,
%            GoldCoin:32,SilverCoin:32,Potential:32,Smartgas:32,Godgas:32, 
%            Soul:32, Fight:32,Boundary:32,Rank_sub:32,
%			  Rand:16,Max:32,
%			  FullStrLv:32,PetColumn:16,VipDay:32,VipGfsLvl:32,Gfs_goldsum:32,
%			PkVal:32,YaoQi:32,RoleType:32, ZhanJi:32, PkWinRate:32, VipCardUse:32>>,
%    Data.


write_role_detail(#mhrole{roleid=Roleid,rolename=RoleName,sex=Sex,career=Career}) ->
	io:format("~n~nRoleid=~p,RoleName=~p,Sex=~p,career=~p~n~n", [Roleid,RoleName,Sex,Career]),
    Bname = pt:write_string(RoleName),
    Data = << Roleid:64,Bname/binary,Sex:32,Career:32>>,
    Data.

write_role_attr(#roleattr{phy=Phy,smart=Smart,endur=Endur,agile=Agile,att=Att,def=Def,spd=Spd,
    dodge=Dodge,hit=Hit,crit=Crit,combo=Combo,break=Break,resist=Resist,counter=Counter,metal = Metal,wood=Wood,
    water=Water,fire=Fire,earth=Earth, barrier = Barrier, disturbance = Disturbance }) ->
    Data = << Phy:32,Smart:32,Endur:32,Agile:32,Att:32,Def:32,Spd:32,Dodge:32,Hit:32,Crit:32,Combo:32,
        Break:32,Resist:32,Counter:32,Metal:32,Wood:32,Water:32,Fire:32,Earth:32, 
        Barrier:32, Disturbance:32 >>,
    Data.

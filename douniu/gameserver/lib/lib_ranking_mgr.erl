%%Author: gavin
%%Create: 2013-04-24
%%Description: 排行榜

-module(lib_ranking_mgr).

-include("common.hrl").
-include("ranking.hrl").

-export([
        load_role_ranking/0, 	%人物榜
        load_pet_ranking/0, 	%宠物榜
        load_equip_ranking/0, 	%装备榜
        delete_role_ranking_from_db/2, 	%删除人物榜信息
        update_role_ranking_to_db/2,
		delete_pet_ranking_from_db/2, 	%删除宠物榜信息
		update_pet_ranking_to_db/2,
		delete_equip_ranking_from_db/2,
		update_equip_ranking_to_db/2,
		load_mount_ranking/0,
		delete_mount_ranking_from_db/2,
		update_mount_ranking_to_db/2
]).

%%
%%local function
%%

%%==============================================================================
%%  Role Ranking
%%==============================================================================
load_role_ranking() ->
    Sql = "SELECT gd_type,gd_roleid,gd_sex,gd_career,gd_dao,gd_role_grade,
    gd_pet_grade,gd_total_grade,gd_level,gd_record,gd_xianban_exp,
    gd_rolename,gd_guildname FROM gd_role_ranking",
    case db_sql:get_all(Sql) of
        [] ->
            [];
        Res ->
            _RoleRankingList = role_ranking_format(Res)
    end.




delete_role_ranking_from_db(Type, RoleId) ->
    Sql = io_lib:format("delete from gd_role_ranking where gd_type=~p and 
        gd_roleid=~p", [Type, RoleId]), 
    mod_db_server:execute_one(0, Sql).

update_role_ranking_to_db(_Type, []) ->
    ok;
update_role_ranking_to_db(Type, [RoleRanking | RestList]) ->
    %?INFO("RoleRanking:~p", [RoleRanking]),
        #role_ranking{
            ranking = Rank,
            roleid = RoleId,
            sex = Sex,
            career = Career,
            dao = Dao,
            level = Level,
            role_grade = RoleGrade,
            pet_grade = PetGrade,
            total_grade = TotalGrade,
            record = Record,
            xianbanexp = XianbanExp,
            name = Rolename,
            guild_name = Guildname
        } = RoleRanking,
        %StrRolename = util:term_to_string(Rolename), 
        %StrGuildname = util:term_to_string(Guildname),
    Sql = db_sql:make_replace_sql("gd_role_ranking", 
        ["gd_type", "gd_roleid","gd_sex","gd_career","gd_dao","gd_role_grade","gd_pet_grade",
            "gd_total_grade","gd_level","gd_record","gd_xianban_exp",
            "gd_rolename","gd_guildname"],
        [Type, RoleId, Sex, Career, Dao, RoleGrade, PetGrade,TotalGrade,Level,
            Record, XianbanExp, Rolename, Guildname]), 
    %?INFO("update sql:~p", [Sql]),
    mod_db_server:execute_one(0, Sql),
    update_role_ranking_to_db(Type, RestList).


role_ranking_format(RoleRanking)->
    role_ranking_format(RoleRanking, 1, []).

role_ranking_format([], _Ranking, RtList) ->
    RtList;
role_ranking_format([H|RestList], Ranking, RtList) ->
    [Type, RoleId, Sex, Career, Dao, RoleGrade, PetGrade, TotalGrade, Level, 
        Record, XianbanExp, RoleName, GuildName] = H , 
    StrRoleName = binary_to_list(RoleName),
    StrGuildName = binary_to_list(GuildName),
    %?INFO("RoleName:~p,GuildName:~p", [RoleName, GuildName]),
    RoleRanking = #role_ranking{
        ranking = Ranking,
        roleid = RoleId,
        sex = Sex,
        career = Career,
        dao = Dao,
        level = Level, 
        total_grade = TotalGrade,
        role_grade = RoleGrade,
        pet_grade = PetGrade,
        name = StrRoleName,
        guild_name = StrGuildName
    },
    %?INFO("RoleRanking:~p", [RoleRanking]),
    role_ranking_format(RestList, Ranking+1, [{Type, RoleRanking} | RtList]).



%%==============================================================================
%%  Pet Ranking
%%==============================================================================

%%加载宠物榜信息
load_pet_ranking()->
	Sql = "SELECT gd_type,gd_petid,gd_roleid,gd_grade,gd_dao,gd_hp,gd_attr,gd_spd,gd_master,gd_pet_name,gd_role_name,gd_sex,gd_career
		  FROM gd_pet_ranking ",
    case db_sql:get_all(Sql) of
        [] ->
            [];
        Res ->
            _PetRankingList = pet_ranking_format(Res)
    end.



%%宠物信息格式化
pet_ranking_format(PetRanking)->
    do_pet_ranking_format(PetRanking, 1, []).

do_pet_ranking_format([], _Ranking, RtList) ->RtList;
do_pet_ranking_format([H|RestList], Ranking, RtList) ->
    [Type,Petid,Roleid,Grade,Dao,Hp,Attr,Spd,Master,Name,RoleName,RoleSex, RoleCareer] = H , 
    StrPetName  = binary_to_list(Name),
    StrRoleName = binary_to_list(RoleName),
    PetRanking  = #pet_ranking{
        ranking = Ranking,
		roleid  = Roleid,
		petid 	= Petid,
		grade 	= Grade,
		dao 	= Dao,
		hp 		= Hp,
		attr	= Attr,
		spd		= Spd, 
		master  = Master,
		name 	= StrPetName,
		role_name 	= StrRoleName,
		role_sex 	= RoleSex,
		role_career = RoleCareer},
    do_pet_ranking_format(RestList, Ranking+1, [{Type,PetRanking}|RtList]).


%%删除宠物排行信息
delete_pet_ranking_from_db(Type, PetId) ->
    Sql = io_lib:format("delete from gd_pet_ranking where gd_type=~p and 
        gd_petid=~p", [Type, PetId]), 
    mod_db_server:execute_one(0, Sql).


update_pet_ranking_to_db(_Type, []) ->ok;
update_pet_ranking_to_db(Type, [PetRanking | RestList]) ->
    %?INFO("RoleRanking:~p", [RoleRanking]),
	#pet_ranking{
		ranking 	= Rank, 			%名次
		roleid 		= Roleid,			%角色ＩＤ
		petid 		= Petid, 			%宠物ID
		grade 		= Grade, 			%宠物战力
		dao 		= Dao, 				%道行
		hp 			= Hp, 				%资质
		attr		= Attr,				%攻击
		spd			= Spd,				%速度
		master 		= Master, 			%师傅
		name 		= Name, 			%宠物名
		role_name 	= RoleName, 		%玩家名
		role_sex 	= RoleSex, 			%性别
		role_career = RoleCareer 		%角色职业
	} = PetRanking,
	 
	Sql = db_sql:make_replace_sql("gd_pet_ranking", 
	["gd_type", "gd_petid","gd_roleid","gd_grade","gd_dao","gd_hp","gd_attr","gd_spd","gd_master",
	"gd_pet_name","gd_role_name","gd_sex","gd_career"],
	[Type, Petid, Roleid, Grade, Dao,Hp,Attr,Spd,Master,Name,RoleName, RoleSex, RoleCareer]), 
	%?INFO("update sql:~p", [Sql]),
	mod_db_server:execute_one(0, Sql),
	update_pet_ranking_to_db(Type, RestList).
	

%%==============================================================================
%%  Equip Ranking
%%==============================================================================

%%加载宠物榜信息
load_equip_ranking()->
	Sql = "SELECT gd_type,gd_itemid,gd_moduleid,gd_sex,gd_grade,gd_roleid,gd_role_name,gd_role_career FROM gd_equip_ranking ",
    case db_sql:get_all(Sql) of
        [] ->
            [];
        Res ->
            _PetRankingList = equip_ranking_format(Res)
    end.



%%宠物信息格式化
equip_ranking_format(EquipRanking)->
    do_equip_ranking_format(EquipRanking, 1, []).

do_equip_ranking_format([], _Ranking, RtList) ->RtList;
do_equip_ranking_format([H|RestList], Ranking, RtList) ->
    [Type,Itemid,Moduleid,Sex,Grade,Roleid,RoleName,RoleCareer] = H , 
    StrRoleName = binary_to_list(RoleName),
    EquipRanking = #equip_ranking{
		ranking = Ranking, 			%名次
        itemid  = Itemid, 			%装备ＩＤ
        moduleid= Moduleid,		 	%装备原型ID
        sex 	= Sex, 				%性别
        grade 	= Grade, 			% 装备评分
        roleid 	= Roleid,
        role_name 	= StrRoleName, 	%角色名字
        role_career = RoleCareer 	%角色职业						   
        },
    do_equip_ranking_format(RestList, Ranking+1, [{Type,EquipRanking}|RtList]).


%%删除宠物排行信息
delete_equip_ranking_from_db(Type, Itemid) ->
    Sql = io_lib:format("delete from gd_equip_ranking where gd_type=~p and 
        gd_itemid=~p", [Type, Itemid]), 
    mod_db_server:execute_one(0, Sql).


update_equip_ranking_to_db(_Type, []) ->ok;
update_equip_ranking_to_db(Type, [EquipRanking | RestList]) ->
    %?INFO("RoleRanking:~p", [RoleRanking]),
	#equip_ranking{
		ranking = Ranking, 			%名次
        itemid  = Itemid, 			%装备ＩＤ
        moduleid= Moduleid,		 	%装备原型ID
        sex 	= Sex, 				%性别
        grade 	= Grade, 			% 装备评分
        roleid 	= Roleid,
        role_name 	= StrRoleName, 	%角色名字
        role_career = RoleCareer 	%角色职业	
	} = EquipRanking,
	 
	Sql = db_sql:make_replace_sql("gd_equip_ranking", 
	["gd_type", "gd_itemid","gd_moduleid","gd_sex","gd_grade","gd_roleid","gd_role_name","gd_role_career"],
	[Type, Itemid, Moduleid, Sex, Grade,Roleid,StrRoleName,RoleCareer]), 
	%?INFO("update sql:~p", [Sql]),
	mod_db_server:execute_one(0, Sql),
	update_equip_ranking_to_db(Type, RestList).



	
%%==============================================================================
%%  MOUNT RANKING
%%==============================================================================

%%加载宠物榜信息
load_mount_ranking()->
	Sql = "SELECT gd_type,gd_mountid,gd_roleid,gd_school,gd_grade,gd_zhizhi,gd_rare,gd_quality,gd_level,gd_mount_name,gd_role_name FROM gd_mount_ranking ",
    case db_sql:get_all(Sql) of
        [] ->
            [];
        Res ->
            _MountRankingList = mount_ranking_format(Res)
    end.



%%宠物信息格式化
mount_ranking_format(MountRanking)->
    do_mount_ranking_format(MountRanking, 1, []).

do_mount_ranking_format([], _Ranking, RtList) ->RtList;
do_mount_ranking_format([H|RestList], Ranking, RtList) ->
    [Type,Mountid,Roleid,School,Grade,Zhizhi,Rare,Quality,Level,Mount_name,Role_name] = H , 
    StrRoleName  = binary_to_list(Role_name),
	StrMountName = binary_to_list(Mount_name),
    MountRanking = #mount_ranking{
		ranking = Ranking, 			
        mountid = Mountid, 			
        roleid  = Roleid,		 	
        school 	= School, 				
        grade 	= Grade, 			
        zhizi 	= util:string_to_term(binary_to_list(Zhizhi)),
        rare 	= Rare, 
		quality = Quality,		
		level   = Level,
        mount_name = StrMountName, 	
		role_name  = StrRoleName },
    do_mount_ranking_format(RestList, Ranking+1, [{Type,MountRanking}|RtList]).


%%删除宠物排行信息
delete_mount_ranking_from_db(Type, Itemid) ->
    Sql = io_lib:format("delete from gd_mount_ranking where gd_type = ~p and gd_mountid = ~p;", [Type, Itemid]), 
    mod_db_server:execute_one(0, Sql).


update_mount_ranking_to_db(_Type, []) ->ok;
update_mount_ranking_to_db(Type, [MountRanking | RestList]) ->
        #mount_ranking{
		ranking = Ranking, 			
        mountid = Mountid, 			
        roleid  = Roleid,		 	
        school 	= School, 				
        grade 	= Grade, 			
        zhizi 	= Zhizhi,
        rare 	= Rare, 
		quality = Quality,		
		level   = Level,
        mount_name = StrMountName, 	
		role_name  = StrRoleName  } = MountRanking,
	 
	Sql = db_sql:make_replace_sql("gd_mount_ranking", 
	["gd_type", "gd_mountid","gd_roleid","gd_school","gd_grade","gd_zhizhi","gd_rare","gd_quality","gd_level","gd_mount_name","gd_role_name"],
	[Type, Mountid, Roleid, School, Grade, util:term_to_string(Zhizhi),Rare,Quality,Level,StrMountName,StrRoleName]), 
	mod_db_server:execute_one(0, Sql),
	update_mount_ranking_to_db(Type, RestList).


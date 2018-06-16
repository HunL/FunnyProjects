%% Author: linhuansong
%% Created: 2012-11-3
%% Description: TODO: Add description to lib_random
-module(lib_random).

%%
%% Include files
%%
-include("record.hrl").
-include("common.hrl").
%%
%% Exported Functions
%%
%% 随机
-export([hit_random/2,get_random_info_list/1]).
-export([get_random_fr_weight_list_int/1,
        get_random_fr_weight_list_float/1,
        get_random_event_by_weight/2 %获取权重随机事件,支持指定总权重
    ]).

%%
%% API Functions
%%
%% 从权重列表中获取随机对象 Weight为整数
%% List = [{TypeData,Weight}]
%% return = {TypeData} ｜ []
get_random_fr_weight_list_int(List)->
	{Rand_cfg_list, Sum} = get_random_info_list(List),
	if Sum =< 0 ->
%% 		   ?INFO("Err， List：~p， Sum:~p",[List,Sum]),
		   [];
	   true ->
			Random_int = mod_rand:int(Sum),
			hit_random( Random_int, Rand_cfg_list)
	end.

%% 从权重列表中获取随机对象 Weight为浮点数
%% List = [{TypeData,Weight}]
%% return = {TypeData} 
get_random_fr_weight_list_float(List)->
	{Rand_cfg_list, Sum} = get_random_info_list(List),
	Random_float = mod_rand:float(),
	?INFO("Random_float:~p,Sum:~p,Rand_cfg_list:~p",[Random_float,Sum,Rand_cfg_list]),
	hit_random( Random_float, Rand_cfg_list).


%从权重列表中获取随机事件,
%EventList [{Event, Weight}] Weight为整型
%TotalWeight 总的权重,当这个值大于EventList中所有Weight之和时,可能出现未命中情况
%return false|{true,Event} 
get_random_event_by_weight(EventList, TotalWeight) ->
    WeightSum = lists:sum([XProb || {_,XProb} <- EventList]),
    EmptyWeight = max(TotalWeight - WeightSum,0),
    EventList2 = 
    case EmptyWeight > 0 of
        true -> 
            [{not_hit, EmptyWeight} | EventList];
        _ ->
            EventList
    end,
       
    case get_random_fr_weight_list_int(EventList2) of
        {not_hit} ->
           false;
        {Event} ->
            {true, Event} 
    end.
%%
%% Local Functions
%%



%% List = [{TypeData,Weight}]
%% return = {Random_List,Sum}, Random_List =[{TypeData, Start, End}]
get_random_info_list(List)->
	Fun = fun({TypeData,Weight},Sum)->
			{{TypeData,Sum,Weight+Sum},Weight+Sum}
	end,
	{Rand_cfg_list, Sum} = lists:mapfoldl(Fun, 0, List),
	{Rand_cfg_list, Sum}.

%% List = [{TypeData, Start, End}]
%% return = {TypeData}
hit_random( RandomNum, List)->
	Res_list = [{TypeData,Start,End}||{TypeData,Start,End}<-List,RandomNum=<End andalso RandomNum> Start],
	case Res_list of
		[]->error;	%% 没命中
		[{TypeData,_Start,_End}] ->{TypeData};
		Other -> 
			?INFO("hit_random Error: ~p",[Other]),
			error  %% 概率范围有重复
	end.

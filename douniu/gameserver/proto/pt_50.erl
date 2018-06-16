%% @author j
%% @doc @todo Add description to pt_50.


-module(pt_50).

-include("proto.hrl").
-include("common.hrl").
-include("record.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([read/2, write/2]).



%% ====================================================================
%% Internal functions
%% ====================================================================

%read(?PP_DOUNIU_CREATE_ROOM_REQ, BinContent) ->
%	<<ChatMode:32, Rest1/binary>> = BinContent,
%	{ToName, Rest2}        = pt:read_string(Rest1),
%	{ChatContent, _}       = pt:read_string(Rest2),
%    {ok, [ChatMode, ToName, ChatContent]};
read(?PP_DOUNIU_CREATE_ROOM_REQ, Bin) ->
	?INFO("~n~nB=~p~n~n", [Bin]),
	{First, Rest}        = pt:read_string(Bin),
	{Second, _}       = pt:read_string(Rest),
	?INFO("First=~p,Second=~p~n", [First, Second]),
    {ok, [First, Second]};


read(?PP_DOUNIU_JOIN_ROOM_REQ, Bin) ->
	?INFO("~n~nJOIN_ROO=~p~n~n", [Bin]),
	{First, Rest}        = pt:read_string(Bin),
	{Second, _}       = pt:read_string(Rest),
	?INFO("First=~p,Second=~p~n", [First, Second]),
    {ok, [First, Second]};

read(?PP_DOUNIU_QUIT_ROOM_REQ, Bin) ->
	?INFO("~n~nQUIT_ROOM=~p~n~n", [Bin]),
	{First, Rest}        = pt:read_string(Bin),
	{Second, _}       = pt:read_string(Rest),
	?INFO("First=~p,Second=~p~n", [First, Second]),
    {ok, [First, Second]};

read(?PP_DOUNIU_READY_REQ, Bin) ->
	?INFO("~n~nREADY=~p~n~n", [Bin]),
	{First, Rest}        = pt:read_string(Bin),
	{Second, _}       = pt:read_string(Rest),
	?INFO("First=~p,Second=~p~n", [First, Second]),
    {ok, [First, Second]};

read(?PP_DOUNIU_QIANGZHUANG_REQ, Bin) ->
	?INFO("~n~nQIANGZHUANG=~p~n~n", [Bin]),
    {ok, []};

read(?PP_DOUNIU_YAZHU_REQ, Bin) ->
	?INFO("~n~nYAZHU=~p~n~n", [Bin]),
	<<BeiShu:32>> = Bin,
	?INFO("BeiShu=~p~n", [BeiShu]),
    {ok, [BeiShu]};

read(?PP_DOUNIU_CHONGZHI_REQ, Bin) ->
	?INFO("~n~nchongzhi=~p~n~n", [Bin]),
	<<Num:32>> = Bin,
	?INFO("Num=~p~n", [Num]),
    {ok, [Num]};

read(?PP_DOUNIU_FAPAI_REQ, _) ->
	{ok, []};

read(?PP_DOUNIU_TANPAI_REQ, _) ->
	{ok, []};


read(?PP_DOUNIU_ZHANJI_REQ, _) ->
	{ok, []}.



write(?PP_DOUNIU_CREATE_ROOM_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_CREATE_ROOM_ACK, BinStr)};

write(?PP_DOUNIU_JOIN_ROOM_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_JOIN_ROOM_ACK, BinStr)};

write(?PP_DOUNIU_QUIT_ROOM_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_QUIT_ROOM_ACK, BinStr)};

write(?PP_DOUNIU_READY_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_READY_ACK, BinStr)};

write(?PP_DOUNIU_QIANGZHUANG_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_QIANGZHUANG_ACK, BinStr)};

write(?PP_DOUNIU_YAZHU_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_YAZHU_ACK, BinStr)};

write(?PP_DOUNIU_CHONGZHI_ACK, [Flag, Num])->
	{ok, pt:pack(?PP_DOUNIU_CHONGZHI_ACK, <<Flag:32, Num:32>>)};

write(?PP_DOUNIU_FAPAI_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_FAPAI_ACK, BinStr)};

write(?PP_DOUNIU_TANPAI_ACK, String)->
	BinStr = pt:write_string(String),
	{ok, pt:pack(?PP_DOUNIU_TANPAI_ACK, BinStr)};

write(?PP_DOUNIU_ZHANJI_ACK, List) ->
	?INFO("List=~p~n", [List]),
	case List of
		[] ->
			Bin = pt:write_string(List),
			Data = <<Bin/binary>>,
			{ok, pt:pack(?PP_DOUNIU_ZHANJI_ACK, Data)};
		_ ->
			Bin = pt:write_string(List),
			Data = <<Bin/binary>>,
			{ok, pt:pack(?PP_DOUNIU_ZHANJI_ACK, Data)}
	end.


f(List) -> fun() ->
	[begin
		ok
	end || #rec_zhanji{rivalid = Id, result = Res} <- List]
	end.





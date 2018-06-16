%%%-----------------------------------
%%% @Module  : pt_err
%%% @Email   : error 
%%% @Created : 2011.10.19
%%% @Description: pack the error modules
%%%-----------------------------------
-module(pt_err).
-export([write/2]).
-include("common.hrl").
-include("record.hrl").


%%
%%服务端 -> 客户端 ------------------------------------
%%


write(10999, {Module, Err}) ->
    Data = <<Module:16, Err:32>>,
    {ok, pt:pack(10999, Data)}.




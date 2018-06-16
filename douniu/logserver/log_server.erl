%% Author: LiuYaohua
%% Created: 2012-7-30
%% Description: Log服务器
-module(log_server).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start/0,stop/0]).

%%
%% API Functions
%%
start() ->
	application:start(sasl),
	application:start(log_server).

stop() ->
	application:stop(log_server),
	application:stop(sasl).
%%
%% Local Functions
%%


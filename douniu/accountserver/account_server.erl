%% Author: LiuYaohua
%% Created: 2012-7-4
%% Description: 账号管理服务器
-module(account_server).

%%
%% Include files
%%
-include("common.hrl").
-include("record.hrl").

%%
%% Exported Functions
%%
-export([start/0, stop/0]).

%%
%% API Functions
%%
start() ->
%	application:start(sasl),
%	application:start(account_server),
	clear_work().

stop() ->
%	application:stop(account_server),
%	application:stop(sasl),
	init:stop().

clear_work() ->
	%% waiting for myslq to start
%% 	timer:sleep(5000),
%% 	Sql = "delete from g_curronlineinfo",
%% 	db_sql:execute(Sql),
%% 	error_logger:info_msg("Clear work finished").
	ok.

%%
%% Local Functions
%%


%% Author: L-Jiehui
%% Created: 2012-10-23
%% Description: 屏蔽字过滤操作
-module(lib_word_filter).

%%
%% Include files
%%
-include("common.hrl").

-define(REPLACEMENT_WORDS, [42,42,42,42]).	%% ****
-ifndef(IF).
-define(IF(C, T, F), (case (C) of true -> (T); false -> (F) end)).
-endif.

%%
%% Exported Functions
%%
-export([filter_prohibited_words/1]).

%%
%% API Functions
%%
filter_prohibited_words(Content) when is_list(Content) ->
	Filtered = replace_content(Content, [], 0),
	Filtered.

%%
%% Local Functions
%%
replace_content([], Acc, 0) ->
	lists:reverse(Acc);
replace_content([C], Acc, 0) ->
	lists:reverse([C | Acc]);
replace_content(Content, Acc, 0) ->
	%?INFO("Content = ~p~n, Acc = ~p~n", [Content, Acc]),
	[H | T] = Content,
	{NewH, NewT} = 
	if
		H >= 224 ->
			{H1, T1} = lists:split(1, Content),
			{H2, T2} = lists:split(1, T1),
			{H3, T3} = lists:split(1, T2),
			H4=H1++H2++H3,
			{H4, T3};
		true ->
			{[H], T}
	end,
	case cfg_forbiddenword:get_hashed_word_list(NewH) of
		undefined ->
			replace_content(NewT, [NewH | Acc], 0);
		WordList ->
			case match_words(Content, WordList) of
				{matched, Word} ->
 					Replacement = ?REPLACEMENT_WORDS,
					?IF(length(NewH) =:= 3,
					   replace_content(NewT, Replacement ++ Acc, length(Word)-3), 
					   replace_content(NewT, Replacement ++ Acc, length(Word)-1)
					  );
				no_match ->
					replace_content(NewT, [NewH | Acc], 0)
			end
	end;
replace_content([_|T], Acc, SkipTimes) ->
	replace_content(T, Acc, SkipTimes-1).

match_words(_, []) ->
	no_match;
match_words(PartialContent, [H|T]) ->
	case lists:prefix(H, PartialContent) of 
		true ->
%% 			io:format("H=~ts~n",[list_to_binary(H)]),
			{matched, H};
		false ->
			match_words(PartialContent, T)
	end.


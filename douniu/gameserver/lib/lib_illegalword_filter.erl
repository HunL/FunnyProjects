%% @author Kevin
%% @todo 非法字符过滤操作

-module(lib_illegalword_filter).

%%
%% Include files
%%
-include("common.hrl").
-define(REPLACEMENT_WORDS, [97,97,97,97]).	%% aaaa

%% ====================================================================
%% API functions
%% ====================================================================
-export([has_illegal_word/1]).



%% ====================================================================
%% Internal functions
%% ====================================================================
has_illegal_word([]) ->
	false;
has_illegal_word(Content) when is_list(Content) ->
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
		H > 224 ->
			{H1, T1} = lists:split(1, Content),
			{H2, T2} = lists:split(1, T1),
			{H3, T3} = lists:split(1, T2),
			H4=H1++H2++H3,
			{H4, T3};
		true ->
			{[H], T}
	end,
	case cfg_illegal_character:get_illegal_character(NewH) of
		undefined ->
			replace_content(NewT, [NewH | Acc], 0);
		WordList ->
			%?INFO("Content=~p, WordList=~p~n", [Content, WordList]),
			case match_words(Content, WordList) of
				{matched, Word} ->
					%kmp:patch(WordList,Content)
					%kmp:patch(Content,WordList)
					%Replacement=kmp:patch(Content,Word),
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



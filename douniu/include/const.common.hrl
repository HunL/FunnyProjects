-define(debug, 1).
%% 工具宏
-ifdef(debug).
    -define(MSG_DEBUG(Format, Args),    io:format("P|~p>> ~p:~p " ++ Format ++ "|~n",["0:0:0",?MODULE,?LINE|Args])).
-else.
    -define(MSG_DEBUG(Text),                ok).
-endif.

-define(HTTP_CODE_200,                  200).
-define(HTTP_CODE_400,                  400).
-define(HTTP_CODE_403,                  403).
-define(HTTP_CODE_500,                  500).
-define(HTTP_TIMEOUT,                   600).
-define(HTTP_LISTEN_OPTIONS,     [{active, false},
								  binary,
								  {backlog, 256},
								  {packet, http_bin},
								  {raw, 6, 9, <<1:32/native>>},
								  {reuseaddr, true},
                                  {buffer, 65535}
                              ]).

-define(CONST_ADMIN_MAX_LEN,			102400).

%-define(CONST_GM_PORT,					20001).
-define(CONST_GM_PORT,					mh_env:get_env(admin_port)).
%-define(CONST_GM_KEY,					"aiyou123456").
-define(CONST_GM_KEY,				    mh_env:get_env(key)).

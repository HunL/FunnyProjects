set LOCAL_IP=192.168.0.104
set MHXD_EBIN_PATH=F:\work\dn\svncode\ebin
set COOKIE=%LOCAL_IP%

set ERL_MAX_ETS_TABLES = 300000
set ERL_MAX_PORTS = 300000


cd /d %MHXD_EBIN_PATH%

%start "accountserver" erl -name a001@%LOCAL_IP% -setcookie %COOKIE% -s account_server

start "gameserver" erl -name s001@%LOCAL_IP% -setcookie %COOKIE% -pa ../ebin ../deps/cowboy/ebin ../deps/ranch/ebin/ ../deps/cowlib/ebin -s dn

start "logserver" erl -name log001@%LOCAL_IP% -setcookie %COOKIE% -s log_server

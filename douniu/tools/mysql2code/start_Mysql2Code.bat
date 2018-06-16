
set LOCAL_IP=192.168.51.101
set MHXD_EBIN_PATH=F:\Codes\svncode\ebin

set COOKIE=%LOCAL_IP%

set ERL_MAX_ETS_TABLES = 300000
set ERL_MAX_PORTS = 300000


cd /d %MHXD_EBIN_PATH%

start "tool_mysql2code" erl -s mysql2code



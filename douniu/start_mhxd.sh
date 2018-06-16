#!/bin/sh

set -v
#killall beam.smp

export ERL_MAX_ETS_TABLES=300000
export ERL_MAX_PORTS=300000

export LOCAL_IP=120.24.180.25
export INDEX=1
export COOKIE=$LOCAL_IP"_"$INDEX

echo restart apps
cd ebin

nohup erl -name s001@120.24.180.25 -setcookie abc -pa ../ebin ../deps/cowboy/ebin ../deps/ranch/ebin/ ../deps/cowlib/ebin -s dn
sleep 3

nohup erl -name log001@120.24.180.25 -setcookie abc -s log_server 
sleep 3


#!/bin/bash

# Kill processes
echo "Ignore 2 no-such-process messages (from trying to kill grep and jps)"
ps -u u7300623 -f | grep spark | awk '{print $2}' | xargs kill # kill all processes associated to spark (this includes scripts in spark directory)
jps | awk '{print $1}' | xargs kill # kill java processes
pkill iostat
pkill mpstat

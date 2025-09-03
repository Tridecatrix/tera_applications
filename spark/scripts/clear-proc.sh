#!/bin/bash

echo "Ignore 2 no-such-process messages (from ps | grep and jps including themselves in their outputs)"

# kill run scripts
pkill top_level_run.sh -f
pkill run.sh

./run.sh -k # kill background processes
ps -u u7300623 -f | grep spark | awk '{print $2}' | xargs kill # kill all processes associated to spark (this includes scripts in spark directory)
jps | awk '{print $1}' | xargs kill # kill java processes
pkill iostat
pkill mpstat

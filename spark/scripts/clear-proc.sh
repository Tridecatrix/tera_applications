#!/bin/bash

# kill run scripts
ps -u u7300623 -f | grep run.sh | awk '{print $2, $8}' | while read pid cmd; do
    if [[ $cmd -eq "grep" ]]; then
        continue; 
    fi
    echo "Killing run.sh process with PID $pid, CMD: $cmd"
    kill "$pid"
done

# kill all other processes
./run.sh -k # kill background processes

ps -u u7300623 -f | grep spark | awk '{print $2, $8}' | while read pid cmd; do
    if [[ $cmd -eq "grep" ]]; then
        continue;
    fi
    echo "Killing spark process with PID $pid, CMD: $cmd"
    kill "$pid"
done

jps | awk '{print $1, $2}' | while read pid pname; do
    if [[ $cmd -eq "jps" ]]; then
        continue;
    fi
    echo "Killing java process with PID $pid, Name: $pname"
    kill "$pid"
done

for proc in iostat mpstat; do
    pkill "$proc" && echo "Killed all $proc processes"
done
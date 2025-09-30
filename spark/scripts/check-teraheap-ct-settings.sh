#!/bin/bash
# path to sharedDefines.h for updating (on raven3):
# /home/users/u7300623/teraheap/jdk17u067/src/hotspot/share/memory/sharedDefines.h

source ../config.sh

echo "All enabled options:"
cat $TERAHEAP_REPO/jdk17u067/src/hotspot/share/memory/sharedDefines.h | grep "#define" | grep -E -v "\/\/(\s)*#define" | tee /tmp/enabled

echo
echo "Summary:"

if [[ ! -z $(grep TERA_STATS /tmp/enabled) ]]; then echo "Stats ENABLED"
else echo "Stats DISABLED"; fi

if [[ ! -z $(grep TERA_TIMERS /tmp/enabled) ]]; then echo "Timers ENABLED"
else echo "Timers DISABLED"; fi

if [[ ! -z $(grep -w SYNC /tmp/enabled) ]]; then
    echo "Using SYNC option"
else
    echo "Using ASYNC option"
fi
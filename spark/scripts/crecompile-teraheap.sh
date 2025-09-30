#!/bin/bash
# path to sharedDefines.h for updating (on raven3):
# /home/users/u7300623/teraheap/jdk17u067/src/hotspot/share/memory/sharedDefines.h

source ../config.sh

# Recompile teraheap
echo "Recompiling allocator:"
cd $TERAHEAP_REPO/allocator
./build.sh 
echo

echo "Recompiling tera malloc:"
cd $TERAHEAP_REPO/tera_malloc
./build.sh
echo

echo "Recompiling teraheap:"
cd $TERAHEAP_REPO/jdk17u067
./compile.sh -t x86_64 -b /usr/lib/jvm/java-17-openjdk-amd64 -g 9 -i "release"

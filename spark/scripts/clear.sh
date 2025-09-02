#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: ./clear.sh [conf]"
    exit
fi

CONF=$1
. ./$CONF

# Clear H2 and Shuffle
find "$MNT_H2" -mindepth 1 ! -name 'SparkBench' ! -name 'lost+found' -exec rm -rf {} +
find "$MNT_SHFL" -mindepth 1 ! -name 'SparkBench' ! -name 'lost+found' -exec rm -rf {} +

./clear-proc.sh
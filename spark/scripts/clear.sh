#!/bin/bash

usage() {
    echo
    echo "Usage:"
    echo "      $0 [options ...] [-c conf.sh]"
    echo "Options:"
    echo "      -c  Path to conf.sh file"
    echo "      -h  Show usage"
    echo
    exit 1
}

while getopts ":c:h" opt
do
    case "${opt}" in
        c)
            CONF_FILE=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z $CONF_FILE ]; then
    usage
    exit 1
fi

. "${CONF_FILE}"

# Clear H2 and Shuffle
find "$MNT_H2" -mindepth 1 -maxdepth 1 \
    \( -name 'SparkBench' -o -name 'lost+found' \) -prune \
    -o -exec rm -r {} +
find "$MNT_SHFL" -mindepth 1 -maxdepth 1 \
    \( -name 'SparkBench' -o -name 'lost+found' \) -prune \
    -o -exec rm -r {} +

./clear-proc.sh

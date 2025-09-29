#!/bin/bash
# Wrapper for the result parsing section of the run script

# Usage message
usage() {
    echo "Usage: $0 -c path/to/conf.sh -r resultdir"
    exit 1
}

# Parse arguments
while getopts ":c:r:h" opt; do
    case "${opt}" in
        c)
            CONF_SH="${OPTARG}"
            ;;
        r)
            RUN_DIR="${OPTARG}"
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z $CONF_SH || -z $RUN_DIR ]]; then
    usage
    exit 1
fi

# Source the specified conf.sh
. "$CONF_SH"

TH=true
SERDES=false
CUSTOM_BENCHMARK=false

if [ "$SERDES" == "true" ]
    then
    # Parse cpu and disk statistics results
    ./system_util/extract-data.sh -r "${RUN_DIR}" -d "${DEV_SHFL}" -d "${DEV_H2}" >> "${BENCH_LOG}" 2>&1
    elif [ "$TH" == "true" ]
    then
    # Parse cpu and disk statistics results
    ./system_util/extract-data.sh -r "${RUN_DIR}" -d "${DEV_H2}" -d "${DEV_SHFL}" >> "${BENCH_LOG}" 2>&1
    fi

    if [ "$CUSTOM_BENCHMARK" == "false" ]
    then
    # Save the total duration of the benchmark execution
    tail -n 1 "${SPARK_BENCH_DIR}"/num/bench-report.dat >> "${RUN_DIR}"/total_time.txt
    fi

    if [ "$PERF_TOOL" == "false" ]
    then
    # Stop perf monitor
    stop_perf
    fi

    # Parse results
    if [ "$TH" == "true" ]
    then
    TH_METRICS=$(ls -td "${SPARK_DIR}"/work/* | head -n 1)
    cp "${TH_METRICS}"/0/teraHeap.txt "${RUN_DIR}"/
    ./parse_results.sh -d "${RUN_DIR}" -n "${NUM_EXECUTORS}" -t
    else
    ./parse_results.sh -d "${RUN_DIR}" -n "${NUM_EXECUTORS}" -s
    fi

    # Parse compression results
    ./parse_zram_results.sh ${RUN_DIR} ${DEV_H2} >> "${RUN_DIR}/zram.csv"
done
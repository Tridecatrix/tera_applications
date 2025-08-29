#!/usr/bin/env bash

###################################################
#
# file: run_gen_dataset_tpcds.sh
#
# @Author:   Iacovos G. Kolokasis
# @Version:  05-05-2024 
# @email:    kolokasis@ics.forth.gr
#
# Scrpt to generate datase for TPC-DS
#
###################################################

CONF_FILE="./conf.sh"

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

. "${CONF_FILE}"

"${SPARK_DIR}"/bin/spark-submit \
  --class org.apache.spark.sql.GenTPCDSData \
  --conf spark.executor.instances="${NUM_EXECUTORS[0]}" \
  --conf spark.executor.cores="${EXEC_CORES[0]}" \
  --conf spark.executor.memory="${H1_SIZE[0]}"g \
  "${SPARK_DIR}"/sql/core/target/spark-sql_2.12-3.3.0-tests.jar \
  --master spark://sith4-fast:7077 \
  --dsdgenDir "${BENCH_DIR}"/spark/spark-tpcds/build/resources/main/binaries/Linux/x86_64/ \
  --location "${DATA_HDFS}"/tpcds \
  --scaleFactor 200 \
  --numPartitions 256

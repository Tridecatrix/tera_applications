#!/usr/bin/env bash

###################################################
#
# file: run.sh
#
# @Author:   Iacovos G. Kolokasis
# @Version:  20-01-2021 
# @email:    kolokasis@ics.forth.gr
#
# Scrpt to run the experiments
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

##
# Description:
#   Create a cgroup
setup_cgroup() {
	# Change user/group IDs to your own
	sudo cgcreate -a u7300623:sudo -t u7300623:sudo -g memory:memlim
	# cgset -r memory.limit_in_bytes="$MEM_BUDGET" memlim
	cgset -r memory.max="$MEM_BUDGET" memlim
	sudo chmod o+w /sys/fs/cgroup/cgroup.procs
	#sudo cgset -r memory.numa_stat=0 memlim
}

##
# Description:
#   Delete a cgroup
delete_cgroup() {
	sudo cgdelete memory:memlim
}

run_cgexec() {
  cgexec -g memory:memlim --sticky ./run_cgexec.sh "$@"
}

##
# Description: 
#   Start Spark
##
start_spark() {
  run_cgexec "${SPARK_DIR}"/sbin/start-all.sh >> "${BENCH_LOG}" 2>&1
}

##
# Description: 
#   Stop Spark
##
stop_spark() {
  run_cgexec "${SPARK_DIR}"/sbin/stop-all.sh >> "${BENCH_LOG}" 2>&1
}


CUSTOM_BENCHMARK=false

setup_cgroup

cp ./configs/native/spark-defaults.conf "${SPARK_DIR}"/conf

./update_conf.sh -b ${CUSTOM_BENCHMARK}

start_spark

# Run benchmark and save output to tmp_out.txt
for BENCHMARK in ${BENCHMARKS[@]}; do
	run_cgexec "${SPARK_BENCH_DIR}"/"${BENCHMARK}"/bin/gen_data.sh >> "${BENCH_LOG}" 2>&1
done

stop_spark

delete_cgroup

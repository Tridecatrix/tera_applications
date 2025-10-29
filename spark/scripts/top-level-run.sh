# to run while sending output to ctoo:
# stdbuf -oL nohup ./top-level-run.sh | tee ../results/log.txt | ssh ctoo 'cat /dev/stdin > teraLogRaven3.txt' & disown

# ./run.sh -t -n 1 -c confs/conf-ssd.sh -o ../results/debug-sync/ssd-200g -T 1800

# ./run.sh -t -n 3 -c confs/conf-ssd.sh -o ../results/second-run-smaller-heap-4-8/ssd-200g -T 1800
# ./run.sh -t -n 3 -c confs/conf-zram-zstd.sh -o ../results/second-run-smaller-heap-4-8/zstd-200g -T 1800
# ./run.sh -t -n 3 -c confs/conf-zram-lzo.sh -o ../results/second-run-smaller-heap-4-8/lzo-200g -T 1800
# ./run.sh -t -n 3 -c confs/conf-zram-lz4.sh -o ../results/second-run-smaller-heap-4-8/lz4-200g -T 1800

PC=16
for H1 in 4 8 16 24 32 48 64 72; do
     python3 confs/modify_config.py confs/conf-ssd-smaller-pg-cache.sh confs/conf-ssd-$H1-$PC.sh -p H1_SIZE=$H1 -p MEM_BUDGET=$(echo "$H1+$PC" | bc -l)G --force

    ./run.sh -t -n 1 -c confs/conf-ssd-$H1-$PC.sh -o ../results/finding-H1-sizes-all-bcs/ssd-$H1-$PC -T 1000
done
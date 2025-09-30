# to run while sending output to ctoo:
# stdbuf -oL nohup ./top-level-run.sh | tee ../results/log.txt | ssh ctoo 'cat /dev/stdin > teraLogRaven3.txt' & disown

./run.sh -t -n 3 -c confs/conf-ssd.sh -o ../results/first-run-smaller-heap-16-10/ssd-200g -T 1000
./run.sh -t -n 3 -c confs/conf-zram-zstd.sh -o ../results/first-run-smaller-heap-16-10/zstd-200g -T 1000
./run.sh -t -n 3 -c confs/conf-zram-lzo.sh -o ../results/first-run-smaller-heap-16-10/lzo-200g -T 1000
./run.sh -t -n 3 -c confs/conf-zram-lz4.sh -o ../results/first-run-smaller-heap-16-10/lz4-200g -T 1000
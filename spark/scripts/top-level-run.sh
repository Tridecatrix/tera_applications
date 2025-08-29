./run.sh -t -n 4 -c conf-ssd.sh -o ../results/ssd-pr-small-200g
./run.sh -t -n 4 -c conf-zram-zstd.sh -o ../results/zstd-pr-small-200g
./run.sh -t -n 4 -c conf-zram-lzo.sh -o ../results/lzo-pr-small-200g
./run.sh -t -n 4 -c conf-zram-lz4.sh -o ../results/lz4-pr-small-200g

./run.sh -t -n 6 -o ../results/debug-ssd
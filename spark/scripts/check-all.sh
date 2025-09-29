#!/bin/bash

./check-conf.sh -c confs/conf-ssd.sh
./check-conf.sh -c confs/conf-zram-lz4.sh
./check-conf.sh -c confs/conf-zram-lzo.sh
./check-conf.sh -c confs/conf-zram-zstd.sh

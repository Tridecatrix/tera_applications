#!/usr/bin/env bash

DOWNLOAD_PATH=$1
CONF_SH=$2

if [ -f "${DOWNLOAD_PATH}/kdd12" ]
then
  exit
fi

if [ ! -f "${CONF_SH}" ] || [ ! -x "${CONF_SH}" ]; then
  echo "Error: ${CONF_SH} does not exist or is not executable."
  exit 1
fi

. ./${CONF_SH}

# KDD2012
wget -P "${DOWNLOAD_PATH}" https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/kdd12.bz2

# Extract the dataset
if ! [ -x "$(command -v unxz)" ]
then
  sudo yum install xz
fi

cd "${DOWNLOAD_PATH}" || exit

unxz kdd12.xz

cd - > /dev/null || exit

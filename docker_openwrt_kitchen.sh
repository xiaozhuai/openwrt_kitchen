#!/usr/bin/env bash
set -e

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

tty_op=""
[[ -t 1 ]] && tty_op="-it"

docker build -t openwrt_kitchen:latest .

docker run --rm ${tty_op} \
  --privileged \
  --name openwrt_kitchen \
  --hostname openwrt_kitchen \
  -v /dev:/dev \
  -v "${base_dir}":/openwrt_kitchen \
  openwrt_kitchen:latest \
  "$@"

#!/usr/bin/env bash
set -e

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

docker build -t openwrt_kitchen:latest .
docker run --rm -it \
  --privileged \
  --name openwrt_kitchen \
  --hostname openwrt_kitchen \
  --entrypoint /bin/bash \
  -v /dev:/dev \
  -v "${base_dir}":/openwrt_kitchen \
  openwrt_kitchen:latest \
  "$@"

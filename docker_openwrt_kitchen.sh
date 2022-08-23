#!/usr/bin/env bash
set -e

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

old_id="$(docker images openwrt_kitchen:latest --format "{{.ID}}")"
docker build --rm -t openwrt_kitchen:latest .
new_id="$(docker images openwrt_kitchen:latest --format "{{.ID}}")"

if [[ -n "${old_id}" && "${old_id}" != "${new_id}" ]]; then
  docker image rm "${old_id}"
fi

docker run --rm -it \
  --privileged \
  --name openwrt_kitchen \
  --hostname openwrt_kitchen \
  -v /dev:/dev \
  -v "${base_dir}":/openwrt_kitchen \
  openwrt_kitchen:latest \
  "$@"

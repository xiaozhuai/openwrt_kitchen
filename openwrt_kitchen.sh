#!/usr/bin/env bash
set -e

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
input_img="$1"
output_img="$2"
img_size="1024" # MB
input_img_gzipped=false
output_img_device=""
output_img_mount_point=""
cleaned=false

if [[ -z "${input_img}" ]]; then
  echo "Usage: customize-openwrt.sh input_img [output_img]"
  exit 1
fi

if [[ ! -f "${input_img}" ]]; then
  echo "File not found, ${input_img}"
  exit 1
fi

if [[ "${input_img}" == *.gz ]]; then
  input_img_gzipped=true
fi

[[ "$(whoami)" != "root" ]] && echo "Please run as root" && exit 1

if [[ -z "${output_img}" ]]; then
  if [[ "${input_img_gzipped}" == "true" ]]; then
    img_file_name="$(basename "${input_img}" .img.gz)"
  else
    img_file_name="$(basename "${input_img}" .img)"
  fi
  output_img="$(dirname "${input_img}")/${img_file_name}-cooked.img"
fi

cleanup() {
  if [[ "${cleaned}" == "false" ]]; then
    cleaned=true
    echo "- Cleanup"
    if [[ -n "${output_img_mount_point}" ]]; then
      rm -rf "${output_img_mount_point}/var/lock"
      rm -rf "${output_img_mount_point}/kitchen"
      rm -f "${output_img_mount_point}/config.default.sh"
      if [[ -f "${output_img_mount_point}/config.user.sh" ]]; then
        rm -f "${output_img_mount_point}/config.user.sh"
      fi
      rm -f "${output_img_mount_point}/tmp/resolv.conf"
      rm -f "${output_img_mount_point}/tmp/resolv.conf.bak"
      rm -rf "${output_img_mount_point}/tmp/resolv.conf.d"
      rm -rf "${output_img_mount_point}"/tmp/*
      echo "- Unmount ${output_img_device}p2 --> ${output_img_mount_point}"
      umount "${output_img_mount_point}"
      rm -rf "${output_img_mount_point}"
    fi
    if [[ -n "${output_img_device}" ]]; then
      echo "- Detach ${output_img_device} --> ${output_img}"
      losetup -d "${output_img_device}"
      output_img_device=""
    fi
  fi
}
trap cleanup EXIT

if [[ -f "${output_img}" ]]; then
  rm "${output_img}"
fi

echo "- Create ${output_img}, size: ${img_size}M"
dd if=/dev/zero of="${output_img}" bs=1M count=${img_size} status=none
sync

echo "- Attach ${output_img}"
output_img_device=$(losetup -Pf --show "${output_img}")
echo "- Attached ${output_img_device} --> ${output_img}"

echo "- Flash ${input_img} --> ${output_img_device}"
if [[ "${input_img_gzipped}" == "true" ]]; then
  gzip -qdc "${input_img}" | dd of="${output_img_device}" bs=16M status=none
else
  dd if="${input_img}" of="${output_img_device}" bs=16M status=none
fi
sync

echo "- Detach ${output_img_device} --> ${output_img}"
losetup -d "${output_img_device}"
output_img_device=""

echo "- Attach ${output_img}"
output_img_device=$(losetup -Pf --show "${output_img}")
echo "- Attached ${output_img_device} --> ${output_img}"

echo "- Resize ${output_img_device}p2"
parted "${output_img_device}" resizepart 2 100%
resize2fs "${output_img_device}p2"
parted "${output_img_device}" print

echo "- Mount ${output_img_device}p2"
tmp_mount_point=$(mktemp -d)
mount "${output_img_device}p2" "${tmp_mount_point}"
output_img_mount_point="${tmp_mount_point}"
echo "- Mounted ${output_img_device}p2 --> ${output_img_mount_point}"

echo "- Prepare chroot"
mkdir -p "${output_img_mount_point}/var/lock"
cp -rf "${base_dir}/kitchen" "${output_img_mount_point}/"
cp -f "${base_dir}/config.default.sh" "${output_img_mount_point}/"
if [[ -f "${base_dir}/config.user.sh" ]]; then
  cp -f "${base_dir}/config.user.sh" "${output_img_mount_point}/"
fi
echo "nameserver 8.8.8.8" >"${output_img_mount_point}/tmp/resolv.conf"
echo "nameserver 223.5.5.5" >>"${output_img_mount_point}/tmp/resolv.conf"
cp -f "${output_img_mount_point}/tmp/resolv.conf" "${output_img_mount_point}/tmp/resolv.conf.bak"
mkdir "${output_img_mount_point}/tmp/resolv.conf.d"

chroot "${output_img_mount_point}" /kitchen/entrypoint.sh

echo "- Copy rootfs_override/* to /"
cp -rf "${base_dir}/rootfs_override"/* "${output_img_mount_point}/"
rm -f "${output_img_mount_point}/.gitkeep"

cleanup

echo "- Done!"

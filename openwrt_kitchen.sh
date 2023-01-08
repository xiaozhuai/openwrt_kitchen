#!/usr/bin/env bash
set -e

print_usage() {
  echo "Usage: $(basename "$0") [OPTION]..."
  echo "Options:"
  echo "  -i      input image file"
  echo "  -o      output image file"
  echo "  -c      user config"
  echo "  -s      image size in MB (default: ${img_size})"
  echo "  -f      force overwrite exists output image file"
}

input_img=""
output_img=""
user_config_name=""
img_size=512 #MB
force_overwrite_output=false

while getopts ':i:o:c:f' OPTION; do
  case "${OPTION}" in
  i)
    input_img="${OPTARG}"
    ;;
  o)
    output_img="${OPTARG}"
    ;;
  c)
    user_config_name="${OPTARG}"
    ;;
  f)
    force_overwrite_output=true
    ;;
  ?)
    print_usage
    exit 1
    ;;
  esac
done

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
user_config_file=""
input_img_gzipped=false
output_img_device=""
output_img_mount_point=""
cleaned=false

if [[ -z "${input_img}" ]]; then
  echo "Missing -i option"
  print_usage
  exit 1
fi

if [[ ! -f "${input_img}" ]]; then
  echo "File not found, ${input_img}"
  exit 1
fi

if [[ -z "${output_img}" ]]; then
  echo "Missing -o option"
  print_usage
  exit 1
fi

if [[ -f "${output_img}" ]]; then
  if [[ "${force_overwrite_output}" == "true" ]]; then
    rm "${output_img}"
  else
    echo "Output image file already exists, specify -f option to force overwrite it"
    print_usage
    exit 1
  fi
fi

if [[ -n "${user_config_name}" ]]; then
  if [[ ! -f "${base_dir}/configs/config.${user_config_name}.sh" ]]; then
    echo "File not found, configs/config.${user_config_name}.sh"
    print_usage
    exit 1
  else
    user_config_file="${base_dir}/configs/config.${user_config_name}.sh"
  fi
fi

if [[ "${input_img}" == *.gz ]]; then
  input_img_gzipped=true
fi

[[ "$(id -u)" != "0" ]] && echo "Please run as root" && exit 1

[[ -z "$(which -a parted)" ]] && echo "Please install parted" && exit 1

[[ -z "$(which -a resize2fs)" ]] && echo "Please install resize2fs" && exit 1

cleanup() {
  local suc="$1"
  if [[ "${cleaned}" == "false" ]]; then
    cleaned=true
    sync
    echo "- Cleanup"
    if [[ -n "${output_img_mount_point}" ]]; then
      rm -rf "${output_img_mount_point}/var/lock"
      rm -rf "${output_img_mount_point}/tmp/.uci"
      rm -rf "${output_img_mount_point}/tmp/kitchen"
      rm -f "${output_img_mount_point}/tmp/resolv.conf"
      rm -f "${output_img_mount_point}/tmp/resolv.conf.bak"
      rm -rf "${output_img_mount_point}/tmp/resolv.conf.d"
      rm -rf "${output_img_mount_point}"/tmp/*
      echo "- Unmount ${output_img_device}p2 --> ${output_img_mount_point}"
      umount -R "${output_img_mount_point}"
      rm -rf "${output_img_mount_point}"
    fi
    if [[ -n "${output_img_device}" ]]; then
      echo "- Detach ${output_img_device} --> ${output_img}"
      losetup -d "${output_img_device}"
      output_img_device=""
    fi
    if [[ -z "${suc}" ]]; then
      echo "- Remove ${output_img}"
      rm -f "${output_img}"
      echo "- Error occurred!"
      exit 1
    fi
  fi
}
trap cleanup EXIT

echo "- Create ${output_img}, size: ${img_size}M"
dd if=/dev/zero of="${output_img}" bs=1M count=${img_size} status=none
sync

echo "- Attach ${output_img}"
output_img_device=$(losetup -Pf --show "${output_img}")
echo "- Attached ${output_img_device} --> ${output_img}"

echo "- Flash ${input_img} --> ${output_img_device}"
if [[ "${input_img_gzipped}" == "true" ]]; then
  gzip -qdc "${input_img}" | dd of="${output_img_device}" bs=4M status=none
else
  dd if="${input_img}" of="${output_img_device}" bs=4M status=none
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
mount -t proc /proc "${output_img_mount_point}/proc"
mount --rbind /sys "${output_img_mount_point}/sys"
mount --rbind /dev "${output_img_mount_point}/dev"
mkdir -p "${output_img_mount_point}/var/lock"
mkdir -p "${output_img_mount_point}/tmp/.uci"
cp -rf "${base_dir}/kitchen" "${output_img_mount_point}/tmp/"
cp -f "${base_dir}/configs/config.default.sh" "${output_img_mount_point}/tmp/kitchen/"
if [[ -n "${user_config_file}" ]]; then
  cp -f "${user_config_file}" "${output_img_mount_point}/tmp/kitchen/config.user.sh"
fi
echo "nameserver 8.8.8.8" >"${output_img_mount_point}/tmp/resolv.conf"
echo "nameserver 223.5.5.5" >>"${output_img_mount_point}/tmp/resolv.conf"
cp -f "${output_img_mount_point}/tmp/resolv.conf" "${output_img_mount_point}/tmp/resolv.conf.bak"
mkdir "${output_img_mount_point}/tmp/resolv.conf.d"

chroot "${output_img_mount_point}" /tmp/kitchen/entrypoint.sh

if [[ -z "$(ls "${base_dir}/rootfs_override")" ]]; then
  echo "- Skip copy rootfs_override/* to /"
else
  echo "- Copy rootfs_override/* to /"
  cp -rf "${base_dir}/rootfs_override"/* "${output_img_mount_point}/"
fi
rm -f "${output_img_mount_point}/.gitkeep"

#chroot "${output_img_mount_point}" /bin/sh

cleanup true

echo "- Done!"

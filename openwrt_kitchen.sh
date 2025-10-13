#!/usr/bin/env bash
set -e

print_usage() {
  echo "Usage: $(basename "$0") [OPTION]..."
  echo "Options:"
  echo "  -i      input image file"
  echo "  -o      output image file"
  echo "  -u      user custom dir"
  echo "  -c      user config"
  echo "  -s      image size in MB (default: ${img_size})"
  echo "  -f      force overwrite exists output image file"
  echo ""
}

input_img=""
output_img=""
user_config_name=""
img_size=512 #MB
force_overwrite_output=false
user_custom_dir=""

while getopts ':i:o:c:d:f' OPTION; do
  case "${OPTION}" in
  i)
    input_img="${OPTARG}"
    ;;
  o)
    output_img="${OPTARG}"
    ;;
  d)
    user_custom_dir="${OPTARG}"
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
  print_usage
  echo "Missing -i option"
  exit 1
fi

if [[ ! -f "${input_img}" ]]; then
  echo "File not found, ${input_img}"
  exit 1
fi

if [[ -z "${output_img}" ]]; then
  print_usage
  echo "Missing -o option"
  exit 1
fi

if [[ -f "${output_img}" ]]; then
  if [[ "${force_overwrite_output}" == "true" ]]; then
    rm "${output_img}"
  else
    print_usage
    echo "Output image file already exists, specify -f option to force overwrite it"
    exit 1
  fi
fi

if [[ -n "${user_custom_dir}" ]]; then
  if [[ ! -d "${user_custom_dir}" ]]; then
    print_usage
    echo "User custom dir non-exists, ${user_custom_dir}"
    exit 1
  fi
fi

if [[ -n "${user_config_name}" ]]; then
  if [[ -f "${base_dir}/configs/config.${user_config_name}.sh" ]]; then
    user_config_file="${base_dir}/configs/config.${user_config_name}.sh"
  fi
  if [[ -n "${user_custom_dir}" ]]; then
    if [[ -f "${user_custom_dir}/configs/config.${user_config_name}.sh" ]]; then
      user_config_file="${user_custom_dir}/configs/config.${user_config_name}.sh"
    fi
  fi
  if [[ -z "${user_config_file}" ]]; then
    print_usage
    echo "Config not found: ${user_config_name}"
    exit 1
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
partprobe "${output_img_device}"

echo "- Resize ${output_img_device}p2"
parted -s -f "${output_img_device}" resizepart 2 100%
parted -s -f "${output_img_device}" print
sync
partprobe "${output_img_device}"

echo "- Check ${output_img_device}p2"
e2fsck -f -p /dev/loop0p2 || {
    rc=$?
    case $rc in
        0|1)
            ;;
        *)
            echo "e2fsck exited with $rc"
            exit $rc
            ;;
    esac
}
sync
partprobe "${output_img_device}"

echo "- Resize2fs ${output_img_device}p2"
resize2fs "${output_img_device}p2"
sync
partprobe "${output_img_device}"

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
if [[ -n "${user_custom_dir}" ]]; then
  if [ -d "${user_custom_dir}/scripts.d" ]; then
    cp -rf "${user_custom_dir}/scripts.d" "${output_img_mount_point}/tmp/kitchen/user_scripts.d"
  fi
fi
cp -f "${base_dir}/configs/config.default.sh" "${output_img_mount_point}/tmp/kitchen/"
if [[ -n "${user_config_file}" ]]; then
  cp -f "${user_config_file}" "${output_img_mount_point}/tmp/kitchen/config.user.sh"
fi
echo "nameserver 8.8.8.8" >"${output_img_mount_point}/tmp/resolv.conf"
echo "nameserver 223.5.5.5" >>"${output_img_mount_point}/tmp/resolv.conf"
cp -f "${output_img_mount_point}/tmp/resolv.conf" "${output_img_mount_point}/tmp/resolv.conf.bak"
mkdir "${output_img_mount_point}/tmp/resolv.conf.d"

chroot "${output_img_mount_point}" /tmp/kitchen/entrypoint.sh

if [[ -n "${user_custom_dir}" ]]; then
  if [ -d "${user_custom_dir}/rootfs" ]; then
    if [[ -z "$(ls "${user_custom_dir}/rootfs")" ]]; then
      echo "- Skip copy ${user_custom_dir}/rootfs/* to /, dir is empty"
    else
      echo "- Copy ${user_custom_dir}/rootfs/* to /"
      cp -rf "${user_custom_dir}/rootfs"/* "${output_img_mount_point}/"
    fi
  fi
fi

#chroot "${output_img_mount_point}" /bin/sh

cleanup true

echo "- Done!"

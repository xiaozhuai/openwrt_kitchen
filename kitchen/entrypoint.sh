#!/bin/sh
set -e

kitchen_dir="/tmp/kitchen"
cd ${kitchen_dir}

fix_resolv_conf() {
  cmp -s /tmp/resolv.conf /tmp/resolv.conf.bak || cp -f /tmp/resolv.conf.bak /tmp/resolv.conf
}

install_by_cond() {
  if [ "$1" = "true" ]; then
    echo "  - Install $2"
    opkg install "$2"
  fi
}

install_by_version() {
  if [ -n "$1" ]; then
    echo "  - Install $1"
    opkg install "$1"
  fi
}

install_app_by_cond() {
  if [ "$1" = "true" ]; then
    app_pkg="luci-app-$2"
    echo "  - Install ${app_pkg}"
    opkg install "${app_pkg}"
    if [ -n "${LUCI_LANGUAGE}" ]; then
      i18n_pkg="luci-i18n-$2-${LUCI_LANGUAGE}"
      i18n_pkg_exists="$(opkg list | grep "^${i18n_pkg}" || echo "")"
      if [ -n "${i18n_pkg_exists}" ]; then
        echo "  - Install ${i18n_pkg}"
        opkg install "${i18n_pkg}"
      fi
    fi
  fi
}

download_and_install_by_cond() {
  if [ "$1" = "true" ]; then
    file="$2"
    url="$3"
    mkdir -p "/tmp/ipk-cache"
    tmp_file="/tmp/ipk-cache/${file}"
    echo "  - Install ${file}"
    wget -q -t 30 -w 5 -O "${tmp_file}" "${url}"
    opkg install "${tmp_file}"
    rm -f "${tmp_file}"
    i18n_file="$4"
    i18n_url="$5"
    if [ -n "${i18n_file}" ] && [ -n "${i18n_url}" ]; then
      tmp_file="/tmp/ipk-cache/${i18n_file}"
      i18n_file_exists=$(wget -q -O /dev/null "${i18n_url}" && echo "true" || echo "false")
      if [ "${i18n_file_exists}" = "true" ]; then
        echo "  - Install ${i18n_file}"
        wget -q -t 30 -w 5 -O "${tmp_file}" "${i18n_url}"
        opkg install "${tmp_file}"
        rm -f "${tmp_file}"
      fi
    fi
  fi
}

echo "- Load configs"
. "${kitchen_dir}/config.default.sh"
if [ -f "${kitchen_dir}/config.user.sh" ]; then
  . "${kitchen_dir}/config.user.sh"
fi
. "${kitchen_dir}/ipk_urls.sh"
#. /etc/os-release

echo "- Exec scripts"
cd ${kitchen_dir}/scripts.d
for script in *.sh; do
  if [ -r "${script}" ]; then
    echo "- Exec ${script}"
    cd ${kitchen_dir}/scripts.d
    # shellcheck disable=SC1090
    . "${kitchen_dir}/scripts.d/${script}"
    fix_resolv_conf
  fi
done
unset script
cd ${kitchen_dir}

if [ -d "${kitchen_dir}/user_scripts.d" ]; then
  echo "- Exec user scripts"
  cd ${kitchen_dir}/user_scripts.d
  for script in *.sh; do
    if [ -r "${script}" ]; then
      echo "- Exec ${script}"
      cd ${kitchen_dir}/user_scripts.d
      # shellcheck disable=SC1090
      . "${kitchen_dir}/user_scripts.d/${script}"
      fix_resolv_conf
    fi
  done
  unset script
  cd ${kitchen_dir}
fi

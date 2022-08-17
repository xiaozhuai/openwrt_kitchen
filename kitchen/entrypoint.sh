#!/bin/sh
set -e

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
    echo "  - Install luci-app-$2"
    opkg install "luci-app-$2"
    if [ -n "${LUCI_LANGUAGE}" ]; then
      opkg install "luci-i18n-$2-${LUCI_LANGUAGE}"
    fi
  fi
}

download_and_install_by_cond() {
    if [ "$1" = "true" ]; then
      echo "  - Install $2"
      tmp_file="$(mktemp)"
      rm -f "${tmp_file}"
      tmp_file="${tmp_file}.ipk"
      wget -q -O "${tmp_file}" "$2"
      opkg install "${tmp_file}"
      rm -f "${tmp_file}"
    fi
}

echo "- Prepare ssl"
cp -f /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.bak
sed -i 's/https:/http:/' /etc/opkg/distfeeds.conf
# cat /etc/opkg/distfeeds.conf

opkg update
opkg install ca-bundle ca-certificates wget-ssl

mv -f /etc/opkg/distfeeds.conf.bak /etc/opkg/distfeeds.conf
cat /etc/opkg/distfeeds.conf

echo "- Load config"
. /config.default.sh
if [ -f "/config.user.sh" ]; then
  . /config.user.sh
fi

echo "- Exec scripts"
cd /kitchen/scripts.d
for script in *.sh; do
  if [ -r "${script}" ]; then
    echo "- Exec ${script}"
    cd /kitchen/scripts.d
    . "./$script"
    fix_resolv_conf
  fi
done
unset script
cd /

echo "- Exec user scripts"
cd /kitchen/user_scripts.d
for script in *.sh; do
  if [ -r "${script}" ]; then
    echo "- Exec ${script}"
    cd /kitchen/user_scripts.d
    . "./$script"
    fix_resolv_conf
  fi
done
unset script
cd /
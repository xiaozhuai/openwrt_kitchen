#TODO
#if [ -n "${SYSTEM_ZONENAME}" ]; then
#  echo "  - Set zonename ${SYSTEM_ZONENAME}"
#  uci set system.system.zonename="${SYSTEM_ZONENAME}"
#  uci commit system
#fi
#
#if [ -n "${SYSTEM_TIMEZONE}" ]; then
#  echo "  - Set timezone ${SYSTEM_TIMEZONE}"
#  uci set system.system.timezone="${SYSTEM_TIMEZONE}"
#  uci commit system
#fi

#TODO
#if [ -n "${LUCI_LANGUAGE}" ]; then
#  echo "  - Set language ${LUCI_LANGUAGE}"
#  uci set luci.main.lang="${LUCI_LANGUAGE}"
#  uci commit luci
#fi

if [ -n "${LUCI_THEME}" ]; then
  echo "  - Set theme ${LUCI_THEME}"
  mediaurlbase="$(uci -q get "luci.themes.${LUCI_THEME}" || true)"
  if [ -z "${mediaurlbase}" ]; then
    echo "Unknown theme ${LUCI_THEME}"
    exit 1
  fi
  uci set luci.main.mediaurlbase="${mediaurlbase}"
  uci commit luci
  unset mediaurlbase
fi

#TODO
#uci set luci.ccache.enable="${LUCI_CCACHE_ENABLE}"
#uci set luci.diag.ping="${LUCI_DIAG_URL}"
#uci set luci.diag.route="${LUCI_DIAG_URL}"
#uci set luci.diag.dns="${LUCI_DIAG_URL}"
#uci commit luci

#TODO
#uci del system.ntp.server
#for server in $NTP_SERVERS; do
#  uci add_list system.ntp.server="${server}"
#done
#uci commit system

UCI_DEFAULTS_CUSTOM="/etc/uci-defaults/90-kitchen-custom"

uci_defaults() {
  action="$1"
  key="$2"
  value="$3"
  if [ "${action}" = "set" ]; then
    echo "uci set ${key}='${value}'" >> "${UCI_DEFAULTS_CUSTOM}"
  elif [ "${action}" = "del" ]; then
    echo "uci del ${key}" >> "${UCI_DEFAULTS_CUSTOM}"
  elif [ "${action}" = "add_list" ]; then
    echo "uci add_list ${key}='${value}'" >> "${UCI_DEFAULTS_CUSTOM}"
  elif [ "${action}" = "commit" ]; then
    echo "uci commit" >> "${UCI_DEFAULTS_CUSTOM}"
  fi
}

touch "${UCI_DEFAULTS_CUSTOM}"
chmod 755 "${UCI_DEFAULTS_CUSTOM}"

if [ -n "${SYSTEM_ZONENAME}" ]; then
  echo "  - Set zonename ${SYSTEM_ZONENAME}"
  uci_defaults set "system.system.zonename" "${SYSTEM_ZONENAME}"
fi

if [ -n "${SYSTEM_TIMEZONE}" ]; then
  echo "  - Set timezone ${SYSTEM_TIMEZONE}"
  uci_defaults set "system.system.timezone" "${SYSTEM_TIMEZONE}"
fi

if [ -n "${LUCI_LANGUAGE}" ]; then
  echo "  - Set language ${LUCI_LANGUAGE}"
  uci_defaults set "luci.main.lang" "${LUCI_LANGUAGE}"
fi

if [ -n "${LUCI_THEME}" ]; then
  echo "  - Set theme ${LUCI_THEME}"
  mediaurlbase="$(uci -q get "luci.themes.${LUCI_THEME}" || true)"
  if [ -z "${mediaurlbase}" ]; then
    echo "Unknown theme ${LUCI_THEME}"
  else
    uci_defaults set "luci.main.mediaurlbase" "${mediaurlbase}"
  fi
  unset mediaurlbase
fi

echo "  - Set ccache enable ${LUCI_CCACHE_ENABLE}"
uci_defaults set "luci.ccache.enable" "${LUCI_CCACHE_ENABLE}"

echo "  - Set luci diag host ${LUCI_DIAG_HOST}"
uci_defaults set "luci.diag.ping" "${LUCI_DIAG_HOST}"
uci_defaults set "luci.diag.route" "${LUCI_DIAG_HOST}"
uci_defaults set "luci.diag.dns" "${LUCI_DIAG_HOST}"

echo "  - Set system ntp server"
uci_defaults del "system.ntp.server"
for ntp_server in $SYSTEM_NTP_SERVERS; do
  echo "    - Add ntp server ${ntp_server}"
  uci_defaults add_list "system.ntp.server" "${ntp_server}"
done

uci_defaults commit

#cat "${UCI_DEFAULTS_CUSTOM}"

uci set luci.ccache.enable="${LUCI_CCACHE_ENABLE}"
uci set luci.diag.ping="${LUCI_DIAG_URL}"
uci set luci.diag.route="${LUCI_DIAG_URL}"
uci set luci.diag.dns="${LUCI_DIAG_URL}"
uci commit luci

uci del system.ntp.server
for server in $NTP_SERVERS; do
  uci add_list system.ntp.server="${server}"
done
uci commit system
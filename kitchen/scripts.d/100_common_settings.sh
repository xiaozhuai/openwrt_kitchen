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

#TODO
#if [ -z "${ROOT_PASSWORD}" ]; then
#  passwd root -d
#else
#  echo "TODO"
#fi

echo " Cooked by openwrt_kitchen" >> /etc/banner
echo " Repo   : https://github.com/xiaozhuai/openwrt_kitchen" >> /etc/banner
echo " Author : xiaozhuai" >> /etc/banner
echo " -----------------------------------------------------" >> /etc/banner

cat /etc/banner

echo "  - Install luci-compat"
opkg install luci-compat

install_app_by_cond "${INSTALL_LUCI_WOL}" wol
install_app_by_cond "${INSTALL_LUCI_UHTTPD}" uhttpd
install_app_by_cond "${INSTALL_LUCI_WIREGUARD}" wireguard
install_app_by_cond "${INSTALL_LUCI_SAMBA4}" samba4
install_app_by_cond "${INSTALL_LUCI_MINIDLNA}" minidlna
install_app_by_cond "${INSTALL_LUCI_UPNP}" upnp
install_app_by_cond "${INSTALL_LUCI_WATCHCAT}" watchcat
install_app_by_cond "${INSTALL_LUCI_TTYD}" ttyd
install_app_by_cond "${INSTALL_LUCI_FRPC}" frpc
install_app_by_cond "${INSTALL_LUCI_FRPS}" frps
install_app_by_cond "${INSTALL_LUCI_QOS}" qos
install_app_by_cond "${INSTALL_LUCI_NFT_QOS}" nft-qos
install_app_by_cond "${INSTALL_LUCI_NLBWMON}" nlbwmon
install_app_by_cond "${INSTALL_LUCI_COMMANDS}" commands
install_app_by_cond "${INSTALL_LUCI_MWAN3}" mwan3
install_app_by_cond "${INSTALL_LUCI_PRIVOXY}" privoxy
install_app_by_cond "${INSTALL_LUCI_BANIP}" banip
install_app_by_cond "${INSTALL_LUCI_ACL}" acl
install_app_by_cond "${INSTALL_LUCI_ACME}" acme
install_app_by_cond "${INSTALL_LUCI_ARIA2}" aria2
install_app_by_cond "${INSTALL_LUCI_ADBLOCK}" adblock
install_app_by_cond "${INSTALL_LUCI_DOCKERMAN}" dockerman
install_app_by_cond "${INSTALL_LUCI_HD_IDLE}" hd-idle
install_app_by_cond "${INSTALL_LUCI_OPENVPN}" openvpn
install_app_by_cond "${INSTALL_LUCI_SHADOWSOCKS_LIBEV}" shadowsocks-libev
install_app_by_cond "${INSTALL_LUCI_SHAIRPLAY}" shairplay
install_app_by_cond "${INSTALL_LUCI_SIMPLE_ADBLOCK}" simple-adblock
install_app_by_cond "${INSTALL_LUCI_SMART_DNS}" smartdns
install_app_by_cond "${INSTALL_LUCI_SNMPD}" snmpd
install_app_by_cond "${INSTALL_LUCI_TRANSMISSION}" transmission
download_and_install_by_cond "${INSTALL_LUCI_OPENCLASH}" "https://github.com/vernesong/OpenClash/releases/download/v0.45.47-beta/luci-app-openclash_0.45.47-beta_all.ipk"
download_and_install_by_cond "${INSTALL_LUCI_ALIDDNS}" "https://github.com/honwen/luci-app-aliddns/releases/download/v20210117/luci-app-aliddns_0.4.0-1_all.ipk"
install_app_by_cond "${INSTALL_LUCI_DDNS}" ddns
if [ "${INSTALL_LUCI_DDNS}" = "true" ]; then
  install_by_cond "${INSTALL_DDNS_SCRIPTS}" ddns-scripts
  install_by_cond "${INSTALL_DDNS_SCRIPTS_CLOUDFLARE}" ddns-scripts-cloudflare
  install_by_cond "${INSTALL_DDNS_SCRIPTS_CNKUAI}" ddns-scripts-cnkuai
  install_by_cond "${INSTALL_DDNS_SCRIPTS_DIGITALOCEAN}" ddns-scripts-digitalocean
  install_by_cond "${INSTALL_DDNS_SCRIPTS_FREEDNS}" ddns-scripts-freedns
  install_by_cond "${INSTALL_DDNS_SCRIPTS_GANDI}" ddns-scripts-gandi
  install_by_cond "${INSTALL_DDNS_SCRIPTS_GODADDY}" ddns-scripts-godaddy
  install_by_cond "${INSTALL_DDNS_SCRIPTS_NOIP}" ddns-scripts-noip
  install_by_cond "${INSTALL_DDNS_SCRIPTS_NSUPDATE}" ddns-scripts-nsupdate
  install_by_cond "${INSTALL_DDNS_SCRIPTS_ROUTE53}" ddns-scripts-route53
fi

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
download_and_install_by_cond "${INSTALL_LUCI_ALIDDNS}" "https://github.com/honwen/luci-app-aliddns/releases/download/v20210117/luci-app-aliddns_0.4.0-1_all.ipk"


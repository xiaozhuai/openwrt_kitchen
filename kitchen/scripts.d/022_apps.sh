echo "  - Install luci-compat"
opkg install luci-compat

install_app_by_cond "${INSTALL_LUCI_WOL}" wol

install_by_cond "${INSTALL_LUCI_THEME_BOOTSTRAP}" luci-theme-bootstrap
install_by_cond "${INSTALL_LUCI_THEME_MATERIAL}" luci-theme-material
download_and_install_by_cond "${INSTALL_LUCI_THEME_ARGON}" "https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.2.9.4/luci-theme-argon-master_2.2.9.4_all.ipk"

mediaurlbase="$(uci -q get "luci.themes.${LUCI_THEME}" || true)"
if [ -n "${mediaurlbase}" ]; then
  echo "Active theme ${LUCI_THEME}"
  uci set luci.main.mediaurlbase="${mediaurlbase}"
  uci commit
else
  echo "Skip active theme ${LUCI_THEME}, unknown mediaurlbase"
fi

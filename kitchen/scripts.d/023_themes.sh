install_by_cond "${INSTALL_LUCI_THEME_BOOTSTRAP}" luci-theme-bootstrap
install_by_cond "${INSTALL_LUCI_THEME_MATERIAL}" luci-theme-material
download_and_install_by_cond "${INSTALL_LUCI_THEME_ARGON}" "${LUCI_THEME_ARGON_IPX_FILE}" "${LUCI_THEME_ARGON_IPX_URL}"

mediaurlbase="$(uci -q get "luci.themes.${LUCI_THEME}" || true)"
if [ -n "${mediaurlbase}" ]; then
  echo "Active theme ${LUCI_THEME}"
  uci set luci.main.mediaurlbase="${mediaurlbase}"
  uci commit
else
  echo "Skip active theme ${LUCI_THEME}, unknown mediaurlbase"
fi

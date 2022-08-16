if [ -n "${LUCI_LANGUAGE}" ]; then
  echo "  - Install luci-i18n-base-${LUCI_LANGUAGE} luci-i18n-opkg-${LUCI_LANGUAGE} luci-i18n-firewall-${LUCI_LANGUAGE}"
  opkg install "luci-i18n-base-${LUCI_LANGUAGE}" "luci-i18n-opkg-${LUCI_LANGUAGE}" "luci-i18n-firewall-${LUCI_LANGUAGE}"
fi

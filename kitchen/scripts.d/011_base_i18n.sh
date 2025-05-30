if [ -n "${LUCI_LANGUAGE}" ]; then
  version_id=$(. /etc/os-release && echo "$VERSION_ID")
  major_version=$(echo "$version_id" | cut -d '.' -f1)
  if [ "$major_version" -ge 24 ]; then
    echo "  - Install luci-i18n-base-${LUCI_LANGUAGE} luci-i18n-package-manager-${LUCI_LANGUAGE} luci-i18n-firewall-${LUCI_LANGUAGE}"
    opkg install "luci-i18n-base-${LUCI_LANGUAGE}" "luci-i18n-package-manager-${LUCI_LANGUAGE}" "luci-i18n-firewall-${LUCI_LANGUAGE}"
  else
    echo "  - Install luci-i18n-base-${LUCI_LANGUAGE} luci-i18n-opkg-${LUCI_LANGUAGE} luci-i18n-firewall-${LUCI_LANGUAGE}"
    opkg install "luci-i18n-base-${LUCI_LANGUAGE}" "luci-i18n-opkg-${LUCI_LANGUAGE}" "luci-i18n-firewall-${LUCI_LANGUAGE}"
  fi
fi

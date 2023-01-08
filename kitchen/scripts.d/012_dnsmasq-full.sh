if [ "${USE_DNSMASQ_FULL}" = "true" ]; then
  cp -f /etc/hosts /etc/hosts.bak
  feeds_ip="$(nslookup downloads.openwrt.org | tail -n +3 | sed -n 's/Address:\s*//p' | grep -v -e : | head -n 1)"
  echo "${feeds_ip} downloads.openwrt.org" >>/etc/hosts
  echo "  - Resolve downloads.openwrt.org ${feeds_ip}"

  echo "  - Remove dnsmasq"
  opkg remove dnsmasq

  echo "  - Install dnsmasq-full"
  if [ -f "/etc/config/dhcp" ]; then
    rm -f /etc/config/dhcp
  fi
  opkg install dnsmasq-full

  mv -f /etc/hosts.bak /etc/hosts
  fix_resolv_conf
fi

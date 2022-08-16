if [ "${USE_DNSMASQ_FULL}" = "true" ]; then
  cp -f /etc/hosts /etc/hosts.bak
  # TODO nslookup ip
  echo "168.119.138.211 downloads.openwrt.org" >>/etc/hosts

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

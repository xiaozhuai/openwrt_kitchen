if [ "${UPGRADE_ALL}" = "true" ]; then
  for pkg in $(opkg list-upgradable | cut -f 1 -d ' '); do
    echo "  - Upgrade ${pkg}"
    opkg upgrade "${pkg}"
    fix_resolv_conf
  done
fi

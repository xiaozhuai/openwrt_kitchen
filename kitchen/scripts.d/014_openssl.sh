if [ "${USE_OPENSSL}" = "true" ]; then
  echo "  - Remove wolfssl"
  opkg remove luci-ssl libustream-wolfssl* px5g-wolfssl libwolfssl*
  echo "  - Install openssl"
  opkg install luci-ssl-openssl
fi

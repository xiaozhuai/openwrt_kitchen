if [ "${USE_OPENSSL}" = "true" ]; then
  echo "  - Remove luci-ssl"
  opkg remove luci-ssl
  echo "  - Remove wolfssl"
  opkg remove libustream-wolfssl* px5g-wolfssl libwolfssl*
  echo "  - Remove mbedtls"
  opkg remove libustream-mbedtls* px5g-mbedtls libmbedtls*
  echo "  - Install luci-ssl-openssl"
  opkg install luci-ssl-openssl
fi

if [ "${INSTALL_BLOCK_MOUNT}" = "true" ]; then
  echo "  - Install block-mount usbutils"
  opkg install block-mount usbutils
fi

if [ "${INSTALL_BASH}" = "true" ]; then
  echo "  - Install bash"
  opkg install bash

  if [ "${LOGIN_SHELL_BASH}" = "true" ]; then
    echo "  - Change login shell to bash"
    sed -i 's|/root:/bin/ash|/root:/bin/bash|' /etc/passwd
    sed -i 's|/root:/bin/sh|/root:/bin/bash|' /etc/passwd
  fi
fi

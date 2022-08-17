if [ "${INSTALL_BASH}" = "true" ]; then
  echo "  - Install bash"
  opkg install bash

  if [ "${LOGIN_SHELL_BASH}" = "true" ]; then
    echo "  - Change login shell to bash"
    sed -i 's|/root:/bin/ash|/root:/bin/bash|' /etc/passwd
    sed -i 's|/root:/bin/sh|/root:/bin/bash|' /etc/passwd
  fi

  if [ "${USE_DEFAULT_BASH_PROFILE}" = "true" ]; then
    echo "  - Copy .bash_profile & .bash_profile.d to ${HOME}"
    cp -f ../assets/.bash_profile /root/
    cp -rf ../assets/.bash_profile.d /root/
  fi
fi

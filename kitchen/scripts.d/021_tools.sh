install_by_cond "${INSTALL_ANNOUNCE}" announce
install_by_cond "${INSTALL_OPENSSH_SFTP_SERVER}" openssh-sftp-server
install_by_cond "${INSTALL_SHADOW_CHSH}" shadow-chsh
install_by_cond "${INSTALL_CURL}" curl
install_by_cond "${INSTALL_LSOF}" lsof
install_by_cond "${INSTALL_JQ}" jq
install_by_cond "${INSTALL_GIT}" git
install_by_version "${INSTALL_IP_VERSION}"
install_by_cond "${INSTALL_PARTED}" parted
install_by_cond "${INSTALL_RESIZE2FS}" resize2fs
install_by_version "${INSTALL_VIM_VERSION}"
install_by_cond "${INSTALL_ETHTOOL}" ethtool
if [ "${INSTALL_ETHINFO}" = "true" ]; then
  echo "  - Install ethinfo"
  [ -z "$(which -a ip)" ] && opkg install ip-full
  [ -z "$(which -a ethtool)" ] && opkg install ethtool
  cp -f ../prebuilt/ethinfo /usr/bin/
  chmod 755 /usr/bin/ethinfo
fi

install_by_cond "${INSTALL_E2FSPROGS}" e2fsprogs
install_by_cond "${INSTALL_F2FS_TOOLS}" f2fs-tools
install_by_cond "${INSTALL_DOSFSTOOLS}" dosfstools

install_by_cond "${INSTALL_DOCKER}" docker
install_by_cond "${INSTALL_DOCKERD}" dockerd
install_by_cond "${INSTALL_DOCKER_COMPOSE}" docker-compose


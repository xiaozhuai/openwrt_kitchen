install_by_cond "${INSTALL_OPENSSH_SFTP_SERVER}" openssh-sftp-server
install_by_cond "${INSTALL_SHADOW_CHSH}" shadow-chsh
install_by_cond "${INSTALL_CURL}" curl
install_by_cond "${INSTALL_LSOF}" lsof
install_by_cond "${INSTALL_JQ}" jq
install_by_cond "${INSTALL_GIT}" git
install_by_cond "${INSTALL_IP_FULL}" ip-full
install_by_cond "${INSTALL_PARTED}" parted
install_by_cond "${INSTALL_RESIZE2FS}" resize2fs
install_by_version "${INSTALL_VIM_VERSION}"

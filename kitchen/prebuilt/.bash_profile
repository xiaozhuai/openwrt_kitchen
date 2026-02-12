# source all sh files in ~/.bash_profile.d
if [ -d "${HOME}/.bash_profile.d" ]; then
    for i in ${HOME}/.bash_profile.d/*.sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
    unset i
fi

if [ -d "${HOME}/.local/bin" ]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

opkg_upgrade_all() {
    for pkg in $(opkg list-upgradable | cut -f 1 -d ' '); do
        opkg upgrade ${pkg}
    done
}

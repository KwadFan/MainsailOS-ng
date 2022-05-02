#!/bin/bash
#### MainsailOS Build Chain
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2022
#### https://github.com/mainsail-crew/MainsailOS
####
#### This File is distributed under GPLv3
####

# shellcheck enable=require-variable-braces

set -ex

export LC_ALL=C

# shellcheck disable=SC1091
source /common.sh
install_cleanup_trap

#### Raspberry Pi OS has autologin enabled by default
### Revert that!

function disable_autologin {
cat << EOF > /etc/systemd/system/noautologin.service
### Revert Raspberry Pi OS autologin behavior
### To enable auto login, disable this service and
### run 'sudo raspi-config'
### written 2022 by Stephan Wendel <me (at) stephanwe (dot) de>
[Unit]
Description=Revert Raspberry Pi OS autologin
ConditionPathExists=/etc/systemd/system/getty@tty1.service.d/autologin.conf
Before=rc.local.service getty@.service

[Install]
WantedBy=multi-user.target

[Service]
Type=oneshot
ExecStart= rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf
ExecStartPost= systemctl daemon-reload
ExecStartPost= systemctl restart getty@tty1.service
EOF
}

### MAIN
if [ "${EDITBASE_DISABLE_AUTOLOGIN}" == "1" ]; then
    echo_green "Disable autologin for default user ..."
    disable_autologin
    systemctl_if_exists enable noautologin.service
    echo_green "... done!"
fi


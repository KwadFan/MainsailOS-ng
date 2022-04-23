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

# Setup vars
PICONFIG_CONFIG_TXT_FILE="/boot/config.txt"
PICONFIG_CMDLINE_TXT_FILE="/boot/cmdline.txt"
PICONFIG_CONFIG_BAK_FILE="/boot/orig-config.txt"
PICONFIG_CMDLINE_BAK_FILE="/boot/orig-cmdline.txt"

# Setup first user, reference:
# https://www.raspberrypi.com/documentation/computers/configuration.html#configuring-a-user
echo_green "Setup default user and password ..."
function create_userconf {
    local pw_encrypt
    if [ -n "${EDITBASE_BASE_USER}" ] || [ -n "${EDITBASE_BASE_USER_PW}" ]; then
        pw_encrypt="$(echo "${EDITBASE_BASE_USER_PW}" | openssl passwd -6 -stdin)"
        echo "${EDITBASE_BASE_USER}:${pw_encrypt}" > /boot/userconf.txt
    else
        echo_red "First user name and password not set! [FAILED]"
        exit 1
    fi
}
create_userconf

# enable or disable SSH Server, see config.local
if [ "${EDITBASE_PICFG_SSH}" == "1" ]; then
    echo_green "Enable SSH Server by default ..."
    sudo touch /boot/ssh
else
    echo_red "SSH disabled by configuration!"
    echo_red "WARNING: This Image will not be accessible due SSH!"
fi

# Copy files and backup config.txt and cmdline.txt
echo_green "Backup original config.txt and cmdline.txt ..."
mv "${PICONFIG_CONFIG_TXT_FILE}" "${PICONFIG_CONFIG_BAK_FILE}"
cp "${PICONFIG_CMDLINE_TXT_FILE}" "${PICONFIG_CMDLINE_BAK_FILE}"

echo_green "Copying files to root filesystem ..."
unpack files/piconfig/root /

### Disable Console and services to enable Hardware Serial.
# See config.local
if [ "${EDITBASE_PICFG_WIFI_PM}" != "0" ]; then
    echo_green "Disable Serial Linux console ..."
    sed -i 's/console=serial0,115200 //' "${PICONFIG_CMDLINE_TXT_FILE}"

    ### disable bluetooth and related services
    echo_green "Disabling Bluetooth related services..."
    systemctl_if_exists disable hciuart.service
    systemctl_if_exists disable bluetooth.service
    systemctl_if_exists disable bluealsa.service
fi

### Enable wifi-power-management-off.service
## This disables wifi power_save on boot
## See config.local
if [ "${EDITBASE_PICFG_WIFI_PM}" != "0" ]; then
    echo_green "Enable wifi-power-management-off service ..."
    systemctl_if_exists enable wifi-power-management-off.service
fi

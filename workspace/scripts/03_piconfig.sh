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

echo_green "Backup original config.txt and cmdline.txt ..."
mv "${PICONFIG_CONFIG_TXT_FILE}" "${PICONFIG_CONFIG_BAK_FILE}"
cp "${PICONFIG_CMDLINE_TXT_FILE}" "${PICONFIG_CMDLINE_BAK_FILE}"

echo_green "Copying files to root filesystem ..."
unpack files/piconfig/root /

### Disable Console and services to enable Hardware Serial.
echo_green "Disable Serial Linux console ..."
sed -i 's/console=serial0,115200 //' "${PICONFIG_CMDLINE_TXT_FILE}"

### disable bluetooth and related services
echo_green "Disabling Bluetooth related services..."
systemctl_if_exists disable hciuart.service
systemctl_if_exists disable bluetooth.service
systemctl_if_exists disable bluealsa.service

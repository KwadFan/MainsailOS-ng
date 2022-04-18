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

# Setup Vars
BASE_USER="pi"

KLIPPER_SRC_DIR="/home/${BASE_USER}/klipper"
KLIPPER_PYTHON_DIR="/home/${BASE_USER}/klippy-env"

KLIPPER_REPO_SHIP="https://github.com/Klipper3d/klipper.git"
KLIPPER_REPO_BRANCH="master"
KLIPPER_DEPS=(git virtualenv python3-dev libffi-dev build-essential \
libncurses-dev libusb-dev avrdude gcc-avr binutils-avr avr-libc \
stm32flash dfu-util libnewlib-arm-none-eabi \
gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0-0)
KLIPPER_USER_GROUPS="tty,dialout"
KLIPPER_USER_DIRS="klipper_config klipper_logs gcode_files"
KLIPPER_PYENV_REQ="scripts/klippy-requirements.txt"

# Install service file
unpack /files/klipper/root /

echo_green "Installing Klipper and enable klippy Service ..."

### install all deps at once for time consumption reasons.
## APT: Update Repo Database and install Dependencies

apt update
apt install "${KLIPPER_DEPS[@]}" -y

### Make sure user pi has access to serial ports
## NOTE: BASE_USER is defined by CustomPIOS Variable
## there for if you plan to set something else than "pi"
## Currently CustomPIOS uses "pi"

usermod -a -G "${KLIPPER_USER_GROUPS}" "${BASE_USER}"

### clone klipper repo
pushd /home/"${BASE_USER}"
sudo -u "${BASE_USER}" git clone -b "${KLIPPER_REPO_BRANCH}" "${KLIPPER_REPO_SHIP}" klipper

### Create needed dirs
for dirs in ${KLIPPER_USER_DIRS}; do
    if [ -d "/home/${BASE_USER}/${dirs}" ]; then
        echo_green "${dirs} already exists!"
    else
        echo_green "Creating ${dirs}"
        sudo -u "${BASE_USER}" mkdir -p "${dirs}"
    fi
done
popd

# create python virtualenv and install klipper requirements
pushd /home/${BASE_USER}
echo_green "Creating Virtualenv for Klipper (klipper-env) ..."
sudo -u "${BASE_USER}" virtualenv -p python3 "${KLIPPER_PYTHON_DIR}"
echo_green "Installing klippy Python Dependencies ..."
sudo -u "${BASE_USER}" "${KLIPPER_PYTHON_DIR}"/bin/pip install -r "${KLIPPER_SRC_DIR}"/"${KLIPPER_PYENV_REQ}"
popd


# enable systemd service
systemctl_if_exists enable klipper.service

echo_green "... done!"

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
apt install --yes --no-install-recommends "${KLIPPER_DEPS[@]}"

### Make sure user pi has access to serial ports
## NOTE: BASE_USER is defined by CustomPIOS Variable
## there for if you plan to set something else than "pi"
## Currently CustomPIOS uses "pi"

usermod -a -G "${KLIPPER_USER_GROUPS}" "${BASE_USER}"

### clone klipper repo
pushd /home/"${BASE_USER}" &> /dev/null || exit 1
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
popd &> /dev/null || exit 1

# create python virtualenv and install klipper requirements
pushd /home/"${BASE_USER}" &> /dev/null || exit 1
echo_green "Creating Virtualenv for Klipper (klipper-env) ..."
sudo -u "${BASE_USER}" virtualenv -p python3 "${KLIPPER_PYTHON_DIR}"
echo_green "Installing klippy Python Dependencies ..."
sudo -u "${BASE_USER}" "${KLIPPER_PYTHON_DIR}"/bin/pip install -r "${KLIPPER_SRC_DIR}"/"${KLIPPER_PYENV_REQ}"
popd &> /dev/null || exit 1


# enable systemd service
systemctl_if_exists enable klipper.service

echo_green "... done!"

### Input Shaper preinstall

# Setup Vars

IS_REQ_PREINSTALL_DEPS=(python3-numpy python3-matplotlib)
IS_REQ_PREINSTALL_PIP="numpy"
IS_REQ_PREINSTALL_CFG_FILE="/boot/config.txt"


echo_green "Input Shaper Requirements preinstall"

### install all deps at once for time consumption reasons.
## APT: Update Repo Database and install Dependencies

echo_green "Installing Input Shaper Dependencies ..."
apt update
apt install --yes --no-install-recommends "${IS_REQ_PREINSTALL_DEPS[@]}"

### numpy Parallelizing
function max_cores() {
    local core_count
    core_count="$(nproc)"
    if [ "${core_count}" -lt 3 ]; then
        echo "${core_count}"
    else
        echo "$(("${core_count}" -1))"
    fi
}

echo_green "System has $(nproc) Cores available."
echo_green "Using $(max_cores)..."
NPY_NUM_BUILD_JOBS="$(max_cores)"
export NPY_NUM_BUILD_JOBS


### Check for Klipper Venv installed.
pushd /home/"${BASE_USER}" &> /dev/null || exit 1
if [ -d "${KLIPPER_PYTHON_DIR}" ] && [ -x "${KLIPPER_PYTHON_DIR}/bin/pip" ]; then
    echo_green "Installing numpy..."
    sudo -u "${BASE_USER}" "${KLIPPER_PYTHON_DIR}"/bin/pip install -v "${IS_REQ_PREINSTALL_PIP}"
else
    echo_red "Klipper Venv not found!"
    return 1
fi

## Cleanup
sudo -u "${BASE_USER}" rm -rf /home/"${BASE_USER}"/.cache
popd &> /dev/null || exit 1

## Enable spi interface by default
echo_green "Enabling SPI Interface..."
sed -i 's/#dtparam=spi=on/dtparam=spi=on/' "${IS_REQ_PREINSTALL_CFG_FILE}"

echo_green "... done!"

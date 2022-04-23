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

echo_green "Installing Klipper and enable klippy Service ..."
# Install service file
unpack /files/klipper/root /

### install all deps at once for time consumption reasons.
## APT: Update Repo Database and install Dependencies
apt update
# shellcheck disable=SC2086
# Disable SC2086 here, because we want word splitting
apt install --yes --no-install-recommends ${EDITBASE_KLIPPER_DEPS}

### Make sure first user (EDITBASE_BASE_USER) has access to serial ports
usermod -a -G "${EDITBASE_KLIPPER_USER_GROUPS}" "${EDITBASE_BASE_USER}"

### clone klipper repo
pushd /home/"${EDITBASE_BASE_USER}" &> /dev/null || exit 1
sudo -u "${EDITBASE_BASE_USER}" \
git clone -b "${EDITBASE_KLIPPER_REPO_BRANCH}" "${EDITBASE_KLIPPER_REPO_SHIP}" klipper
### Create needed dirs
for dirs in ${EDITBASE_KLIPPER_USER_DIRS}; do
    if [ -d "/home/${EDITBASE_BASE_USER}/${dirs}" ]; then
        echo_green "${dirs} already exists!"
    else
        echo_green "Creating ${dirs}"
        sudo -u "${EDITBASE_BASE_USER}" mkdir -p "${dirs}"
    fi
done
popd &> /dev/null || exit 1

# create python virtualenv and install klipper requirements
pushd /home/"${EDITBASE_BASE_USER}" &> /dev/null || exit 1
echo_green "Creating Virtualenv for Klipper (klipper-env) ..."
sudo -u "${EDITBASE_BASE_USER}" \
virtualenv -p python3 "${EDITBASE_KLIPPER_PYTHON_DIR}"
echo_green "Installing klippy Python Dependencies ..."
sudo -u "${EDITBASE_BASE_USER}" \
"${EDITBASE_KLIPPER_PYTHON_DIR}"/bin/pip install \
-r "${EDITBASE_KLIPPER_SRC_DIR}"/"${EDITBASE_KLIPPER_PYENV_REQ}"
popd &> /dev/null || exit 1


# enable systemd service
systemctl_if_exists enable klipper.service

echo_green "... done!"


### Input Shaper preinstall
if [ "${EDITBASE_KLIPPER_IS_INSTALL}" == "1" ]; then
    echo_green "Perform Input Shaper preinstall ..."


    # install all deps at once for time consumption reasons.
    echo_green "Installing Input Shaper Dependencies ..."
    apt update
    # shellcheck disable=SC2086
    # Disable SC2086 here, because we want word splitting
    apt install --yes --no-install-recommends ${EDITBASE_IS_DEPS}


    ### Check for Klipper Venv installed.
    pushd /home/"${EDITBASE_BASE_USER}" &> /dev/null || exit 1
    if [ -d "${EDITBASE_KLIPPER_PYTHON_DIR}" ] && \
    [ -x "${EDITBASE_KLIPPER_PYTHON_DIR}/bin/pip" ]; then
        echo_green "Installing numpy..."
        sudo -u "${EDITBASE_BASE_USER}" \
        "${EDITBASE_KLIPPER_PYTHON_DIR}"/bin/pip install -v "${EDITBASE_IS_PIP}"
    else
        echo_red "Klipper Venv not found! [EXITING]!"
        exit 1
    fi
    ## Cleanup
    sudo -u "${EDITBASE_BASE_USER}" rm -rf /home/"${EDITBASE_BASE_USER}"/.cache
    popd &> /dev/null || exit 1

    ## Enable spi interface by default
    echo_green "Enabling SPI Interface..."
    sed -i 's/#dtparam=spi=on/dtparam=spi=on/' "${EDITBASE_IS_CFG_FILE}"

    echo_green "... done!"
fi

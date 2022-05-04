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

if [ "${EDITBASE_INSTALL_CROWSNEST=1}" == "1" ]; then
    # Install crowsnest
    echo_green "Installing crowsnest and enable crowsnest Service ..."

    # make sure that this module can be used standalone
    # Only git is needed due reusing crowsnest install script.
    apt update
    apt install --yes --no-install-recommends git


    # clone crowsnest repo
    pushd /home/"${EDITBASE_BASE_USER}" &> /dev/null || exit 1
    sudo -u "${EDITBASE_BASE_USER}" \
    git clone -b "${EDITBASE_CROWSNEST_REPO_BRANCH}" "${EDITBASE_CROWSNEST_REPO_SHIP}" crowsnest
    popd &> /dev/null || exit 1

    # use crowsnest's  make unattended
    echo_green "Launch crowsnest install routine ..."
    pushd /home/"${EDITBASE_BASE_USER}"/crowsnest &> /dev/null || exit 1
    if [ "${EDITBASE_ADD_CROWSNEST_MOONRAKER}" == "1" ]; then
        sudo -u "${EDITBASE_BASE_USER}" \
        make unattended
    else
        sudo -u "${EDITBASE_BASE_USER}" \
        make install
    fi

    popd &> /dev/null || exit 1

    # enable systemd service
    systemctl_if_exists enable crowsnest.service

    echo_green "...done!"
fi

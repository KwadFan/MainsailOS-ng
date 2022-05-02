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

if [ "${EDITBASE_INSTALL_SONAR=1}" == "1" ]; then
    # Install sonar
    echo_green "Installing sonar and enable sonar Service ..."

    # make sure that this module can be used standalone
    # Only git is needed due reusing sonar install script.
    apt update
    apt install --yes --no-install-recommends git


    # clone sonar repo
    pushd /home/"${EDITBASE_BASE_USER}" &> /dev/null || exit 1
    sudo -u "${EDITBASE_BASE_USER}" \
    git clone -b "${EDITBASE_SONAR_REPO_BRANCH}" "${EDITBASE_SONAR_REPO_SHIP}" sonar
    popd &> /dev/null || exit 1

    # use sonar's  make install
    echo_green "Launch sonar install routine ..."
    pushd /home/"${EDITBASE_BASE_USER}"/sonar &> /dev/null || exit 1
    make install
    popd &> /dev/null || exit 1
    echo_green "...done!"
fi

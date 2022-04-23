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

if [ "${EDITBASE_RUN_FULL_UPGRADE}" != "0" ]; then
    echo_green "Get latest OS updates ..."
    apt update --allow-releaseinfo-change
    apt dist-upgrade --yes
    echo_green "...done!"
else
    echo_red "Full Upgrade disabled by configuration! ... [SKIPPED]"
fi

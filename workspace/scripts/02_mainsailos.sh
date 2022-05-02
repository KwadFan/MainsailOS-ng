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

echo_green "Setup default hostname '${EDITBASE_DIST_HOSTNAME}' ..."
echo "${EDITBASE_DIST_HOSTNAME}" > /etc/hostname


echo_green "Creating Release file... "
# Create mainsailos release file
if [ -f "/etc/mainsailos_version" ]; then
    sudo rm -f /etc/mainsailos_version
fi
function get_parent {
grep "VERSION_CODENAME" /etc/os-release | cut -d '=' -f2
}
echo "${EDITBASE_DIST_NAME} release ${EDITBASE_DIST_VERSION} ($(get_parent))" > \
/etc/"${EDITBASE_DIST_NAME,,}"-release
echo_green "... done!"

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

### Revert Raspberry's passwordless sudo
## It is not a good idea to allow sudo commands without password
## So let's revert that!
if [ "${EDITBASE_REVERT_SUDO_NOPASSWD}" == "1" ]; then
    echo_green "Revert passwordless sudo ..."
    sed -i 's/^pi/#pi/' /etc/sudoers.d/010_pi-nopasswd
    echo_green "... done!"
fi

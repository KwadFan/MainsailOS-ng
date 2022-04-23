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

# Install moonraker
echo_green "Installing Moonraker and enable Moonraker Service ..."

# make sure that this module can be used standalone
# Only git is needed due reusing moonraker install script.
apt update
apt install --yes --no-install-recommends git

# install MainsailOS premade moonraker.conf
echo_green "Copying MainsailOS premade moonraker.conf ..."
unpack /files/moonraker/home/"${EDITBASE_BASE_USER}" \
/home/"${EDITBASE_BASE_USER}" "${EDITBASE_BASE_USER}"

# clone klipper repo
pushd /home/"${EDITBASE_BASE_USER}" &> /dev/null || exit 1
sudo -u "${EDITBASE_BASE_USER}" \
git clone -b "${EDITBASE_MOONRAKER_REPO_BRANCH}" "${EDITBASE_MOONRAKER_REPO_SHIP}" moonraker

# use moonrakers Install script
echo_green "Launch moonraker Install script (scripts/install-moonraker.sh)"
sudo -u "${EDITBASE_BASE_USER}" \
bash -c \
'${HOME}/moonraker/scripts/install-moonraker.sh -z \
-c ${HOME}/klipper_config/moonraker.conf \
-l ${HOME}/klipper_logs/moonraker.log'

# enable systemd service
systemctl_if_exists enable moonraker.service

# install Polkit Rules
echo_green "Install PolicyKit Rules"
sudo -u "${EDITBASE_BASE_USER}" sh -c './moonraker/scripts/set-policykit-rules.sh -z --root'
# finished
popd &> /dev/null || exit 1

echo_green "...done!"

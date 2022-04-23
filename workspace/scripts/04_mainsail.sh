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

### Install mainsail.cfg
unpack files/mainsail/home/"${EDITBASE_BASE_USER}" /home/"${EDITBASE_BASE_USER}" "${EDITBASE_BASE_USER}"

echo_green "Installing Mainsail Webfrontend ..."

### install all deps at once for time consumption reasons.
## APT: Update Repo Database and install Dependencies

apt update
apt install --yes --no-install-recommends "${EDITBASE_MAINSAIL_DEPS}"

### Preparing nginx
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/mainsail /etc/nginx/sites-enabled/

# lower nginx rotate cycle to 2 instead 14
sudo sed -i 's/rotate 14/rotate 2/' /etc/logrotate.d/nginx

### Download and Install Mainsail Web Frontend
pushd /home/"${EDITBASE_BASE_USER}" &> /dev/null || exit 1
sudo -u "${EDITBASE_BASE_USER}" wget -q --show-progress -O mainsail.zip "${EDITBASE_MAINSAIL_URL}"
sudo -u "${EDITBASE_BASE_USER}" unzip mainsail.zip -d /home/"${EDITBASE_BASE_USER}"/mainsail
## cleanup
rm /home/"${EDITBASE_BASE_USER}"/mainsail.zip
popd &> /dev/null || exit 1

### Link logfiles to klipper_logs
if [ ! -d "/home/${EDITBASE_BASE_USER}/klipper_logs" ]; then
    sudo -u "${EDITBASE_BASE_USER}" mkdir -p "/home/${EDITBASE_BASE_USER}/klipper_logs"
fi
ln -s /var/log/nginx/mainsail-access.log /home/"${EDITBASE_BASE_USER}"/klipper_logs/
ln -s /var/log/nginx/mainsail-error.log /home/"${EDITBASE_BASE_USER}"/klipper_logs/

# Unpack root at the end, so files are modified before
unpack files/mainsail/root /

echo_green "...done!"

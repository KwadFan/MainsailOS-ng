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

# Functions
# delete old compressed image
function delete_old_image {
    local img
    img="$(find workspace/ -iname '*.xz' 2> /dev/null || echo )"
    if [ -n "${img}" ]; then
        echo -e "Removing existing Image '${img}' ..."
        rm -f "${img}"
    else
        return 0
    fi
}

# call rename_output_img <directory> <imagename>
function rename_output_img {
    if [ -f "${1}/output.img" ]; then
        echo -e "Renaming 'output.img' to '${2}' ..."
        mv -f "${1}"/output.img "${1}/${2}"
    else
        echo -e "No 'output.img' found ... [EXITING!]"
        exit 1
    fi
}

# call compress_img <imagename>
function compress_img {
    echo -e "Compressing image using xz ..."
    # needs dirty pipe hack due file permissions (error on set group)
    xz -efvz9T"$(nproc)" "${PWD}/workspace/${1}" || true
}

### MAIN
function main {
    local date dir img_name
    date="$(date +%Y-%m-%d)"
    dir="${PWD}/workspace"
    # shellcheck disable=1091
    source "${dir}/config.mainsail"
    img_name="${date}-${EDITBASE_DIST_NAME,,}-${EDITBASE_DIST_VERSION}.img"
    echo -e "Rename and compress 'output.img' ..."
    delete_old_image
    rename_output_img "${dir}" "${img_name}"
    compress_img "${img_name}"
}

time main
exit 0

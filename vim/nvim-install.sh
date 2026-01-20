#!/bin/bash

function must() {
    echo cmd: "$@"
    "$@";
    code=$?
    if [ $code -ne 0 ]
    then
        echo "Last command ($*) failed with non-zero exit code ($code)."
        exit 1
    fi
}

# Variables
NVIM_CONFIG_REPO="https://github.com/itsankoff/nvim.git"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

must git clone "${NVIM_CONFIG_REPO}" "${NVIM_CONFIG_DIR}"

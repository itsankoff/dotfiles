#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPT_NAME=$(basename ${0})

NEOVIM_CONFIG="${HOME}/.config/nvim"

# source the utility library
source ${SCRIPT_DIR}/../lib/lib.sh

pkg_install neovim || skip_error
mkdir -p ${NEOVIM_CONFIG}
git clone https://github.com/nvim-lua/kickstart.nvim.git ${NEOVIM_CONFIG}

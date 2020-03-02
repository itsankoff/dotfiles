#!/bin/bash

VIM_DIR=~/.vim-itsankoff
VIM_PLUGIN_DIR=${VIM_DIR}/plugged

function must() {
    echo cmd: $@
    "$@";
    code=$?
    if [ $code -ne 0 ]
    then
        echo "Last command ($*) failed with non-zero exit code ($code)."
        exit 1
    fi
}

# Install Plug
must curl -fLo ${VIM_DIR}/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Setup colorscheme
must mkdir -p ${VIM_DIR}/colors
must ln -sf $(pwd)/jellygrass.vim ${VIM_DIR}/colors/jellygrass.vim

# Install NERDTree plugin
test -d ${VIM_PLUGIN_DIR}/nerdtree || must git clone https://github.com/scrooloose/nerdtree.git ${VIM_PLUGIN_DIR}/nerdtree

# Install TypeScript syntax
test -d ${VIM_PLUGIN_DIR}/typescript-vim || must git clone https://github.com/leafgarland/typescript-vim.git ${VIM_PLUGIN_DIR}/typescript-vim

# Install vim configuration
test -f ~/.vimrc && must mv ~/.vimrc ~/.vimrc-${USER}
must ln -s $(pwd)/.vimrc ~/.vimrc

# Install all plug plugins
must vim -c 'PlugInstall' +qall

echo "VIM Plugins installed"

# Install YouCompleteMe server
pushd ${VIM_DIR}/YouCompleteMe
    must python3 install.py
popd

must vim -c 'GoInstallBinaries' +qall
# Install vim-go binaries
must go get github.com/mdempsky/gocode
GO111MODULE=on must go get golang.org/x/tools/gopls@latest

echo "Happy vim-ing!"

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
echo "Installing Plug..."
must curl -fLo ${VIM_DIR}/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Installing color scheme..."
must mkdir -p ${VIM_DIR}/colors
must ln -sf $(pwd)/colors/jellygrass.vim ${VIM_DIR}/colors/jellygrass.vim

echo "Installing NERDTree plugin..."
test -d ${VIM_PLUGIN_DIR}/nerdtree || must git clone https://github.com/scrooloose/nerdtree.git ${VIM_PLUGIN_DIR}/nerdtree

echo "Installing TypeScript syntax..."
test -d ${VIM_PLUGIN_DIR}/typescript-vim || must git clone https://github.com/leafgarland/typescript-vim.git ${VIM_PLUGIN_DIR}/typescript-vim

echo "Installing vim config..."
test -f ~/.vimrc && \
    echo "WARNING: Detected existing vimrc. Moving it to ~/.vimrc-${USER}" && \
    sleep 2 && \
    must mv ~/.vimrc ~/.vimrc-${USER}
must ln -s $(pwd)/.vimrc ~/.vimrc

echo "Installing Plug plugins..."
must vim -c 'PlugInstall' +qall
echo "VIM Plugins installed"

echo "Installing Go binaries..."
GO111MODULE=on vim -c 'GoInstallBinaries'

# Install vim-go binaries
must go get github.com/mdempsky/gocode
GO111MODULE=on must go get golang.org/x/tools/gopls@latest

echo "Happy vim-ing!"

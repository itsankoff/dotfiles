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

echo "Installing vim config..."
test -f ~/.vimrc && \
    echo "WARNING: Detected existing vimrc. Moving it to ~/.vimrc-${USER}" && \
    sleep 2 && \
    must mv ~/.vimrc ~/.vimrc-${USER}
must ln -s $(pwd)/.vimrc ~/.vimrc

echo "Installing Plug plugins..."
must vim -c 'PlugInstall' +qall
echo "VIM Plugins installed"

# Install coc.nvim extensions
if [ -f coc_extensions.txt ]; then
  while read extension; do
    vim -n -c "CocInstall -sync $extension" +qall
  done < coc_extensions.txt
else
  echo "WARNING: coc_extensions.txt not found. Skipping CocInstall step."
fi

echo "Happy vim-ing!"

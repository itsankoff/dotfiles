#!/bin/bash

VIM_DIR=~/.vim

# Install pathogen
mkdir -p ${VIM_DIR}/autoload
mkdir -p ${VIM_DIR}/bundle
curl -fLo ${VIM_DIR}/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install vimrc
ln -s $(pwd)/.vimrc ~/.vimrc

# Setup colorscheme
mkdir -p ${VIM_DIR}/colors
ln -s $(pwd)/jellygrass.vim ~/.vim/colors/

# Install Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install plug
curl -fLo ${VIM_DIR}/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Plugins from this folder are autoloaded
mkdir -p ${VIM_DIR}/plugin

# Install c++ .h/.cpp changer with :A
curl -fLo ${VIM_DIR}/plugin/a.vim http://www.vim.org/scripts/download_script.php?src_id=7218

# Install supertab from vimball
curl -fLo /tmp/supertab.vmb http://www.vim.org/scripts/download_script.php?src_id=21752
vim -c 'so %' -c 'q' /tmp/supertab.vmb

# Install NERDTree plugin
git clone https://github.com/scrooloose/nerdtree.git ${VIM_DIR}/bundle/nerdtree

# Install tasklist plugin
# Usage:
# :TaskList
curl -fLo ${VIM_DIR}/plugin/tasklist.vim http://www.vim.org/scripts/download_script.php?src_id=10388

# Install vim-polygot
# Make sure you want syntax on in .vimrc
git clone github.com/sheerun/vim-polyglot ${VIM_DIR}/bundle/nerdtree

# Install vim-go
git clone https://github.com/fatih/vim-go.git ${VIM_DIR}/plugged/vim-go

# Install grep search plugin
mkdir ${VIM_DIR}/bundle/grep
curl -fLo /tmp/grep.zip https://www.vim.org/scripts/download_script.php?src_id=25816
unzip /tmp/grep.zip -d ${VIM_DIR}/bundle/grep/
rm /tmp/grep.zip

# Install missing syntax
git clone https://github.com/leafgarland/typescript-vim.git ~/.vim/bundle/typescript-vim

# Install all vundle plugins
vim +PluginInstall +qall

# Install vim-go binaries
go get github.com/mdempsky/gocode
vim +'silent :GoInstallBinaries' +qall

echo "Happy vim-ing!"

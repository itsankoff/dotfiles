#!/bin/bash

VIM_DIR=~/.vim

# Install pathogen
mkdir -p ${VIM_DIR}/autoload
mkdir -p ${VIM_DIR}/bundle
curl -fLo ${VIM_DIR}/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install Plug
curl -fLo ${VIM_DIR}/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Plugins from this folder are autoloaded
mkdir -p ${VIM_DIR}/plugin

# Setup colorscheme
mkdir -p ${VIM_DIR}/colors
ln -s $(pwd)/jellygrass.vim ~/.vim/colors/

# Install NERDTree plugin
git clone https://github.com/scrooloose/nerdtree.git ${VIM_DIR}/bundle/nerdtree

# Install grep search plugin
mkdir ${VIM_DIR}/bundle/grep
curl -fLo /tmp/grep.zip https://www.vim.org/scripts/download_script.php?src_id=25816
unzip /tmp/grep.zip -d ${VIM_DIR}/bundle/grep/
rm /tmp/grep.zip

# Install missing syntax
git clone https://github.com/leafgarland/typescript-vim.git ~/.vim/bundle/typescript-vim

# Install vimrc
ln -s $(pwd)/.vimrc ~/.vimrc

# Install all vundle plugins
vim +PluginInstall +qall

# Install all plug plugins
vim +PlugInstall +qall

echo "Plugins installed"

# Install YouCompleteMe server
pushd ~/.vim/bundle/YouCompleteMe && python install.py && popd

# Install vim-go binaries
go get github.com/mdempsky/gocode
vim +'silent :GoInstallBinaries' +qall

# Install fugative.vim
cd ~/.vim/bundle
git clone https://github.com/tpope/vim-fugitive.git
vim -u NONE -c "helptags vim-fugitive/doc" -c q

echo "Happy vim-ing!"

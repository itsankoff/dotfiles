#!/bin/bash

# NOTE:
# This file can work as stanalone installer for mac environment

# Install fonts
mkdir -p /tmp/fonts
pushd /tmp/fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
popd
exit 1

# Install basic apps
brew install git
brew cask install iterm2
brew cask install the-unarchiver
brew cask install google-chrome
brew cask install java
brew cask install docker
brew cask install tunnelblick
brew cask install ngrok
brew install terraform
brew install wget
brew install curl
brew install htop
brew install git
brew install direnv
brew install autojump
brew install grip
brew install node
brew install ansible
brew install python3
brew install vim
brew install cmake
pip3 install virtualenv
sudo gem install cocoapods

# Setup development structure
USER_HOME="/Users/${USER}"
DEV_HOME="${USER_HOME}/developers"

mkdir -p $DEV_HOME

# Setup golang workspace structure
mkdir -p $DEV_HOME/workspace
mkdir -p $DEV_HOME/workspace/src
mkdir -p $DEV_HOME/workspace/pkg
mkdir -p $DEV_HOME/workspace/bin

# install golang
brew install go
brew install hg

# Install goimports
go get golang.org/x/tools/cmd/goimports

# Install postgres
brew install postgresql
initdb
brew services start postgres
createdb $USER

# Setup Oh my zsh
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
pushd developers && git clone https://github.com/powerline/fonts.git && pushd fonts && ./install.sh && popd && popd
mv ${USER_HOME}/.zshrc ${USER_HOME}/.zshrc.orig
ln -s ${USER_HOME}/developers/dotfiles/.zshrc ${USER_HOME}/.zshrc
ln -s ${USER_HOME}/developers/dotfiles/.aliases ${USER_HOME}/.aliases

# Setup vim
pushd ${USER_HOME}/developers/dotfiles/vim && ./install.sh && popd

# Setup github
ln -s ${USER_HOME}/developers/dotfiles/.gitconfig ${USER_HOME}/.gitconfig

# Reload zsh config
source ${USER_HOME}/.zshrc

echo Done!

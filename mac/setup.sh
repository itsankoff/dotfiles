#!/bin/bash

# NOTE:
# This file can work as stanalone installer for mac environment

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
brew install vim --with-override-system-vi
brew install cmake
brew install fzf
pip3 install virtualenv
sudo gem install cocoapods

# Setup development structure
DEV_HOME=~developers
mkdir $DEV_HOME

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
gem install lunchy
mkdir -p ~/Library/LaunchAgents
cp /usr/local/Cellar/postgresql/10.4/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
lunchy start postgres
createdb $USER

# Setup Oh my zsh
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
pushd developers && git clone https://github.com/powerline/fonts.git && pushd fonts && ./install.sh && popd && popd
mv .zshrc .zshrc.orig
pushd developers && git clone git@github.com:itsankoff/dotfiles.git && popd
ln -s ~/developers/dotfiles/.zshrc ~/.zshrc
ln -s ~/developers/dotfiles/.aliases ~/.aliases

# Install zsh themes
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# Clone dotfiles repo
pushd ~/developers && git clone git@github.com:itsankoff/dotfiles.git popd

# Setup vim
pushd ~/developers/dotfiles/vim && ./install.sh && popd

# Setup github
ln -s ~/developers/dotfiles/.gitconfig ~/.gitconfig

# Reload zsh config
source ~/.zshrc

echo Done!

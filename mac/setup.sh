#!/bin/bash

# Setup development structure
DEV_HOME=~developers
mkdir $DEV_HOME

# Setup golang workspace structure
mkdir -p $DEV_HOME/workspace
mkdir -p $DEV_HOME/workspace/src
mkdir -p $DEV_HOME/workspace/pkg
mkdir -p $DEV_HOME/workspace/bin

# Install basic apps
brew cask install iterm2
brew cask install google-chrome
brew install wget
brew install curl
brew install htop
brew install git
brew install autoenv
brew install autojump
brew install go
brew install hg

# Postgres
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

# Enable zsh config
source ~/.zshrc

# Install golang
wget https://dl.google.com/go/go1.10.3.darwin-amd64.pkg
tar -C /usr/local -xzf /usr/local go1.10.3.darwin-amd64.pkg


# Clone dotfiles repo
pushd ~/developers && git clone git@github.com:itsankoff/dotfiles.git popd

# Setup vim
pushd ~/developers/dotfiles/vim && ./install.sh && popd

# Setup github
ln -s ~/developers/dotfiles/.gitconfig ~/.gitconfig

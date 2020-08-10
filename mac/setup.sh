#!/bin/bash

# NOTE:
# This file can work as stanalone installer for mac environment

function message {
    echo "$1"
}

function verify {
    message "$1? ($2/$3): "
    read PROMPT

    if [ $PROMPT == "$2" ]
    then
        message "Nicee!"
    fi

    if [ $PROMPT == "$3" ]
    then
        message "I am sorry, but I can't help with that..."
    fi
}

message "OK Let's setup this machine! I will take care..."
message "Go and make yourself a coffee or a tea!"
sleep 2

message "Setting up the environment..."

# Setup machine hostname
sudo scutil --set HostName molar

# Install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install basic apps
brew install git || message "Failed to install git"
brew install terraform || message "Failed to install terraform"
brew install wget || message "Failed to install wget"
brew install curl || message "Failed to install curl"
brew install htop || message "Failed to install htop"
brew install direnv || message "Failed to install direnv"
brew install autojump || message "Failed to install autojump"
brew install grip || message "Failed to install grip"
brew install node || message "Failed to install node"
brew install ansible || message "Failed to install ansible"
brew install python3 || message "Failed to install python3"
brew install vim || message "Failed to install vim"
brew install cmake || message "Failed to install cmake"
brew install ffmpeg || message "Failed to install ffmpeg"
brew install jq || message "Failed to install jq"
brew install kubectl || message "Failed to install kubectl"
brew install eksctl || message "Failed to install eksctl"
brew install k9s || message "Failed to install k9s"
brew install the_silver_searcher || message "Failed to install silver searcher"
pip3 install virtualenv || message "Failed to install virtualenv"
brew cask install iterm2 || message "Failed to install iterm2"
brew cask install the-unarchiver || message "Failed to install the-unarchiver"
brew cask install google-chrome || message "Failed to install Chrome"
brew cask install java || message "Failed to install java"
brew cask install docker || message "Failed to install docker"
brew cask install tunnelblick || message "Failed to install tunnelblick"
brew cask install ngrok || message "Failed to install ngrok"
brew cask install skype || message "Failed to install skype"
brew cask install slack || message "Failed to install slack"
brew cask install spotify || message "Failed to install spotify"
brew cask install visual-studio-code || message "Failed to install xcode"
sudo gem install cocoapods || message "Failed to install cocoapods"

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
sleep 10
initdb
brew services start postgres
createdb $USER

# Install fonts
mkdir -p /tmp/fonts
pushd /tmp/fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
popd

# Setup Oh my zsh
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
pushd developers && git clone https://github.com/powerline/fonts.git && pushd fonts && ./install.sh && popd && popd
mv ${USER_HOME}/.zshrc ${USER_HOME}/.zshrc.orig
ln -s ${USER_HOME}/developers/dotfiles/.zshrc ${USER_HOME}/.zshrc
ln -s ${USER_HOME}/developers/dotfiles/.aliases ${USER_HOME}/.aliases

# zsh-autosuggestions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Setup vim
pushd ${USER_HOME}/developers/dotfiles/vim && ./install.sh && popd

# Setup github
ln -s ${USER_HOME}/developers/dotfiles/.gitconfig ${USER_HOME}/.gitconfig

# Reload zsh config
source ${USER_HOME}/.zshrc


verify "Btw how was your coffee/tea" "good" "bad"
sleep 1

message "Anyway..."
sleep 1

message "Don't forget to uncheck keyboard shortcuts in Settings -> Keyboards -> Shortcuts -> Mission Control ^<- ^->"
sleep 2

message "Happy coding!"

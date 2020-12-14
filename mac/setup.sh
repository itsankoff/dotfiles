#!/bin/bash

# NOTE:
# This file can work as stand alone installer for mac environment.

# Always use the current working directory and add the SCRIPT_DIR path
# to produce an absolute SCRIPT_PATH. Maybe there is a easier way.
CURRENT_DIR=$(pwd)
SCRIPT_DIR="$(pwd)/$(dirname ${0})"

# SCRIPT_NAME holds the script name.
SCRIPT_NAME=$(basename ${0})

# CONFIG_DIR hold all the configurations.
CONFIG_DIR="${SCRIPT_DIR}/config"

# MANAGER_SETUP_LOCK controls the manager setup single execution.
MANAGER_SETUP_LOCK=".setup.ready"

# Coloring variables
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
white=`tput setaf 7`
reset_clr=`tput sgr0`
white_bg=`tput setaf 0 && tput setab 7`

# Here are all the supported package managers.
OSX_BREW="brew"

# PIP controls which pip to use for the python packages.
PIP="pip3"

GUI_ENV="gui"
TERMINAL_ENV="terminal"

# SETUP_ENV controls whether the script runs on terminal only or GUI environment.
# If you want to set the environment for terminal only change to ${TERMINAL_ENV}
SETUP_ENV=${GUI_ENV}

# source the utility library
source ${SCRIPT_DIR}/lib.sh

# execute os setup
setup_os

if [[ ${SETUP_OS} == ${OS_OSX} ]]
then
    # MANAGER controls the package manager for the setup script.
    MANAGER=${OSX_BREW}
fi


message "OK Let's setup this machine! I will take care..."
message "Go, make yourself a coffee or a tea!"
message "------------------------------------------------"

manager_setup
manager_update

message "Setting up the environment..."

# source the needed packages
source ./packages.sh

for pkg in "${terminal_packages[@]}"
do
    pkg_install ${pkg}
done

if [[ ${SETUP_ENV} == ${GUI_ENV} ]]
then
    for pkg in "${gui_packages[@]}"
    do
        pkg_install ${pkg} "gui"
    done
fi

for pkg in "${pip_packages[@]}"
do
    pip_install ${pkg}
done

for pkg in "${ruby_gems[@]}"
do
    gem_install ${pkg}
done

# setup_development sets up the development structure.
function setup_development() {
    message "Setting up development structure"

    if [[ ${SETUP_OS} == ${OS_OSX} ]]
    then
        HOME_PATH_PREFIX="/Users"
    elif [[ ${SETUP_OS} == ${OS_LINUX} ]]
    then
        HOME_PATH_PREFIX="/home"
    else
        HOME_PATH_PREFIX="/tmp"
    fi

    # setup development structure
    USER_HOME="${HOME_PATH_PREFIX}/${USER}"
    DEV_HOME="${USER_HOME}/developers"

    mkdir -p ${DEV_HOME}
}

# setup_zsh sets up Oh my zsh environment.
function setup_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    pushd ${DEV_HOME} && \
        git clone https://github.com/powerline/fonts.git || skip_error && \
        pushd fonts && \
            ./install.sh && \
        popd && \
    popd

    if [[ -e ${USER_HOME}/.zshrc ]]
    then
        verify "There is existing .zshrc for the ${USER}. Do you want to move it to ${USER_HOME}/.zshrc.backup" "y" "n" && \
            mv ${USER_HOME}/.zshrc ${USER_HOME}/.zshrc.backup

    fi
    ln -s ${CONFIG_DIR}/zshrc ${USER_HOME}/.zshrc

    if [[ -e ${USER_HOME}/.aliases ]]
    then
        verify "There is existing .aliases for the ${USER}. Do you want to move it to ${USER_HOME}/.aliases.backup" "y" "n" && \
            mv ${USER_HOME}/.aliases ${USER_HOME}/.aliases.backup
    fi
    ln -s ${CONFIG_DIR}/aliases ${USER_HOME}/.aliases

    # zsh-autosuggestions plugin
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-${USER_HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null 2>&1 || skip_error
}

# install_fonts install the fonts in case of gui environment.
function install_fonts() {
    if [[ ${SETUP_ENV} == ${GUI_ENV} ]]
    then
        mkdir -p /tmp/fonts
        pushd /tmp/fonts
        git clone https://github.com/powerline/fonts.git --depth=1
        cd fonts
        ./install.sh
        cd ..
        rm -rf fonts
        popd
    fi
}

# setup_golang sets up the golang environment.
function setup_golang() {
    # setup golang workspace structure
    mkdir -p ${DEV_HOME}/workspace
    mkdir -p ${DEV_HOME}/workspace/src
    mkdir -p ${DEV_HOME}/workspace/pkg
    mkdir -p ${DEV_HOME}/workspace/bin

    # injecting the go toochain into the PATH
    # FIXME: Proper setup of golang executables in OSX
    shell_inject 'export GOROOT=/usr/local/Cellar/go@1.13/1.13.15/libexec'
    shell_inject 'export PATH="$PATH:/usr/local/opt/go@1.13/bin"'

    # injecting the go environment
    shell_inject "export GOPATH=${DEV_HOME}/workspace"
    shell_inject 'export GOBIN=$GOPATH/bin'

    # injecting go bin to environment path
    shell_inject 'export PATH="$PATH:$GOBIN"'

    # Install goimports
    go get golang.org/x/tools/cmd/goimports
}

# setup_postgresql sets up the postgresql environment.
function setup_postgresql() {
    initdb
    run_service postgres
    createdb ${USER}
}

# setup_vim sets up the vim environment. For more information check the script
# content.
function setup_vim() {
    # Setup vim
    pushd ${SCRIPT_DIR}/../vim && ./install.sh && popd
}

# setup_git sets up the git config and aliases.
function setup_git() {
    if [[ -e ${USER_HOME}/.gitconfig ]]
    then
        verify "There is existing .gitconfig for the ${USER}. Do you want to move it to ${USER_HOME}/.gitconfig.backup" "y" "n" && \
            mv ${USER_HOME}/.gitconfig ${USER_HOME}/.giconfig.backup
    fi
    ln -s ${CONFIG_DIR}/gitconfig ${USER_HOME}/.gitconfig
}

is_pkg "setup_development" && setup_development
is_pkg "setup_zsh" && setup_zsh
is_pkg "setup_golang" && setup_golang
is_pkg "setup_postgresql" && setup_postgresql
is_pkg "install_fonts" && install_fonts
is_pkg "setup_vim" && setup_vim
is_pkg "setup_git" && setup_git

verify "Btw how was your coffee/tea" "good" "bad"
sleep 1

message "Anyway..."
sleep 1

if [[ ${SETUP_OS} == ${OS_OSX} ]]
then
    message "Don't forget to uncheck keyboard shortcuts in Settings -> Keyboards -> Shortcuts -> Mission Control ^<- ^->"
    sleep 2
fi

warn "Don't forget to source the new terminal environment"
code "source ${USER_HOME}/.zshrc"

message "Happy coding!"

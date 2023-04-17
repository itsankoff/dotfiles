#!/bin/bash

# This file can work as stand alone installer for mac environment.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# source the utility library
source ${SCRIPT_DIR}/../lib/lib.sh

SCRIPT_NAME=$(basename ${0})
CONFIG_DIR="${SCRIPT_DIR}/config"
GUI_ENV="gui"
TERMINAL_ENV="terminal"
DEV_HOME="~/developers"
SSH_DIR="~/.ssh"

# SETUP_ENV controls whether the script runs on terminal only or GUI environment.
# If you want to set the environment for terminal only change to ${TERMINAL_ENV}
SETUP_ENV=${GUI_ENV}

# help prints the help section of the script
function help() {
    plain "for full setup run: ${SCRIPT_NAME}"
    plain "${SCRIPT_NAME} [-p|--package <package>] [-h|--help]"
    exit 0
}

ALL_PACKAGES="all"
# is_pkg is used for conditional package installation. If the ${1} is the name
# of the package provided by the CLI args then return 0 (true)
# otherwise 1 (false).
# Example:
# 1. $> is_pkg direnv
# PACKAGE will be set to "direnv" and then is_pkg "direnv" will return 0 (true).
# NOTE: In case no package is provided by CLI or as environment variable then
# "all" is assumed which will allow all package installations and configuration.
function is_pkg() {
    if [[ "${PACKAGE}" == "${ALL_PACKAGES}" ]] || [[ "${PACKAGE}" == "${1}" ]]
    then
        return 0
    else
        return 1
    fi
}

# setup_dev_env sets up the development structure.
function setup_dev_env() {
    mkdir -p ${DEV_HOME} ${SSH_DIR}
}

# zsh_env sets up Oh my zsh environment.
function zsh_env() {
    if [[ -z $ZSH ]]
    then
        message "zshell installation is missing. Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        pushd ${DEV_HOME} && \
            git clone https://github.com/powerline/fonts.git || skip_error && \
            pushd fonts && \
                ./install.sh && \
            popd && \
        popd || exit 10

        # zsh-autosuggestions plugin
        message "installing zshell autosuggestion plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null 2>&1 || skip_error
    fi

    message "configuring zsh environment..."
    if [[ -f ${HOME}/.zshrc ]]
    then
        verify "there is existing .zshrc for the ${USER}. Do you want to move it to ${HOME}/.zshrc.backup" "y" "n" \
        && mv ${HOME}/.zshrc ${HOME}/.zshrc.backup
    fi
    ln -s ${CONFIG_DIR}/zshrc ${HOME}/.zshrc

    if [[ -f ${HOME}/.aliases ]]
    then
        verify "there is existing .aliases for the ${USER}. Do you want to move it to ${HOME}/.aliases.backup" "y" "n" \
        && mv ${HOME}/.aliases ${HOME}/.aliases.backup
    fi
    ln -s ${CONFIG_DIR}/aliases ${HOME}/.aliases
}

# fonts installs the fonts in case of gui environment.
function fonts() {
    if [[ "${SETUP_ENV}" == "${GUI_ENV}" ]]
    then
        ensure mkdir -p /tmp/fonts
        ensure pushd /tmp/fonts
            git clone https://github.com/powerline/fonts.git --depth=1
            ensure cd fonts
            ./install.sh
            cd ..
            rm -rf fonts
        ensure popd
    fi
}

# golang_env sets up the golang environment.
function golang_env() {
    # setup golang workspace structure
    mkdir -p ${DEV_HOME}/workspace
    mkdir -p ${DEV_HOME}/workspace/src
    mkdir -p ${DEV_HOME}/workspace/pkg
    mkdir -p ${DEV_HOME}/workspace/bin

    # injecting the go environment
    shell_inject "export GOPATH=${DEV_HOME}/workspace"
    shell_inject 'export GOBIN=$GOPATH/bin'
    shell_inject 'export PATH="$PATH:$GOBIN"'

    # Install goimports
    go get golang.org/x/tools/cmd/goimports
}

# postgresql_env sets up the postgresql environment.
function postgresql_env() {
    initdb
    run_service postgres
    createdb ${USER}
}

# vim_setup sets up the vim environment. For more information check the script
# content.
function vim_setup() {
    # Setup vim
    ensure pushd ${SCRIPT_DIR}/../vim
        ensure ./install.sh
    ensure popd
}

# git_setup sets up the git config and aliases.
function git_setup() {
    if [[ -e ${HOME}/.gitconfig ]]
    then
        verify "There is existing .gitconfig for the ${USER}. Do you want to move it to ${HOME}/.gitconfig.backup" "y" "n" && \
            mv ${HOME}/.gitconfig ${HOME}/.giconfig.backup
    fi
    ln -s ${CONFIG_DIR}/gitconfig ${HOME}/.gitconfig
}

# terminal_apps installs terminal and cli apps
function terminal_apps() {
    for pkg in "${terminal_packages[@]}"
    do
        local ready=$(pkg_install ${pkg} >> setup.log 2>&1)
        if [[ ${ready} -eq 0 ]]
        then
            message "${pkg} ready for use"
        else
            warn "failed to set up ${pkg}. For more information check logs"
        fi
    done
}

# gui_apps installs GUI packages and apps
function gui_apps() {
    if [[ "${SETUP_ENV}" == "${GUI_ENV}" ]]
    then
        for pkg in "${gui_packages[@]}"
        do
            local ready=$(pkg_install ${pkg} "gui" >> setup.log 2>&1)
            if [[ ${ready} -eq 0 ]]
            then
                message "${pkg} ready for use"
            else
                warn "failed to set up ${pkg}. for more information check logs"
            fi
        done
    else
        warn "skip installing gui apps"
    fi
}

# python_apps installs python related packages and apps
function python_apps() {
    for pkg in "${pip_packages[@]}"
    do
        pip_install "${pkg}"
    done
}

# ruby_apps installs ruby related packages and apps
function ruby_apps() {
    for pkg in "${ruby_gems[@]}"
    do
        gem_install "${pkg}"
    done
}

# source the needed packages
source ./packages.sh

# parse script arguments. Each of the arguments support long version. See below.
PACKAGE="${ALL_PACKAGES}"
if [[ $# -gt 0 ]]
then
    FLAGS="p:h-:"
    while getopts "${FLAGS}" FLAG; do
        case "${FLAG}" in
            p)
                PACKAGE=${OPTARG}
                ;;
            h)
                help
                ;;
            -)
                case ${OPTARG} in
                    package)
                        PACKAGE="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                        ;;
                    help)
                        help
                        ;;
                esac;;
            \?)
                ask_for_help
                exit 2
                ;;
        esac
    done
else
    export PACKAGE=${ALL_PACKAGES}
fi

message "OK Let's setup this machine! I will take care..."
message "Go, make yourself a coffee or a tea!"
plain   "------------------------------------------------"
message "Setting up the environment..."

is_pkg "dev_env" && setup_dev_env
is_pkg "terminal_apps" && terminal_apps
is_pkg "gui_apps" && gui_apps
is_pkg "python_apps" && python_apps
is_pkg "ruby_apps" && ruby_apps
is_pkg "zsh" && zsh_env
is_pkg "golang" && golang_env
is_pkg "postgresql" && postgresql_env
is_pkg "fonts" && fonts
is_pkg "vim" && vim_setup
is_pkg "git" && git_setup

warn "Don't forget to source the new terminal environment"
code "source ${HOME}/.zshrc"

message "Happy coding!"

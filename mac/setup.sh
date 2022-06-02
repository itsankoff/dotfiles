#!/bin/bash

# NOTE:
# This file can work as stand alone installer for mac environment.

# Always use the current working directory and add the SCRIPT_DIR path
# to produce an absolute SCRIPT_PATH. Maybe there is a easier way.
CURRENT_DIR=$(pwd)
SCRIPT_DIR="${CURRENT_DIR}/$(dirname ${0})"

# SCRIPT_NAME holds the script name.
export SCRIPT_NAME=""
SCRIPT_NAME=$(basename ${0})

# CONFIG_DIR hold all the configurations.
CONFIG_DIR="${SCRIPT_DIR}/config"

# MANAGER_SETUP_LOCK controls the manager setup single execution.
export MANAGER_SETUP_LOCK=".setup.ready"

GUI_ENV="gui"
#TERMINAL_ENV="terminal"

# SETUP_ENV controls whether the script runs on terminal only or GUI environment.
# If you want to set the environment for terminal only change to ${TERMINAL_ENV}
SETUP_ENV=${GUI_ENV}

# source the utility library
source ${SCRIPT_DIR}/lib.sh

# Print help section
function help {
    echo "${SCRIPT} [-p|--package <package>] [-h|--help]"
    exit 1
}

# setup_env sets up the development structure.
function setup_development_env() {
    mkdir -p ${DEV_HOME} ${SSH_DIR}
}

# setup_zsh sets up Oh my zsh environment.
function setup_zsh() {
    mkdir -p ~/.ssh

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
    fi

    message "Configuring zsh environment..."
    if [[ -f ${USER_HOME}/.zshrc ]]
    then
        verify "There is existing .zshrc for the ${USER}. Do you want to move it to ${USER_HOME}/.zshrc.backup" "y" "n" && \
            mv ${USER_HOME}/.zshrc ${USER_HOME}/.zshrc.backup
    fi
    ln -s ${CONFIG_DIR}/zshrc ${USER_HOME}/.zshrc

    if [[ -f ${USER_HOME}/.aliases ]]
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

# setup_golang sets up the golang environment.
function setup_golang() {
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
    ensure pushd ${SCRIPT_DIR}/../vim
        ensure ./install.sh
    ensure popd
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

# Install terminal packages and cli apps
function setup_terminal_apps() {
    manager_setup
    manager_update
    for pkg in "${terminal_packages[@]}"
    do
        ready=$(pkg_install ${pkg} >> setup.log 2>&1)
        if [[ ${ready} -eq 0 ]]
        then
            message "${pkg} ready for use"
        else
            warn "Failed to set up ${pkg}. For more information check logs"
        fi
    done
}

# Install gui packages and apps
function setup_gui_apps() {
    manager_setup
    manager_update
    if [[ "${SETUP_ENV}" == "${GUI_ENV}" ]]
    then
        for pkg in "${gui_packages[@]}"
        do
            ready=$(pkg_install ${pkg} "gui" >> setup.log 2>&1)
            if [[ ${ready} -eq 0 ]]
            then
                message "${pkg} ready for use"
            else
                warn "Failed to set up ${pkg}. For more information check logs"
            fi
        done
    fi
}

# Install pip packages
function setup_python_apps() {
    for pkg in "${pip_packages[@]}"
    do
        pip_install "${pkg}"
    done
}

# Install ruby packages
function setup_ruby_apps() {
    for pkg in "${ruby_gems[@]}"
    do
        gem_install "${pkg}"
    done
}

# execute os setup
setup_os

# execute env setup
setup_env

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
message "------------------------------------------------"
message "Setting up the environment..."

is_pkg "terminal_apps" && setup_terminal_apps
is_pkg "gui_apps" && setup_gui_apps
is_pkg "python_apps" && setup_python_apps
is_pkg "ruby_apps" && setup_ruby_apps
is_pkg "zsh" && setup_zsh
is_pkg "golang" && setup_golang
is_pkg "postgresql" && setup_postgresql
is_pkg "fonts" && install_fonts
is_pkg "vim" && setup_vim
is_pkg "git" && setup_git

warn "Don't forget to source the new terminal environment"
code "source ${USER_HOME}/.zshrc"

message "Happy coding!"

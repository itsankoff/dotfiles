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

# Set of supported values for SETUP_OS. Please always use these is os specific
# conditions.
OS_LINUX='linux'
OS_OSX='osx'
OS_WINDOWS='the-forbidden-land'
OS_BSD='the-unexplored-land'

# setup_os sets up SETUP_OS environment variable to one of the possible values
# (check above ^^)
# In case of unknown OS type it exists the script with code 6.
function setup_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        SETUP_OS=${OS_LINUX}
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        SETUP_OS=${OS_OSX}
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
        SETUP_OS=${OS_LINUX}
    elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        SETUP_OS=${OS_WINDOWS}
    elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
        SETUP_OS=${OS_WINDOWS}
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # The land of unexplored creatures and artifacts worth exloring
        SETUP_OS=${OS_BSD}
    else
        message "You are running a very uncommon environment :?"
        exit 6
    fi
}
setup_os

# Coloring variables
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
white=`tput setaf 7`
reset_clr=`tput sgr0`
white_bg=`tput setaf 0 && tput setab 7`


# Here are all the supported package managers.
OSX_BREW="brew"

GUI_ENV="gui"
TERMINAL_ENV="terminal"

# SETUP_ENV controls whether the script runs on terminal only or GUI environment.
# If you want to set the environment for terminal only change to ${TERMINAL_ENV}
SETUP_ENV=${GUI_ENV}

if [[ ${SETUP_OS} == ${OS_OSX} ]]
then
    # MANAGER controls the package manager for the setup script.
    MANAGER=${OSX_BREW}
fi

# PIP controls which pip to use for the python packages.
PIP="pip3"

# plain prints the given message in plain mode (using echo).
function plain() {
    echo "${1}"
}

# message prints formatted message.
function message() {
    echo "${white}${SCRIPT_NAME}: ${1}${reset_clr}"
}

# warn prints formatted warn message.
function warn() {
    echo "${yellow}${SCRIPT_NAME}: Warning ${1}${reset_clr}"
}

# error prints formatted error message and exists the script with return code 1.
function error() {
    echo "${red}${SCRIPT_NAME}: Error ${1}${reset_clr}"
    exit 1
}

# success prints formatted success message.
function success() {
    echo "${green}${SCRIPT_NAME}: ${1}"
}

# code prints the given message as code.
function code() {
    echo "${white_bg}${1}${reset_clr}"
}

# verify given action. If discarded then the script exits with 2.
function verify() {
    warn "${1}? (${2}/${3}): "
    read PROMPT

    if [ ${PROMPT} == ${2} ]
    then
        message "Nicee!"
    fi

    if [ ${PROMPT} == ${3} ]
    then
        warn "I am sorry, but I can't help with that..."
        return 1
    fi
}

# should is used for conditional action over packages. It compares
# the provided package name in ${1} and the CLI package names provided
# and process with the install or update action if there is a match.
# If match occurs then the function returns 0 (true), otherwise 1 (false).
# If no packages are provided by the CLI, 'all' is assumed which will allow
# all packages to proceed (always returns 0).
function should() {
    if [[ ${PACKAGE} == "all" ]] || [[ ${PACKAGE} == ${1} ]]
    then
        return 0
    else
        return 1
    fi
}

# skip_error returns always true and can be used for swallowing errors silently.
# Example: cmd_fail || skip_error
function skip_error() {
    return 0
}

# ensure stops the execution process if provided command failed with non-zero
# exit code.
function ensure() {
    "${@}";
    CODE=${?}
    if [ ${CODE} -ne 0 ]
    then
        message "Action ($*) failed with non-zero exit code (${CODE})."
        exit 1
    fi
}

# unsupported prints the {1} and interrupts the script with code 3.
function unsupported() {
    error "Unsupported ${1}"
    exit 3
}

# manager_setup sets up the package manager. It will be executed only per
# system. If needed to rerun delete the MANAGER_SETUP_LOCK file and re-run
# the script.
function manager_setup() {
    message "Setting up ${MANAGER}..."

    if [[ -f ${MANAGER_SETUP_LOCK} ]]
    then
        message "Mananger ${MANAGER} already setup on this system."
        return 0
    fi

    if [[ ${MANAGER} == ${OSX_BREW} ]]
    then
        # install brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    touch ${MANAGER_SETUP_LOCK}
}

# update the repos for the OS specific package manager specified in MANAGER.
function manager_update() {
    message "Updating package manager's sources..."

    if [[ ${MANAGER} == ${OSX_BREW} ]]
    then
        brew update 2>&1
        export HOMEBREW_NO_AUTO_UPDATE=1
    else
        error "Unsupported package manager ${MANAGER}. Please implement me!"
    fi
}

# is_installed performs a check if the package is already installed from the
# package manager.
function is_installed() {
    if [[ ${MANAGER} == ${OSX_BREW} ]]
    then
        is_gui_pkg=false
        if [[ ! -z ${2} ]]
        then
            is_gui_pkg=true
        fi

        installed_result=1
        if [[ ${is_gui_pkg} == true ]]
        then
            brew list --cask --versions ${1} > /dev/null 2>&1
            installed_result=${?}
        else
            brew list --versions ${1} > /dev/null 2>&1
            installed_result=${?}
        fi

        return ${installed_result}
    else
        unsupported "package manager"
    fi
}

# pkg_update attempts to update a package.
function pkg_update() {
    if [[ ${MANAGER} == ${OSX_BREW} ]]
    then
        message "Package ${1} is already installed. Trying to update..."

        is_gui_pkg=false
        if [[ ! -z ${2} ]]
        then
            is_gui_pkg=true
        fi

        # Prevent upgrade fail because the most recent version already installed.
        update_result=1
        update_output=""
        if [[ ${is_gui_pkg} == true ]]
        then
            update_output=$(brew upgrade --cask ${1} 2>&1)
            update_result=${?}
        else
            update_output=$(brew upgrade ${1} 2>&1)
            update_result=${?}
        fi

        if [[ ${update_result} -eq 0 ]]
        then
            message "${1} is up-to-date"
        else
            warn "Failed to upgrade ${1}: exit code ${update_result}!"
            error "${update_output}"
        fi
    else
        unsupported 'package manager'
    fi
}

# pkg_install attempts to install a package. It automatically attempts to
# update the package if already installed.
function pkg_install() {
    # TODO: consider using https://github.com/Homebrew/homebrew-bundle which can do it all and more
    message "Installing ${1}..."

    if is_installed ${@}
    then
        pkg_update ${@}
    else
        if [[ ${MANAGER} == ${OSX_BREW} ]]
        then
            is_gui_pkg=false
            if [[ ! -z ${2} ]]
            then
                is_gui_pkg=true
            fi

            pkg_output=''
            if [[ ${is_gui_pkg} == true ]]
            then
                brew install --cask ${1}
            else
                brew install ${1}
            fi
        fi
    fi
}

PACKAGE="all"
# is_pkg is used for conditional package installation. If the ${1} is the name
# of the package provided by the CLI args then return 0 (true)
# otherwise 1 (false).
# Example:
# 1. $> is_pkg direnv
# PACKAGE will be set to "direnv" and then is_pkg "direnv" will return 0 (true).
# NOTE: In case no package is provided by CLI or as environment variable then
# "all" is assumed which will allow all package installations and configuration.
function is_pkg() {
    if [[ ${PACKAGE} == "all" ]] || [[ ${PACKAGE} == ${1} ]]
    then
        return 0
    else
        return 1
    fi
}

# pip_install runs the configured pip environment to install the given package.
function pip_install() {
    message "Installing pip ${1}..."

    pip_output=$(${PIP} install ${1} 2>&1)
    plain ${pip_output}
}

# gem_install runs the configured gem.
function gem_install() {
    message "Installing ruby gem ${1}..."

    sudo gem install ${1}
}

# run_service runs a service.
function run_service() {
    if [[ ${SETUP_OS} == ${OS_OSX} ]]
    then
        brew services run ${1}
    elif [[ ${SETUP_OS} == ${OS_LINUX} ]]
    then
        service ${1} start
    else
        unsupported "service implementation"
    fi
}

# shell_inject injects the given statement into the configured default shell.
# Example: shell_inject "export GOPATH=/path/to/go/env"
function shell_inject() {
    # zshell hook setup
    SHELL_CONFIG=""
    if [[ ${SHELL} =~ "zsh" ]]
    then
        SHELL_CONFIG="${USER_HOME}/.zshrc"
    elif [[ ${SHELL} =~ "bash" ]]
    then
        SHELL_CONFIG="${USER_HOME}/.bashrc"
    else
        unsupported "shell environment"
    fi

    # check if the line already exists in the shell config
    # to prevent redundant configuration
    grep -R -n "${1}" ${SHELL_CONFIG} > /dev/null 2>&1 || \
        echo -e "# Configured by ${SCRIPT_NAME}" >> ${SHELL_CONFIG} && \
        (echo -e "${1}" >> ${SHELL_CONFIG} && code "Injecting ${1} into ${SHELL_CONFIG}")
        message "Re-sourcing the ${SHELL_CONFIG} to reflect the changes"
}

message "OK Let's setup this machine! I will take care..."
message "Go, make yourself a coffee or a tea!"
message "------------------------------------------------"

manager_setup
manager_update

message "Setting up the environment..."

# source the needed packages
source ./packages.sh

# for pkg in "${terminal_packages[@]}"
# do
#     pkg_install ${pkg}
# done
# 
# if [[ ${SETUP_ENV} == ${GUI_ENV} ]]
# then
#     for pkg in "${gui_packages[@]}"
#     do
#         pkg_install ${pkg} "gui"
#     done
# fi
# 
# for pkg in "${pip_packages[@]}"
# do
#     pip_install ${pkg}
# done
# 
# for pkg in "${ruby_gems[@]}"
# do
#     gem_install ${pkg}
# done

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
# is_pkg "setup_zsh" && setup_zsh
# is_pkg "setup_golang" && setup_golang
# is_pkg "setup_postgresql" && setup_postgresql
# is_pkg "install_fonts" && install_fonts
# is_pkg "setup_vim" && setup_vim
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

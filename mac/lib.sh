#!/bin/bash

# Set of supported values for SETUP_OS. Please always use these is os specific
# conditions.
OS_LINUX='linux'
OS_OSX='osx'
OS_WINDOWS='the-forbidden-land'
OS_BSD='the-unexplored-land'

# Package installers

# PIP controls which pip to use for the python packages.
PIP="pipx"

# Here are all the supported package managers.
BREW="brew"
APT="apt"

# Coloring variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)
reset_clr=$(tput sgr0)
white_bg=$(tput setaf 0 && tput setab 7)

# setup_os sets up SETUP_OS environment variable to one of the possible values
# (check above ^^)
# In case of unknown OS type it exists the script with code 6.
function setup_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]];
    then
        SETUP_OS=${OS_LINUX}
        MANAGER=${APT}
    elif [[ "$OSTYPE" == "darwin"* ]];
    then
        SETUP_OS=${OS_OSX}
        MANAGER=${BREW}
    elif [[ "$OSTYPE" == "cygwin" ]];
    then
        # POSIX compatibility layer and Linux environment emulation for Windows
        SETUP_OS=${OS_LINUX}
    elif [[ "$OSTYPE" == "msys" ]];
    then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        SETUP_OS=${OS_WINDOWS}
    elif [[ "$OSTYPE" == "win32" ]];
    then
        # I'm not sure this can happen.
        SETUP_OS=${OS_WINDOWS}
    elif [[ "$OSTYPE" == "freebsd"* ]];
    then
        # The land of unexplored creatures and artifacts worth exloring
        SETUP_OS=${OS_BSD}
    else
        message "You are running a very uncommon environment :?"
        exit 6
    fi
}

# setup_env sets up basic variables
function setup_env() {
    message "Setting up development structure"

    if [[ "${SETUP_OS}" == "${OS_OSX}" ]]
    then
        HOME_PATH_PREFIX="/Users"
    elif [[ "${SETUP_OS}" == "${OS_LINUX}" ]]
    then
        HOME_PATH_PREFIX="/home"
    else
        HOME_PATH_PREFIX="/tmp"
    fi

    # setup development structure
    USER_HOME="${HOME_PATH_PREFIX}/${USER}"
    DEV_HOME="${USER_HOME}/developers"
    SSH_DIR="${USER_HOME}/.ssh"
}

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
    echo "${yellow}${SCRIPT_NAME}(warning): ${1}${reset_clr}"
}

# error prints formatted error message and exists the script with return code 1.
function error() {
    echo "${red}${SCRIPT_NAME}(error): ${1}${reset_clr}"
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

# unsupported prints the {1} and interrupts the script with code 3.
function unsupported() {
    error "Unsupported ${1}"
    exit 3
}

# verify given action. If discarded then the script exits with 2.
function verify() {
    warn "${1}? (${2}/${3}): "
    read -r PROMPT

    if [ "${PROMPT}" == "${2}" ]
    then
        message "Nice!"
    fi

    if [ "${PROMPT}" == "${3}" ]
    then
        warn "I am sorry, but I can't help with that..."
        return 1
    fi
}

# should - is used for conditional action over packages. It compares
# the provided package name in ${1} and the CLI package names provided
# and install or update if there is a match.
# If match occurs then the function returns 0 (true), otherwise 1 (false).
# If no packages are provided by the CLI, 'all' is assumed which will allow
# all packages to proceed (always returns 0).
function should() {
    if [[ "${PACKAGE}" == "${ALL_PACKAGES}" ]] || [[ "${PACKAGE}" == "${1}" ]]
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
    if [ ${?} -ne 0 ]
    then
        message "Action ($*) failed with non-zero exit code (${CODE})."
        exit 1
    fi
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

    if [[ "${MANAGER}" == "${BREW}" ]]
    then
        ${MANAGER} --version > /dev/null 2>&1
        if [[ ${?} -eq 0 ]]
        then
            message "Package manager ${MANAGER} already installed. Trying to upgrade..."
            ${MANAGER} upgrade
        else
            message "Package manager ${MANAGER} is not installed. Trying to install..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            BREW_BIN='/opt/homebrew/bin'
            if [[ "${PATH}" == *"${BREW_BIN}"* ]];
            then
                message "BREW_BIN already in PATH"
            else
                export PATH="${PATH}:/opt/homebrew/bin"
                message "Setting up BREW_BIN in PATH only for script execution"
            fi
        fi
    fi

    touch "${MANAGER_SETUP_LOCK}"
}

# update the repos for the OS specific package manager specified in MANAGER.
function manager_update() {
    message "Updating package manager's sources..."

    if [[ "${MANAGER}" == "${BREW}" ]]
    then
        ${MANAGER} update 2>&1
        export HOMEBREW_NO_AUTO_UPDATE=1
    elif [[ "${MANAGER}" == "${APT}" ]]
    then
        ${MANAGER} update 2>&1
    else
        error "Unsupported package manager ${MANAGER}. Please implement me!"
    fi
}

# is_installed performs a check if the package is already installed from the
# package manager.
function is_installed() {
    if [[ "${MANAGER}" == "${BREW}" ]]
    then
        is_gui_pkg=false
        if [[ ! -z ${2} ]]
        then
            is_gui_pkg=true
        fi

        installed_result=1
        if [[ ${is_gui_pkg} == true ]]
        then
            brew list --cask --versions "${1}" > /dev/null 2>&1
            installed_result=${?}
        else
            brew list --versions "${1}" > /dev/null 2>&1
            installed_result=${?}
        fi

        return ${installed_result}
    elif [[ "${MANAGER}" == "${APT}" ]]
    then
        dpkg -l "${1}" > /dev/null 2>&1
        installed_result=${?}

        return ${installed_result}
    else
        unsupported "package manager"
    fi
}

# pkg_update attempts to update a package.
function pkg_update() {
    message "Package ${1} is already installed. Trying to update..."

    update_output=""
    update_result="-1"

    if [[ "${MANAGER}" == "${BREW}" ]]
    then
        is_gui_pkg=false
        if [[ ! -z ${2} ]]
        then
            is_gui_pkg=true
        fi

        # Prevent upgrade fail because the most recent version already installed.
        if [[ ${is_gui_pkg} == true ]]
        then
            update_output=$(brew upgrade --cask "${1}" 2>&1)
            update_result=${?}
        else
            update_output=$(brew upgrade "${1}" 2>&1)
            update_result=${?}
        fi
    elif [[ "${MANAGER}" == "${APT}" ]]
    then
        update_output=$(${MANAGER} install --only-upgrade "${1}" 2>&1)
        update_result=${?}
    else
        unsupported 'package manager'
    fi

    if [[ ${update_result} -eq 0 ]]
    then
        message "${1} is up-to-date"
    else
        warn "Failed to upgrade ${1}: exit code ${update_result}!"
        error "${update_output}"
    fi
}

# pkg_install attempts to install a package. It automatically attempts to
# update the package if already installed.
function pkg_install() {
    # TODO: consider using https://github.com/Homebrew/homebrew-bundle which can do it all and more
    message "Installing ${1}..."

    if is_installed "${@}"
    then
        pkg_update "${@}"
    else
        if [[ "${MANAGER}" == "${BREW}" ]]
        then
            is_gui_pkg=false
            if [[ ! -z ${2} ]]
            then
                is_gui_pkg=true
            fi

            if [[ ${is_gui_pkg} == true ]]
            then
                brew install --cask "${1}"
            else
                brew install "${1}"
            fi
        elif [[ "${MANAGER}" == "${APT}" ]]
        then
            ${MANAGER} install "${1}"
        fi
    fi
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

# pip_install runs the configured pip environment to install the given package.
function pip_install() {
    message "Installing pip ${1}..."

    pip_output=$(${PIP} install "${1}" 2>&1)
    plain "${pip_output}"
}

# gem_install runs the configured gem.
function gem_install() {
    message "Installing ruby gem ${1}..."

    sudo gem install "${1}"
}

# run_service runs a service.
function run_service() {
    if [[ "${SETUP_OS}" == "${OS_OSX}" ]]
    then
        brew services run "${1}"
    elif [[ "${SETUP_OS}" == "${OS_LINUX}" ]]
    then
        service "${1}" start
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
    grep -R -n "${1}" "${SHELL_CONFIG}" > /dev/null 2>&1 || \
        echo -e "# Configured by ${SCRIPT_NAME}" >> "${SHELL_CONFIG}" && \
        (echo -e "${1}" >> "${SHELL_CONFIG}" && code "Injecting ${1} into ${SHELL_CONFIG}")
        message "Re-sourcing the ${SHELL_CONFIG} to reflect the changes"
}

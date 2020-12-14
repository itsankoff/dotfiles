#!/bin/bash

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

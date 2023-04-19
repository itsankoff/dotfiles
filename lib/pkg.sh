#!/bin/bash


_pkg_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# imports
source ${_pkg_script_dir}/msg.sh
source ${_pkg_script_dir}/os.sh


_pkg_manager=${_pkg_manager:=unset}

_pkg_manager_setup_lock=".pkg-manager.lock"
_osx_pkg_manager="brew"
_linux_pkg_manager="apt"

# choose_manager chooses package manager based on the OS
function choose_manager() {
    if [[ ${SETUP_OS} == ${OS_OSX} ]]
    then
        _pkg_manager="${_osx_pkg_manager}"
    elif [[ ${SETUP_OS} == ${OS_LINUX} ]]
    then
        _pkg_manager="${_linux_pkg_manager}"
    else
        warn "unsupported os and package manager"
    fi
}

# setup_pkg_manager sets up the package manager.
# It will be executed only once per system. If needed to re-run the setup of the
# package manager, delete the MANAGER_SETUP_LOCK file and invoke the function
function setup_pkg_manager() {
    if [[ "${_pkg_manager}" == "unset" ]]
    then
        error "no package manager chosen"
        exit 1
    fi

    message "setting up ${_pkg_manager}..."
    if [[ -f "${_pkg_script_dir}/${_pkg_manager_setup_lock}" ]]
    then
        message "${_pkg_manager} already set up on this system."
        message "to re-run the setup, delete ${_pkg_script_dir}/${_pkg_manager_setup_lock} and run the function ${0} again"
        return 0
    fi

    if [[ "${_pkg_manager}" == "${_osx_pkg_manager}" ]]
    then
        ${_pkg_manager} --version > /dev/null 2>&1
        if [[ ${?} -eq 0 ]]
        then
            message "${_pkg_manager} already installed. trying to upgrade..."
            ${_pkg_manager} upgrade
        else
            message "${_pkg_manager} is not installed. trying to install..."
            ${SHELL} -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi

    touch "${_pkg_manager_setup_lock}"
}

# update_pkg_manager updates the repos for the OS specific package manager
function update_pkg_manager() {
    message "updating ${_pkg_manager} sources..."

    if [[ "${pkg_manager}" == "${_osx_pkg_manager}" ]]
    then
        ${pkg_manager} update 2>&1
        export HOMEBREW_NO_AUTO_UPDATE=1
    elif [[ "${pkg_manager}" == "${_linux_pkg_manager}" ]]
    then
        ${pkg_manager} update 2>&1
    else
        unsupported "update sources for ${_pkg_manager}"
    fi
}

# is_pkg_installed performs a check if the package is already installed
function is_pkg_installed() {
    local is_installed=1

    if [[ "${_pkg_manager}" == "${_osx_pkg_manager}" ]]
    then
        local is_gui_pkg=false
        if [[ ! -z ${2} ]]
        then
            is_gui_pkg=true
        fi

        if [[ ${is_gui_pkg} == true ]]
        then
            ${_pkg_manager} list --cask --versions "${1}" > /dev/null 2>&1
            is_installed=${?}
        else
            ${_pkg_manager} list --versions "${1}" > /dev/null 2>&1
            is_installed=${?}
        fi
    elif [[ "${_pkg_manager}" == "${_linux_pkg_manager}" ]]
    then
        ${_pkg_manager} -qq list ${1} 2>&1 | grep "installed" > /dev/null 2>&1
        is_installed=${?}
    else
        unsupported "package installed check"
    fi

    return ${is_installed}
}

# pkg_upgrade attempts to upgrade the given package
function pkg_upgrade() {
    local update_result=1
    local update_output=""

    if [[ "${_pkg_manager}" == "${_osx_pkg_manager}" ]]
    then
        message "package ${1} is already installed. trying to update..."

        local is_gui_pkg=false
        if [[ ! -z ${2} ]]
        then
            is_gui_pkg=true
        fi

        if [[ ${is_gui_pkg} == true ]]
        then
            upgrade_output=$(${_pkg_manager} upgrade --cask "${1}" 2>&1)
            upgrade_result=${?}
        else
            upgrade_output=$(${_pkg_manager} upgrade "${1}" 2>&1)
            upgrade_result=${?}
        fi
    elif [[ "${_pkg_manager}" == "${_linux_pkg_manager}" ]]
    then
        upgrade_output=$(${_pkg_manager} install --only-upgrade ${1})
        upgrade_result=${?}
    else
        unsupported "upgrade action for ${1}"
    fi

    # prevent upgrade to fail in case the most recent version is installed
    if [[ ${update_result} -eq 0 ]]
    then
        message "${1} is up-to-date"
    else
        warn "failed to upgrade ${1}: exit code ${update_result}!"
        error "${update_output}"
    fi
}

# pkg_install attempts to install a package. It automatically attempts to
# upgrade the package if already installed.
function pkg_install() {
    message "installing ${1}..."

    if [[ "${_pkg_manager}" == "${_osx_pkg_manager}" ]]
    then
        local is_gui_pkg=false
        if [[ ! -z ${2} ]]
        then
            is_gui_pkg=true
        fi

        if [[ ${is_gui_pkg} == true ]]
        then
            ${_pkg_manager} install --cask "${1}"
        else
            ${_pkg_manager} install "${1}"
        fi
    elif [[ "${_pkg_manager}" == "${_linux_pkg_manager}" ]]
    then
        ${_pkg_manager} install ${1}
    fi
}

# pip_install runs the configured pip environment to install the given package.
function pip_install() {
    message "installing pip ${1}..."
    pip3 install "${1}" 2>&1
}

# gem_install runs the configured gem.
function gem_install() {
    message "installing ruby gem ${1}..."
    gem install "${1}"
}

choose_manager
setup_pkg_manager

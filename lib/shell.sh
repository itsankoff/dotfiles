#!/bin/bash


_shell_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# imports
source ${_shell_script_dir}/msg.sh


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

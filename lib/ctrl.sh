#!/bin/bash


_control_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# imports
source ${_control_script_dir}/msg.sh


# must executes the given input command. If the command fails with non-zero
# code must exists the script with the resulted non-zero exit code
function ensure() {
    "${@}";
    if [ ${?} -ne 0 ]
    then
        message "Action ($*) failed with non-zero exit code (${CODE})."
        exit 1
    fi
}

# skip_error returns always true and can be used for swallowing errors silently.
# Example: cmd_fail || skip_error
function skip_error() {
    return 0
}

# unsupported prints the given input string and interrupts the script with code 3.
function unsupported() {
    error "Unsupported ${1}"
    exit 3
}

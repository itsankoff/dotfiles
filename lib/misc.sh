#!/bin/bash


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

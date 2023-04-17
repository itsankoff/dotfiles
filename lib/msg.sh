#!/bin/bash

# Coloring variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)
white_bg=$(tput setaf 0 && tput setab 7)
reset_clr=$(tput sgr0)

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

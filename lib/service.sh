#!/bin/bash

# start_service runs the service
function start_service() {
    if [[ "${SETUP_OS}" == "${OS_OSX}" ]]
    then
        brew services run "${1}"
    elif [[ "${SETUP_OS}" == "${OS_LINUx}" ]]
    then
        systemctl start "${1}"
    else
        unsupported "start service action"
    fi
}

# stop_service stops the service
function stop_service() {
    if [[ "${SETUP_OS}" == "${OS_OSX}" ]]
    then
        brew services stop "${1}"
    elif [[ "${SETUP_OS}" == "${OS_LINUx}" ]]
    then
        systemctl stop "${1}"
    else
        unsupported "stop service action"
    fi
}

# restart_service restarts the service
function restart_service() {
    if [[ "${SETUP_OS}" == "${OS_OSX}" ]]
    then
        brew services restart "${1}"
    elif [[ "${SETUP_OS}" == "${OS_LINUx}" ]]
    then
        systemctl restart "${1}"
    else
        unsupported "restart service action"
    fi
}

# enable_service sets the service to start on system startup
function enable_service() {
    if [[ "${SETUP_OS}" == "${OS_OSX}" ]]
    then
        message "service enable is not supported on ${OS_OSX}"
        return 0
    elif [[ "${SETUP_OS}" == "${OS_LINUX}" ]]
    then
        systemctl enable "${1}"
    else
        unsupported "enable service action"
    fi
}

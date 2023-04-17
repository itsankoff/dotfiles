#!/bin/bash


# Supported values for SETUP_OS variable. Please always use these for os
# specific conditions.
OS_LINUX='linux'
OS_OSX='osx'
OS_WINDOWS='the-forbidden-land'
OS_BSD='the-unexplored-land'
SETUP_OS=${SETUP_OS:=unset}

# setup_os sets up SETUP_OS environment variable to one of the possible values
# (check above ^^)
# In case of unknown OS type it exists the script with code 6.
function setup_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]];
    then
        SETUP_OS=${OS_LINUX}
    elif [[ "$OSTYPE" == "darwin"* ]];
    then
        SETUP_OS=${OS_OSX}
        MANAGER=${OSX_BREW}
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
        # The land of unexplored creatures and artifacts worth exploring
        SETUP_OS=${OS_BSD}
    else
        message "You are running a very uncommon environment :?"
        exit 6
    fi
}

# run the setup_os to set the SETUP_OS variable
setup_os

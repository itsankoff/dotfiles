#!/bin/bash

# sets the scripts dir
_lib_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# imports
# NOTE: Import order matters as some of the internal scripts use base functions
# from libs like message or control
source ${_lib_script_dir}/msg.sh
source ${_lib_script_dir}/ctrl.sh
source ${_lib_script_dir}/os.sh
source ${_lib_script_dir}/pkg.sh
source ${_lib_script_dir}/service.sh

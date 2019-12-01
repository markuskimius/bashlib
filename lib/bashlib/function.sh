##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::function::names() {
    bashlib::string regex=${1-}
    bashlib::string name

    for name in $(declare -F | awk '{ print $NF }'); do
        if [[ "$name" =~ $regex ]]; then
            echo "$name"
        fi
    done
}

function bashlib::function::__test__() {
    include "./exception.sh"

    function myfunction() { :; }

    [[ $(bashlib::function::names) == *myfunction* ]]     || bashlib::throw
    [[ $(bashlib::function::names) == *nosuchfunction* ]] && bashlib::throw

    echo "[PASS]"
}

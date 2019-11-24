##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::function::defined() {
    declare -F "$1" >& /dev/null
}

function bashlib::function::get() {
    declare -f "$1"
}

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

    bashlib::function::defined myfunction     || bashlib::die
    bashlib::function::defined nosuchfunction && bashlib::die
    [[ $(bashlib::function::names) == *myfunction* ]]     || bashlib::die
    [[ $(bashlib::function::names) == *nosuchfunction* ]] && bashlib::die
    [[ $(bashlib::function::get myfunction | wc -l) -gt 0 ]] || bashlib::die

    echo "[OK]"
}

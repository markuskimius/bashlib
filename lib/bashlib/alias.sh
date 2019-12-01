##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./exception.sh"

# Enable aliases in the script
shopt -s expand_aliases

function bashlib::alias::names() {
    (( $# == 0 || $# == 1 )) || bashlib::throw "Invalid argument count!"

    bashlib::string regex=${1-}
    bashlib::string name

    for name in $(alias | awk -F ' |=' '{ print $2 }'); do
        if [[ "$name" =~ $regex ]]; then
            echo "$name"
        fi
    done
}

function bashlib::alias::__test__() {
    alias myalias="ls -F"

    [[ $(bashlib::alias::names) == *myalias* ]]     || bashlib::throw
    [[ $(bashlib::alias::names) == *nosuchalias* ]] && bashlib::throw

    echo "[PASS]"
}


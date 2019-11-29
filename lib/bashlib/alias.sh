##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

# Enable aliases in the script
shopt -s expand_aliases

function bashlib::alias::defined() {
    alias "$1" &> /dev/null
}

function bashlib::alias::definition_of() {
    alias "$1"
}

function bashlib::alias::names() {
    bashlib::string regex=${1-}
    bashlib::string name

    for name in $(alias | awk -F ' |=' '{ print $2 }'); do
        if [[ "$name" =~ $regex ]]; then
            echo "$name"
        fi
    done
}

function bashlib::alias::__test__() {
    include "./exception.sh"

    alias myalias="ls -F"

    bashlib::alias::defined myalias     || bashlib::throw
    bashlib::alias::defined nosuchalias && bashlib::throw
    [[ $(bashlib::alias::names) == *myalias* ]]     || bashlib::throw
    [[ $(bashlib::alias::names) == *nosuchalias* ]] && bashlib::throw
    [[ $(bashlib::alias::definition_of myalias | wc -l) -gt 0 ]] || bashlib::throw

    echo "[PASS]"
}


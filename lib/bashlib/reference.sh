##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::reference::isreference() {
    bashlib::string decl=$(declare -p "$1" 2>/dev/null || echo "? ? ?" )

    decl=${decl#* }
    decl=${decl%% *}

    [[ "${decl}" == *n* ]]
}

function bashlib::reference::source() {
    bashlib::string name="$1"

    if bashlib::reference::isreference "$name"; then
        bashlib::string decl=$(declare -p "$1" || echo "? ? ?" )

        name=${decl#*\"}
        name=${name%\"}

        name=$(bashlib::reference::source "$name")
    fi

    echo "$name"
}


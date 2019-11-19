##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function reference::isreference() {
    string decl=( $(declare -p "$1" 2>/dev/null || echo "? ? ?" ) )

    [[ "${decl[1]}" == *n* ]]
}

function reference::underlyingof() {
    string name="$1"

    if reference::isreference "$name"; then
        string decl=( $(declare -p "$1" || echo "? ? ?" ) )

        name=${decl[2]#*=}
        name=${name#\"}
        name=${name%\"}

        name=$(reference::underlyingof $name)
    fi

    echo $name
}


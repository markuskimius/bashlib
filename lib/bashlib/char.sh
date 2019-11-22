##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function char::chr() {
    int ord=$1

    if (( "$ord" < 256 )); then
        echo -e "\\x$(printf "%02x" "$ord")"
    else
        echo -e "\\u$(printf "%04x" "$ord")"
    fi
}

function char::ord() {
    printf "%d" "'${1}"
}

function char::__test__() {
    include "./exception.sh"

    [[ $(char::ord 'A') == 65 ]] || die
    [[ $(char::chr 65) == 'A' ]] || die
    [[ $(char::ord ' ') == 32 ]] || die
    [[ $(char::chr 32) == ' ' ]] || die
    [[ $(char::ord $'\r') == 13 ]] || die
    [[ $(char::chr 13) == $'\r' ]] || die
    [[ $(char::ord $'\n') == 10 ]] || die
    # [[ $(char::chr 10) == $'\n' ]] || die     # BASH deletes newline

    echo "Done!"
}


##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::char::chr() {
    bashlib::int ord=$1
    bashlib::string buffer=""
    bashlib::reference __bashlib_output=${2-buffer}

    if (( "$ord" < 256 )); then
        printf -v __bashlib_output "\\x$(printf "%02x" "$ord")"
    else
        printf -v __bashlib_output "\\u$(printf "%04x" "$ord")"
    fi

    if (( $# < 2 )); then
        echo -en "$__bashlib_output"
    fi
}

function bashlib::char::ord() {
    printf "%d" "'${1}"
}

function bashlib::char::__test__() {
    include "./exception.sh"

    [[ $(bashlib::char::ord 'A') == 65 ]] || bashlib::throw
    [[ $(bashlib::char::chr 65) == 'A' ]] || bashlib::throw
    [[ $(bashlib::char::ord ' ') == 32 ]] || bashlib::throw
    [[ $(bashlib::char::chr 32) == ' ' ]] || bashlib::throw
    [[ $(bashlib::char::ord $'\r') == 13 ]] || bashlib::throw
    [[ $(bashlib::char::chr 13) == $'\r' ]] || bashlib::throw
    [[ $(bashlib::char::ord $'\n') == 10 ]] || bashlib::throw

    # BASH deletes newline returned by $() so it needs to be returned differently
    bashlib::char::chr 10 c && [[ "$c" == $'\n' ]] || bashlib::throw

    echo "[PASS]"
}


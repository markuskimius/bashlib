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
include "./int.sh"

function bashlib::chr() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    bashlib::isint "$1" || bashlib::throw "Argument must be integer -- '$1'"

    bashlib::int ord=$1
    bashlib::reference __bashlib_output=$2

    printf -v __bashlib_output "\\u$(printf "%04x" "$ord")"
}

function bashlib::ord() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    (( ${#1} == 1)) || bashlib::throw "Argument must be one character -- '$1'"

    printf "%d" "'${1}"
}

function bashlib::char::__test__() {
    bashlib::string c

    [[ $(bashlib::ord 'A') == 65 ]] || bashlib::throw
    [[ $(bashlib::ord ' ') == 32 ]] || bashlib::throw
    [[ $(bashlib::ord $'\r') == 13 ]] || bashlib::throw
    [[ $(bashlib::ord $'\n') == 10 ]] || bashlib::throw

    bashlib::chr 65 c && [[ "$c" == 'A' ]] || bashlib::throw
    bashlib::chr 32 c && [[ "$c" == ' ' ]] || bashlib::throw
    bashlib::chr 13 c && [[ "$c" == $'\r' ]] || bashlib::throw
    bashlib::chr 10 c && [[ "$c" == $'\n' ]] || bashlib::throw

    echo "[PASS]"
}


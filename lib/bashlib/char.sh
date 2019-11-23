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
    string buffer=""
    reference __bashlib_output=${2-buffer}

    if (( "$ord" < 256 )); then
        printf -v __bashlib_output "\\x$(printf "%02x" "$ord")"
    else
        printf -v __bashlib_output "\\u$(printf "%04x" "$ord")"
    fi

    if (( $# < 2 )); then
        echo -en "$__bashlib_output"
    fi
}

function char::ord() {
    printf "%d" "'${1}"
}

function char::__test__() {
    include "./exception.sh"
    include "./mode.sh"

    mode::strict

    [[ $(char::ord 'A') == 65 ]] || die
    [[ $(char::chr 65) == 'A' ]] || die
    [[ $(char::ord ' ') == 32 ]] || die
    [[ $(char::chr 32) == ' ' ]] || die
    [[ $(char::ord $'\r') == 13 ]] || die
    [[ $(char::chr 13) == $'\r' ]] || die
    [[ $(char::ord $'\n') == 10 ]] || die

    # BASH deletes newline returned by $() so it needs to be returned differently
    char::chr 10 c && [[ "$c" == $'\n' ]] || die

    echo "Done!"
}


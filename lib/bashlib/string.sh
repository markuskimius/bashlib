##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./char.sh"

function bashlib::string::isempty() {
    [[ -z "${1-}" ]]
}

function bashlib::string::isnonempty() {
    [[ -n "${1-}" ]]
}

function bashlib::string::encode() {
    bashlib::string value=$1
    bashlib::string buffer
    bashlib::reference __bashlib_output=${2-buffer}
    bashlib::string c
    bashlib::int i

    __bashlib_output=""

    for ((i=0; i < $(bashlib::string::length "$value"); i++)); do
        c=${value:$i:1}

        case "$c" in
            "\\") c='\\\\' ;;
            $'\t') c='\\t' ;;
            $'\r') c='\\r' ;;
            $'\n') c='\\n' ;;
            *)
                bashlib::int o=$(bashlib::char::ord "$c")

                if (( o < 0x20 || o == 0x7f )); then
                    c=$(printf "\\\\x%02x" "$o")
                fi
                ;;
        esac

        __bashlib_output+="$c"
    done

    if (( $# < 2 )); then
        echo -en "$__bashlib_output"
    fi
}

function bashlib::string::decode() {
    bashlib::string value=$1
    bashlib::string buffer
    bashlib::reference __bashlib_output=${2-buffer}

    printf -v __bashlib_output "%b" "$value"

    if (( $# < 2 )); then
        echo -en "$__bashlib_output"
    fi
}

function bashlib::string::length() {
    echo "${#1}"
}

function bashlib::string::tolower() {
    echo "${1,,}"
}

function bashlib::string::toupper() {
    echo "${1^^}"
}

function bashlib::string::replacefirst() {
    echo "${1/$2/$3}"
}

function bashlib::string::replaceall() {
    echo "${1//$2/$3}"
}

function bashlib::string::substr() {
    echo "${1:$2:$3}"
}

function bashlib::string::split() {
    bashlib::string __bashlib_string=$1
    bashlib::string IFS="$2"
    bashlib::reference __bashlib_array=$3

    read -ra __bashlib_array <<< "$__bashlib_string"
}

function bashlib::string::join() {
    bashlib::string IFS="$1" && shift

    echo "$*"
}

function bashlib::string::__test__() {
    include "./exception.sh"

    bashlib::string mystring="Hello, world!"
    bashlib::string evilstring=$'$Hello, \n"world\\!'
    bashlib::string emptystring=""

    bashlib::string::isempty $mystring    && bashlib::throw
    bashlib::string::isempty $emptystring || bashlib::throw
    bashlib::string::isnonempty $mystring    || bashlib::throw
    bashlib::string::isnonempty $emptystring && bashlib::throw

    [[ "$(bashlib::string::encode "$evilstring")" == '$Hello, \n"world\\!' ]]  || bashlib::throw
    [[ "$(bashlib::string::decode "$(bashlib::string::encode "$evilstring")")" == "$evilstring" ]] || bashlib::throw

    [[ $(bashlib::string::length "$mystring") -eq 13 ]] || bashlib::throw
    [[ $(bashlib::string::length "$emptystring") -eq 0 ]] || bashlib::throw

    [[ $(bashlib::string::tolower "$mystring") == "hello, world!" ]] || bashlib::throw
    [[ $(bashlib::string::toupper "$mystring") == "HELLO, WORLD!" ]] || bashlib::throw
    [[ $(bashlib::string::tolower "$emptystring") == "" ]] || bashlib::throw
    [[ $(bashlib::string::toupper "$emptystring") == "" ]] || bashlib::throw

    [[ $(bashlib::string::replacefirst "$mystring" l L)       == "HeLlo, world!" ]] || bashlib::throw
    [[ $(bashlib::string::replaceall   "$mystring" l L)       == "HeLLo, worLd!" ]] || bashlib::throw
    [[ $(bashlib::string::replacefirst "$mystring" world Joe) == "Hello, Joe!"   ]] || bashlib::throw
    [[ $(bashlib::string::replaceall   "$mystring" world Joe) == "Hello, Joe!"   ]] || bashlib::throw
    [[ $(bashlib::string::replacefirst "$mystring" x X)       == "Hello, world!" ]] || bashlib::throw
    [[ $(bashlib::string::replaceall   "$mystring" x X)       == "Hello, world!" ]] || bashlib::throw
    [[ $(bashlib::string::replacefirst "$mystring" ", " --)   == "Hello--world!" ]] || bashlib::throw
    [[ $(bashlib::string::replaceall   "$mystring" ", " --)   == "Hello--world!" ]] || bashlib::throw
    [[ $(bashlib::string::replacefirst "$mystring" ? !)       == "!ello, world!" ]] || bashlib::throw
    [[ $(bashlib::string::replaceall   "$mystring" ? !)       == "!!!!!!!!!!!!!" ]] || bashlib::throw

    [[ $(bashlib::string::substr "$mystring" 0 99 ) == "Hello, world!" ]] || bashlib::throw
    [[ $(bashlib::string::substr "$mystring" 0  3 ) == "Hel" ]] || bashlib::throw
    [[ $(bashlib::string::substr "$mystring" 10 3 ) == "ld!" ]] || bashlib::throw

    bashlib::array myarray
    bashlib::string::split "$mystring" "," myarray
    [[ "${myarray[0]}" == "Hello" ]] || bashlib::throw
    [[ "${myarray[1]}" == " world!" ]] || bashlib::throw
    [[ $(bashlib::string::join "," "${myarray[@]}") == "$mystring" ]] || bashlib::throw

    echo "[PASS]"
}


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
include "./int.sh"

function bashlib::length() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    echo ${#1}
}

function bashlib::tolower() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    echo "${1,,}"
}

function bashlib::toupper() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    echo "${1^^}"
}

function bashlib::replacefirst() {
    (( $# == 3 )) || bashlib::throw "Invalid argument count!"

    echo "${1/$2/$3}"
}

function bashlib::replaceall() {
    (( $# == 3 )) || bashlib::throw "Invalid argument count!"

    echo "${1//$2/$3}"
}

function bashlib::substr() {
    (( $# == 3 )) || bashlib::throw "Invalid argument count!"

    echo "${1:$2:$3}"
}

function bashlib::split() {
    (( $# == 3 )) || bashlib::throw "Invalid argument count!"

    bashlib::string __bashlib_string=$1
    bashlib::string IFS="$2"
    bashlib::reference __bashlib_array=$3

    read -ra __bashlib_array <<< "$__bashlib_string"
}

function bashlib::join() {
    (( $# >= 1 )) || bashlib::throw "Invalid argument count!"

    bashlib::string IFS="$1" && shift

    echo "$*"
}

function bashlib::encode() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    bashlib::string value=$1
    bashlib::string buffer
    bashlib::reference __bashlib_output=${2-buffer}
    bashlib::string c
    bashlib::int i

    __bashlib_output=""

    for ((i=0; i < $(bashlib::length "$value"); i++)); do
        c=${value:$i:1}

        case "$c" in
            "\\") c='\\\\' ;;
            $'\t') c='\\t' ;;
            $'\r') c='\\r' ;;
            $'\n') c='\\n' ;;
            *)
                bashlib::int o=$(bashlib::ord "$c")

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

function bashlib::decode() {
    (( $# == 1 || $# == 2 )) || bashlib::throw "Invalid argument count!"

    bashlib::string value=$1
    bashlib::string buffer
    bashlib::reference __bashlib_output=${2-buffer}

    printf -v __bashlib_output "%b" "$value"

    if (( $# == 1 )); then
        echo -en "$__bashlib_output"
    fi
}

function bashlib::string::__test__() {
    include "./exception.sh"

    bashlib::string mystring="Hello, world!"
    bashlib::string evilstring=$'$Hello, \n"world\\!'
    bashlib::string emptystring=""

    [[ "$(bashlib::encode "$evilstring")" == '$Hello, \n"world\\!' ]]  || bashlib::throw
    [[ "$(bashlib::decode "$(bashlib::encode "$evilstring")")" == "$evilstring" ]] || bashlib::throw

    [[ $(bashlib::length "$mystring") -eq 13 ]] || bashlib::throw
    [[ $(bashlib::length "$emptystring") -eq 0 ]] || bashlib::throw

    [[ $(bashlib::tolower "$mystring") == "hello, world!" ]] || bashlib::throw
    [[ $(bashlib::toupper "$mystring") == "HELLO, WORLD!" ]] || bashlib::throw
    [[ $(bashlib::tolower "$emptystring") == "" ]] || bashlib::throw
    [[ $(bashlib::toupper "$emptystring") == "" ]] || bashlib::throw

    [[ $(bashlib::replacefirst "$mystring" l L)       == "HeLlo, world!" ]] || bashlib::throw
    [[ $(bashlib::replaceall   "$mystring" l L)       == "HeLLo, worLd!" ]] || bashlib::throw
    [[ $(bashlib::replacefirst "$mystring" world Joe) == "Hello, Joe!"   ]] || bashlib::throw
    [[ $(bashlib::replaceall   "$mystring" world Joe) == "Hello, Joe!"   ]] || bashlib::throw
    [[ $(bashlib::replacefirst "$mystring" x X)       == "Hello, world!" ]] || bashlib::throw
    [[ $(bashlib::replaceall   "$mystring" x X)       == "Hello, world!" ]] || bashlib::throw
    [[ $(bashlib::replacefirst "$mystring" ", " --)   == "Hello--world!" ]] || bashlib::throw
    [[ $(bashlib::replaceall   "$mystring" ", " --)   == "Hello--world!" ]] || bashlib::throw
    [[ $(bashlib::replacefirst "$mystring" "?" "!")   == "!ello, world!" ]] || bashlib::throw
    [[ $(bashlib::replaceall   "$mystring" "?" "!")   == "!!!!!!!!!!!!!" ]] || bashlib::throw

    [[ $(bashlib::substr "$mystring" 0 99 ) == "Hello, world!" ]] || bashlib::throw
    [[ $(bashlib::substr "$mystring" 0  3 ) == "Hel" ]] || bashlib::throw
    [[ $(bashlib::substr "$mystring" 10 3 ) == "ld!" ]] || bashlib::throw

    bashlib::array myarray
    bashlib::split "$mystring" "," myarray
    [[ "${myarray[0]}" == "Hello" ]] || bashlib::throw
    [[ "${myarray[1]}" == " world!" ]] || bashlib::throw
    [[ $(bashlib::join "," "${myarray[@]}") == "$mystring" ]] || bashlib::throw

    echo "[PASS]"
}


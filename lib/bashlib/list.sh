##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./string.sh"

function bashlib::list::encode() {
    bashlib::string encoded=$(bashlib::string::encode "$1")

    encoded="${encoded// /\\x20}"

    if [[ "$encoded" == *\"* ]]; then
        encoded="\"$encoded\""
    fi

    echo "$encoded"
}

function bashlib::list::decode() {
    bashlib::string decoded=$(bashlib::string::decode "$1")

    if [[ "$decoded" == \"*\" ]]; then
        decoded=${decoded#\"}
        decoded=${decoded%\"}
    fi

    echo "$decoded"
}

function bashlib::list() {
    bashlib::string list=""

    bashlib::lappend list "$@"
}

function bashlib::llength() {
    bashlib::reference __bashlib_list=$1
    bashlib::array array=( $__bashlib_list )

    echo ${#array[@]}
}

function bashlib::lappend() {
    bashlib::reference __bashlib_list=$1 && shift
    bashlib::string item

    for item in "$@"; do
        if [[ -n $__bashlib_list ]]; then
            __bashlib_list+=" "
        fi

        __bashlib_list+=$(bashlib::list::encode "$item")
    done

    echo "$__bashlib_list"
}

function bashlib::lindex() {
    bashlib::reference __bashlib_list=$1
    bashlib::int index=$2
    bashlib::array array=( $__bashlib_list )

    echo "$(bashlib::list::decode "${array[$index]}")"
}

function bashlib::lsearch() {
    bashlib::reference __bashlib_list=$1
    bashlib::string item=$2
    bashlib::array array=( $__bashlib_list )
    bashlib::int index=-1
    bashlib::int i

    for ((i=0; i < ${#array[@]}; i++)); do
        bashlib::string decoded=$(bashlib::list::decode "${array[$i]}")

        if [[ "$decoded" == "$item" ]]; then
            index=i
            break
        fi
    done

    echo $index
}

function bashlib::list::__test__() {
    include "./exception.sh"

    bashlib::string mylist=$(bashlib::list "alpha alpha" "\"bravo bravo\"" $'charlie\ncharlie')
    bashlib::string emptylist=$(bashlib::list)

    [[ $(bashlib::lindex mylist 0) == "alpha alpha" ]]       || bashlib::throw
    [[ $(bashlib::lindex mylist 1) == "\"bravo bravo\"" ]]   || bashlib::throw
    [[ $(bashlib::lindex mylist 2) == $'charlie\ncharlie' ]] || bashlib::throw
    [[ $(bashlib::lsearch mylist "nosuchitem") -eq -1 ]]       || bashlib::throw
    [[ $(bashlib::lsearch mylist "alpha alpha") -eq 0 ]]       || bashlib::throw
    [[ $(bashlib::lsearch mylist "\"bravo bravo\"") -eq 1 ]]   || bashlib::throw
    [[ $(bashlib::lsearch mylist $'charlie\ncharlie') -eq 2 ]] || bashlib::throw
    [[ $(bashlib::llength mylist) -eq 3 ]] || bashlib::throw

    [[ $(bashlib::llength emptylist) -eq 0 ]] || bashlib::throw
    [[ $(bashlib::lsearch emptylist "nosuchitem") -eq -1 ]] || bashlib::throw

    echo "[PASS]"
}

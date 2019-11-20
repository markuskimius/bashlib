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
include "./inspect.sh"
include "./reference.sh"

function array::exists() {
    [[ $(typeof "$1") == "array" ]]
}

function array::isset() {
    string varname=$(reference::underlying "$1")

    array::exists "$varname" && [[ $(declare -p "$varname") == *=* ]]
}

function array::isempty() {
    [[ $(array::length "$1") -eq 0 ]]
}

function array::isnonempty() {
    [[ $(array::length "$1") -gt 0 ]]
}

function array::length() {
    reference __bashlib_array=$1

    if array::isset __bashlib_array; then
        echo "${#__bashlib_array[@]}"
    else
        echo 0
    fi
}

function array::push() {
    reference __bashlib_array=$1
    string __bashlib_value=$2

    __bashlib_array+=( "$__bashlib_value" )
}

function array::pop() {
    reference __bashlib_array=$1

    unset __bashlib_array[-1]
}

function array::shift() {
    reference __bashlib_array=$1

    __bashlib_array=("${__bashlib_array[@]:1}")
}

function array::unshift() {
    reference __bashlib_array=$1
    string __bashlib_value=$2

    __bashlib_array=( "$__bashlib_value" "${__bashlib_array[@]}" )
}

function array::insert() {
    reference __bashlib_array=$1
    int __bashlib_index=$2
    string __bashlib_value=$3

    __bashlib_array=(
        "${__bashlib_array[@]::$__bashlib_index}"
        "$__bashlib_value"
        "${__bashlib_array[@]:$__bashlib_index}"
    )
}

function array::delete() {
    reference __bashlib_array=$1
    int __bashlib_index=$2
    int __bashlib_count=${3-1}
    int __bashlib_index_plus=$((__bashlib_index+__bashlib_count))

    __bashlib_array=(
        "${__bashlib_array[@]::$__bashlib_index}"
        "${__bashlib_array[@]:$__bashlib_index_plus}"
    )
}

function array::clear() {
    reference __bashlib_array=$1

    __bashlib_array=()
}

function array::front() {
    reference __bashlib_array=$1

    echo "${__bashlib_array[0]}"
}

function array::back() {
    reference __bashlib_array="$1"

    echo "${__bashlib_array[-1]}"
}

function array::get() {
    reference __bashlib_array="$1"
    int __bashlib_index="$2"

    echo "${__bashlib_array[$__bashlib_index]}"
}

function array::indexof() {
    reference __bashlib_array="$1"
    string __bashlib_value="$2"
    int index=-1
    int i

    for i in ${!__bashlib_array[@]}; do
        if [[ "$__bashlib_value" == "${__bashlib_array[$i]}" ]]; then
            index=$i
            break
        fi
    done

    echo $index
}

function array::dump() {
    reference __bashlib_array="$1"
    int i

    echo "$1 = ("
    for i in "${!__bashlib_array[@]}"; do
        string escaped_value=$(string::escape "${__bashlib_array[$i]}")

        echo "  [$i] = \"${escaped_value}\""
    done
    echo ")"
}

function array::__test__() {
    include "./exception.sh"
    include "./mode.sh"

    mode::strict

    # ( charlie delta echo )
    array myarray=( "charlie" "delta" "echo" )
    [[ $(array::length myarray) -eq 3 ]]       || die
    [[ $(array::front myarray) == "charlie" ]] || die
    [[ $(array::back myarray) == "echo" ]]     || die

    # ( delta echo )
    array::shift myarray
    [[ $(array::length myarray) -eq 2 ]]     || die
    [[ $(array::front myarray) == "delta" ]] || die
    [[ $(array::back myarray) == "echo" ]]   || die

    # ( delta echo foxtrot )
    array::push myarray "foxtrot"
    [[ $(array::length myarray) -eq 3 ]]      || die
    [[ $(array::front myarray) == "delta" ]]  || die
    [[ $(array::back myarray) == "foxtrot" ]] || die

    # ( bravo delta echo foxtrot )
    array::unshift myarray "bravo"
    [[ $(array::length myarray) -eq 4 ]]      || die
    [[ $(array::front myarray) == "bravo" ]]  || die
    [[ $(array::back myarray) == "foxtrot" ]] || die

    # ( bravo charlie delta echo foxtrot )
    array::insert myarray 1 "charlie"
    [[ $(array::length myarray) -eq 5 ]]       || die
    [[ $(array::front myarray) == "bravo" ]]   || die
    [[ $(array::back myarray) == "foxtrot" ]]  || die
    [[ $(array::get myarray 0) == "bravo" ]]   || die
    [[ $(array::get myarray 1) == "charlie" ]] || die
    [[ $(array::get myarray 2) == "delta" ]]   || die

    # ( alpha bravo charlie delta echo foxtrot )
    array::insert myarray 0 "alpha"
    [[ $(array::length myarray) -eq 6 ]]      || die
    [[ $(array::front myarray) == "alpha" ]]  || die
    [[ $(array::back myarray) == "foxtrot" ]] || die
    [[ $(array::get myarray 0) == "alpha" ]]  || die
    [[ $(array::get myarray 1) == "bravo" ]]  || die

    # ( alpha bravo charlie delta echo foxtrot golf )
    array::insert myarray 6 "golf"
    [[ $(array::length myarray) -eq 7 ]]       || die
    [[ $(array::front myarray) == "alpha" ]]   || die
    [[ $(array::back myarray) == "golf" ]]     || die
    [[ $(array::get myarray 5) == "foxtrot" ]] || die
    [[ $(array::get myarray 6) == "golf" ]]    || die

    # ( alpha bravo charlie echo foxtrot golf )
    array::delete myarray 3
    [[ $(array::length myarray) -eq 6 ]]       || die
    [[ $(array::front myarray) == "alpha" ]]   || die
    [[ $(array::back myarray) == "golf" ]]     || die
    [[ $(array::get myarray 2) == "charlie" ]] || die
    [[ $(array::get myarray 3) == "echo" ]]    || die

    # ( bravo charlie echo foxtrot golf )
    array::delete myarray 0
    [[ $(array::length myarray) -eq 5 ]]       || die
    [[ $(array::front myarray) == "bravo" ]]   || die
    [[ $(array::back myarray) == "golf" ]]     || die

    # ( bravo charlie echo foxtrot )
    array::delete myarray 4
    [[ $(array::length myarray) -eq 4 ]]       || die
    [[ $(array::front myarray) == "bravo" ]]   || die
    [[ $(array::back myarray) == "foxtrot" ]]  || die

    [[ $(array::get myarray 0) == "bravo" ]]   || die
    [[ $(array::get myarray 1) == "charlie" ]] || die
    [[ $(array::get myarray 3) == "foxtrot" ]] || die

    [[ $(array::indexof myarray "bravo") == 0 ]]   || die
    [[ $(array::indexof myarray "charlie") == 1 ]] || die
    [[ $(array::indexof myarray "foxtrot") == 3 ]] || die

    array::dump myarray

    array emptyarray=()
    array unsetarray

    array::exists myarray     || die
    array::exists emptyarray  || die
    array::exists unsetarray  || die
    array::exists nosucharray && die

    array::isset myarray     || die
    array::isset emptyarray  || die
    array::isset unsetarray  && die
    array::isset nosucharray && die

    array::isempty myarray     && die
    array::isempty emptyarray  || die
    array::isempty unsetarray  || die

    array::isnonempty myarray     || die
    array::isnonempty emptyarray  && die
    array::isnonempty unsetarray  && die

    array::clear myarray
    array::isempty myarray || die

    echo "Done!"
}


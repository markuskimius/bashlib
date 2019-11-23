##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./reference.sh"

function bashlib::defined() {
    declare -p "$1" >& /dev/null || return 1
}

function bashlib::typeof() {
    bashlib::string __bashlib_declare=$(bashlib::defined "$1" && declare -p "$1" || echo "? ? ?" )
    bashlib::string __bashlib_type="string"

    __bashlib_declare=${__bashlib_declare#* }
    __bashlib_declare=${__bashlib_declare%% *}

    case "$__bashlib_declare" in
        *a*)    __bashlib_type="array"     ;;
        *A*)    __bashlib_type="hashmap"   ;;
        *f*)    __bashlib_type="function"  ;;
        *n*)    __bashlib_type=$(bashlib::typeof "$(bashlib::reference::source "$1")") ;;
        \?)     __bashlib_type="undefined" ;;
        *i*)    __bashlib_type="int"       ;;
        *)      __bashlib_type="string"    ;;
    esac

    echo "$__bashlib_type"
}

function bashlib::inspect::__test__() {
    include "./exception.sh"
    include "./mode.sh"

    bashlib::mode::strict

    bashlib::int myint=13
    bashlib::string mystring="Hello, world!"
    bashlib::const myconst="Hi there!"
    bashlib::array myarray=( alpha bravo charlie )
    bashlib::hashmap myhashmap=( [first]=one [second]=two [third]=4 )
    bashlib::reference myreference=myarray

    [[ "$myint" -eq 13 ]]                 || bashlib::die
    [[ "$mystring" == "Hello, world!" ]]  || bashlib::die
    [[ "$myconst" == "Hi there!" ]]       || bashlib::die
    [[ "${myarray[1]}" == "bravo" ]]      || bashlib::die
    [[ "${myhashmap[second]}" == "two" ]] || bashlib::die
    myreference+=( "delta" )
    [[ "${myarray[3]}" == "delta" ]]      || bashlib::die

    [[ $(bashlib::typeof myint) == "int" ]]           || bashlib::die
    [[ $(bashlib::typeof mystring) == "string" ]]     || bashlib::die
    [[ $(bashlib::typeof myconst) == "string" ]]      || bashlib::die
    [[ $(bashlib::typeof myarray) == "array" ]]       || bashlib::die
    [[ $(bashlib::typeof myhashmap) == "hashmap" ]]   || bashlib::die
    [[ $(bashlib::typeof myreference) == "array" ]]   || bashlib::die
    [[ $(bashlib::typeof mynothing) == "undefined" ]] || bashlib::die

    echo "Done!"
}


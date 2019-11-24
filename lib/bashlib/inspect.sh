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
    [[ $(bashlib::typeof "$1") != "undefined" ]]
}

function bashlib::typeof() {
    bashlib::string __bashlib_declare=$(declare -p "$1" 2>/dev/null || echo "? ? ?")
    bashlib::string __bashlib_function=$(declare -F "$1" 2>/dev/null || echo "")
    bashlib::string __bashlib_alias=$(alias declare "$1" 2>/dev/null || echo "")
    bashlib::string __bashlib_type="string"

    __bashlib_declare=${__bashlib_declare#* }
    __bashlib_declare=${__bashlib_declare%% *}

    case "$__bashlib_declare" in
        *a*)    __bashlib_type="array"     ;;
        *A*)    __bashlib_type="hashmap"   ;;
        *i*)    __bashlib_type="int"       ;;
        *n*)    __bashlib_type=$(bashlib::typeof "$(bashlib::reference::source "$1")")
                ;;
        \?)     if [[ -n "$__bashlib_alias" ]]; then
                    __bashlib_type="alias"
                elif [[ -n "$__bashlib_function" ]]; then
                    __bashlib_type="function"
                else
                    __bashlib_type="undefined"
                fi
                ;;
        *)      __bashlib_type="string"
                ;;
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
    alias myalias=':'
    function myfunction() { :; }

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
    [[ $(bashlib::typeof myalias) == "alias" ]]       || bashlib::die
    [[ $(bashlib::typeof myfunction) == "function" ]] || bashlib::die

    bashlib::defined myint       || bashlib::die
    bashlib::defined mystring    || bashlib::die
    bashlib::defined myconst     || bashlib::die
    bashlib::defined myarray     || bashlib::die
    bashlib::defined myhashmap   || bashlib::die
    bashlib::defined myreference || bashlib::die
    bashlib::defined mynothing   && bashlib::die
    bashlib::defined myfunction  || bashlib::die
    bashlib::defined myalias     || bashlib::die

    echo "[PASS]"
}


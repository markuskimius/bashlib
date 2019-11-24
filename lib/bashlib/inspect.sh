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

    bashlib::int myint=13
    bashlib::string mystring="Hello, world!"
    bashlib::const myconst="Hi there!"
    bashlib::array myarray=( alpha bravo charlie )
    bashlib::hashmap myhashmap=( [first]=one [second]=two [third]=4 )
    bashlib::reference myreference=myarray
    alias myalias=':'
    function myfunction() { :; }

    [[ "$myint" -eq 13 ]]                 || bashlib::throw
    [[ "$mystring" == "Hello, world!" ]]  || bashlib::throw
    [[ "$myconst" == "Hi there!" ]]       || bashlib::throw
    [[ "${myarray[1]}" == "bravo" ]]      || bashlib::throw
    [[ "${myhashmap[second]}" == "two" ]] || bashlib::throw
    myreference+=( "delta" )
    [[ "${myarray[3]}" == "delta" ]]      || bashlib::throw

    [[ $(bashlib::typeof myint) == "int" ]]           || bashlib::throw
    [[ $(bashlib::typeof mystring) == "string" ]]     || bashlib::throw
    [[ $(bashlib::typeof myconst) == "string" ]]      || bashlib::throw
    [[ $(bashlib::typeof myarray) == "array" ]]       || bashlib::throw
    [[ $(bashlib::typeof myhashmap) == "hashmap" ]]   || bashlib::throw
    [[ $(bashlib::typeof myreference) == "array" ]]   || bashlib::throw
    [[ $(bashlib::typeof mynothing) == "undefined" ]] || bashlib::throw
    [[ $(bashlib::typeof myalias) == "alias" ]]       || bashlib::throw
    [[ $(bashlib::typeof myfunction) == "function" ]] || bashlib::throw

    bashlib::defined myint       || bashlib::throw
    bashlib::defined mystring    || bashlib::throw
    bashlib::defined myconst     || bashlib::throw
    bashlib::defined myarray     || bashlib::throw
    bashlib::defined myhashmap   || bashlib::throw
    bashlib::defined myreference || bashlib::throw
    bashlib::defined mynothing   && bashlib::throw
    bashlib::defined myfunction  || bashlib::throw
    bashlib::defined myalias     || bashlib::throw

    echo "[PASS]"
}


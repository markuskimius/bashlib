##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function defined() {
    declare -p "$1" >& /dev/null || return 1
}

function typeof() {
    var __bashlib_declare=( $(defined "$1" && declare -p "$1" || echo "? ? ?" ) )
    var __bashlib_type=var

    case "${__bashlib_declare[1]}" in
        *a*)    __bashlib_type="array"     ;;
        *A*)    __bashlib_type="hashmap"   ;;
        *f*)    __bashlib_type="function"  ;;

        *n*)    # Reference to another variable
                var __bashlib_underlying
                
                __bashlib_underlying=${__bashlib_declare[2]#*=}
                __bashlib_underlying=${__bashlib_underlying#\"}
                __bashlib_underlying=${__bashlib_underlying%\"}
                __bashlib_type=$(typeof "${__bashlib_underlying}")
                ;;

        \?)     __bashlib_type="undefined" ;;
        *i*)    __bashlib_type="int"       ;;
        *)      __bashlib_type="var"       ;;
    esac

    echo "$__bashlib_type"
}

function inspect::__test__() {
    include "./exception.sh"

    int myint=13
    var myvar="Hello, world!"
    const myconst="Hi there!"
    array myarray=( alpha bravo charlie )
    hashmap myhashmap=( [first]=one [second]=two [third]=4 )
    reference myreference=myarray

    [[ "$myint" -eq 13 ]]                 || die
    [[ "$myvar" == "Hello, world!" ]]     || die
    [[ "$myconst" == "Hi there!" ]]       || die
    [[ "${myarray[1]}" == "bravo" ]]      || die
    [[ "${myhashmap[second]}" == "two" ]] || die
    myreference+=( "delta" )
    [[ "${myarray[3]}" == "delta" ]]      || die

    [[ $(typeof myint) == "int" ]]           || die
    [[ $(typeof myvar) == "var" ]]           || die
    [[ $(typeof myconst) == "var" ]]         || die
    [[ $(typeof myarray) == "array" ]]       || die
    [[ $(typeof myhashmap) == "hashmap" ]]   || die
    [[ $(typeof myreference) == "array" ]]   || die
    [[ $(typeof mynothing) == "undefined" ]] || die

    echo "Done!"
}


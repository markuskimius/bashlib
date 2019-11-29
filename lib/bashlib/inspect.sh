##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::defined() {
    [[ $(bashlib::typeof "$1") != "undefined" ]]
}

function bashlib::isset() {
    bashlib::string varname=$(bashlib::realvar "$1")
    bashlib::string decl=$(declare -p "$varname" 2>/dev/null || :)

    bashlib::defined "$varname" && [[ "$decl" == *=* ]]
}

function bashlib::realvar() {
    bashlib::string varname="$1"
    bashlib::string decl=$(declare -p "$varname" 2>/dev/null || echo "? ? ?")
    bashlib::string decl_t=${decl#* } && decl_t=${decl_t%% *}  # 2nd part of declare -p

    if [[ "$decl_t" == *n* ]]; then
        bashlib::string decl_q=${decl#*\"} && decl_q=${decl_q%\"}  # Quoted part of declare -p

        varname=$(bashlib::realvar "$decl_q")
    fi

    echo "$varname"
}

function bashlib::typeof() {
    bashlib::string varname="$1"
    bashlib::string decl=$(declare -p "$varname" 2>/dev/null || echo "? ? ?")
    bashlib::string decl_t=${decl#* } && decl_t=${decl_t%% *}  # 2nd part of declare -p
    bashlib::string return_t

    case "$decl_t" in
        *a*)    return_t="array"                                           ;;
        *A*)    return_t="hashmap"                                         ;;
        *i*)    return_t="int"                                             ;;
        *n*)    return_t=$(bashlib::typeof $(bashlib::realvar "$varname")) ;;
        \?)     if alias "$1" &>/dev/null; then
                    return_t="alias"
                elif declare -F "$varname" &>/dev/null; then
                    return_t="function"
                else
                    return_t="undefined"
                fi                                                         ;;
        *)      return_t="string"                                          ;;
    esac

    echo "$return_t"
}

function bashlib::inspect::__test__() {
    include "./exception.sh"

    bashlib::int myint=13
    bashlib::string mystring="Hello, world!"
    bashlib::const myconst="Hi there!"
    bashlib::array myarray=( alpha bravo charlie )
    bashlib::hashmap myhashmap=( [first]=one [second]=two [third]=4 )
    bashlib::reference myreference=myarray
    bashlib::int unsetint
    bashlib::string unsetstring
    bashlib::const unsetconst
    bashlib::array unsetarray
    bashlib::hashmap unsethashmap
    bashlib::reference unsetreference
    bashlib::reference referencetounset=unsetarray

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

    bashlib::isset unsetint         && bashlib::throw
    bashlib::isset unsetstring      && bashlib::throw
    bashlib::isset unsetconst       && bashlib::throw
    bashlib::isset unsetarray       && bashlib::throw
    bashlib::isset unsethashmap     && bashlib::throw
    bashlib::isset unsetreference   && bashlib::throw
    bashlib::isset referencetounset && bashlib::throw
    bashlib::isset unsetnothing     && bashlib::throw

    echo "[PASS]"
}


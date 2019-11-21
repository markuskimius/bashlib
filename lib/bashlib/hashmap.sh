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

function hashmap::exists() {
    [[ $(typeof "$1") == "hashmap" ]]
}

function hashmap::isset() {
    string varname=$(reference::underlying "$1")

    hashmap::exists "$varname" && [[ $(declare -p "$varname") == *=* ]]
}

function hashmap::isempty() {
    [[ $(hashmap::length "$1") -eq 0 ]]
}

function hashmap::isnonempty() {
    [[ $(hashmap::length "$1") -gt 0 ]]
}

function hashmap::length() {
    reference __bashlib_hashmap=$1

    if hashmap::isset __bashlib_hashmap; then
        echo "${#__bashlib_hashmap[@]}"
    else
        echo 0
    fi
}

function hashmap::haskey() {
    reference __bashlib_array="$1"
    string __bashlib_key="$2"

    [[ -v __bashlib_array["$__bashlib_key"] ]]
}

function hashmap::hasvalue() {
    reference __bashlib_array="$1"
    string __bashlib_value="$2"
    string v
    int haskey=0

    for v in "${__bashlib_array[@]}"; do
        if [[ "$__bashlib_value" == "$v" ]]; then
            haskey=1
            break
        fi
    done

    (( $haskey ))
}

function hashmap::keyof() {
    reference __bashlib_hashmap="$1"
    string __bashlib_value="$2"
    string value
    string k

    for k in "${!__bashlib_hashmap[@]}"; do
        value="${__bashlib_hashmap[$k]}"

        if [[ "$__bashlib_value" == "$value" ]]; then
            echo "$k"
            break
        fi
    done
}

function hashmap::get() {
    reference __bashlib_hashmap="$1"
    string key="$2"

    if [[ -v __bashlib_hashmap["$key"] ]]; then
        echo "${__bashlib_hashmap[$key]}"
    else
        return 1
    fi
}

function hashmap::set() {
    reference __bashlib_hashmap="$1"
    string key="$2"
    string value="$3"

    __bashlib_hashmap["$key"]="${value}"
}

function hashmap::delete() {
    reference __bashlib_hashmap="$1"
    string key="$2"

    unset __bashlib_hashmap["$key"]
}

function hashmap::clear() {
    reference __bashlib_hashmap=$1

    __bashlib_hashmap=()
}

function hashmap::dump() {
    reference __bashlib_hashmap="$1"
    string k

    echo "$1 = ("
    for k in "${!__bashlib_hashmap[@]}"; do
        string escaped_value=$(string::escape "${__bashlib_hashmap[$k]}")

        echo "  [$k] = \"${escaped_value}\""
    done
    echo ")"
}

function hashmap::__test__() {
    include "./exception.sh"
    include "./mode.sh"

    mode::strict

    hashmap myhashmap=( ["alpha one"]="duck duck" ["bravo two"]="duck goose" ["charlie three"]="goose goose" )

    [[ $(hashmap::length myhashmap) -eq 3 ]] || die
    hashmap::haskey myhashmap "bravo two"         || die
    hashmap::hasvalue myhashmap "duck goose"      || die
    [[ $(hashmap::get myhashmap "bravo two") == "duck goose" ]]   || die
    [[ $(hashmap::keyof myhashmap "duck goose") == "bravo two" ]] || die

    hashmap::set myhashmap "bravo two" "duck duck goose"
    [[ $(hashmap::length myhashmap) -eq 3 ]] || die
    hashmap::haskey myhashmap "bravo two"         || die
    hashmap::hasvalue myhashmap "duck duck goose" || die
    [[ $(hashmap::get myhashmap "bravo two") == "duck duck goose" ]]   || die
    [[ $(hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || die

    hashmap::set myhashmap "duck duck goose" "charlie three"
    [[ $(hashmap::length myhashmap) -eq 4 ]] || die
    hashmap::haskey myhashmap "duck duck goose"   || die
    hashmap::hasvalue myhashmap "charlie three"   || die
    [[ $(hashmap::get myhashmap "duck duck goose") == "charlie three" ]]   || die
    [[ $(hashmap::keyof myhashmap "charlie three") == "duck duck goose" ]] || die
    hashmap::haskey myhashmap "bravo two"         || die
    hashmap::hasvalue myhashmap "duck duck goose" || die
    [[ $(hashmap::get myhashmap "bravo two") == "duck duck goose" ]]   || die
    [[ $(hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || die

    hashmap::delete myhashmap "bravo two"
    [[ $(hashmap::length myhashmap) -eq 3 ]] || die
    hashmap::haskey myhashmap "bravo two"         && die
    hashmap::hasvalue myhashmap "duck duck goose" && die
    [[ $(hashmap::get myhashmap "bravo two") == "duck duck goose" ]]   && die
    [[ $(hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] && die

    hashmap::dump myhashmap

    hashmap emptyhashmap=()
    hashmap unsethashmap

    hashmap::exists myhashmap     || die
    hashmap::exists emptyhashmap  || die
    hashmap::exists unsethashmap  || die
    hashmap::exists nosuchhashmap && die

    hashmap::isset myhashmap     || die
    hashmap::isset emptyhashmap  || die
    hashmap::isset unsethashmap  && die
    hashmap::isset nosuchhashmap && die

    hashmap::isempty myhashmap     && die
    hashmap::isempty emptyhashmap  || die
    hashmap::isempty unsethashmap  || die

    hashmap::isnonempty myhashmap     || die
    hashmap::isnonempty emptyhashmap  && die
    hashmap::isnonempty unsethashmap  && die

    hashmap::clear myhashmap
    hashmap::isempty myhashmap || die

    hashmap::dump myhashmap

    echo "Done!"
}


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

function bashlib::hashmap::exists() {
    [[ $(bashlib::typeof "$1") == "hashmap" ]]
}

function bashlib::hashmap::isset() {
    bashlib::string varname=$(bashlib::reference::source "$1")

    bashlib::hashmap::exists "$varname" && [[ $(declare -p "$varname") == *=* ]]
}

function bashlib::hashmap::isempty() {
    [[ $(bashlib::hashmap::length "$1") -eq 0 ]]
}

function bashlib::hashmap::isnonempty() {
    [[ $(bashlib::hashmap::length "$1") -gt 0 ]]
}

function bashlib::hashmap::length() {
    bashlib::reference __bashlib_hashmap=$1

    if bashlib::hashmap::isset __bashlib_hashmap; then
        echo "${#__bashlib_hashmap[@]}"
    else
        echo 0
    fi
}

function bashlib::hashmap::haskey() {
    bashlib::reference __bashlib_array="$1"
    bashlib::string __bashlib_key="$2"

    [[ -v __bashlib_array["$__bashlib_key"] ]]
}

function bashlib::hashmap::hasvalue() {
    bashlib::reference __bashlib_array="$1"
    bashlib::string __bashlib_value="$2"
    bashlib::string v
    bashlib::int haskey=0

    for v in "${__bashlib_array[@]}"; do
        if [[ "$__bashlib_value" == "$v" ]]; then
            haskey=1
            break
        fi
    done

    (( $haskey ))
}

function bashlib::hashmap::keyof() {
    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string __bashlib_value="$2"
    bashlib::string value
    bashlib::string k

    for k in "${!__bashlib_hashmap[@]}"; do
        value="${__bashlib_hashmap[$k]}"

        if [[ "$__bashlib_value" == "$value" ]]; then
            echo "$k"
            break
        fi
    done
}

function bashlib::hashmap::get() {
    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"

    if [[ -v __bashlib_hashmap["$key"] ]]; then
        echo "${__bashlib_hashmap[$key]}"
    else
        return 1
    fi
}

function bashlib::hashmap::set() {
    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"
    bashlib::string value="$3"

    __bashlib_hashmap["$key"]="${value}"
}

function bashlib::hashmap::delete() {
    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"

    unset __bashlib_hashmap["$key"]
}

function bashlib::hashmap::clear() {
    bashlib::reference __bashlib_hashmap=$1

    __bashlib_hashmap=()
}

function bashlib::hashmap::dump() {
    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string k

    echo "$1 = ("
    for k in "${!__bashlib_hashmap[@]}"; do
        bashlib::string encoded_value=$(bashlib::string::encode "${__bashlib_hashmap[$k]}")

        echo "  [$k] = \"${encoded_value}\""
    done
    echo ")"
}

function bashlib::hashmap::__test__() {
    include "./exception.sh"
    include "./mode.sh"

    bashlib::mode::strict

    bashlib::hashmap myhashmap=( ["alpha one"]="duck duck" ["bravo two"]="duck goose" ["charlie three"]="goose goose" )

    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::die
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::die
    bashlib::hashmap::hasvalue myhashmap "duck goose"      || bashlib::die
    [[ $(bashlib::hashmap::get myhashmap "bravo two") == "duck goose" ]]   || bashlib::die
    [[ $(bashlib::hashmap::keyof myhashmap "duck goose") == "bravo two" ]] || bashlib::die

    bashlib::hashmap::set myhashmap "bravo two" "duck duck goose"
    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::die
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::die
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" || bashlib::die
    [[ $(bashlib::hashmap::get myhashmap "bravo two") == "duck duck goose" ]]   || bashlib::die
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::die

    bashlib::hashmap::set myhashmap "duck duck goose" "charlie three"
    [[ $(bashlib::hashmap::length myhashmap) -eq 4 ]] || bashlib::die
    bashlib::hashmap::haskey myhashmap "duck duck goose"   || bashlib::die
    bashlib::hashmap::hasvalue myhashmap "charlie three"   || bashlib::die
    [[ $(bashlib::hashmap::get myhashmap "duck duck goose") == "charlie three" ]]   || bashlib::die
    [[ $(bashlib::hashmap::keyof myhashmap "charlie three") == "duck duck goose" ]] || bashlib::die
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::die
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" || bashlib::die
    [[ $(bashlib::hashmap::get myhashmap "bravo two") == "duck duck goose" ]]   || bashlib::die
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::die

    bashlib::hashmap::delete myhashmap "bravo two"
    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::die
    bashlib::hashmap::haskey myhashmap "bravo two"         && bashlib::die
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" && bashlib::die
    [[ $(bashlib::hashmap::get myhashmap "bravo two") == "duck duck goose" ]]   && bashlib::die
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] && bashlib::die

    bashlib::hashmap::dump myhashmap

    bashlib::hashmap emptyhashmap=()
    bashlib::hashmap unsethashmap

    bashlib::hashmap::exists myhashmap     || bashlib::die
    bashlib::hashmap::exists emptyhashmap  || bashlib::die
    bashlib::hashmap::exists unsethashmap  || bashlib::die
    bashlib::hashmap::exists nosuchhashmap && bashlib::die

    bashlib::hashmap::isset myhashmap     || bashlib::die
    bashlib::hashmap::isset emptyhashmap  || bashlib::die
    bashlib::hashmap::isset unsethashmap  && bashlib::die
    bashlib::hashmap::isset nosuchhashmap && bashlib::die

    bashlib::hashmap::isempty myhashmap     && bashlib::die
    bashlib::hashmap::isempty emptyhashmap  || bashlib::die
    bashlib::hashmap::isempty unsethashmap  || bashlib::die

    bashlib::hashmap::isnonempty myhashmap     || bashlib::die
    bashlib::hashmap::isnonempty emptyhashmap  && bashlib::die
    bashlib::hashmap::isnonempty unsethashmap  && bashlib::die

    bashlib::hashmap::clear myhashmap
    bashlib::hashmap::isempty myhashmap || bashlib::die

    bashlib::hashmap::dump myhashmap

    echo "Done!"
}


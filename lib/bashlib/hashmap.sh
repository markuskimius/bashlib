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

function bashlib::hashmap::defined() {
    [[ $(bashlib::typeof "$1") == "hashmap" ]]
}

function bashlib::hashmap::isset() {
    bashlib::string varname=$(bashlib::reference::source "$1")

    bashlib::hashmap::defined "$varname" && [[ $(declare -p "$varname") == *=* ]]
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
    bashlib::string key="$2"

    [[ -v __bashlib_array["$key"] ]]
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
    bashlib::reference __bashlib_array="$1"
    bashlib::string value="$2"
    bashlib::string key="${3-}"
    bashlib::string k

    for k in "${!__bashlib_array[@]}"; do
        if [[ "$value" == "${__bashlib_array[$k]}" ]]; then
            key=$k
            break
        fi
    done

    echo "$key"
}

function bashlib::hashmap::definition_of() {
    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"

    if [[ -v __bashlib_hashmap["$key"] ]]; then
        echo "${__bashlib_hashmap[$key]}"
    else
        return 1
    fi
}

function bashlib::hashmap::add() {
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

    bashlib::hashmap myhashmap=( ["alpha one"]="duck duck" ["bravo two"]="duck goose" ["charlie three"]="goose goose" )

    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck goose"      || bashlib::throw
    [[ $(bashlib::hashmap::definition_of myhashmap "bravo two") == "duck goose" ]]   || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::hashmap::add myhashmap "bravo two" "duck duck goose"
    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" || bashlib::throw
    [[ $(bashlib::hashmap::definition_of myhashmap "bravo two") == "duck duck goose" ]]   || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::hashmap::add myhashmap "duck duck goose" "charlie three"
    [[ $(bashlib::hashmap::length myhashmap) -eq 4 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "duck duck goose"   || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "charlie three"   || bashlib::throw
    [[ $(bashlib::hashmap::definition_of myhashmap "duck duck goose") == "charlie three" ]]   || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "charlie three") == "duck duck goose" ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" || bashlib::throw
    [[ $(bashlib::hashmap::definition_of myhashmap "bravo two") == "duck duck goose" ]]   || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::hashmap::delete myhashmap "bravo two"
    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         && bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" && bashlib::throw
    [[ $(bashlib::hashmap::definition_of myhashmap "bravo two") == "duck duck goose" ]]   && bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] && bashlib::throw

    [[ $(bashlib::hashmap::dump myhashmap) == *alpha?one*duck?duck* ]]           || bashlib::throw
    [[ $(bashlib::hashmap::dump myhashmap) == *duck?duck?goose*charlie?three* ]] || bashlib::throw
    [[ $(bashlib::hashmap::dump myhashmap) == *charlie?three*goose?goose* ]]     || bashlib::throw
    [[ $(bashlib::hashmap::dump myhashmap | wc -l) -eq 5 ]]                      || bashlib::throw

    bashlib::hashmap emptyhashmap=()
    bashlib::hashmap unsethashmap

    bashlib::hashmap::defined myhashmap     || bashlib::throw
    bashlib::hashmap::defined emptyhashmap  || bashlib::throw
    bashlib::hashmap::defined unsethashmap  || bashlib::throw
    bashlib::hashmap::defined nosuchhashmap && bashlib::throw

    bashlib::hashmap::isset myhashmap     || bashlib::throw
    bashlib::hashmap::isset emptyhashmap  || bashlib::throw
    bashlib::hashmap::isset unsethashmap  && bashlib::throw
    bashlib::hashmap::isset nosuchhashmap && bashlib::throw

    bashlib::hashmap::isempty myhashmap     && bashlib::throw
    bashlib::hashmap::isempty emptyhashmap  || bashlib::throw
    bashlib::hashmap::isempty unsethashmap  || bashlib::throw

    bashlib::hashmap::isnonempty myhashmap     || bashlib::throw
    bashlib::hashmap::isnonempty emptyhashmap  && bashlib::throw
    bashlib::hashmap::isnonempty unsethashmap  && bashlib::throw

    bashlib::hashmap::clear myhashmap
    bashlib::hashmap::isempty myhashmap || bashlib::throw

    [[ $(bashlib::hashmap::dump myhashmap | wc -l) -eq 2 ]] || bashlib::throw

    echo "[PASS]"
}


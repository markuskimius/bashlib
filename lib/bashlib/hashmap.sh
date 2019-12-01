##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./inspect.sh"
include "./string.sh"

function bashlib::hashmap::length() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap=$1

    echo ${#__bashlib_hashmap[@]}
}

function bashlib::hashmap::haskey() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"

    [[ -v __bashlib_hashmap["$key"] ]]
}

function bashlib::hashmap::hasvalue() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string value="$2"
    bashlib::string v
    bashlib::int hasvalue=0

    for v in "${__bashlib_hashmap[@]}"; do
        if [[ "$value" == "$v" ]]; then
            hasvalue=1
            break
        fi
    done

    (( $hasvalue ))
}

function bashlib::hashmap::keyof() {
    (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string value="$2"
    bashlib::string key="${3-}"
    bashlib::string k

    for k in "${!__bashlib_hashmap[@]}"; do
        if [[ "$value" == "${__bashlib_hashmap[$k]}" ]]; then
            key=$k
            break
        fi
    done

    echo "$key"
}

function bashlib::hashmap::set() {
    (( $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"
    bashlib::string value="$3"

    __bashlib_hashmap["$key"]="$value"
}

function bashlib::hashmap::delete() {
    (( $# >= 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap=$1
    bashlib::string key
    shift 1

    for key in "$@"; do
        unset __bashlib_hashmap["$key"]
    done
}

function bashlib::hashmap::dump() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key

    echo "$1 = ("
    for key in "${!__bashlib_hashmap[@]}"; do
        bashlib::string encoded_value=$(bashlib::string::encode "${__bashlib_hashmap[$key]}")

        echo "  [$key] = \"${encoded_value}\""
    done
    echo ")"
}

function bashlib::hashmap::clear() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap=$1

    __bashlib_hashmap=()
}

function bashlib::hashmap::valueof() {
    (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"
    bashlib::string value="${3-}"

    if [[ -v __bashlib_hashmap["$key"] ]]; then
        value=${__bashlib_hashmap["$key"]}
    fi

    echo "$value"
}

function bashlib::hashmap::copy() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") =~ hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_source="$1"
    bashlib::reference __bashlib_target="$2"
    bashlib::string key

    __bashlib_target=()

    for key in "${!__bashlib_source[@]}"; do
        __bashlib_target["$key"]="${__bashlib_source[$key]}"
    done
}

function bashlib::hashmap::map() {
    (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") =~ array|hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib__source="$1"
    bashlib::reference __bashlib__target="${3-$1}"
    bashlib::string func="$2"
    bashlib::string key

    if [[ ! $(bashlib::typeof __bashlib__target) =~ array|hashmap ]]; then
        __bashlib_target=()
    fi

    for key in "${!__bashlib__source[@]}"; do
        __bashlib__target["$key"]=$("$func" "${__bashlib__source[$key]}")
    done
}

function bashlib::hashmap::__test__() {
    include "./exception.sh"

    bashlib::hashmap myhashmap=( ["alpha one"]="duck duck" ["bravo two"]="duck goose" ["charlie three"]="goose goose" )

    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck goose"      || bashlib::throw
    [[ $(bashlib::hashmap::valueof myhashmap "bravo two") == "duck goose" ]] || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::hashmap::set myhashmap "bravo two" "duck duck goose"
    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" || bashlib::throw
    [[ $(bashlib::hashmap::valueof myhashmap "bravo two") == "duck duck goose" ]] || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::hashmap::set myhashmap "duck duck goose" "charlie three"
    [[ $(bashlib::hashmap::length myhashmap) -eq 4 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "duck duck goose"   || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "charlie three"   || bashlib::throw
    [[ $(bashlib::hashmap::valueof myhashmap "duck duck goose") == "charlie three" ]] || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "charlie three") == "duck duck goose" ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" || bashlib::throw
    [[ $(bashlib::hashmap::valueof myhashmap "bravo two") == "duck duck goose" ]] || bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::hashmap::delete myhashmap "bravo two"
    [[ $(bashlib::hashmap::length myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::hashmap::haskey myhashmap "bravo two"         && bashlib::throw
    bashlib::hashmap::hasvalue myhashmap "duck duck goose" && bashlib::throw
    [[ $(bashlib::hashmap::keyof myhashmap "duck duck goose") == "bravo two" ]] && bashlib::throw

    [[ $(bashlib::hashmap::dump myhashmap) == *alpha?one*duck?duck* ]]           || bashlib::throw
    [[ $(bashlib::hashmap::dump myhashmap) == *duck?duck?goose*charlie?three* ]] || bashlib::throw
    [[ $(bashlib::hashmap::dump myhashmap) == *charlie?three*goose?goose* ]]     || bashlib::throw
    [[ $(bashlib::hashmap::dump myhashmap | wc -l) -eq 5 ]]                      || bashlib::throw

    bashlib::hashmap emptyhashmap=()
    bashlib::hashmap unsethashmap

    bashlib::hashmap::clear myhashmap
    [[ $(bashlib::hashmap::length myhashmap) -eq 0 ]]        || bashlib::throw
    [[ $(bashlib::typeof myhashmap) == hashmap ]]           || bashlib::throw
    [[ $(bashlib::hashmap::dump myhashmap | wc -l) -eq 2 ]] || bashlib::throw

    echo "[PASS]"
}


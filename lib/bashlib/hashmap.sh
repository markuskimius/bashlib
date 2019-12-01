##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./array.sh"

function bashlib::haskey() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"

    [[ -v __bashlib_hashmap["$key"] ]]
}

function bashlib::keyof() {
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

function bashlib::set() {
    (( $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap="$1"
    bashlib::string key="$2"
    bashlib::string value="$3"

    __bashlib_hashmap["$key"]="$value"
}

function bashlib::hashmap::__test__() {
    include "./exception.sh"

    bashlib::hashmap myhashmap=( ["alpha one"]="duck duck" ["bravo two"]="duck goose" ["charlie three"]="goose goose" )

    [[ $(bashlib::count myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hasvalue myhashmap "duck goose"      || bashlib::throw
    [[ $(bashlib::valueof myhashmap "bravo two") == "duck goose" ]] || bashlib::throw
    [[ $(bashlib::keyof myhashmap "duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::set myhashmap "bravo two" "duck duck goose"
    [[ $(bashlib::count myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hasvalue myhashmap "duck duck goose" || bashlib::throw
    [[ $(bashlib::valueof myhashmap "bravo two") == "duck duck goose" ]] || bashlib::throw
    [[ $(bashlib::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::set myhashmap "duck duck goose" "charlie three"
    [[ $(bashlib::count myhashmap) -eq 4 ]] || bashlib::throw
    bashlib::haskey myhashmap "duck duck goose"   || bashlib::throw
    bashlib::hasvalue myhashmap "charlie three"   || bashlib::throw
    [[ $(bashlib::valueof myhashmap "duck duck goose") == "charlie three" ]] || bashlib::throw
    [[ $(bashlib::keyof myhashmap "charlie three") == "duck duck goose" ]] || bashlib::throw
    bashlib::haskey myhashmap "bravo two"         || bashlib::throw
    bashlib::hasvalue myhashmap "duck duck goose" || bashlib::throw
    [[ $(bashlib::valueof myhashmap "bravo two") == "duck duck goose" ]] || bashlib::throw
    [[ $(bashlib::keyof myhashmap "duck duck goose") == "bravo two" ]] || bashlib::throw

    bashlib::remove myhashmap "bravo two"
    [[ $(bashlib::count myhashmap) -eq 3 ]] || bashlib::throw
    bashlib::haskey myhashmap "bravo two"         && bashlib::throw
    bashlib::hasvalue myhashmap "duck duck goose" && bashlib::throw
    [[ $(bashlib::keyof myhashmap "duck duck goose") == "bravo two" ]] && bashlib::throw

    [[ $(bashlib::dump myhashmap) == *alpha?one*duck?duck* ]]           || bashlib::throw
    [[ $(bashlib::dump myhashmap) == *duck?duck?goose*charlie?three* ]] || bashlib::throw
    [[ $(bashlib::dump myhashmap) == *charlie?three*goose?goose* ]]     || bashlib::throw
    [[ $(bashlib::dump myhashmap | wc -l) -eq 5 ]]                      || bashlib::throw

    bashlib::hashmap emptyhashmap=()
    bashlib::hashmap unsethashmap

    bashlib::clear myhashmap
    [[ $(bashlib::count myhashmap) -eq 0 ]] || bashlib::throw
    [[ $(bashlib::typeof myhashmap) == hashmap ]] || bashlib::throw
    [[ $(bashlib::dump myhashmap | wc -l) -eq 2 ]] || bashlib::throw

    echo "[PASS]"
}


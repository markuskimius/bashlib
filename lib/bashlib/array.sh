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
include "./exception.sh"

function bashlib::array::length() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    echo ${#__bashlib_array[@]}
}

function bashlib::array::front() {
    (( $# == 1 || $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1
    bashlib::reference __bashlib_var=${2-$1}
    bashlib::string value=${__bashlib_array[0]}

    if (( $# == 1 )); then
        echo "$value"
    else
        __bashlib_var=$value
    fi
}

function bashlib::array::back() {
    (( $# == 1 || $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1
    bashlib::reference __bashlib_var=${2-$1}
    bashlib::string value=${__bashlib_array[-1]}

    if (( $# == 1 )); then
        echo "$value"
    else
        __bashlib_var=$value
    fi
}

function bashlib::array::push() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1
    bashlib::string value=$2

    __bashlib_array+=( "$value" )
}

function bashlib::array::pop() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    unset __bashlib_array[-1]
}

function bashlib::array::shift() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    __bashlib_array=( "${__bashlib_array[@]:1}" )
}

function bashlib::array::unshift() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1
    bashlib::string value=$2

    __bashlib_array=( "$value" "${__bashlib_array[@]}" )
}

function bashlib::array::insert() {
    (( $# >= 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1
    bashlib::int index=$2
    shift 2

    __bashlib_array=(
        "${__bashlib_array[@]::$index}"
        "$@"
        "${__bashlib_array[@]:$index}"
    )
}

function bashlib::array::delete() {
    (( $# >= 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
    bashlib::reference __bashlib_array=$1
    bashlib::int index=$2
    bashlib::int count=${3-1}

    __bashlib_array=(
        "${__bashlib_array[@]::$index}"
        "${__bashlib_array[@]:$(( index + count ))}"
    )
}

function bashlib::array::dump() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array="$1"
    bashlib::int i

    echo "$1 = ("
    for i in "${!__bashlib_array[@]}"; do
        bashlib::string encoded_value=$(bashlib::string::encode "${__bashlib_array[$i]}")

        echo "  [$i] = \"${encoded_value}\""
    done
    echo ")"
}

function bashlib::array::clear() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    __bashlib_array=()
}

function bashlib::array::hasindex() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array="$1"
    bashlib::int index="$2"

    [[ -v __bashlib_array[$index] ]]
}

function bashlib::array::hasvalue() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array="$1"
    bashlib::string value="$2"
    bashlib::string v
    bashlib::int hasvalue=0

    for v in "${__bashlib_array[@]}"; do
        if [[ "$value" == "$v" ]]; then
            hasvalue=1
            break
        fi
    done

    (( $hasvalue ))
}

function bashlib::array::indexof() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array="$1"
    bashlib::string value="$2"
    bashlib::int index=-1
    bashlib::int i

    for i in "${!__bashlib_array[@]}"; do
        if [[ "$value" == "${__bashlib_array[$i]}" ]]; then
            index=$i
            break
        fi
    done

    echo "$index"
}

function bashlib::array::valueof() {
    (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array="$1"
    bashlib::int index="$2"
    bashlib::string value="${3-}"

    if [[ -v __bashlib_array[$index] ]]; then
        value=${__bashlib_array[$index]}
    fi

    echo "$value"
}

function bashlib::array::copy() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_source="$1"
    bashlib::reference __bashlib_target="$2"
    bashlib::int i

    __bashlib_target=()

    for i in "${!__bashlib_source[@]}"; do
        __bashlib_target[$i]="${__bashlib_source[$i]}"
    done
}

function bashlib::array::map() {
    (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib__source="$1"
    bashlib::reference __bashlib__target="${3-$1}"
    bashlib::string func="$2"
    bashlib::int i

    if [[ ! $(bashlib::typeof __bashlib__target) == array ]]; then
        __bashlib_target=()
    fi

    for i in "${!__bashlib__source[@]}"; do
        __bashlib__target[$i]=$("$func" "${__bashlib__source[$i]}")
    done
}

function bashlib::array::sort() {
    (( $# == 1 || $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_source="$1"
    bashlib::reference __bashlib_target="${2-$1}"
    bashlib::string IFS=$'\n'

    bashlib::array::map __bashlib_source bashlib::string::encode __bashlib_target
    __bashlib_target=( $(sort <<<"${__bashlib_target[*]}") )
    bashlib::array::map __bashlib_target bashlib::string::decode
}

function bashlib::array::__test__() {
    # ( charlie delta echo )
    bashlib::array myarray=( "charlie" "delta" "echo" )
    [[ $(bashlib::array::length myarray) -eq 3 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "charlie" ]] || bashlib::throw
    [[ $(bashlib::array::back myarray) == "echo" ]]     || bashlib::throw

    # ( delta echo )
    bashlib::array::shift myarray
    [[ $(bashlib::array::length myarray) -eq 2 ]]     || bashlib::throw
    [[ $(bashlib::array::front myarray) == "delta" ]] || bashlib::throw
    [[ $(bashlib::array::back myarray) == "echo" ]]   || bashlib::throw

    # ( delta echo foxtrot )
    bashlib::array::push myarray "foxtrot"
    [[ $(bashlib::array::length myarray) -eq 3 ]]      || bashlib::throw
    [[ $(bashlib::array::front myarray) == "delta" ]]  || bashlib::throw
    [[ $(bashlib::array::back myarray) == "foxtrot" ]] || bashlib::throw

    # ( bravo delta echo foxtrot )
    bashlib::array::unshift myarray "bravo"
    [[ $(bashlib::array::length myarray) -eq 4 ]]      || bashlib::throw
    [[ $(bashlib::array::front myarray) == "bravo" ]]  || bashlib::throw
    [[ $(bashlib::array::back myarray) == "foxtrot" ]] || bashlib::throw

    # ( bravo charlie delta echo foxtrot )
    bashlib::array::insert myarray 1 "charlie"
    [[ $(bashlib::array::length myarray) -eq 5 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::array::back myarray) == "foxtrot" ]]  || bashlib::throw

    # ( alpha bravo charlie delta echo foxtrot )
    bashlib::array::insert myarray 0 "alpha"
    [[ $(bashlib::array::length myarray) -eq 6 ]]      || bashlib::throw
    [[ $(bashlib::array::front myarray) == "alpha" ]]  || bashlib::throw
    [[ $(bashlib::array::back myarray) == "foxtrot" ]] || bashlib::throw

    # ( alpha bravo charlie delta echo foxtrot golf )
    bashlib::array::insert myarray 6 "golf"
    [[ $(bashlib::array::length myarray) -eq 7 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "alpha" ]]   || bashlib::throw
    [[ $(bashlib::array::back myarray) == "golf" ]]     || bashlib::throw

    bashlib::array::hasindex myarray 6       || bashlib::throw
    bashlib::array::hasvalue myarray "delta" || bashlib::throw

    # ( alpha bravo charlie echo foxtrot golf )
    bashlib::array::delete myarray 3
    [[ $(bashlib::array::length myarray) -eq 6 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "alpha" ]]   || bashlib::throw
    [[ $(bashlib::array::back myarray) == "golf" ]]     || bashlib::throw

    bashlib::array::hasindex myarray 6       && bashlib::throw
    bashlib::array::hasvalue myarray "delta" && bashlib::throw

    # ( bravo charlie echo foxtrot golf )
    bashlib::array::delete myarray 0
    [[ $(bashlib::array::length myarray) -eq 5 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::array::back myarray) == "golf" ]]     || bashlib::throw

    # ( bravo charlie echo foxtrot )
    bashlib::array::delete myarray 4
    [[ $(bashlib::array::length myarray) -eq 4 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::array::back myarray) == "foxtrot" ]]  || bashlib::throw

    [[ $(bashlib::array::indexof myarray "bravo") == 0 ]]   || bashlib::throw
    [[ $(bashlib::array::indexof myarray "charlie") == 1 ]] || bashlib::throw
    [[ $(bashlib::array::indexof myarray "foxtrot") == 3 ]] || bashlib::throw

    # newarray=( ravo harlie cho oxtrot )
    function chopfirst() { echo "${1:1}"; }
    bashlib::array::map myarray chopfirst newarray
    [[ $(bashlib::array::front newarray) == "ravo" ]]   || bashlib::throw
    [[ $(bashlib::array::back newarray)  == "oxtrot" ]] || bashlib::throw
    [[ $(bashlib::array::front myarray)  != $(bashlib::array::front newarray) ]] || bashlib::throw
    [[ $(bashlib::array::back myarray)   != $(bashlib::array::back newarray)  ]] || bashlib::throw

    # newarray=( cho harlie oxtrot ravo )
    bashlib::array::sort newarray
    [[ $(bashlib::array::front newarray) == "cho" ]]  || bashlib::throw
    [[ $(bashlib::array::back newarray)  == "ravo" ]] || bashlib::throw

    [[ $(bashlib::array::dump myarray) == *0*bravo*   ]] || bashlib::throw
    [[ $(bashlib::array::dump myarray) == *1*charlie* ]] || bashlib::throw
    [[ $(bashlib::array::dump myarray) == *2*echo*    ]] || bashlib::throw
    [[ $(bashlib::array::dump myarray) == *3*foxtrot* ]] || bashlib::throw
    [[ $(bashlib::array::dump myarray | wc -l) -eq 6 ]]  || bashlib::throw

    # ( bravo charlie echo )
    bashlib::array::pop myarray
    [[ $(bashlib::array::length myarray) -eq 3 ]]            || bashlib::throw
    [[ $(bashlib::array::front myarray) == "bravo" ]]       || bashlib::throw
    [[ $(bashlib::array::back myarray) == "echo" ]]         || bashlib::throw
    [[ $(bashlib::array::valueof myarray 1) == "charlie" ]] || bashlib::throw

    bashlib::array::copy myarray newarray
    [[ $(bashlib::array::length newarray) -eq 3 ]]            || bashlib::throw
    [[ $(bashlib::array::front newarray) == "bravo" ]]       || bashlib::throw
    [[ $(bashlib::array::back newarray) == "echo" ]]         || bashlib::throw
    [[ $(bashlib::array::valueof newarray 1) == "charlie" ]] || bashlib::throw

    bashlib::array::copy myarray newnewarray
    [[ $(bashlib::array::length newnewarray) -eq 3 ]]            || bashlib::throw
    [[ $(bashlib::array::front newnewarray) == "bravo" ]]       || bashlib::throw
    [[ $(bashlib::array::back newnewarray) == "echo" ]]         || bashlib::throw
    [[ $(bashlib::array::valueof newnewarray 1) == "charlie" ]] || bashlib::throw

    bashlib::array emptyarray=()
    bashlib::array unsetarray

    bashlib::defined myarray     || bashlib::throw
    bashlib::defined emptyarray  || bashlib::throw
    bashlib::defined unsetarray  || bashlib::throw
    bashlib::defined nosucharray && bashlib::throw

    bashlib::isset myarray     || bashlib::throw
    bashlib::isset emptyarray  || bashlib::throw
    bashlib::isset unsetarray  && bashlib::throw
    bashlib::isset nosucharray && bashlib::throw

    bashlib::array::clear myarray
    [[ $(bashlib::array::length myarray) -eq 0 ]] || bashlib::throw
    [[ $(bashlib::typeof myarray) == array ]] || bashlib::throw
    [[ $(bashlib::array::dump myarray | wc -l) -eq 2 ]] || bashlib::throw

    echo "[PASS]"
}


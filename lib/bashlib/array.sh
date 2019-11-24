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

function bashlib::array::defined() {
    bashlib::string varname=$(bashlib::reference::source "$1")

    [[ $(bashlib::typeof "$varname") == "array" ]]
}

function bashlib::array::isset() {
    bashlib::string varname=$(bashlib::reference::source "$1")

    bashlib::array::defined "$varname" && [[ $(declare -p "$varname") == *=* ]]
}

function bashlib::array::isempty() {
    [[ $(bashlib::array::length "$1") -eq 0 ]]
}

function bashlib::array::isnonempty() {
    [[ $(bashlib::array::length "$1") -gt 0 ]]
}

function bashlib::array::length() {
    bashlib::reference __bashlib_array=$1

    if bashlib::array::isset __bashlib_array; then
        echo "${#__bashlib_array[@]}"
    else
        echo 0
    fi
}

function bashlib::array::push() {
    bashlib::reference __bashlib_array=$1
    bashlib::string __bashlib_value=$2

    __bashlib_array+=( "$__bashlib_value" )
}

function bashlib::array::pop() {
    bashlib::reference __bashlib_array=$1

    unset __bashlib_array[-1]
}

function bashlib::array::shift() {
    bashlib::reference __bashlib_array=$1

    __bashlib_array=("${__bashlib_array[@]:1}")
}

function bashlib::array::unshift() {
    bashlib::reference __bashlib_array=$1
    bashlib::string __bashlib_value=$2

    __bashlib_array=( "$__bashlib_value" "${__bashlib_array[@]}" )
}

function bashlib::array::insert() {
    bashlib::reference __bashlib_array=$1
    bashlib::int __bashlib_index=$2
    bashlib::string __bashlib_value=$3

    __bashlib_array=(
        "${__bashlib_array[@]::$__bashlib_index}"
        "$__bashlib_value"
        "${__bashlib_array[@]:$__bashlib_index}"
    )
}

function bashlib::array::delete() {
    bashlib::reference __bashlib_array=$1
    bashlib::int __bashlib_index=$2
    bashlib::int __bashlib_count=${3-1}
    bashlib::int __bashlib_index_plus=$((__bashlib_index+__bashlib_count))

    __bashlib_array=(
        "${__bashlib_array[@]::$__bashlib_index}"
        "${__bashlib_array[@]:$__bashlib_index_plus}"
    )
}

function bashlib::array::clear() {
    bashlib::reference __bashlib_array=$1

    __bashlib_array=()
}

function bashlib::array::front() {
    bashlib::reference __bashlib_array=$1

    echo "${__bashlib_array[0]}"
}

function bashlib::array::back() {
    bashlib::reference __bashlib_array="$1"

    echo "${__bashlib_array[-1]}"
}

function bashlib::array::hasindex() {
    bashlib::reference __bashlib_array="$1"
    bashlib::int __bashlib_index="$2"

    [[ -v __bashlib_array["$__bashlib_index"] ]]
}

function bashlib::array::hasvalue() {
    bashlib::reference __bashlib_array="$1"
    bashlib::string __bashlib_value="$2"
    bashlib::string v
    bashlib::int hasvalue=0

    for v in "${__bashlib_array[@]}"; do
        if [[ "$__bashlib_value" == "$v" ]]; then
            hasvalue=1
            break
        fi
    done

    (( $hasvalue ))
}

function bashlib::array::indexof() {
    bashlib::reference __bashlib_array="$1"
    bashlib::string __bashlib_value="$2"
    bashlib::int index=-1
    bashlib::int i

    for i in "${!__bashlib_array[@]}"; do
        if [[ "$__bashlib_value" == "${__bashlib_array[$i]}" ]]; then
            index=$i
            break
        fi
    done

    echo $index
}

function bashlib::array::get() {
    bashlib::reference __bashlib_array="$1"
    bashlib::int __bashlib_index="$2"

    echo "${__bashlib_array[$__bashlib_index]}"
}

function bashlib::array::copy() {
    bashlib::reference __bashlib_source="$1"
    bashlib::reference __bashlib_target="$2"
    bashlib::int i

    __bashlib_target=()

    for i in "${!__bashlib_source[@]}"; do
        __bashlib_target[i]=${__bashlib_source["$i"]}
    done
}

function bashlib::array::map() {
    bashlib::reference __bashlib__source="$1"
    bashlib::reference __bashlib__target="${3-$1}"
    bashlib::string func="$2"
    bashlib::int i

    if ! bashlib::array::isset __bashlib__target; then
        __bashlib_target=()
    fi

    for i in "${!__bashlib__source[@]}"; do
        __bashlib__target[i]=$("$func" "${__bashlib__source["$i"]}")
    done
}

function bashlib::array::sort() {
    bashlib::reference __bashlib_source="$1"
    bashlib::reference __bashlib_target="${2-$1}"
    bashlib::string IFS=$'\n'

    bashlib::array::map __bashlib_source bashlib::string::encode __bashlib_target
    __bashlib_target=( $(sort <<<"${__bashlib_target[*]}") )
    bashlib::array::map __bashlib_target bashlib::string::decode
}

function bashlib::array::dump() {
    bashlib::reference __bashlib_array="$1"
    bashlib::int i

    echo "$1 = ("
    for i in "${!__bashlib_array[@]}"; do
        bashlib::string encoded_value=$(bashlib::string::encode "${__bashlib_array[$i]}")

        echo "  [$i] = \"${encoded_value}\""
    done
    echo ")"
}

function bashlib::array::__test__() {
    include "./exception.sh"

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
    [[ $(bashlib::array::get myarray 0) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::array::get myarray 1) == "charlie" ]] || bashlib::throw
    [[ $(bashlib::array::get myarray 2) == "delta" ]]   || bashlib::throw

    # ( alpha bravo charlie delta echo foxtrot )
    bashlib::array::insert myarray 0 "alpha"
    [[ $(bashlib::array::length myarray) -eq 6 ]]      || bashlib::throw
    [[ $(bashlib::array::front myarray) == "alpha" ]]  || bashlib::throw
    [[ $(bashlib::array::back myarray) == "foxtrot" ]] || bashlib::throw
    [[ $(bashlib::array::get myarray 0) == "alpha" ]]  || bashlib::throw
    [[ $(bashlib::array::get myarray 1) == "bravo" ]]  || bashlib::throw

    # ( alpha bravo charlie delta echo foxtrot golf )
    bashlib::array::insert myarray 6 "golf"
    [[ $(bashlib::array::length myarray) -eq 7 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "alpha" ]]   || bashlib::throw
    [[ $(bashlib::array::back myarray) == "golf" ]]     || bashlib::throw
    [[ $(bashlib::array::get myarray 5) == "foxtrot" ]] || bashlib::throw
    [[ $(bashlib::array::get myarray 6) == "golf" ]]    || bashlib::throw

    bashlib::array::hasindex myarray 6       || bashlib::throw
    bashlib::array::hasvalue myarray "delta" || bashlib::throw

    # ( alpha bravo charlie echo foxtrot golf )
    bashlib::array::delete myarray 3
    [[ $(bashlib::array::length myarray) -eq 6 ]]       || bashlib::throw
    [[ $(bashlib::array::front myarray) == "alpha" ]]   || bashlib::throw
    [[ $(bashlib::array::back myarray) == "golf" ]]     || bashlib::throw
    [[ $(bashlib::array::get myarray 2) == "charlie" ]] || bashlib::throw
    [[ $(bashlib::array::get myarray 3) == "echo" ]]    || bashlib::throw

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

    [[ $(bashlib::array::get myarray 0) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::array::get myarray 1) == "charlie" ]] || bashlib::throw
    [[ $(bashlib::array::get myarray 3) == "foxtrot" ]] || bashlib::throw

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

    bashlib::array emptyarray=()
    bashlib::array unsetarray

    bashlib::array::defined myarray     || bashlib::throw
    bashlib::array::defined emptyarray  || bashlib::throw
    bashlib::array::defined unsetarray  || bashlib::throw
    bashlib::array::defined nosucharray && bashlib::throw

    bashlib::array::isset myarray     || bashlib::throw
    bashlib::array::isset emptyarray  || bashlib::throw
    bashlib::array::isset unsetarray  && bashlib::throw
    bashlib::array::isset nosucharray && bashlib::throw

    bashlib::array::isempty myarray     && bashlib::throw
    bashlib::array::isempty emptyarray  || bashlib::throw
    bashlib::array::isempty unsetarray  || bashlib::throw

    bashlib::array::isnonempty myarray     || bashlib::throw
    bashlib::array::isnonempty emptyarray  && bashlib::throw
    bashlib::array::isnonempty unsetarray  && bashlib::throw

    bashlib::array::clear myarray
    bashlib::array::isempty myarray || bashlib::throw

    [[ $(bashlib::array::dump myarray | wc -l) -eq 2 ]] || bashlib::throw

    echo "[PASS]"
}


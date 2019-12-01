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

function bashlib::count() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") =~ array|hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    echo ${#__bashlib_array[@]}
}

function bashlib::front() {
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

function bashlib::back() {
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

function bashlib::push() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1
    bashlib::string value=$2

    __bashlib_array+=( "$value" )
}

function bashlib::pop() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    unset __bashlib_array[-1]
}

function bashlib::shift() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    __bashlib_array=( "${__bashlib_array[@]:1}" )
}

function bashlib::unshift() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1
    bashlib::string value=$2

    __bashlib_array=( "$value" "${__bashlib_array[@]}" )
}

function bashlib::add() {
    (( $# == 3 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_hashmap=$1
    bashlib::string key="$2"
    bashlib::string value="$3"

    __bashlib_hashmap["$key"]="$value"
}

function bashlib::insert() {
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

function bashlib::remove() {
    (( $# >= 2 )) || bashlib::throw "Invalid argument count!"

    case "$(bashlib::typeof "$1")" in
        array)
            (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
            bashlib::reference __bashlib_array=$1
            bashlib::int index=$2
            bashlib::int count=${3-1}

            __bashlib_array=(
                "${__bashlib_array[@]::$index}"
                "${__bashlib_array[@]:$(( index + count ))}"
            )
            ;;

        hashmap)
            bashlib::reference __bashlib_array=$1
            bashlib::string key
            shift 1

            for key in "$@"; do
                unset __bashlib_array["$key"]
            done
            ;;

        *)  bashlib::throw "Invalid argument -- '$1'"
            ;;
    esac
}

function bashlib::dump() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") =~ array|hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array="$1"
    bashlib::string key

    echo "$1 = ("
    for key in "${!__bashlib_array[@]}"; do
        bashlib::string encoded_value=$(bashlib::encode "${__bashlib_array[$key]}")

        echo "  [$key] = \"${encoded_value}\""
    done
    echo ")"
}

function bashlib::clear() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") =~ array|hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array=$1

    __bashlib_array=()
}

function bashlib::hasindex() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_array="$1"
    bashlib::int index="$2"

    [[ -v __bashlib_array[$index] ]]
}

function bashlib::hasvalue() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") =~ array|hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

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

function bashlib::indexof() {
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

function bashlib::valueof() {
    (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"
    bashlib::reference __bashlib_array="$1"
    bashlib::string key="$2"
    bashlib::string value="${3-}"

    if [[ -v __bashlib_array["$key"] ]]; then
        value=${__bashlib_array["$key"]}
    fi

    echo "$value"
}

function bashlib::copy() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") =~ array|hashmap ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_source="$1"
    bashlib::reference __bashlib_target="$2"
    bashlib::string key

    __bashlib_target=()

    for key in "${!__bashlib_source[@]}"; do
        __bashlib_target["$key"]="${__bashlib_source[$key]}"
    done
}

function bashlib::map() {
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

function bashlib::sort() {
    (( $# == 1 || $# == 2 )) || bashlib::throw "Invalid argument count!"
    [[ $(bashlib::typeof "$1") == array ]] || bashlib::throw "Invalid argument -- '$1'"

    bashlib::reference __bashlib_source="$1"
    bashlib::reference __bashlib_target="${2-$1}"
    bashlib::string IFS=$'\n'

    bashlib::map __bashlib_source bashlib::encode __bashlib_target
    __bashlib_target=( $(sort <<<"${__bashlib_target[*]}") )
    bashlib::map __bashlib_target bashlib::decode
}

function bashlib::array::__test__() {
    include "./exception.sh"

    # ( charlie delta echo )
    bashlib::array myarray=( "charlie" "delta" "echo" )
    [[ $(bashlib::count myarray) -eq 3 ]]       || bashlib::throw
    [[ $(bashlib::front myarray) == "charlie" ]] || bashlib::throw
    [[ $(bashlib::back myarray) == "echo" ]]     || bashlib::throw

    # ( delta echo )
    bashlib::shift myarray
    [[ $(bashlib::count myarray) -eq 2 ]]     || bashlib::throw
    [[ $(bashlib::front myarray) == "delta" ]] || bashlib::throw
    [[ $(bashlib::back myarray) == "echo" ]]   || bashlib::throw

    # ( delta echo foxtrot )
    bashlib::push myarray "foxtrot"
    [[ $(bashlib::count myarray) -eq 3 ]]      || bashlib::throw
    [[ $(bashlib::front myarray) == "delta" ]]  || bashlib::throw
    [[ $(bashlib::back myarray) == "foxtrot" ]] || bashlib::throw

    # ( bravo delta echo foxtrot )
    bashlib::unshift myarray "bravo"
    [[ $(bashlib::count myarray) -eq 4 ]]      || bashlib::throw
    [[ $(bashlib::front myarray) == "bravo" ]]  || bashlib::throw
    [[ $(bashlib::back myarray) == "foxtrot" ]] || bashlib::throw

    # ( bravo charlie delta echo foxtrot )
    bashlib::insert myarray 1 "charlie"
    [[ $(bashlib::count myarray) -eq 5 ]]       || bashlib::throw
    [[ $(bashlib::front myarray) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::back myarray) == "foxtrot" ]]  || bashlib::throw

    # ( alpha bravo charlie delta echo foxtrot )
    bashlib::insert myarray 0 "alpha"
    [[ $(bashlib::count myarray) -eq 6 ]]      || bashlib::throw
    [[ $(bashlib::front myarray) == "alpha" ]]  || bashlib::throw
    [[ $(bashlib::back myarray) == "foxtrot" ]] || bashlib::throw

    # ( alpha bravo charlie delta echo foxtrot golf )
    bashlib::insert myarray 6 "golf"
    [[ $(bashlib::count myarray) -eq 7 ]]       || bashlib::throw
    [[ $(bashlib::front myarray) == "alpha" ]]   || bashlib::throw
    [[ $(bashlib::back myarray) == "golf" ]]     || bashlib::throw

    bashlib::hasindex myarray 6       || bashlib::throw
    bashlib::hasvalue myarray "delta" || bashlib::throw

    # ( alpha bravo charlie echo foxtrot golf )
    bashlib::remove myarray 3
    [[ $(bashlib::count myarray) -eq 6 ]]       || bashlib::throw
    [[ $(bashlib::front myarray) == "alpha" ]]   || bashlib::throw
    [[ $(bashlib::back myarray) == "golf" ]]     || bashlib::throw

    bashlib::hasindex myarray 6       && bashlib::throw
    bashlib::hasvalue myarray "delta" && bashlib::throw

    # ( bravo charlie echo foxtrot golf )
    bashlib::remove myarray 0
    [[ $(bashlib::count myarray) -eq 5 ]]       || bashlib::throw
    [[ $(bashlib::front myarray) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::back myarray) == "golf" ]]     || bashlib::throw

    # ( bravo charlie echo foxtrot )
    bashlib::remove myarray 4
    [[ $(bashlib::count myarray) -eq 4 ]]       || bashlib::throw
    [[ $(bashlib::front myarray) == "bravo" ]]   || bashlib::throw
    [[ $(bashlib::back myarray) == "foxtrot" ]]  || bashlib::throw

    [[ $(bashlib::indexof myarray "bravo") == 0 ]]   || bashlib::throw
    [[ $(bashlib::indexof myarray "charlie") == 1 ]] || bashlib::throw
    [[ $(bashlib::indexof myarray "foxtrot") == 3 ]] || bashlib::throw

    # newarray=( ravo harlie cho oxtrot )
    function chopfirst() { echo "${1:1}"; }
    bashlib::map myarray chopfirst newarray
    [[ $(bashlib::front newarray) == "ravo" ]]   || bashlib::throw
    [[ $(bashlib::back newarray)  == "oxtrot" ]] || bashlib::throw
    [[ $(bashlib::front myarray)  != $(bashlib::front newarray) ]] || bashlib::throw
    [[ $(bashlib::back myarray)   != $(bashlib::back newarray)  ]] || bashlib::throw

    # newarray=( cho harlie oxtrot ravo )
    bashlib::sort newarray
    [[ $(bashlib::front newarray) == "cho" ]]  || bashlib::throw
    [[ $(bashlib::back newarray)  == "ravo" ]] || bashlib::throw

    [[ $(bashlib::dump myarray) == *0*bravo*   ]] || bashlib::throw
    [[ $(bashlib::dump myarray) == *1*charlie* ]] || bashlib::throw
    [[ $(bashlib::dump myarray) == *2*echo*    ]] || bashlib::throw
    [[ $(bashlib::dump myarray) == *3*foxtrot* ]] || bashlib::throw
    [[ $(bashlib::dump myarray | wc -l) -eq 6 ]]  || bashlib::throw

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

    bashlib::clear myarray
    [[ $(bashlib::count myarray) -eq 0 ]] || bashlib::throw
    [[ $(bashlib::typeof myarray) == array ]] || bashlib::throw
    [[ $(bashlib::dump myarray | wc -l) -eq 2 ]] || bashlib::throw

    echo "[PASS]"
}


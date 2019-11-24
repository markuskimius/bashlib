##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./alias.sh"
include "./function.sh"
include "./exception.sh"

function bashlib::using() {
    what=$1

    case "$what" in
        namespace)
            bashlib::string namespace=$2
            bashlib::string target
            bashlib::int count=0

            for target in $(bashlib::function::names "^${namespace}::"); do
                source <(bashlib::function::get "$target" | sed "s/^${namespace}:://")
                count="count + 1"
            done

            for target in $(bashlib::alias::names "^${namespace}::"); do
                source <(bashlib::alias::get "$target" | sed "s/^alias ${namespace}::/alias /i")
                count="count + 1"
            done

            if (( ! $count )); then
                bashlib::throw "Invalid namespace -- '${namespace}'"
            fi
            ;;

        *::*)
            bashlib::string namespace=${what%::*}
            bashlib::int count=0

            if bashlib::function::defined "$what"; then
                source <(bashlib::function::get "$what" | sed "s/^${namespace}:://i")
                count="count + 1"
            fi

            if bashlib::alias::defined "$what"; then
                source <(bashlib::alias::get "$what" | sed "s/^alias ${namespace}::/alias /i")
                count="count + 1"
            fi

            if (( ! $count )); then
                bashlib::throw "Invalid function or alias -- '$what'"
            fi
            ;;

        *)
            bashlib::throw "Invalid argument to 'bashlib::using' -- '$what'"
            ;;
    esac
}

function bashlib::namespace::__test__() {
    function mynamespace::myfunction1() { echo "myfunction 1"; }
    function mynamespace::myfunction2() { echo "myfunction 2"; }
    function mynamespace::myfunction3() { echo "myfunction 3"; }

    alias mynamespace::myalias1='echo "myalias 1"'
    alias mynamespace::myalias2='echo "myalias 2"'
    alias mynamespace::myalias3='echo "myalias 3"'

    bashlib::function::defined myfunction1 && bashlib::throw
    bashlib::function::defined myfunction2 && bashlib::throw
    bashlib::function::defined myfunction3 && bashlib::throw
    bashlib::alias::defined myalias1 && bashlib::throw
    bashlib::alias::defined myalias2 && bashlib::throw
    bashlib::alias::defined myalias3 && bashlib::throw

    bashlib::using mynamespace::myfunction2
    bashlib::function::defined myfunction1 && bashlib::throw
    bashlib::function::defined myfunction2 || bashlib::throw
    bashlib::function::defined myfunction3 && bashlib::throw
    bashlib::alias::defined myalias1 && bashlib::throw
    bashlib::alias::defined myalias2 && bashlib::throw
    bashlib::alias::defined myalias3 && bashlib::throw
    [[ $(myfunction2) == $(mynamespace::myfunction2) ]] || bashlib::throw

    bashlib::using mynamespace::myalias2
    bashlib::function::defined myfunction1 && bashlib::throw
    bashlib::function::defined myfunction2 || bashlib::throw
    bashlib::function::defined myfunction3 && bashlib::throw
    bashlib::alias::defined myalias1 && bashlib::throw
    bashlib::alias::defined myalias2 || bashlib::throw
    bashlib::alias::defined myalias3 && bashlib::throw
    [[ $(myalias2) == $(mynamespace::myalias2) ]] || bashlib::throw

    bashlib::using namespace mynamespace
    bashlib::function::defined myfunction1 || bashlib::throw
    bashlib::function::defined myfunction2 || bashlib::throw
    bashlib::function::defined myfunction3 || bashlib::throw
    bashlib::alias::defined myalias1 || bashlib::throw
    bashlib::alias::defined myalias2 || bashlib::throw
    bashlib::alias::defined myalias3 || bashlib::throw
    [[ $(myfunction1) == $(mynamespace::myfunction1) ]] || bashlib::throw
    [[ $(myfunction2) == $(mynamespace::myfunction2) ]] || bashlib::throw
    [[ $(myfunction3) == $(mynamespace::myfunction3) ]] || bashlib::throw
    [[ $(myalias1) == $(mynamespace::myalias1) ]] || bashlib::throw
    [[ $(myalias2) == $(mynamespace::myalias2) ]] || bashlib::throw
    [[ $(myalias3) == $(mynamespace::myalias3) ]] || bashlib::throw

    echo "[PASS]"
}


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
include "./exception.sh"
include "./function.sh"
include "./alias.sh"

function bashlib::using() {
    (( $# >= 1 && $# <= 3 )) || bashlib::throw "Invalid argument count!"

    bashlib::string what=$1

    case "$what" in
        namespace)
            (( $# == 2 || $# == 3 )) || bashlib::throw "Invalid argument count!"

            bashlib::string namespace=$2
            bashlib::string namespace2=${3-}${3+::}
            bashlib::string target
            bashlib::int count=0

            for target in $(bashlib::alias::names "^${namespace}::"); do
                source <(alias "$target" | sed "s/^alias ${namespace}::/alias ${namespace2}/")
                count="count + 1"
            done

            for target in $(bashlib::function::names "^${namespace}::"); do
                source <(declare -f "$target" | sed "s/^${namespace}::/${namespace2}/")
                count="count + 1"
            done

            if (( ! $count )); then
                bashlib::throw "Invalid namespace -- '${namespace}'"
            fi
            ;;

        *::*)
            (( $# == 1 || $# == 2 )) || bashlib::throw "Invalid argument count!"

            bashlib::string what2=${what##*::}

            if (( $# == 2 )); then
                what2=$2
            fi

            case "$(bashlib::typeof "$what")" in
                alias)
                    source <(alias "$what" | sed "s/^alias ${what}/alias ${2-$what2}/")
                    ;;

                function)
                    source <(declare -f "$what" | sed "s/^${what}/${2-$what2}/")
                    ;;

                *)  bashlib::throw "Invalid argument to 'bashlib::using' -- '$what'"
                    ;;
            esac
            ;;

        *)
            bashlib::throw "Invalid argument(s) to 'using' -- $*"
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

    bashlib::defined myfunction1 && bashlib::throw
    bashlib::defined myfunction2 && bashlib::throw
    bashlib::defined myfunction3 && bashlib::throw
    bashlib::defined myalias1 && bashlib::throw
    bashlib::defined myalias2 && bashlib::throw
    bashlib::defined myalias3 && bashlib::throw

    bashlib::using mynamespace::myfunction2
    bashlib::defined myfunction1 && bashlib::throw
    bashlib::defined myfunction2 || bashlib::throw
    bashlib::defined myfunction3 && bashlib::throw
    bashlib::defined myalias1 && bashlib::throw
    bashlib::defined myalias2 && bashlib::throw
    bashlib::defined myalias3 && bashlib::throw
    [[ $(myfunction2) == $(mynamespace::myfunction2) ]] || bashlib::throw

    bashlib::using mynamespace::myalias2
    bashlib::defined myfunction1 && bashlib::throw
    bashlib::defined myfunction2 || bashlib::throw
    bashlib::defined myfunction3 && bashlib::throw
    bashlib::defined myalias1 && bashlib::throw
    bashlib::defined myalias2 || bashlib::throw
    bashlib::defined myalias3 && bashlib::throw
    [[ $(myalias2) == $(mynamespace::myalias2) ]] || bashlib::throw

    bashlib::using namespace mynamespace
    bashlib::defined myfunction1 || bashlib::throw
    bashlib::defined myfunction2 || bashlib::throw
    bashlib::defined myfunction3 || bashlib::throw
    bashlib::defined myalias1 || bashlib::throw
    bashlib::defined myalias2 || bashlib::throw
    bashlib::defined myalias3 || bashlib::throw
    [[ $(myfunction1) == $(mynamespace::myfunction1) ]] || bashlib::throw
    [[ $(myfunction2) == $(mynamespace::myfunction2) ]] || bashlib::throw
    [[ $(myfunction3) == $(mynamespace::myfunction3) ]] || bashlib::throw
    [[ $(myalias1) == $(mynamespace::myalias1) ]] || bashlib::throw
    [[ $(myalias2) == $(mynamespace::myalias2) ]] || bashlib::throw
    [[ $(myalias3) == $(mynamespace::myalias3) ]] || bashlib::throw

    bashlib::using mynamespace::myfunction2 anothernamespace::mynewfunction
    bashlib::defined anothernamespace::mynewfunction || bashlib::throw
    bashlib::defined anothernamespace::myfunction1 && bashlib::throw
    bashlib::defined anothernamespace::myfunction2 && bashlib::throw
    bashlib::defined anothernamespace::myfunction3 && bashlib::throw
    bashlib::defined anothernamespace::myalias1 && bashlib::throw
    bashlib::defined anothernamespace::myalias2 && bashlib::throw
    bashlib::defined anothernamespace::myalias3 && bashlib::throw
    [[ $(mynamespace::myfunction2) == $(anothernamespace::mynewfunction) ]] || bashlib::throw

    bashlib::using namespace mynamespace yetanothernamespace
    bashlib::defined yetanothernamespace::myfunction1 || bashlib::throw
    bashlib::defined yetanothernamespace::myfunction2 || bashlib::throw
    bashlib::defined yetanothernamespace::myfunction3 || bashlib::throw
    bashlib::defined yetanothernamespace::myalias1 || bashlib::throw
    bashlib::defined yetanothernamespace::myalias2 || bashlib::throw
    bashlib::defined yetanothernamespace::myalias3 || bashlib::throw
    [[ $(mynamespace::myfunction1) == $(yetanothernamespace::myfunction1) ]] || bashlib::throw
    [[ $(mynamespace::myfunction2) == $(yetanothernamespace::myfunction2) ]] || bashlib::throw
    [[ $(mynamespace::myfunction3) == $(yetanothernamespace::myfunction3) ]] || bashlib::throw
    [[ $(mynamespace::myalias1) == $(yetanothernamespace::myalias1) ]] || bashlib::throw
    [[ $(mynamespace::myalias2) == $(yetanothernamespace::myalias2) ]] || bashlib::throw
    [[ $(mynamespace::myalias3) == $(yetanothernamespace::myalias3) ]] || bashlib::throw

    echo "[PASS]"
}


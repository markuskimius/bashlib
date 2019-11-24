##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

trap "bashlib::exception::__handler__" ERR      # Trap any nonzero return values
set -o errtrace                        # ERR traps are inherited by function calls

function bashlib::exception::__handler__() {
    echo "Unhandled nonzero return value" 1>&2

    bashlib::exception::dump_stacktrace ${2-1}
}

function bashlib::die() {
    echo "${1-"bashlib::die() called"}" 1>&2

    bashlib::exception::dump_stacktrace ${2-1}

    exit 1
}

function bashlib::exception::dump_stacktrace() {
    bashlib::int frame=${1-0}
    bashlib::string lineno func file

    while true; do
        read -r lineno func file <<<$(caller $frame || :)
        [[ -n "$lineno" ]] || break

        echo -e "\tat $file:$lineno in $func() [$frame]" 1>&2
        frame="frame + 1"
    done
}

function bashlib::exception::__test__() {
    include "./mode.sh"

    function frame1() {
        bashlib::exception::dump_stacktrace ${1-0}
    }

    function frame2() {
        frame1 ${1-0}
    }

    case "${1-1}" in
        1)  [[ $(diff <(frame2 2 2>&1) <(frame2 1 2>&1) | grep '^[<>]' | wc -l) == 1 ]] || bashlib::die
            ;;

        2)  let 0
            ;;

        3)  bashlib::mode::strict
            let 0
            ;;

        *)  bashlib::die "No such test: ${1}"
            ;;
    esac

    echo "[OK]"
}

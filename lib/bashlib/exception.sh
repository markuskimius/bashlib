##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function exception::dump_stacktrace() {
    int frame=${1-0}
    int lineno
    string func file

    while true; do
        read -r lineno func file <<<$(caller $frame || :)
        [[ -n "$lineno" ]] || break

        echo -e "\tat $file:$lineno in $func() [$frame]" 1>&2
        let frame++ || :
    done
}

function exception::__handler__() {
    echo "Unhandled nonzero return value" 1>&2

    exception::dump_stacktrace ${2-1}
}

function die() {
    echo "${1-"die() called"}:" 1>&2

    exception::dump_stacktrace ${2-1}

    exit 1
}

trap "exception::__handler__" ERR      # Trap any nonzero return values
set -o errtrace                        # ERR traps are inherited by function calls


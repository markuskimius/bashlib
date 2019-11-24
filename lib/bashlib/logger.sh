##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::writelog() {
    bashlib::string level=INFO
    bashlib::string message=$1

    if (( $# >= 2 )); then
        level=$1
        message=$2
    fi

    if [[ " ${BASHLIB_LOGLEVEL-} ERROR " =~ " ${level} " ]]; then
        bashlib::string timestamp=$(date "+%Y%m%d %H:%M:%S.%N")
        bashlib::string lineno file

        read -r lineno file <<<$(caller)

        echo "${timestamp:0:21}|$level|$file:$lineno|$message" 1>&2
    fi
}

function bashlib::logger::__test__() {
    include "./exception.sh"

    unset BASHLIB_LOGLEVEL
    bashlib::writelog "Hello, world!"
    [[ $(bashlib::writelog "Hello, world!" 2>&1) == "" ]] || bashlib::throw
    [[ $(bashlib::writelog ERROR "Hello, world!" 2>&1) == *Hello,?world! ]] || bashlib::throw

    BASHLIB_LOGLEVEL="INFO LEVEL1"
    [[ $(bashlib::writelog "Hello, world!" 2>&1) == *Hello,?world! ]]        || bashlib::throw
    [[ $(bashlib::writelog LEVEL1 "Hello, world!" 2>&1) == *Hello,?world! ]] || bashlib::throw
    [[ $(bashlib::writelog LEVEL2 "Hello, world!" 2>&1) == "" ]]             || bashlib::throw

    echo "[PASS]"
}


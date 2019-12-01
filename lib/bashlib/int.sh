##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::isint() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [ "$1" -eq "$1" ] 2>/dev/null
}

function bashlib::int::__test__() {
    include "./exception.sh"

    bashlib::string mynonzerostring=7
    bashlib::string myzerostring=0
    bashlib::int mynonzeroint=7
    bashlib::int myzeroint=0
    bashlib::string mynonintstring="Hello, world!"
    bashlib::string myemptystring=""
    bashlib::string myunsetstring

    bashlib::isint "$mynonzerostring"  || bashlib::throw
    bashlib::isint "$myzerostring"     || bashlib::throw
    bashlib::isint "$mynonzeroint"     || bashlib::throw
    bashlib::isint "$myzeroint"        || bashlib::throw
    bashlib::isint "$mynonintstring"   && bashlib::throw
    bashlib::isint "$myemptystring"    && bashlib::throw
    bashlib::isint "${myunsetstring-}" && bashlib::throw

    echo "[PASS]"
}


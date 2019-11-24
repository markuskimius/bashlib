##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

bashlib::string -g BASHLIB_SCRIPTNAME="${BASH_SOURCE[-1]}"

function bashlib::globals::__test__() {
    include "./exception.sh"

    [[ "$BASHLIB_SCRIPTNAME" == *test.sh ]] || bashlib::die

    echo "[PASS]"
}

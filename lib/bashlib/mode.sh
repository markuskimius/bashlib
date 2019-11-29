##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

function bashlib::strictmode() {
    shopt -so nounset     # Do not allow reading of uninitialized variable
    shopt -so errexit     # Exit script if any nonzero exit status is not caught
    shopt -so pipefail    # Exit status of any command in a pipe chain is the exit status of the chain
    shopt -so noclobber   # Do not allow exiting file to be redirected to
}

function bashlib::extmode() {
    shopt -s extglob    # Enable extended glob
    shopt -s globstar   # ** expands to subdirectories
}


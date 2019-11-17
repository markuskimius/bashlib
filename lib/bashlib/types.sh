##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

alias var="declare"
alias int="declare -i"
alias const="declare -r"
alias array="declare -a"
alias map="declare -A"
alias ref="declare -n"

# Export aliases outside of the sourced file. Unfortunately this has the side
# effect of alias export outside of the whole script, not just this one file.
shopt -s expand_aliases


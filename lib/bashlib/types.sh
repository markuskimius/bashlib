##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

alias string="declare"
alias int="declare -i"
alias const="declare -r"
alias array="declare -a"
alias hashmap="declare -A"
alias reference="declare -n"

# Enable aliases in the script
shopt -s expand_aliases


##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

# Enable aliases in the script
shopt -s expand_aliases

alias bashlib::string="declare"
alias bashlib::int="declare -i"
alias bashlib::const="declare -r"
alias bashlib::array="declare -a"
alias bashlib::hashmap="declare -A"
alias bashlib::reference="declare -n"


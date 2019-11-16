alias var="declare"
alias int="declare -i"
alias array="declare -a"
alias map="declare -A"
alias ref="declare -n"

# Export aliases outside of the sourced file. Unfortunately this has the side
# effect of alias export outside of the whole script, not just this one file.
shopt -s expand_aliases


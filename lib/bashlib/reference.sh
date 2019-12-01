##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function bashlib::realvar() {
    bashlib::string varname="$1"
    bashlib::string decl=$(declare -p "$varname" 2>/dev/null || echo "? ? ?")
    bashlib::string decl_t=${decl#* } && decl_t=${decl_t%% *}  # 2nd part of declare -p

    if [[ "$decl_t" == *n* ]]; then
        bashlib::string decl_q=${decl#*\"} && decl_q=${decl_q%\"}  # Quoted part of declare -p

        varname=$(bashlib::realvar "$decl_q")
    fi

    echo "$varname"
}

function bashlib::reference::__test__() {
    include "./exception.sh"

    bashlib::string mystring
    bashlib::int myint
    bashlib::array myarray
    bashlib::hashmap myhashmap
    bashlib::reference mystringref=mystring
    bashlib::reference myintref=myint
    bashlib::reference myarrayref=myarray
    bashlib::reference myhashmapref=myhashmap
    bashlib::reference mynosuchvarref=nosuchvar
    bashlib::reference mynosuchref
    bashlib::reference mystringrefref=mystringref
    bashlib::reference myintrefref=myintref
    bashlib::reference myarrayrefref=myarrayref
    bashlib::reference myhashmaprefref=myhashmapref
    bashlib::reference mynosuchvarrefref=nosuchvarref
    bashlib::reference mynosuchrefref=mynosuchref

    [[ $(bashlib::realvar mystring) == "mystring" ]]   || bashlib::throw
    [[ $(bashlib::realvar myint) == "myint" ]]         || bashlib::throw
    [[ $(bashlib::realvar myarray) == "myarray" ]]     || bashlib::throw
    [[ $(bashlib::realvar myhashmap) == "myhashmap" ]] || bashlib::throw
    [[ $(bashlib::realvar nosuchvar) == "nosuchvar" ]] || bashlib::throw

    [[ $(bashlib::realvar mystringref) == "mystring" ]]      || bashlib::throw
    [[ $(bashlib::realvar myintref) == "myint" ]]            || bashlib::throw
    [[ $(bashlib::realvar myarrayref) == "myarray" ]]        || bashlib::throw
    [[ $(bashlib::realvar myhashmapref) == "myhashmap" ]]    || bashlib::throw
    [[ $(bashlib::realvar nosuchvarref) == "nosuchvarref" ]] || bashlib::throw
    [[ $(bashlib::realvar nosuchref) == "nosuchref" ]]       || bashlib::throw

    [[ $(bashlib::realvar mystringrefref) == "mystring" ]]         || bashlib::throw
    [[ $(bashlib::realvar myintrefref) == "myint" ]]               || bashlib::throw
    [[ $(bashlib::realvar myarrayrefref) == "myarray" ]]           || bashlib::throw
    [[ $(bashlib::realvar myhashmaprefref) == "myhashmap" ]]       || bashlib::throw
    [[ $(bashlib::realvar nosuchvarrefref) == "nosuchvarrefref" ]] || bashlib::throw
    [[ $(bashlib::realvar nosuchrefref) == "nosuchrefref" ]]       || bashlib::throw

    echo "[PASS]"
}


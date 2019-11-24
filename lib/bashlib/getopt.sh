##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./array.sh"

__bashlib_getopt_bin__=$(command -v getopt)

function bashlib::getopt() {
    bashlib::array -g OPTARRAY
    bashlib::string -g OPTOPT
    bashlib::string -g OPTARG
    bashlib::string shortopts=$1 && shift
    bashlib::string longopts=$1 && shift
    bashlib::int errcount=0

    # Set up the positional parameters
    if ! bashlib::array::isset OPTARRAY; then
        bashlib::string optstring
        
        optstring=$("$__bashlib_getopt_bin__" -o "$shortopts" --long "$longopts" -- "$@") || errcount=1
        eval set -- "$optstring"

        # Save the positional parameters
        OPTARRAY=( "$@" )
    fi

    # Initial values
    OPTOPT=$(bashlib::array::front OPTARRAY) && bashlib::array::shift OPTARRAY
    OPTARG=""

    # Argument?
    case "$OPTOPT" in
        --)  # End of parameters
             OPTOPT=-1
             ;;

        -?)  # Short option
             if [[ "$shortopts" == *${OPTOPT#-}:* ]]; then
                 OPTARG=$(bashlib::array::front OPTARRAY) && bashlib::array::shift OPTARRAY
             fi
             ;;

        --*) # Long option
             if [[ ",$longopts" == *,${OPTOPT#--}:* ]]; then
                 OPTARG=$(bashlib::array::front OPTARRAY) && bashlib::array::shift OPTARRAY
             fi
             ;;

        *)   # Bad option
             OPTOPT=?
             ;;
    esac

    return $errcount
}

function bashlib::getopt::__test__() {
    include "./exception.sh"
    include "./mode.sh"

    bashlib::mode::strict

    function main() {
        local OPTARRAY
        local OPTOPT
        local OPTARG
        local output

        while true; do
            bashlib::getopt "sm:o::" "single,mandatory:,optional::" "$@" || output+="PARSE "
            [[ $OPTOPT == -1 ]] && break

            case "$OPTOPT" in
                -s|--single)    output+="s "         ;;
                -m|--mandatory) output+="m=($OPTARG) " ;;
                -o|--optional)  output+="o=($OPTARG) " ;;
                *)              output+="ERROR "     ;;
            esac
        done

        for OPTARG in "${OPTARRAY[@]}"; do
            output+="$OPTARG "
        done

        echo "$output"
    }

    [[ "$(main alpha bravo charlie)" == "alpha bravo charlie " ]] || bashlib::die
    [[ "$(main -s alpha --single bravo)" == "s s alpha bravo " ]] || bashlib::die
    [[ "$(main -malpha -m bravo --mandatory=charlie --mandatory delta)" == "m=(alpha) m=(bravo) m=(charlie) m=(delta) " ]] || bashlib::die
    [[ "$(main -oalpha -o bravo --optional=charlie --optional delta)" == "o=(alpha) o=() o=(charlie) o=() bravo delta " ]] || bashlib::die

    [[ "$(main -ss alpha bravo charlie)" == "s s alpha bravo charlie " ]]    || bashlib::die
    [[ "$(main -so alpha bravo charlie)" == "s o=() alpha bravo charlie " ]] || bashlib::die
    [[ "$(main -sm alpha bravo charlie)" == "s m=(alpha) bravo charlie " ]]  || bashlib::die

    [[ "$(main -soalpha bravo charlie)" == "s o=(alpha) bravo charlie " ]] || bashlib::die
    [[ "$(main -smalpha bravo charlie)" == "s m=(alpha) bravo charlie " ]] || bashlib::die

    [[ "$(main -s alpha -mbravo -ocharlie)" == "s m=(bravo) o=(charlie) alpha " ]] || bashlib::die
    [[ "$(main --single alpha --mandatory=bravo --optional=charlie)" == "s m=(bravo) o=(charlie) alpha " ]] || bashlib::die

    [[ "$(main -s alpha -m bravo -o charlie)" == "s m=(bravo) o=() alpha charlie " ]] || bashlib::die
    [[ "$(main --single alpha --mandatory bravo --optional charlie)" == "s m=(bravo) o=() alpha charlie " ]] || bashlib::die

    [[ "$(main -- -s alpha -m bravo -o charlie)" == "-s alpha -m bravo -o charlie " ]] || bashlib::die
    [[ "$(main -- --single alpha --mandatory bravo --optional charlie)" == "--single alpha --mandatory bravo --optional charlie " ]] || bashlib::die

    [[ "$(main -s "alpha bravo" -m"charlie delta" -o"echo foxtrot")" == "s m=(charlie delta) o=(echo foxtrot) alpha bravo " ]] || bashlib::die
    [[ "$(main --single "alpha bravo" --mandatory="charlie delta" --optional="echo foxtrot")" == "s m=(charlie delta) o=(echo foxtrot) alpha bravo " ]] || bashlib::die

    [[ "$(main -i --invalid -s alpha -mbravo -ocharlie 2>/dev/null)" == "PARSE s m=(bravo) o=(charlie) alpha " ]]      || bashlib::die
    [[ "$(main -i --invalid=none -s alpha -mbravo -ocharlie 2>/dev/null)" == "PARSE s m=(bravo) o=(charlie) alpha " ]] || bashlib::die

    echo "[OK]"
}


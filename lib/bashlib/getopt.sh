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
include "./inspect.sh"
include "./exception.sh"

__bashlib_getopt_bin__=$(command -v getopt)

function bashlib::getopt() {
    (( $# >= 2 )) || bashlib::throw "Invalid argument count!"

    bashlib::array -g OPTARRAY
    bashlib::string -g OPTOPT
    bashlib::string -g OPTARG
    bashlib::string shortopts=$1
    bashlib::string longopts=$2
    bashlib::int errcount=0
    shift 2

    # Set up the positional parameters
    if ! bashlib::isset OPTARRAY; then
        bashlib::string optstring
        
        optstring=$("$__bashlib_getopt_bin__" -o "$shortopts" --long "$longopts" -- "$@") || errcount=1
        eval set -- "$optstring"

        # Save the positional parameters
        OPTARRAY=( "$@" )
    fi

    # Initial values
    OPTOPT=$(bashlib::front OPTARRAY) && bashlib::shift OPTARRAY
    OPTARG=""

    # Argument?
    case "$OPTOPT" in
        --)  # End of parameters
             OPTOPT=-1
             ;;

        -?)  # Short option
             if [[ "$shortopts" == *${OPTOPT#-}:* ]]; then
                 OPTARG=$(bashlib::front OPTARRAY) && bashlib::shift OPTARRAY
             fi
             ;;

        --*) # Long option
             if [[ ",$longopts" == *,${OPTOPT#--}:* ]]; then
                 OPTARG=$(bashlib::front OPTARRAY) && bashlib::shift OPTARRAY
             fi
             ;;

        *)   # Bad option
             OPTOPT=?
             ;;
    esac

    return $errcount
}

function bashlib::getopt::__test__() {
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

    [[ "$(main alpha bravo charlie)" == "alpha bravo charlie " ]] || bashlib::throw
    [[ "$(main -s alpha --single bravo)" == "s s alpha bravo " ]] || bashlib::throw
    [[ "$(main -malpha -m bravo --mandatory=charlie --mandatory delta)" == "m=(alpha) m=(bravo) m=(charlie) m=(delta) " ]] || bashlib::throw
    [[ "$(main -oalpha -o bravo --optional=charlie --optional delta)" == "o=(alpha) o=() o=(charlie) o=() bravo delta " ]] || bashlib::throw

    [[ "$(main -ss alpha bravo charlie)" == "s s alpha bravo charlie " ]]    || bashlib::throw
    [[ "$(main -so alpha bravo charlie)" == "s o=() alpha bravo charlie " ]] || bashlib::throw
    [[ "$(main -sm alpha bravo charlie)" == "s m=(alpha) bravo charlie " ]]  || bashlib::throw

    [[ "$(main -soalpha bravo charlie)" == "s o=(alpha) bravo charlie " ]] || bashlib::throw
    [[ "$(main -smalpha bravo charlie)" == "s m=(alpha) bravo charlie " ]] || bashlib::throw

    [[ "$(main -s alpha -mbravo -ocharlie)" == "s m=(bravo) o=(charlie) alpha " ]] || bashlib::throw
    [[ "$(main --single alpha --mandatory=bravo --optional=charlie)" == "s m=(bravo) o=(charlie) alpha " ]] || bashlib::throw

    [[ "$(main -s alpha -m bravo -o charlie)" == "s m=(bravo) o=() alpha charlie " ]] || bashlib::throw
    [[ "$(main --single alpha --mandatory bravo --optional charlie)" == "s m=(bravo) o=() alpha charlie " ]] || bashlib::throw

    [[ "$(main -- -s alpha -m bravo -o charlie)" == "-s alpha -m bravo -o charlie " ]] || bashlib::throw
    [[ "$(main -- --single alpha --mandatory bravo --optional charlie)" == "--single alpha --mandatory bravo --optional charlie " ]] || bashlib::throw

    [[ "$(main -s "alpha bravo" -m"charlie delta" -o"echo foxtrot")" == "s m=(charlie delta) o=(echo foxtrot) alpha bravo " ]] || bashlib::throw
    [[ "$(main --single "alpha bravo" --mandatory="charlie delta" --optional="echo foxtrot")" == "s m=(charlie delta) o=(echo foxtrot) alpha bravo " ]] || bashlib::throw

    [[ "$(main -i --invalid -s alpha -mbravo -ocharlie 2>/dev/null)" == "PARSE s m=(bravo) o=(charlie) alpha " ]]      || bashlib::throw
    [[ "$(main -i --invalid=none -s alpha -mbravo -ocharlie 2>/dev/null)" == "PARSE s m=(bravo) o=(charlie) alpha " ]] || bashlib::throw

    echo "[PASS]"
}


include "./types.sh"
include "./array.sh"

__bashlib_getopt_bin__=$(command -v getopt)

function getopt::getopt() {
    array -g OPTARRAY
    var -g OPTOPT
    var -g OPTARG
    var shortopts=$1 && shift
    var longopts=$1 && shift
    int errcount=0

    # Set up the positional parameters
    if ! array::isset OPTARRAY; then
        var optstring
        
        optstring=$("$__bashlib_getopt_bin__" -o "$shortopts" --long "$longopts" -- "$@") || errcount=1
        eval set -- "$optstring"

        # Save the positional parameters
        OPTARRAY=( "$@" )
    fi

    # Initial values
    OPTOPT=$(array::front OPTARRAY) && array::shift OPTARRAY
    OPTARG=""

    # Argument?
    case "$OPTOPT" in
        --)  # End of parameters
             OPTOPT=-1
             ;;

        -?)  # Short option
             if [[ "$shortopts" == *${OPTOPT#-}:* ]]; then
                 OPTARG=$(array::front OPTARRAY) && array::shift OPTARRAY
             fi
             ;;

        --*) # Long option
             if [[ ",$longopts" == *,${OPTOPT#--}:* ]]; then
                 OPTARG=$(array::front OPTARRAY) && array::shift OPTARRAY
             fi
             ;;

        *)   # Bad option
             OPTOPT=?
             ;;
    esac

    return $errcount
}

function getopt::__test__() {
    include "./exception.sh"

    function main() {
        local OPTARRAY
        local OPTOPT
        local OPTARG
        local output

        while true; do
            getopt::getopt "sm:o::" "single,mandatory:,optional::" "$@" || output+="PARSE "
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

    [[ "$(main alpha bravo charlie)" == "alpha bravo charlie " ]] || die
    [[ "$(main -s alpha --single bravo)" == "s s alpha bravo " ]] || die
    [[ "$(main -malpha -m bravo --mandatory=charlie --mandatory delta)" == "m=(alpha) m=(bravo) m=(charlie) m=(delta) " ]] || die
    [[ "$(main -oalpha -o bravo --optional=charlie --optional delta)" == "o=(alpha) o=() o=(charlie) o=() bravo delta " ]] || die

    [[ "$(main -ss alpha bravo charlie)" == "s s alpha bravo charlie " ]]    || die
    [[ "$(main -so alpha bravo charlie)" == "s o=() alpha bravo charlie " ]] || die
    [[ "$(main -sm alpha bravo charlie)" == "s m=(alpha) bravo charlie " ]]  || die

    [[ "$(main -soalpha bravo charlie)" == "s o=(alpha) bravo charlie " ]] || die
    [[ "$(main -smalpha bravo charlie)" == "s m=(alpha) bravo charlie " ]] || die

    [[ "$(main -s alpha -mbravo -ocharlie)" == "s m=(bravo) o=(charlie) alpha " ]] || die
    [[ "$(main --single alpha --mandatory=bravo --optional=charlie)" == "s m=(bravo) o=(charlie) alpha " ]] || die

    [[ "$(main -s alpha -m bravo -o charlie)" == "s m=(bravo) o=() alpha charlie " ]] || die
    [[ "$(main --single alpha --mandatory bravo --optional charlie)" == "s m=(bravo) o=() alpha charlie " ]] || die

    [[ "$(main -- -s alpha -m bravo -o charlie)" == "-s alpha -m bravo -o charlie " ]] || die
    [[ "$(main -- --single alpha --mandatory bravo --optional charlie)" == "--single alpha --mandatory bravo --optional charlie " ]] || die

    [[ "$(main -s "alpha bravo" -m"charlie delta" -o"echo foxtrot")" == "s m=(charlie delta) o=(echo foxtrot) alpha bravo " ]] || die
    [[ "$(main --single "alpha bravo" --mandatory="charlie delta" --optional="echo foxtrot")" == "s m=(charlie delta) o=(echo foxtrot) alpha bravo " ]] || die

    [[ "$(main -i --invalid -s alpha -mbravo -ocharlie 2>/dev/null)" == "PARSE s m=(bravo) o=(charlie) alpha " ]]      || die
    [[ "$(main -i --invalid=none -s alpha -mbravo -ocharlie 2>/dev/null)" == "PARSE s m=(bravo) o=(charlie) alpha " ]] || die

    echo "Done!"
}


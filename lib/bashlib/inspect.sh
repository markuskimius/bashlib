include "./types.sh"

function defined() {
    declare -p "$1" >& /dev/null || return 1
}

function typeof() {
    var __bashlib_declare=( $(defined "$1" && declare -p "$1" || echo "? ? ?" ) )
    var __bashlib_type=var

    case "${__bashlib_declare[1]}" in
        *i*)    __bashlib_type="int"       ;;
        *a*)    __bashlib_type="array"     ;;
        *A*)    __bashlib_type="map"       ;;
        *f*)    __bashlib_type="function"  ;;

        *n*)    # Reference to another variable
                var __bashlib_underlying
                
                __bashlib_underlying=${__bashlib_declare[2]#*=}
                __bashlib_underlying=${__bashlib_underlying#\"}
                __bashlib_underlying=${__bashlib_underlying%\"}
                __bashlib_type=$(typeof "${__bashlib_underlying}")
                ;;

        \?)     __bashlib_type="undefined" ;;
        *)      __bashlib_type="var"       ;;
    esac

    echo "$__bashlib_type"
}

function inspect::__test__() {
    include "./exception.sh"

    int myint=13
    var myvar="Hello, world!"
    array myarray=( alpha bravo charlie )
    map mymap=( [first]=one [second]=two [third]=4 )
    ref myref=myarray

    [[ "$myint" -eq 13 ]]             || die
    [[ "$myvar" == "Hello, world!" ]] || die
    [[ "${myarray[1]}" == "bravo" ]]  || die
    [[ "${mymap[second]}" == "two" ]] || die
    myref+=( "delta" )
    [[ "${myarray[3]}" == "delta" ]]  || die

    [[ $(typeof myint) == "int" ]]           || die
    [[ $(typeof myvar) == "var" ]]           || die
    [[ $(typeof myarray) == "array" ]]       || die
    [[ $(typeof mymap) == "map" ]]           || die
    [[ $(typeof myref) == "array" ]]         || die
    [[ $(typeof mynothing) == "undefined" ]] || die

    echo "Done!"
}


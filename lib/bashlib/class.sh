##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"
include "./inspect.sh"
include "./exception.sh"

bashlib::hashmap -g __bashlib_class__=( [COUNTER]=0 )

function bashlib::class::create() {
    (( $# >= 2 )) || bashlib::throw "Invalid argument count!"

    bashlib::string class=$1
    bashlib::reference __bashlib_object=$2
    shift 2

    __bashlib_object="__bashlib_class__${class}__$((__bashlib_class__[COUNTER]++))"

    # Build the object
    source <(cat <<....EOF
        function ${__bashlib_object}() {
            (( \$# >= 1 )) || bashlib::throw "Invalid argument count!"
            bashlib::string method=\$1

            case "\$method" in
                __get__)
                    (( \$# == 2 )) || bashlib::throw "Invalid argument count!"

                    # Get a member variable
                    bashlib::string name=\$2
                    echo "\${__bashlib_class__["${__bashlib_object}.\$name"]}"
                    ;;

                __set__)
                    (( \$# == 3 )) || bashlib::throw "Invalid argument count!"

                    # Set a member variable
                    bashlib::string name=\$2
                    bashlib::string value=\$3
                    __bashlib_class__["${__bashlib_object}.\$name"]="\$value"
                    ;;

                __unset__)
                    (( \$# == 2 )) || bashlib::throw "Invalid argument count!"

                    # Unset a member variable
                    bashlib::string name=\$2
                    unset __bashlib_class__["${__bashlib_object}.\$name"]
                    ;;

                __has__)
                    (( \$# == 2 )) || bashlib::throw "Invalid argument count!"

                    # Test for a member variable
                    bashlib::string name=\$2
                    [[ -v __bashlib_class__["${__bashlib_object}.\$name"] ]] || return 1
                    ;;

                *)
                    bashlib::string method2="${class}::\${method}"
                    shift 1

                    if bashlib::defined "\${method2}"; then
                        "\${method2}" "${__bashlib_object}" "\$@" || return \$?
                    else
                        bashlib::throw "Unknown method: \${method2}"
                    fi
                    ;;
            esac
        }
....EOF
    )

    # Populate default member variables
    "${__bashlib_object}" __set__ __classname__ "${class}"
    "${__bashlib_object}" __set__ __objname__ "${__bashlib_object}"

    # Call the constructor, if any
    if bashlib::defined "${class}::__constructor__"; then
        "${__bashlib_object}" __constructor__ "$@"
    fi
}

function bashlib::class::destroy() {
    (( $# >= 1 )) || bashlib::throw "Invalid argument count!"

    bashlib::string object=$1
    bashlib::string class=$( ${object} __get__ "__classname__" )
    shift 1

    # Call the destructor, if any
    if bashlib::defined "${class}::__destructor__"; then
        "${object}" __destructor__
    fi

    # Delete the object
    unset -f "${object}"

    # Delete member variables
    for key in "${!__bashlib_class__[@]}"; do
        if [[ "$key" == ${object}.* ]]; then
            unset __bashlib_class__["$key"]
        fi
    done
}

function bashlib::class::__test__() {
    bashlib::string incr1 incr2
    bashlib::string decr1 decr2
    bashlib::string value

    function IncrementingClass::__constructor__() {
        bashlib::string this=$1
        bashlib::int counter=$2

        $this __set__ counter "$2"
    }

    function IncrementingClass::get() {
        bashlib::string this=$1

        $this __get__ counter
    }

    function IncrementingClass::next() {
        bashlib::string this=$1
        bashlib::int counter=$($this __get__ counter)

        $this __set__ counter $((++counter))
    }

    function IncrementingClass::test() {
        bashlib::string this=$1
        bashlib::int counter=$($this __get__ counter)

        $this __has__ counter   || bashlib::throw
        $this __unset__ counter
        $this __has__ counter   && bashlib::throw
        $this __set__ counter $counter
        $this __has__ counter   || bashlib::throw
    }

    function IncrementingClass::__destructor__() {
        bashlib::string this=$1

        $this __get__ counter
    }

    function DecrementingClass::__constructor__() {
        bashlib::string this=$1
        bashlib::int counter=$2

        $this __set__ counter "$2"
    }

    function DecrementingClass::get() {
        bashlib::string this=$1

        $this __get__ counter
    }

    function DecrementingClass::next() {
        bashlib::string this=$1
        bashlib::int counter=$($this __get__ counter)

        $this __set__ counter $((--counter))
    }

    function DecrementingClass::test() {
        bashlib::string this=$1
        bashlib::int counter=$($this __get__ counter)

        $this __has__ counter   || bashlib::throw
        $this __unset__ counter
        $this __has__ counter   && bashlib::throw
        $this __set__ counter $counter
        $this __has__ counter   || bashlib::throw
    }

    function DecrementingClass::__destructor__() {
        bashlib::string this=$1

        $this __get__ counter
    }

    bashlib::class::create IncrementingClass incr1  3
    bashlib::class::create IncrementingClass incr2 17
    bashlib::class::create DecrementingClass decr1  9
    bashlib::class::create DecrementingClass decr2 25

    $incr1 next && [[ $($incr1 get) -eq  4 ]] || bashlib::throw
    $incr2 next && [[ $($incr2 get) -eq 18 ]] || bashlib::throw
    $decr1 next && [[ $($decr1 get) -eq  8 ]] || bashlib::throw
    $decr2 next && [[ $($decr2 get) -eq 24 ]] || bashlib::throw

    $incr1 next && [[ $($incr1 get) -eq  5 ]] || bashlib::throw
    $incr2 next && [[ $($incr2 get) -eq 19 ]] || bashlib::throw
    $decr1 next && [[ $($decr1 get) -eq  7 ]] || bashlib::throw
    $decr2 next && [[ $($decr2 get) -eq 23 ]] || bashlib::throw

    $incr1 test || bashlib::throw
    $incr2 test || bashlib::throw
    $decr1 test || bashlib::throw
    $decr2 test || bashlib::throw

    [[ $(bashlib::class::destroy $incr1) == 5  ]] || bashlib::throw
    [[ $(bashlib::class::destroy $incr2) == 19 ]] || bashlib::throw
    [[ $(bashlib::class::destroy $decr1) == 7  ]] || bashlib::throw
    [[ $(bashlib::class::destroy $decr2) == 23 ]] || bashlib::throw

    echo "[PASS]"
}


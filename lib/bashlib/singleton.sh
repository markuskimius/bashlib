include "./types.sh"
include "./class.sh"
include "./inspect.sh"
include "./exception.sh"

function bashlib::singleton() {
    (( $# >= 1 )) || bashlib::throw "Invalid argument count!"

    bashlib::string class=$1
    bashlib::string object
    shift 1

    if bashlib::defined $class; then
        bashlib::throw "$class is already defined"
    fi

    bashlib::create $class object "$@"

    source <(cat <<....EOF
        function $class () {
            $object "\$@"
        }
....EOF
    )
}

function bashlib::singleton::__test__() {
    function myclass::__constructor__() {
        bashlib::string this=$1
        shift 1

        $this __set__ value "$@"
    }

    function myclass::read() {
        bashlib::string this=$1
        shift 1

        $this __get__ value "$@"
    }

    bashlib::singleton myclass "Hello, world!"
    [[ $(myclass read) == "Hello, world!" ]] || bashlib::throw

    echo "[PASS]"
}


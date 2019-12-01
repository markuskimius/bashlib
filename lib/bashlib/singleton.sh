include "./types.sh"
include "./class.sh"
include "./inspect.sh"
include "./exception.sh"

function bashlib::singleton() {
    bashlib::string class=$1 && shift
    bashlib::string object

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
        bashlib::string this=$1 && shift

        $this __set__ value "$@"
    }

    function myclass::read() {
        bashlib::string this=$1 && shift

        $this __get__ value "$@"
    }

    bashlib::singleton myclass "Hello, world!"
    [[ $(myclass read) == "Hello, world!" ]] || bashlib::throw

    echo "[PASS]"
}


##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./exception.sh"

function bashlib::file::exists() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -e "$1" ]]
}

function bashlib::file::isdir() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -d "$1" ]]
}

function bashlib::file::isfile() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -f "$1" ]]
}

function bashlib::file::isreadable() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -r "$1" ]]
}

function bashlib::file::iswritable() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -w "$1" ]]
}

function bashlib::file::isempty() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ ! -s "$1" ]]
}

function bashlib::file::isexecutable() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -x "$1" ]]
}

function bashlib::file::issymlink() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -h "$1" ]]
}

function bashlib::file::isnonempty() {
    (( $# == 1 )) || bashlib::throw "Invalid argument count!"

    [[ -s "$1" ]]
}

function bashlib::file::is() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"

    [[ "$1" -ef "$2" ]]
}

function bashlib::file::isnewerthan() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"

    [[ "$1" -nt "$2" ]]
}

function bashlib::file::isolderthan() {
    (( $# == 2 )) || bashlib::throw "Invalid argument count!"

    [[ "$1" -ot "$2" ]]
}

function bashlib::file::__test__() {
    include "./types.sh"

    bashlib::string mydir=$(mktemp -d)
    bashlib::string myfile1=$(mktemp)
    sleep 1
    bashlib::string myfile2=$(mktemp)
    bashlib::string mylink=$(mktemp)

    function on_exit() {
        rmdir "$mydir"
        rm -f "$myfile1"
        rm -f "$myfile2"
        rm -f "$mylink"
    }

    echo "Hello, world!" >> "$myfile2"
    chmod u+x "$myfile2"
    chmod u-rw "$myfile2"

    rm -f "$mylink"
    ln -s "$myfile2" "$mylink"

    bashlib::file::exists "$mydir"   || ( on_exit && bashlib::throw )
    bashlib::file::exists "$myfile1" || ( on_exit && bashlib::throw )

    bashlib::file::isdir "$mydir"   || ( on_exit && bashlib::throw )
    bashlib::file::isdir "$myfile1" && ( on_exit && bashlib::throw )

    bashlib::file::isfile "$mydir"   && ( on_exit && bashlib::throw )
    bashlib::file::isfile "$myfile1" || ( on_exit && bashlib::throw )

    bashlib::file::isreadable "$mydir"   || ( on_exit && bashlib::throw )
    bashlib::file::isreadable "$myfile1" || ( on_exit && bashlib::throw )
    bashlib::file::isreadable "$myfile2" && ( on_exit && bashlib::throw )
    bashlib::file::iswritable "$mydir"   || ( on_exit && bashlib::throw )
    bashlib::file::iswritable "$myfile1" || ( on_exit && bashlib::throw )
    bashlib::file::iswritable "$myfile2" && ( on_exit && bashlib::throw )

    bashlib::file::isempty "$mydir"   && ( on_exit && bashlib::throw )
    bashlib::file::isempty "$myfile1" || ( on_exit && bashlib::throw )
    bashlib::file::isempty "$myfile2" && ( on_exit && bashlib::throw )

    bashlib::file::isexecutable "$mydir"   || ( on_exit && bashlib::throw )
    bashlib::file::isexecutable "$myfile1" && ( on_exit && bashlib::throw )
    bashlib::file::isexecutable "$myfile2" || ( on_exit && bashlib::throw )

    bashlib::file::issymlink "$mydir"   && ( on_exit && bashlib::throw )
    bashlib::file::issymlink "$myfile1" && ( on_exit && bashlib::throw )
    bashlib::file::issymlink "$myfile2" && ( on_exit && bashlib::throw )
    bashlib::file::issymlink "$mylink"  || ( on_exit && bashlib::throw )

    bashlib::file::is "$myfile1" "$myfile1" || ( on_exit && bashlib::throw )
    bashlib::file::is "$myfile1" "$myfile2" && ( on_exit && bashlib::throw )
    bashlib::file::isnewerthan "$myfile1" "$myfile1" && ( on_exit && bashlib::throw )
    bashlib::file::isnewerthan "$myfile1" "$myfile2" && ( on_exit && bashlib::throw )
    bashlib::file::isnewerthan "$myfile2" "$myfile1" || ( on_exit && bashlib::throw )
    bashlib::file::isolderthan "$myfile1" "$myfile1" && ( on_exit && bashlib::throw )
    bashlib::file::isolderthan "$myfile1" "$myfile2" || ( on_exit && bashlib::throw )
    bashlib::file::isolderthan "$myfile2" "$myfile1" && ( on_exit && bashlib::throw )

    on_exit && echo "[PASS]"
}


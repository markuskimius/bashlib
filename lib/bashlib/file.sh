##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

function bashlib::file::exists() {
    [[ -e "$1" ]]
}

function bashlib::file::isdir() {
    [[ -d "$1" ]]
}

function bashlib::file::isfile() {
    [[ -f "$1" ]]
}

function bashlib::file::isreadable() {
    [[ -r "$1" ]]
}

function bashlib::file::iswritable() {
    [[ -w "$1" ]]
}

function bashlib::file::isempty() {
    [[ ! -s "$1" ]]
}

function bashlib::file::isexecutable() {
    [[ -x "$1" ]]
}

function bashlib::file::issymlink() {
    [[ -h "$1" ]]
}

function bashlib::file::isnonempty() {
    [[ -s "$1" ]]
}

function bashlib::file::is() {
    [[ "$1" -ef "$2" ]]
}

function bashlib::file::isnewerthan() {
    [[ "$1" -nt "$2" ]]
}

function bashlib::file::isolderthan() {
    [[ "$1" -ot "$2" ]]
}

function bashlib::file::__test__() {
    include "./types.sh"
    include "./exception.sh"

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

    bashlib::file::exists "$mydir"   || ( on_exit && bashlib::die )
    bashlib::file::exists "$myfile1" || ( on_exit && bashlib::die )

    bashlib::file::isdir "$mydir"   || ( on_exit && bashlib::die )
    bashlib::file::isdir "$myfile1" && ( on_exit && bashlib::die )

    bashlib::file::isfile "$mydir"   && ( on_exit && bashlib::die )
    bashlib::file::isfile "$myfile1" || ( on_exit && bashlib::die )

    bashlib::file::isreadable "$mydir"   || ( on_exit && bashlib::die )
    bashlib::file::isreadable "$myfile1" || ( on_exit && bashlib::die )
    bashlib::file::isreadable "$myfile2" && ( on_exit && bashlib::die )
    bashlib::file::iswritable "$mydir"   || ( on_exit && bashlib::die )
    bashlib::file::iswritable "$myfile1" || ( on_exit && bashlib::die )
    bashlib::file::iswritable "$myfile2" && ( on_exit && bashlib::die )

    bashlib::file::isempty "$mydir"   && ( on_exit && bashlib::die )
    bashlib::file::isempty "$myfile1" || ( on_exit && bashlib::die )
    bashlib::file::isempty "$myfile2" && ( on_exit && bashlib::die )

    bashlib::file::isexecutable "$mydir"   || ( on_exit && bashlib::die )
    bashlib::file::isexecutable "$myfile1" && ( on_exit && bashlib::die )
    bashlib::file::isexecutable "$myfile2" || ( on_exit && bashlib::die )

    bashlib::file::issymlink "$mydir"   && ( on_exit && bashlib::die )
    bashlib::file::issymlink "$myfile1" && ( on_exit && bashlib::die )
    bashlib::file::issymlink "$myfile2" && ( on_exit && bashlib::die )
    bashlib::file::issymlink "$mylink"  || ( on_exit && bashlib::die )

    bashlib::file::is "$myfile1" "$myfile1" || ( on_exit && bashlib::die )
    bashlib::file::is "$myfile1" "$myfile2" && ( on_exit && bashlib::die )
    bashlib::file::isnewerthan "$myfile1" "$myfile1" && ( on_exit && bashlib::die )
    bashlib::file::isnewerthan "$myfile1" "$myfile2" && ( on_exit && bashlib::die )
    bashlib::file::isnewerthan "$myfile2" "$myfile1" || ( on_exit && bashlib::die )
    bashlib::file::isolderthan "$myfile1" "$myfile1" && ( on_exit && bashlib::die )
    bashlib::file::isolderthan "$myfile1" "$myfile2" || ( on_exit && bashlib::die )
    bashlib::file::isolderthan "$myfile2" "$myfile1" && ( on_exit && bashlib::die )

    on_exit && echo "[PASS]"
}

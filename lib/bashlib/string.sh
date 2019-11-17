##############################################################################
# BASHLIB: BASH library framework
# https://github.com/markuskimius/bashlib
#
# Copyright (c)2019 Mark K. Kim
# Released under the Apache license 2.0
# https://github.com/markuskimius/bashlib/blob/master/LICENSE
##############################################################################

include "./types.sh"

function string::isempty() {
    [[ -z "$1" ]]
}

function string::isnonempty() {
    [[ -n "$1" ]]
}

function string::escape() {
    var value=$1

    value=${value//\\/\\\\}
    value=${value//\$/\\$}
    value=${value//\"/\\\"}

    echo "$value"
}

function string::length() {
    echo "${#1}"
}

function string::tolower() {
    echo "${1,,}"
}

function string::toupper() {
    echo "${1^^}"
}

function string::replacefirst() {
    echo "${1/$2/$3}"
}

function string::replaceall() {
    echo "${1//$2/$3}"
}

function string::substr() {
    echo "${1:$2:$3}"
}

function string::__test__() {
    include "./exception.sh"

    var mystring="Hello, world!"
    var evilstring="\$Hello, \"world\\!"
    var emptystring=""

    string::isempty $mystring    && die
    string::isempty $emptystring || die
    string::isempty $nosuchstring || die
    string::isnonempty $mystring    || die
    string::isnonempty $emptystring && die
    string::isnonempty $nosuchstring && die

    [[ $(string::escape "$evilstring") == '\$Hello, \"world\\!' ]] || die

    [[ $(string::length "$mystring") -eq 13 ]] || die
    [[ $(string::length "$emptystring") -eq 0 ]] || die
    [[ $(string::length "$nosuchstring") -eq 0 ]] || die

    [[ $(string::tolower "$mystring") == "hello, world!" ]] || die
    [[ $(string::toupper "$mystring") == "HELLO, WORLD!" ]] || die
    [[ $(string::tolower "$emptystring") == "" ]] || die
    [[ $(string::toupper "$emptystring") == "" ]] || die
    [[ $(string::tolower "$nosuchstring") == "" ]] || die
    [[ $(string::toupper "$nosuchstring") == "" ]] || die

    [[ $(string::replacefirst "$mystring" l L)       == "HeLlo, world!" ]] || die
    [[ $(string::replaceall   "$mystring" l L)       == "HeLLo, worLd!" ]] || die
    [[ $(string::replacefirst "$mystring" world Joe) == "Hello, Joe!"   ]] || die
    [[ $(string::replaceall   "$mystring" world Joe) == "Hello, Joe!"   ]] || die
    [[ $(string::replacefirst "$mystring" x X)       == "Hello, world!" ]] || die
    [[ $(string::replaceall   "$mystring" x X)       == "Hello, world!" ]] || die
    [[ $(string::replacefirst "$mystring" ", " --)   == "Hello--world!" ]] || die
    [[ $(string::replaceall   "$mystring" ", " --)   == "Hello--world!" ]] || die
    [[ $(string::replacefirst "$mystring" ? !)       == "!ello, world!" ]] || die
    [[ $(string::replaceall   "$mystring" ? !)       == "!!!!!!!!!!!!!" ]] || die
    [[ $(string::replacefirst "$nosuchstring" x X)   == ""              ]] || die
    [[ $(string::replaceall   "$nosuchstring" x X)   == ""              ]] || die

    [[ $(string::substr "$mystring" 0 99 ) == "Hello, world!" ]] || die
    [[ $(string::substr "$mystring" 0  3 ) == "Hel" ]] || die
    [[ $(string::substr "$mystring" 10 3 ) == "ld!" ]] || die

    echo "Done!"
}


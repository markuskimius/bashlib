#!/bin/bash

include "bashlib/types.sh"
include "bashlib/mode.sh"

bashlib::strictmode

function main() {
    bashlib::string regex=""

    if (( $# > 0 )); then
        regex="$1"
    fi

    cd "$BASHLIB/lib"

    for file in $(grep -l '__test__' */*.sh); do
        if [[ "$file" =~ "$regex" ]]; then
            include "$file"

            name=$(basename "$file" .sh)

            printf "%-32s" "Testing ${file}..."
            bashlib::$name::__test__
        fi
    done
}

main "$@"

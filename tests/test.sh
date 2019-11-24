#!/bin/bash

cd "$BASHLIB/lib"

for file in $(grep -l '__test__' */*.sh); do
    include "$file"

    name=$(basename "$file" .sh)

    printf "%-32s" "Testing ${file}..."
    bashlib::$name::__test__
done


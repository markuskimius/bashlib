#!/bin/bash

for file in $(grep -l '__test__' $BASHLIB/lib/*/*.sh); do
    name=$(basename "$file" .sh)

    include "$file"
    bashlib::${name}::__test__
done

# for i in $(grep -l '__test__' *); do n=$(basename $i .sh); echo "== $i =="; bash -c "source $i && bashlib::$n::__test__"; done


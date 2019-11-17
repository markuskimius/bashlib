# bashlib
A BASH library framework


## Usage
Add the following to your `~/.bashrc`:

```bash
source /path/to/bashlib/etc/bashrc
export BASHLIB_PATH="$BASHLIB/lib:/path/to/your/lib:/path/to/more/lib"
```

Now your BASH scripts can `include "mylib.sh"` to source `mylib.sh` from a path
in `BASHLIB_PATH`.  Furthermore:

* The filename may be prefixed by a directory name.  E.g., `include
  "mydir/mylib.sh"`sources a file called `mylib.sh` in a subdirectory called
  `mydir` in a path in `BASHLIB_PATH`.  This is useful for namespacing the
  libraries.

* Your script or library can include a file local to its own directory with a
  `./` prefix.  E.g., `include "./mylib.sh"` sources a file called `mylib.sh`
  in the same directory as the caller's file.  This is useful for including a
  file from one's own library even when there is another file by the same name
  in `BASHLIB_PATH`.


## More Information

BASHLIB itself comes with several useful libraries.  See the [API Reference]
for the details.  See also [BASH Notes] for some notes about BASH
programming.


## Example

```bash
include "bashlib/types.sh"
include "bashlib/array.sh"

function main() {
    array students
    var person

    array::push students "John"
    array::push students "Jane"
    array::push students "Mary"
    array::push students "Steve"

    echo "I have $(array::count students) students in my class:"

    for person in "${array[@]}"; do
        echo "$person"
    done
}

main "$@"
```


## License

[Apache 2.0]


[Apache 2.0]: <https://github.com/markuskimius/bashlib/blob/master/LICENSE>
[API Reference]: <https://github.com/markuskimius/bashlib/blob/master/doc/api.md>
[BASH Notes]: <https://github.com/markuskimius/bashlib/blob/master/doc/bash.md>


# bashlib
A BASH library framework


## Usage
Add the following to your `~/.bashrc`:

```bash
source /path/to/bashlib/etc/bashrc
export BASHLIB_PATH="$BASHLIB/lib:/path/to/your/lib:/path/to/more/lib"
```

Now your BASH scripts can `include "mylib.sh"` to source `mylib.sh` in a directory in `BASHLIB_PATH`. Furthermore:

* You can namespace your libraries by putting them in subdirectories. E.g., `include "mydir/mylib.sh"`sources a file called `mylib.sh` in a subdirectory called `mydir` in any of the directories in `BASHLIB_PATH`.
* You can include a file local to your running script or library. E.g., `include "./mylib.sh"` sources a file called `mylib.sh` local to the file from which the `include` call is made. This is useful if you want to source one file from another file in the same library and want to guarantee that it is including the file from the same library and not another file with the same name in `BASHLIB_PATH`.
* You will get an error when attempting to include file that exists under multiple 


## License

[Apache 2.0]


[Apache 2.0]: <https://github.com/markuskimius/getopt-tcl/blob/master/LICENSE>

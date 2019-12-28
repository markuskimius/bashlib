# bashlib API Documentation

Table of Contents:

* General
    * [`bashlib/globals.sh`](#globals) - predefined globals
    * [`bashlib/mode.sh`](#mode) - for enabling/disabling strict mode
    * [`bashlib/types.sh`](#types) - for declaring variables
    * [`bashlib/inspect.sh`](#inspect) - for inspecting variables
    * [`bashlib/alias.sh`](#alias) - for inspecting aliases
    * [`bashlib/function.sh`](#function) - for inspecting functions
* Built-in Types
    * [`bashlib/string.sh`](#string) - string operations
    * [`bashlib/char.sh`](#char) - character operations
    * [`bashlib/int.sh`](#int) - integer operations
    * [`bashlib/array.sh`](#array) - array operations
    * [`bashlib/hashmap.sh`](#hashmap) - hashmap operations
    * [`bashlib/reference.sh`](#reference) - reference operations
* Custom Types
    * [`bashlib/list.sh`](#list) - creation and manipulation of space-separated values
    * [`bashlib/class.sh`](#class) - class operations
    * [`bashlib/singleton.sh`](#singleton) - a class type that is instantiated only once
* Control
    * [`bashlib/namespace.sh`](#namespace) - manipulation of namespaces
    * [`bashlib/exception.sh`](#exception) - exception handling
* Utilities
    * [`bashlib/file.sh`](#file) - file operations
    * [`bashlib/logger.sh`](#logger) - For logging messages
    * [`bashlib/getopt.sh`](#getopt) - GNU-like getopt that accepts long options, optional arguments, etc.

## <a name="globals"></a>`bashlib/globals.sh`

* `BASHLIB_SCRIPTNAME` - The name of the main application script.


## <a name="mode"></a>`bashlib/mode.sh`

* `bashlib::mode::strict` - Enables strict mode.  In this mode:
  * Files may not be overwritten by a pipe redirection.  To redirect with the
    intention to overwrite the file, delete it first,

  * A nonzero return value by any function or child process causes the script
    to terminate with an error message, unless the return value is evaluated
    (e.g., in an `if` or `while` condition, or in a `||` or `&&` operation.)

* `bashlib::mode::extended` - Enables extended mode.  In this mode, extended
  set of globbing operation is enabled.  See `extglob` and `globstar` in the
  BASH manual for more information.


## <a name="types"></a>`bashlib/types.sh`

This file includes aliases for declaring variables:

* `bashlib::string myvariable[=value]` - Declares a variable named `myvariable`
  and optionally initialize it with a value.

* `bashlib::int myinteger[=value]` - Declares an integer variable named
  `myinteger` and optionally initialize it with a value. If not initialized,
  its default value is `0`. Attempt to assign a string value assigns it 0.

* `bashlib::const myconst=value` - Declares a string constant.

* `bashlib::array myarray[=( value1 value2 ... )]` - Declares an array variable
  named `myarray` and optionally initialize it.

* `bashlib::hashmap mymap[=( [key1]=value1 [key2]=value2 ... )]` - Declares an
  associative array variable named `mymap` and optionally initialize it.

* `bashlib::reference myref=myvariable` - Declares a reference to variable
  `variable` named `myref`. Any assignment to `myref` or its reading subsequent
  to initialization modifies and reads `myvariable`.

To declare the variable globally, pass the `-g` option.  A variable declared
outside of a function without the `-g` option will have the file scope only on
the first pass; it will not be accessible in a function.


## <a name="inspect"></a>`bashlib/inspect.sh`

* `bashlib::defined myvariable` - Returns true if `myvariable` has already been
  declared, false otherwise.

* `bashlib::isset myvariable` - Returns true if `myvariable` has been set with
  a value in addition to having been defined.

* `bashlib::typeof myvariable` - Returns the type of `myvariable` which may be one of:
  'string', 'int', 'array', 'hashmap', 'alias', 'function', or 'undefined'. If
  `myvariable` is a reference, the type of the variable it references is
  returned instead.

## <a name="alias"></a>`bashlib/alias.sh`
## <a name="function"></a>`bashlib/function.sh`

## <a name="string"></a>`bashlib/string.sh`
## <a name="char"></a>`bashlib/char.sh`
## <a name="int"></a>`bashlib/int.sh`
## <a name="array"></a>`bashlib/array.sh`
## <a name="hashmap"></a>`bashlib/hashmap.sh`
## <a name="reference"></a>`bashlib/reference.sh`

## <a name="list"></a>`bashlib/list.sh`
## <a name="class"></a>`bashlib/class.sh`
## <a name="singleton"></a>`bashlib/singleton.sh`

## <a name="namespace"></a>`bashlib/namespace.sh`
## <a name="exception"></a>`bashlib/exception.sh`

## <a name="file"></a>`bashlib/file.sh`
## <a name="logger"></a>`bashlib/logger.sh`
## <a name="getopt"></a>`bashlib/getopt.sh`


## License

[Apache 2.0]


[Apache 2.0]: <https://github.com/markuskimius/bashlib/blob/master/LICENSE>


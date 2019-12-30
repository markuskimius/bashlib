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

* `$BASHLIB_SCRIPTNAME` - The name of the main application script.


## <a name="mode"></a>`bashlib/mode.sh`

* `bashlib::mode::strict` - Enable strict mode.  In this mode, (1) an attempt
  to read an unassigned variable terminates the program, (2) a non-zero return
  value by a call to a function or a program terminates the program, and (3) a
  file may not be overwritten by redirection.

* `bashlib::mode::extended` - Enable extended glob matching.  See `extglob`
  and `globstar` in the BASH manual for more information.


## <a name="types"></a>`bashlib/types.sh`

* `bashlib::string mystr[=myvalue]` - Declare a string variable named `mystr`
  and optionally initialize it with `myvalue`.

* `bashlib::int myint[=myvalue]` - Declare an integer variable named `myint`
  and optionally initialize it with `myvalue`.  If not initialized, the
  variable defaults to 0.

* `bashlib::const myconst=myvalue` - Declare a constant named `myconst` with
  `myvalue`.

* `bashlib::array myarray[=( myvalue1 myvalue2 ... )]` - Declare an array
  variable named `myarray` and optionally initialize it.

* `bashlib::hashmap mymap[=( [mykey1]=myvalue1 [mykey2]=myvalue2 ... )]` -
  Declare an associative array variable named `mymap` and optionally initialize
  it.

* `bashlib::reference myref=myvariable` - Declare a reference named `myref` to
  variable `myvariable`.  Any assignment to `myref` or its reading subsequent to
  initialization modifies and reads `myvariable`.

Pass the `-g` option to declare the variable globally.


## <a name="inspect"></a>`bashlib/inspect.sh`

* `bashlib::defined myvariable` - Return true if `myvariable` has already been
  declared, false otherwise.

* `bashlib::isset myvariable` - Return true if `myvariable` has been set,
  false otherwise.

* `bashlib::typeof myvariable` - Return the type of `myvariable` which may be
  `string`, `int`, `array`, `hashmap`, `alias`, `function`, or `undefined.`  If
  `myvariable` is a reference, the type of the variable it references is
  returned.

## <a name="alias"></a>`bashlib/alias.sh`

* `bashlib::alias::names [regex]` - Echo the names of aliases matching
  `regex`.  If no `regex` is specified, all names are echo'ed. 


## <a name="function"></a>`bashlib/function.sh`

* `bashlib::function::names [regex]` - Echo the names of functions matching
  `regex`.  If no `regex` is specified, all names are echo'ed. 


## <a name="string"></a>`bashlib/string.sh`

* `bashlib::string::length mystring` - Echo the length of `mystring`.

* `bashlib::string::tolower mystring` - Echo `mystring` in lower case.

* `bashlib::string::toupper mystring` - Echo `mystring` in upper case.

* `bashlib::string::replacefirst haystack needle replacement` - Echo `haystack`
  with the first occurrence of `needle` replaced by `replacement`.

* `bashlib::string::replaceall haystack needle replacement` - Echo `haystack`
  with all occurrences of `needle` replaced by `replacement`.

* `bashlib::string::substr mystring myindex mylength` - Echo `mylength`
  characters from `mystring` starting at `myindex`.

* `bashlib::string::split mystring delim outarray` - Split `mystring` by
  `delim` and save them to `outarray`.

* `bashlib::string::join delim [token1] [token2] ...` - Echo the `tokens`
  joined by `delim`.

* `bashlib::string::encode mystring` - Echo the encoded form of `mystring`.
  There is no guarantees about the presentation of the encoding except that it
  is guaranteed to include no default IFS character (space, tab, or newline)
  and is decodable.

* `bashlib::string::decode myencoded` - Echo the decoded form of `myencoded`.


## <a name="char"></a>`bashlib/char.sh`

* `bashlib::char::chr mynumber [outc]` - Echo the character representated by
  `mynumber`, or copy the character to `outc` if `outc` is specified.

* `bashlib::char::ord mychar` - Echo the numerical representation of `mychar`.


## <a name="int"></a>`bashlib/int.sh`

* `bashlib::int::isint mystring` - Return true if `mystring` is a valid integer
  representation, false otherwise.


## <a name="array"></a>`bashlib/array.sh`

* `bashlib::array::length myarray` - Echo the length of `myarray`.

* `bashlib::array::front myarray` - Echo the first element of `myarray`.

* `bashlib::array::back myarray` - Echo the last element of `myarray`.

* `bashlib::array::push myarray myvalue` - Add `myvalue` to the end of `myarray`.

* `bashlib::array::pop myarray` - Remove the last element of `myarray`.

* `bashlib::array::shift myarray` - Remove the first element of `myarray`.

* `bashlib::array::unshift myarray myvalue` - Add `myvalue` to the front of `myarray`.

* `bashlib::array::insert myarray myindex [myvalue1] [myvalue2] ...` - Insert
  `myvalues` to `myarray` at `myindex`.

* `bashlib::array::delete myarray myindex [count]` - Delete `count` elements
  from `myarray` at `myindex`.  The default value of `count` is 1.

* `bashlib::array::dump myarray` - Print the contents of `myarray` to stdout.

* `bashlib::array::clear myarray` - Delete the contents of `myarray`.

* `bashlib::array::hasindex myarray myindex` - Return true if `myarray` has
  `myindex`, false otherwise.

* `bashlib::array::hasvalue myarray myvalue` - Return true if `myarray` has
  `myvalue`, false otherwise.

* `bashlib::array::indexof myarray myvalue` - Echo the first index of `myarray`
  with `myvalue`.

* `bashlib::array::copy mysource mytarget` - Copy `mysource` to `mytarget`.

* `bashlib::array::map myarray myfunc [mytarget]` - Apply `myfunc` to every
  element of `myarray`.  The results are saved to `mytarget` if specified,
  `myarray` otherwise.

* `bashlib::array::sort myarray [mytarget]` - Sort the elements of `myarray`.
  The results are saved to `mytarget` if specified, `myarray` otherwise.


## <a name="hashmap"></a>`bashlib/hashmap.sh`

* `bashlib::array::length myhashmap` - Echo the length of `myhashmap`.

* `bashlib::array::haskey myhashmap mykey` - Return true if `myhashmap` has
  `mykey`, false otherwise.

* `bashlib::array::hasvalue myhashmap myvalue` - Return true if `myhashmap` has
  `myvalue`, false otherwise.

* `bashlib::array::keyof myhashmap myvalue` - Echo the key of `myhashmap`
  with `myvalue`.

* `bashlib::array::valueof myhashmap mykey` - Echo the value of `myhashmap`
  at `mykey`.

* `bashlib::array::set myhashmap mykey myvalue` - Insert
  `myvalues` to `myhashmap` at `mykey`.

* `bashlib::array::delete myhashmap mykey [count]` - Delete `count` elements
  from `myhashmap` at `mykey`.  The default value of `count` is 1.

* `bashlib::array::dump myhashmap` - Print the contents of `myhashmap` to stdout.

* `bashlib::array::clear myhashmap` - Delete the contents of `myhashmap`.

* `bashlib::array::copy mysource mytarget` - Copy `mysource` to `mytarget`.

* `bashlib::array::map myhashmap myfunc [mytarget]` - Apply `myfunc` to every
  element of `myhashmap`.  The results are saved to `mytarget` if specified,
  `myhashmap` otherwise.


## <a name="reference"></a>`bashlib/reference.sh`

* `bashlib::bashlib::realvar myreference` - Return the name of the variable
  referenced by `myreference`.  If the reference references another reference,
  the variable it references is returned, etc.


## <a name="list"></a>`bashlib/list.sh`

A list is a string but it can store elements like an array.  It is slower to
access than an array but is useful in situations where arrays cannot be used.
E.g., to return elements from a function, export elements to a subshell,
store elements in one index of an array, etc.

* `bashlib::list [mystring1] [mystring2] ...` - Echo a list consisting
  `mystrings` as its elements.

* `bashlib::list::llength mylist` - Echo the number of elements in `mylist`.

* `bashlib::list::lappend mylist [myvalue1] [myvalue2] ...` - Append `myvalues`
  to `mylist`.

* `bashlib::list::lindex mylist myindex` - Return the value at `myindex` in
  `mylist`.

* `bashlib::list::lsearch mylist myvalue` - Return the index of `myvalue` in
  `mylist`.  Return -1 if the value does not exist in the list.


## <a name="class"></a>`bashlib/class.sh`

* `bashlib::class::create myclass myobject [myarg1] [myarg2] ...` - Instantiate
  `myclass` as `myobject`.  Optional `myargs` may be passed to `myclass`'s
  constructor.

Writing a class:

* `function myclass::mymethod myobject() { ... }` - `myclass::mymethod` is
  called using the format `myobject mymethod [myarg1] [myarg2] ...`.
  `myobject` is passed as the first argument to the function, followed by
  `myargs`.

* `function myclass::__constructor__() { ... }` - `myclass`'s
  constructor is called by `bashlib::class::create`.

Reserved methods:

* `myobject __set__ myvarname myvalue` - Set the member variable `myvarname` to
  `myvalue`.

* `myobject __set__ myvarname` - Echo the value of the member variable `myvarname`.

* `myobject __has__ myvarname` - Return true if `myvarname` is a member
  variable, false otherwise.


## <a name="singleton"></a>`bashlib/singleton.sh`

* `bashlib::singleton myclass [myarg1] [myarg2] ...` - Instantiate the
  class `myclass` as `myclass`.  This is equivalent to `bashlib::class::create`
  with the name of the class and object set the same.


## <a name="namespace"></a>`bashlib/namespace.sh`

* `using mynamespace::mymethod` - Import the alias or function named
  `mynamespace::mymethod` into the global scope.

* `using namespace mynamespace [asnamespace]` - Import all aliases and functions from
  `mynamespace` into the `asnamespace` namespace, or into the global scope if
  `asnamespace` is not specified.


## <a name="exception"></a>`bashlib/exception.sh`

* `bashlib::throw [mymessage] [depth]` - Exit the current program with the
  error message `mymessage` and dump the stacktrace starting at `depth`.  The
  default depth is 0.

* `bashlib::dump_stacktrace [depth]` - Dump the stack trace starting at
  `depth`.  The default depth is 0.


## <a name="file"></a>`bashlib/file.sh`

* `bashlib::file::exists mypath` - Return true if `mypath` exists, false otherwise.

* `bashlib::file::isdir mypath` - Return true if `mypath` is a directory, false otherwise.

* `bashlib::file::isfile mypath` - Return true if `mypath` is a file, false otherwise.

* `bashlib::file::isreadable mypath` - Return true if `mypath` is readable, false otherwise.

* `bashlib::file::iswritable mypath` - Return true if `mypath` is writable, false otherwise.

* `bashlib::file::isexecutable mypath` - Return true if `mypath` is executable, false otherwise.

* `bashlib::file::issymlink mypath` - Return true if `mypath` is a symlink, false otherwise.

* `bashlib::file::isempty myfile` - Return true if `myfile` is empty, false otherwise.

* `bashlib::file::isnonempty myfile` - Return true if `myfile` is not empty, false otherwise.

* `bashlib::file::is myfile1 myfile2` - Return true if `myfile1` is `myfile2`, false otherwise.

* `bashlib::file::isnewerthan myfile1 myfile2` - Return true if `myfile1` is newer than `myfile2`, false otherwise.

* `bashlib::file::isolderthan myfile1 myfile2` - Return true if `myfile1` is older than `myfile2`, false otherwise.


## <a name="logger"></a>`bashlib/logger.sh`

* `bashlib::writelog [myloglevel] mymessage` - Write `mymessage` to stdout if
  `myloglevel` is a token in a space-separated list of tokens in the
  environment variable `$BASHLIB_LOGLEVEL`, or is the string literal `ERROR`.
  The default `myloglevel` is `INFO`.


## <a name="getopt"></a>`bashlib/getopt.sh`

* `bashlib::getopt shortopts longopts "$@"` - A getopt wrapper around the GNU
  `getopt` program that simplifies its syntax.  See the [getopt.sh] source code
  for an example.


## License

[Apache 2.0]


[Apache 2.0]: <https://github.com/markuskimius/bashlib/blob/master/LICENSE>
[getopt.sh]: <https://github.com/markuskimius/bashlib/blob/master/src/bashlib/lib/bashlib/getopt.sh>


# Notes on BASH

These notes are current as of BASH 4.4.


## <a name="types"></a>Variables

The only primitive type BASH supports natively is the string, which is the
default type if a variable is used without a declaration.  BASH also offers an
integer type that is effectively a string type that enforces a valid integer
representation in the decimal format; an integer variable defaults to 0 if it's
not initialized, or an invalid integer representation is attempted to be
assigned to it.

BASH also natively supports arrays and hashmaps.  The BASH documentation
actually refers to them as _indexed_ arrays and _associative_ arrays,
respectively.  Indexed arrays may be sparse.  An array (of either kind) may be
declared as a type that contains strings or integers.  Multi-dimensional arrays
are not supported.

Any of these variable types may also be declared read-only.

BASH 4.3 introduced a reference type.  A reference is like a pointer that
doesn't require a dereference operator to read from or write to, and can only
point to a single variable during its lifetime.  It may reference a string,
an integer, an array of either kind, or an element within an array.

Declaring a variable is done natively in BASH using `declare`, `typeset`, or
`local` keywords and passing the appropriate flags.  To make the code more
readable BASHLIB provides the following aliases:

* `string`
* `int`
* `array` for an indexed string array, `array -i` for the integer variant.
* `hashmap` for an associative string array, `array -i` for the integer variant.
* `const` for a read-only string, `const -i` for the integer variant.
* `reference` for a reference.

`-a` and `-A` may also be passed to `const` to declare a indexed or associative
array, respectively.

These aliases are provided in `bashlib/types.sh`.


## <a name="scope"></a>Scope

The scope of a variable is the function within which it is declared.

BASH also extends the scope of a variable to any called function, so a called
function may modify the variables of its caller.  The exception to this rule is
if the function is called within a subshell using `$()`, `()`, or ``, frequently
used to assign the return string of a function to a variable. (see [Returning
a Value](#return)).

This exception exists because a subshell inherits a _copy_ of the caller's
environment, so modifications made to variables (or functions, or aliases, or
anything else in the environment) are lost when the subshell returns.  So in a
manner of speaking the scope of a variable can also be viewed as being limited
to the subshell as well.


## <a name="return"></a>Returning a Value

The `return` keyword can be used by a function to return an integer value
between -128 and 127, which limits the usefulness of the keyword.  So in
practice the `return` keyword is only used to return an error code, similar to
how programs use `exit` to return error code, or to return a true/false Boolean
value (see [Boolean Logic](#boolean)).

To return any other type of value, a function typically `echo`s the value to
`stdout`, and the caller captures it into a variable using a subshell.  For
example:

```bash
myvar=$(myfunction)
```

As noted in the [scope section](#scope), however, any modification made to the
environment within the subshell are lost upon its completion, so a function
called in such manner must be stateless.

To write a stateful function that returns a value, the value must be returned
using another technique.  One such technique is for the caller to pass the name
of a variable to the function to which it wants the value(s) written.  For
example:

```bash
function myfunction() {
    reference to_be_returned=$1

    to_be_returned="Hello, world!"
}

myfunction returned
echo $returned
```

There is a caveat, however, that if the name of the variable passed to
`myfunction` is identical to the name of the reference it instantiates, then
BASH interprets the reference instantiation as a circular reference, and raises
an error:

```bash
function myfunction() {
    reference returned=$1    # returned=returned is a circular reference
                             # declare: warning: returned: circular name reference
    returned="Hello, world!"
}

myfunction returned
echo $returned
```

To avoid such error, it is a good practice to use a unique name for all
references.  In BASHLIB, all references are namedspaced with the prefix
`__bashlib_` to avoid such error.


## <a name="boolean"></a>Boolean Logic

Deviating from the common convention, BASH treats 0 as true and nonzero as false
when evaluating the *return value* from a function or a program.  This can be
seen in the following code:

```bash
$ $( exit 0 ) && echo true || echo false
true
$ $( exit 1 ) && echo true || echo false
false
```
However, the normal convention is used when evaluating expressions within
`(())`:

```bash
$ (( 0 )) && echo true || echo false
false
$ (( 1 )) && echo true || echo false
true
$
```
Be careful not to get `(())` confused with `[[]]`; while the former is used to
do arithematic calculation, the latter is used for various operations including
string operations, where `0` is treated as a non-zero-length string which
evaluates to true:

```bash
$ [[ 0 ]] && echo true || echo false
true
$ [[ 1 ]] && echo true || echo false
true
$
```
To avoid confusion, use the following rules:
* Use `(())` for numerical calculations.
* Use `[[]]` for string and file expressions.
* Never use the return value from a function or a program inside `(())` or
  `[[]]`.


## Operations

Assigning a value to a variable is done with the assignment operator `=`, which
may not have any whitespace before or after the operator:

```bash
myvar="Hello, world!"      # Ok
myvar = "Hello, world!"    # Bad
```
If the variable is an integer, the value may be an arithmetic calculation:

```bash
int myint

myint="3**2 + 7"           # myint=16
```
It is also possible to perform an arithmetic calculation and assign it to a
variable using the `let` keyword or the `(())` compound command.  However, using
these to change the value of a variable is not recommended because they have the
side effect of returning a nonzero error code which terminates the BASH script
when the strict mode is enabled:

```bash
include "mode.sh"

mode::strict

let a=1-1    # returns nonzero which terminates the script in strict mode
((a=1-1))    # same.
```

To perform an arithmetic calculation and assign it to a non-integer variable,
use `$(())` instead:

```
include "mode.sh"

mode::strict

a=$((1-1))   # Ok
```


## License

[Apache 2.0]


[Apache 2.0]: <https://github.com/markuskimius/bashlib/blob/master/LICENSE>

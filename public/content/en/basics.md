# D's basics
# Import's & Modules

To write a simple hello world program in D you need
`import`s. The `import` statement makes all public functions
and types from the given **module** available.

The standard library is located under the *package* `std`
and those modules are referenced through `import std.MODULE`.

The import statement can also be used to selectively
import certain symbols of a module:

    import std.stdio: writeln, writefln;

An import statement mustn't appear at the top a source file.
It can also be used locally within functions.

The *package* name is induced from the parent folder's name.
So all modules in the directoy `mypkg` can be imported
using `import mypkg.module`.

## {SourceCode}

// Either: import std.stdio;
// or import std.stdio: writeln;

void main()
{
    // This works too:
    import std.stdio;
    writeln("Hello World!");
}

# Basic types

D provides a number of basic types which have always have the same
size **regardless** of the platform - the only exception
is the `real` which provides the highest possible floating point
precision. There is no difference
between the size of an *integer* regardless whether the application
is compiled for 32bit or 64bit systems.

    bool                 (8 bit)
    byte, ubyte, char    (8 bit)
    short, ushort, dchar (16 bit)
    int, uint, wchar     (32 bit)
    long, ulong          (32 bit)

Floating point types:

    float                (32 bit)
    double               (64 bit)
    real                 (depending on platform, 80 bit on x64)

The prefix `u` denotes *unsigned* types. `char` translates to
UTF-8 characters, `dchar` is used in UTF-16 strings and `dchar`
in UTF-32 strings.

A conversion between variables of different types is only
allowed by the compiler if no precision is lost.

A conversion to another type may be forced by using the
`cast(TYPE) var` expression.

The special keyword `auto` creates a variable and infers its
type from the right hand side of the expression. `auto var = 7`
will deduce the type `int` for `var`. Note that the type is still
set at compile-time and can't be changed, just like with any other
variable with an explicitely given type.

## {SourceCode}

import std.stdio;

void main()
{
    int b = 7;
    short c = cast(short) b; // cast needed here.
    uint d = b; // fine

    auto f = 3.1415f; // postfix f denotes a float
    // typeof(VAR) returns the type of an expression
    // .name is a builtin property
    writeln("type of f is %s", typeof(f).name);
    double pi = f; // fine
    // would be an error:
    // float bad = pi;
}

# Arrays

The are two types of Arrays in D: **static** and **dynamic**
arrays.

**static** arrays are stored on the *stack* and have a fixed,
compile-time known *length*. An static array's type includes
the fixed size:

    int[8] arr;

`arr`s tye is `int[8]`. Note that the size of the array is denoted
near the type and not after the variable name like in *C/C++*.

**dynamic** arrays are stored on the *heap* and can be expanded
or shrunk at runtime. A dynamic is created using a `new` expression
and its length:

    int size = 8; // run-time variable
    auto arr = new int[size];

The type of `arr` is `int[]` which is technically a
**slice** - those are introduced in the next section.

Both static and dynamic array provide the property `.length`
which is read-only for static arrays but can be written to
in case of dynamic arrays to change its size dynamically.

When indexing an array through the `arr[idx]` syntax the special
`$` syntax denotes an array's length. `arr[$ - 1]` thus
references the last element and is a short form for `arr[arr.length - 1]`.

## {SourceCode}

# Slices

...

# All the for's

...

* Breaking out of outer for loop.

# Ranges

...

# Storage classes

* shared
* immutable
* const


# Associative Arrays

- AA

# Classes & Interfaces

...

# Structs

...

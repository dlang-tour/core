# D's basics
# Import's & Modules

To write a simple hello world program in D you need
`import`s. The `import` statement makes all public functions
and types from the given **module** available.

The standard library, called [Phobos](https://www.dlang.org/phobos/),
is located under the *package* `std`
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

All integers are initialized with `0`, floating points
with `NaN` (not a number) - unless another value is given
during initialization.

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

# Memory

D is a system programming language and thus allows to manually
manage and mess up *your* memory. Nevertheless D uses a
*garbage collector* per default to free up unused memory.

D provides pointer types `T*` like in C for example:

    int a;
    int* b = &a; // b contains address of a
    auto c = &a // c is int* and contains address of a

A new memory block on the heap is allocated using the
`new` expression which returns a pointer to the managed
memory:

    int* a = new int;

As soon as the memory referenced by `a` isn't referenced anymore
through any variable in the program, the garbage collector
will free its memory.

D also allows pointer arithmetic. This is *not* allowed in
code which is marked as `@safe`
but only in `@system` code.

    void main() @safe {
        int* p = &a;
        int* c = a + 5; // error
    }

Unless specified otherwise the default is `@system`.

## {SourceCode}
//TODO

# Functions

...

# Structs

One way to define compound or custom types in D is to
define them through a `struct`:

    struct Person {
        int age;
        int height;
        float ageXHeight;
    }

`struct`s are always constructed on the stack (unless created
with `new`) and are copied by value in assignments or
function calls.

    Person p(30, 180, 3.1415);
    auto t = p; // copy

When a new object is created of a `struct` its members can be initialized
in the order they are defined in the `struct`. A custom constructor
is defined through a `this(...)` member function:

    struct Person {
        this(int age, int height) {
            this.age = age;
            this.height = height;
            this.ageXHeight = cast(float)age * height;
        }
            ...
    
    Person p(30, 180);

## {SourceCode}

//TODO

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
or shrunk at runtime. A dynamic array is created using a `new` expression
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

import std.stdio;

void main()
{
    // TODO
}

# Slices

Slices are objects from type `T[]` for any given type `T`.
Slices provide a view on a subset (or the whole) of an array
of `T` values.

...

# All the classic for's

D provides four loop constructs.

The classical `for` loop known from C, Java and the like
with initiliazer, loop condition and loop statement:

    for (int i = 0; i < arr.length; ++i) {
        ...

The `while` and `do .. while` loops execute the
given code block while a certain condition is met:

    while (condition) {
        foo();
    }
    
    do {
        foo();
    } while (condition);

The `foreach` loop which will be introduced in the
next section.

The special keyword `break` will immediately abort the current loop.
If we are in a nested loop a label can be used to break any outer loop:

    outer: for (int i = 0; i < 10; ++i) {
        for (int j = 0; j < 5; ++j) {
            ...
            break outer;

The keyword `continue` starts with the next loop iteration.

## {SourceCode}

//TODO

# Foreach

D features a `foreach` loop which makes iterating
through data less error-prone and easier to read.

Given an array `arr` of type `int[]` it is possible to
iterate through the elements using this `foreach` loop:

    foreach(int e; arr) {
        writeln(i);
    }

The first field in the `foreach` definition is the variable
name used in the loop iteration. Its type can be omitted
and it is induced like done when declaring variables with `auto`:

    foreach(e; arr) {
        // typoef(e) is int
        writeln(e);
    }

The second field must be an array - or a special iterable
object called a **range** which will be introduced in the next section.

Elements will be copied from the array or range during iteration -
this is okay for basic types but might be a problem for
large types. To prevent copying or enable in-place
*mutation* use `ref`:

    foreach(ref e; arr) {
        e = 10; // overwrite value
    }

## {SourceCode}

// TODO

# Ranges

...

# Storage classes

* shared
* immutable
* const


# Associative Arrays

D has builtin *associative arrays* - also known as hash maps.
An associative arry with a key type of `int` and a value type
of `string` is declared as follows:

    int[string] arr;

The syntax follows the actual usage of the hashmap:

    arr["key1"] = 10;

To test whether a key is located in the associative array, the
`in` expression should be used:

    if ("key1" in arr)
        writeln("Yes");

The `in` expression actually returns a pointer to the value
which is not `null` when found:

    if (auto test = "key1" in arr)
        *test = 20;

Access to a key which doesn't exist yields an `RangeError`
that immediately aborts the application.

AA's have the `.length` property like arrays and provide
a `.remove(val)` member to remove entries by their key.
The special `.byKeys` and `.byValues` return ranges which
do something which is left as an exercise to the reader.

## {SourceCode}

int[int][string]

# Classes & Interfaces

...

# Templates

...

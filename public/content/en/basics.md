# D's Basics
# Imports and modules

To write a simple hello world program in D you need
`import`s. The `import` statement makes all public functions
and types from the given **module** available.

The standard library, called [Phobos](https://dlang.org/phobos/),
is located under the **package** `std`
and those modules are referenced through `import std.MODULE`.

The import statement can also be used to selectively
import certain symbols of a module. This improves
the already short compile time of D source code.

    import std.stdio: writeln, writefln;

An import statement need not appear at the top a source file.
It can also be used locally within functions.

## {SourceCode}

void main()
{
    import std.stdio;
    // or import std.stdio: writeln;
    writeln("Hello World!");
}

# Basic types

D provides a number of basic types which always have the same
size **regardless** of the platform - the only exception
is the `real` type which provides the highest possible floating point
precision. There is no difference
between the size of an integer regardless whether the application
is compiled for 32bit or 64bit systems.

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">bool</code></td> <td>8-bit</td></tr>
<tr><td><code class="prettyprint">byte, ubyte, char</code></td> <td>8-bit</td></tr>
<tr><td><code class="prettyprint">short, ushort, wchar</code></td> <td>16-bit</td></tr>
<tr><td><code class="prettyprint">int, uint, dchar</code></td> <td>32-bit</td></tr>
<tr><td><code class="prettyprint">long, ulong</code></td> <td>64-bit</td></tr>
</table>

#### Floating point types:

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">float</code></td> <td>32-bit</td></tr>
<tr><td><code class="prettyprint">double</code></td> <td>64-bit</td></tr>
<tr><td><code class="prettyprint">real</code></td> <td>depending on platform, 80 bit on Intel x86 32-bit</td></tr>
</table>

The prefix `u` denotes *unsigned* types. `char` translates to
UTF-8 characters, `wchar` is used in UTF-16 strings and `dchar`
in UTF-32 strings.

A conversion between variables of different types is only
allowed by the compiler if no precision is lost. A conversion
between floating point types (e.g `double` to `float`)
is allowed though.

A conversion to another type may be forced by using the
`cast(TYPE) var` expression.

The special keyword `auto` creates a variable and infers its
type from the right hand side of the expression. `auto var = 7`
will deduce the type `int` for `var`. Note that the type is still
set at compile-time and can't be changed - just like with any other
variable with an explicitly given type.

If no other value is given in the declaration all integers
are initialized with `0` and floating points
with `NaN` (*not a number*).

## {SourceCode}

import std.stdio;

void main()
{
    // Big numbers can be made more
    // readable with an "_"; it's still
    // a 7000000 though.
    int b = 7_000_000;
    short c = cast(short) b; // cast needed here.
    uint d = b; // fine
    int g; // contains 0

    auto f = 3.1415f; // .f denotes a float
    // typeid(VAR) returns the type information
    // of an expression.
    writeln("type of f is ", typeid(f));
    double pi = f; // fine
    float demoted = pi; // also fine
}

# Memory

D is a system programming language and thus allows you to manually
manage and mess up your memory. Nevertheless, D uses a
*garbage collector* per default to free unused memory.

D provides pointer types `T*` like in C:

    int a;
    int* b = &a; // b contains address of a
    auto c = &a // c is int* and contains address of a

A new memory block on the heap is allocated using the
`new` expression, which returns a pointer to the managed
memory:

    int* a = new int;

As soon as the memory referenced by `a` isn't referenced anymore
through any variable in the program, the garbage collector
will free its memory.

D also allows pointer arithmetic, except in
code that is marked as @safe.

    void main() @safe {
        int a = 5;
        int* p = &a;
        int* c = p + 5; // error
    }

Unless specified otherwise the default is `@system`.
Using `@safe`, a subset of D can be forced to prevent memory bugs by design.
`@safe` code can only call other `@safe` or `@trusted` functions.
`@trusted` functions are manually verified functions and allow to bridge the
world between SafeD and the underlying dirty low-level world.

## {SourceCode}

import std.stdio;

void safeFun() @safe
{
    writeln("Hello World");
    // allocating memory with the GC is safe too
    int* p = new int;
}

void unsafeFun()
{
    int* p = new int;
    int* fiddling = p + 5;
}

void main()
{
    safeFun();
    unsafeFun();
}

# Storage classes

D is a statically typed language: once a variable has been declared,
its type can't be changed from that point onwards. This allows
the compiler to prevent bugs early and enforce restrictions
at compile time.  Good type-safety gives you the support you need
to make large programs safer and more maintainable.

In addition to a static type system, D provides
storage classes that enforce additional
constraints on certain objects. For example an
`immutable` object can just
be initialized once and then isn't
allowed to change - never, ever.

    immutable int err = 5;
    // or: immutable arr = 5 and int is inferred.
    err = 5; // won't compile

`immutable` objects can thus safely be shared among different threads
because they never change by design. And `immutable` objects can
be cached perfectly.

`const` objects can't be modified, too. This
restriction is just valid for the current scope. A `const`
pointer can be created from either a *mutable* or
`immutable` object. That means that the object
is `const` for your current scope, but someone
else might modify it in future. Just with an `immutable`
you will be sure that an object's value will never
change.

    immutable a = 10;
    int b = 5;
    const int* pa = &a;
    const int* pb = &b;
    *pa = 7; // disallowed

## {SourceCode}

import std.stdio;

void main()
{
    immutable forever = 100;
    // ERROR:
    // forever = 5;
    writeln("forever: ",
        typeof(forever).stringof);

    const int* cForever = &forever;
    // ERROR:
    // *cForever = 10;
    writeln("const* forever: ",
        typeof(cForever).stringof);

    int mutable = 100;
    writeln("mutable: ",
        typeof(mutable).stringof);
    mutable = 10; // Fine
    const int* cMutable = &mutable; // Fine
    // ERROR:
    // *cMutable = 100;
    writeln("cMutable: ",
        typeof(cMutable).stringof);

    // ERROR:
    // immutable int* imMutable = &mutable;
}

# Controlling flow

Sometimes you have to control your application's flow
depending on input parameters. `if` and `else` are
your friends:

    if (a == 5) {
        writeln("Condition is met");
    } else if (a > 10) {
        writeln("Another condition is met");
    } else {
        writeln("Nothing is met!");
    }

When an `if`/`else` block just contains one statement
the braces can be omitted.

D provides the same operators as C/C++ and Java for testing
variables for equality or compare them otherwise:

* `==` and `!=` for testing equality and inequality
* `<`, `<=`, `>` and `>=` for testing less (- or equal) and greater (- or equal)

For combining multiple conditions the `||` operator represents
the logical *OR*, and `&&` the logical *AND*.

D also defines a `switch`..`case` statement which lets you take
action depending on the value of *one* variable. `switch`
works with all basic types as well as strings!
It's even possible to define ranges for integral types
using the `case START: .. case END:` syntax. Make sure to
take a look at the source code example.

### In-depth

- [Expressions in detail](https://dlang.org/spec/expression.html)

## {SourceCode}

import std.stdio;

void main()
{
    int c = 5;
    // This is EVIL but works
    if (c >= 0 && c < 11)
    switch(c) {
        case 0: .. case 9:
            writeln(c, " is within 0-9");
            break; // necessary!
        case 10:
            writeln("A Ten!");
            break;
        default: // if nothing else matches
            writeln("Nothing");
            break;
    }
}

# Functions, part I

You've seen one function already: `main()` - the starting point of every
D program. A function may return something - or be declared with
`void` if nothing is returned - and an arbitrary number of parameters.

    int add(int lhs, int rhs) {
        return lhs + rhs;
    }

If the return type is defined as `auto` the D compiler infers the return
type automatically. If the types of different `return` statements within
the function's body don't match the compiler will certainly make you
aware of that.

    auto add(int lhs, int rhs) { // returns `int`
        return lhs + rhs;
    }

Functions might even be declared inside others functions where they may be
used locally and aren't visible to the outside world.
These function can even have access to objects local to
the parent's scope

    void fun() {
        int local = 10;
        int fun_secret() {
            local++; // that's legal
        }
        ...

## {SourceCode}

import std.stdio;
import std.random;

void main()
{
    // Define 4 local functions for
    // 4 different mathematical operations
    auto add(int lhs, int rhs) {
        return lhs + rhs;
    }
    auto sub(int lhs, int rhs) {
        return lhs - rhs;
    }
    auto mul(int lhs, int rhs) {
        return lhs * rhs;
    }
    auto div(int lhs, int rhs) {
        return lhs / rhs;
    }

    int a = 10;
    int b = 5;

    // uniform generates a number between START
    // and END, whereas END is NOT inclusive.
    // Depending on the result we call one of
    // the math operations.
    switch (uniform(0,4)) {
        case 0:
            writeln(add(a,b));
            break;
        case 1:
            writeln(sub(a,b));
            break;
        case 2:
            writeln(mul(a,b));
            break;
        case 3:
            writeln(div(a,b));
            break;
        default:
            // special code which marks
            // UNREACHABLE code
            assert(0);
    }
}

// NOTE:
//   add(), sub(), mul() and div()
//   are NOT visible outside of main!



# Structs

One way to define compound or custom types in D is to
define them through a `struct`:

    struct Person {
        int age;
        int height;
        float ageXHeight;
    }

`struct`s are always constructed on the stack (unless created
with `new`) and are copied **by value** in assignments or
as parameters to function calls.

    auto p = Person(30, 180, 3.1415);
    auto t = p; // copy

When a new object of a `struct` type is created its members can be initialized
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

A `struct` might contain any number of member functions. Those
are per default `public` and accessible from the outside. They might
as well be `private` and thus only be callable by other
member functions of the same `struct` or other code in the same
module.

    struct Person {
        void doStuff() {
            ...
        private void privateStuff() {
            ...

    p.doStuff(); // call method doStuff
    p.privateStuff(); // forbidden

If a member function is declared with `const`, it won't be allowed
to modify any of its members. This is enforced by the compiler.
Making a member function `const` makes it callable on any `const`
or `immutable` object, but also helps callers reason about the
code by offering a guarantee that the member function will never
change the state of the object.

If a member function is declared as `static`, it will be callable
without an instantiated object e.g. `Person.myStatic()` but
isn't allowed to access any non-`static` members.  Use a `static`
member function when you want to work with all instances of a given
`struct`, rather than with one instance in particular, or when the
member function must be usable by callers that don't have an instance
available.  For example, a function that asked how many instances
existed would probably be `static`.

Note that a `struct` can't inherit from another `struct`.
Hierachies of types can only be built using classes,
which we will see in a future section.

### In-depth

- [In detail](https://dlang.org/spec/struct.html)

### Exercise

Given the `struct Vector3` implement the following functions and make
the example application successfully run:

* `length()` which returns the vector's length
* `dot(Vector3)` which returns the dot product of two vectors
* `toString()` which returns a string representation of this vector.
  We don't know strings yet but the function `std.string.format`
  conveniently returns a string using `printf`-like syntax:
  `format("MyInt = %d", myInt)`.

## {SourceCode}

struct Vector3 {
    double x;
    double y;
    double z;

    double length() const {
        import std.math: sqrt;
        return 0.0;
    }

    // rhs will be copied
    double dot(Vector3 rhs) const {
        return 0.0;
    }

    /**
    Returns: representation of the string in the
    special format. The output is restricted to
    a precision of one!
    "x: 0.0 y: 0.0 z: 0.0"
    */
    string toString() const {
        import std.string: format;
        // Hint: refer to the documentation of
        // std.format to see how to influence
        // output for floating point numbers.
        return format("");
    }
}

void main() {
    auto vec1 = Vector3(10.0, 0.0, 0.0);
    Vector3 vec2;
    vec2.x = 0.0;
    vec2.y = 20.0;
    vec2.z = 0.0;

    // If a member function has no parameters,
    // the calling braces () might be omitted
    assert(vec1.length == 10.0);
    assert(vec2.length == 20.0);

    // Test the functionality for dot product
    assert(vec1.dot(vec2) == 0.0);


    // Thanks to toString() we can now just
    // output our vector's with writeln
    import std.stdio: writeln, writefln;
    writeln("My vec1 = ", vec1);
    writefln("My vec2 = %s", vec2);

    // Check the string representation
    assert(vec1.toString() ==
        "x: 10.0 y: 0.0 z: 0.0");
    assert(vec2.toString() ==
        "x: 0.0 y: 20.0 z: 0.0");
}

# Arrays

The are two types of Arrays in D: **static** and **dynamic**
arrays. Access to arrays of any kind are always bounds checked;
a failed range check yields a `RangeError` which aborts the application. The brave
can disable this with the compiler flag `-boundschecks=off` to squeeze
the last cycles out of their binary.

**static** arrays are stored on the stack if defined inside a function
or in static memory otherwise.  They have a fixed,
compile-time known length. An static array's type includes
the fixed size:

    int[8] arr;

`arr`s type is `int[8]`. Note that the size of the array is denoted
near the type and not after the variable name like in C/C++.

**dynamic** arrays are stored on the heap and can be expanded
or shrunk at runtime. A dynamic array is created using a `new` expression
and its length:

    int size = 8; // run-time variable
    int[] arr = new int[size];

The type of `arr` is `int[]` which is a **slice**
and will be explained in more detail in the next section. Multi-dimensional
arrays can be created easily using the `auto arr = new int[3][3]` syntax.

Arrays can be concatenated using the `~` operator which
will create a new dynamic array. Mathematical operations can
be applied to whole arrays using the `c[] = a[] + b[]` syntax.
Those operations might be optimized
by the compiler to use special processors instructions that
do the operations in one go.

Both static and dynamic array provide the property `.length`
which is read-only for static arrays but can be written to
in case of dynamic arrays to change its size dynamically. The
property `.dup` creates a copy of the array.

When indexing an array through the `arr[idx]` syntax the special
`$` syntax denotes an array's length. `arr[$ - 1]` thus
references the last element and is a short form for `arr[arr.length - 1]`.

### Exercise

Complete the function `encrypt` to decrypt the secret message.
The text should be encrypted using *Caesar encryption*
that shifts the characters in the alphabet using a certain index.
The to-be-encrypted text just contains characters in the range `a-z`
which should make things easier.

## {SourceCode}

import std.stdio;

/**
Shifts every character in the
array `input` for `shift` characters.
The character range is limited to `a-z`
and the next character after z is a.

Params:
    input = array to shift
    shift = shift length for each char
Returns:
    Shifted char array
*/
char[] encrypt(char[] input, char shift)
{
    auto result = input.dup;
    // ...
    return result;
}

void main()
{
    // We will now encrypt the message with
    // Caesar encryption and a
    // shift factor of 16!
    char[] toBeEncrypted = [ 'w','e','l','c',
      'o','m','e','t','o','d',
      // The last , is okay and will just
      // be ignored!
    ];
    writeln("Before: ", toBeEncrypted);
    auto encrypted = encrypt(toBeEncrypted, 16);
    writeln("After: ", encrypted);

    // Make sure we the algorithm works
    // as expected
    assert(encrypted == [ 'm','u','b','s','e',
            'c','u','j','e','t' ]);
}

# Slices

Slices are objects from type `T[]` for any given type `T`.
Slices provide a view on a subset of an array
of `T` values - or just point to the whole array.
**Slices and dynamic arrays are the same.**

A slice consists of two members - a pointer to the starting element and the
length of the slice:

    T* ptr;
    size_t length; // unsigned 32 bit on 32bit, unsigned 64 bit on 64bit

If a new dynamic array is created, we get a slice to that freshly
allocated memory:

    auto arr = new int[5];
    assert(arr.length == 5); // memory referenced in arr.ptr

Using the `[Start .. End]` syntax a sub-slice is constructed from an existing
slice:

    auto newArr = arr[1 .. 4]; // index 4 ist NOT included
    assert(newArr.length == 3);
    newArr[0] = 10; // changes newArr[0] aka arr[1]

Slices generate a new view on existing memory. They *don't* create
a new copy. If no slice holds a reference to that memory anymore - or a *sliced*
part of it - it will be freed by the garbage collector.

Using slices it's possible to write very efficient code for e.g. parsers
that just operate on one memory block and just slice the parts they really need
to work on - no need allocating new memory blocks.

As seen in the previous section the `[$]` expression indexes the element
one past the slice's end and thus would generate a `RangeError`
(if bounds-checking hasn't been disabled).

### In-depth

- [Introduction to Slices in D](http://dlang.org/d-array-article.html)

## {SourceCode}

import std.stdio;

/**
Calculates the minimum of all values
in slice recursively. For every recursive
call a sub-slice is taken thus we don't
create a copy and don't do any allocations.
*/
int minimum(int[] slice)
{
    assert(slice.length > 0);
    if (slice.length == 1)
        return slice[0];
    auto otherMin = minimum(slice[1 .. $]);
    return slice[0] < otherMin ?
        slice[0] : otherMin;
}

void main()
{
    int[] test = [ 3, 9, 11, 7, 2, 76, 90, 6 ];
    auto min = minimum(test);
    writefln("The minimum of %s is %d",
        test, min);
    assert(min == 2);
}

# Alias & Strings

Now that we know what arrays are, have gotten in touch of `immutable`
and had a quick look at the basic types, it's time to introduce two
new constructs in one line:

    alias string = immutable(char)[];

The term `string` is defined by an `alias` expression which defines it
as a slice of `immutable(char)`'s. That is, once a `string` has been constructed
its content will never change again. And actually this is the second
introduction: welcome UTF-8 `string`! 

Due to their immutablility `string`s can perfectly be shared among
different threads. Being a slice parts can be taken out of it without
allocating memory. The standard function `std.algorithm.splitter`
for example splits a string by newline without any memory allocations.

Beside the UTF-8 `string` there are two more:

    alias wstring = immutable(dchar)[]; // UTF-16
    alias dstring = immutable(wchar)[]; // UTF-32

The variants are most easily converted between each other using
the `to` method from `std.conv`:

    dstring myDstring = to!dstring(myString);
    string myString = to!string(myDstring);

Because `string`s are arrays the same operations apply to them
e.g. strings might be concatenated using the `~` operator for example.
The property `.length` isn't necessarily the number of characters
for UTF strings so in that case use the function `std.utf.count`.

To create multi-line strings use the
`string str = q{ ... }` syntax. For raw strings you can either use
backticks `` ` "unescaped string"` ``
or the r-prefix `r"string that "doesn't" need to be escaped"`.

## {SourceCode}

import std.stdio;
import std.utf: count;
import std.string: format;

void main() {
    // format generates a string using a printf
    // like syntax. D allows native UTF string
    // handling!
    string str = format("%s %s", "Hellö",
        "Wörld");
    writeln("My string: ", str);
    writeln("Array length of string: ",
        str.length);
    writeln("Character length of string: ",
        count(str));

    // Strings are just normal arrays, so any
    // operation that works on arrays works here
    // too!
    import std.array: replace;
    writeln(replace(str, "lö", "lo"));
    import std.algorithm: endsWith;
    writefln("Does %s end with 'rld'? %s",
        str, endsWith(str, "rld"));

    import std.conv: to;
    // Convert to UTF-32
    dstring dstr = to!dstring(str);
    // .. which of course looks the same!
    writeln("My dstring: ", dstr);
}

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
    // ...
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

import std.stdio;

/// Returns: average of array
double average(int[] array) {
    // The property .empty for arrays isn't
    // native in D but has to be made accessible
    // by importing the function from std.array
    import std.array: empty, front;

    double accumulator = 0.0;
    auto length = array.length;
    while (!array.empty) {
        // this could be also done with .front
        // with import std.array: front;
        accumulator += array[0];
        array = array[1 .. $];
    }

    return accumulator / length;
}

void main()
{
    auto testers = [ [5, 15], // 20
          [2, 3, 2, 3], // 10
          [3, 6, 2, 9] ]; // 20

    for (auto i = 0; i < testers.length; ++i) {
      writeln("The average of ", testers[i],
        " = ", average(testers[i]));
    }
}


# Foreach

D features a `foreach` loop which makes iterating
through data less error-prone and easier to read.

Given an array `arr` of type `int[]` it is possible to
iterate through the elements using this `foreach` loop:

    foreach (int e; arr) {
        writeln(e);
    }

The first field in the `foreach` definition is the variable
name used in the loop iteration. Its type can be omitted
and is then induced automatically:

    foreach (e; arr) {
        // typoef(e) is int
        writeln(e);
    }

The second field must be an array - or a special iterable
object called a **range** which will be introduced in the next section.

Elements will be copied from the array or range during iteration -
this is okay for basic types but might be a problem for
large types. To prevent copying or enable *in-place
*mutation use `ref`:

    foreach (ref e; arr) {
        e = 10; // overwrite value
    }

## {SourceCode}

import std.stdio;

void main() {
    auto testers = [ [5, 15], // 20
          [2, 3, 2, 3], // 10
          [3, 6, 2, 9] ]; // 20

    // This is just for the fun of it: iterate
    // through the testers in reverse order. This
    // integrates very nice with foreach because
    // you just apply another algorith before
    // you really iterate over the real object.
    import std.range: retro;
    foreach (tester; retro(testers))
    {
        double accumulator = 0.0;
        foreach (c; tester)
            accumulator += c;

        writeln("The average of ", tester,
            " = ", accumulator / tester.length);
    }
}

# Ranges

If a `foreach` is encountered by the compiler

    foreach(element; range) {

.. it's rewritten to something equivalent to the following internally:

    for (; !range.empty; range.popFront()) {
        auto element = range.front;
        ...

Any object which fulfills the above interface is called a **range**
and is thus something that can be iterated over:

    struct Range {
        @property empty() const;
        void popFront();
        T front();
    }

The functions that are in the `std.range` and `std.algorithm` modules also provide
building blocks that make use of this interface. Ranges allow
to compose complex algorithms behind an object that
can be iterated with ease. And ranges allows to create **lazy**
objects that actually just perform a calculation when this
is really needed in an iteration e.g. when a range's
element is used.

### Exercise

Complete the source code to create the `FibonacciRange` range
that returns numbers of the
[Fibonacci sequence](https://en.wikipedia.org/wiki/Fibonacci_number).
Don't fool yourself into deleting the `assert`ions!

## {SourceCode}

import std.stdio;

struct FibonacciRange
{
    @property empty() const
    {
        // So when does the Fibonacci sequence
        // end?!
    }

    void popFront()
    {
    }

    int front()
    {
    }
}

void main() {
    import std.range: take;
    import std.array: array;

    // Let's test this FibonacciRange!
    FibonacciRange fib;

    // The magic function take creates another
    // range which just will return N elements
    // at maximum. This range is _lazy_ and just
    // touches the original range if actually
    // needed (iteration)!
    auto fib10 = take(fib, 10);

    // But we do want to touch all elements and
    // convert the range to an array of integers.
    int[] the10Fibs = array(fib10);

    writeln("Your first 10 Fibonacci numbers: ",
        the10Fibs);
    assert(the10Fibs ==
        [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
}

# Associative Arrays

D has built-in *associative arrays* also known as hash maps.
An associative array with a key type of `int` and a value type
of `string` is declared as follows:

    int[string] arr;

The syntax follows the actual usage of the hashmap:

    arr["key1"] = 10;

To test whether a key is located in the associative array, use the
`in` expression:

    if ("key1" in arr)
        writeln("Yes");

The `in` expression actually returns a pointer to the value
which is not `null` when found:

    if (auto test = "key1" in arr)
        *test = 20;

Access to a key which doesn't exist yields an `RangeError`
that immediately aborts the application. For a safe access
with a default value, you can use `get(key, defaultValue)`.

AA's have the `.length` property like arrays and provide
a `.remove(val)` member to remove entries by their key.
It is left as an exercise to the reader to explore
the special `.byKeys` and `.byValues` ranges.

### In-depth

- [Associative arrays spec](https://dlang.org/spec/hash-map.html)
- [byPair](http://dlang.org/phobos/std_array.html#.byPair)

## {SourceCode}

import std.stdio;

/**
Splits the given text into words and returns
an associative array that maps words to their
respective word counts.

Params:
    text = text to be splitted
*/
int[string] wordCount(string text)
{
    // The function splitter lazily splits the
    // input into a range
    import std.algorithm.iteration: splitter;

    // Indexed by words and returning the count
    int[string] words;

    // Define a predicate to use for splitting
    // the string.
    alias pred = c => c == ' ' || c == '.'
      || c == ',' || c == '\n';

    // The parameter we pass behind ! is an
    // expression that marks the condition when
    // to split text
    foreach(word; splitter!pred(text)) {
        // Increment word count if word
        // has been found.
        // Integers are by default 0.
        words[word]++;
    }

    return words;
}

void main()
{
    string text = q{This tour will give you an
overview of this powerful and expressive systems
programming language which compiles directly
to efficient, *native* machine code.};

    writeln("Word counts: ", wordCount(text));
}

# Classes

D provides support for classes and interfaces like in Java or C++.

Any `class` type inherits from `Object` implicitely. D classes can only
inherit from one class.

    class Foo { } // inherits from Object
    class Bar: Foo { } // Bar is a Foo too

If a member function of a base class is overridden, the keyword
`override` must be used to indicate that. This prevents unintentional
overriding of functions.

    class Bar: Foo {
        override functionFromFoo() {}
    }

A function can be marked `final` in a base class to disallow overriding
it. A function can be declared as `abstract` to force base classes to override
it. A whole class can be declared as `abstract` to make sure
that it isn't instantiated. To access the base class
use the special keyword `super`.

Classes in D are generally instantiated on the heap using `new`:

    auto bar = new Bar;

Class objects are always references types and unlike `struct` aren't
copied by value.

    Bar bar = foo; // bar points to foo

The garbage collector will make sure the memory is freed
after nobody references the object anymore.

### In-depth

- [Classes in D](https://dlang.org/spec/class.html)

## {SourceCode}

import std.stdio;

// Fancy type which can be used for
// anything...
class Any {
    // protected is just seen by inheriting
    // classes
    protected string type;

    this(string type) {
        this.type = type;
    }

    // public is implicit by the way
    final string getType() {
        return type;
    }

    // This needs to be implemented!
    abstract string convertToString();
}

class Integer: Any {
    // just seen by Integer
    private {
        int number;
    }

    // constructor
    this(int number) {
        // call base class constructor
        super("integer");
        this.number = number;
    }

    // This is implicit. And another way
    // to specify the protection level
    public:

    override string convertToString() {
        import std.conv: to;
        // The swiss army knife of conversion.
        return to!string(number);
    }
}

class Float: Any {
    private float number;

    this(float number) {
        super("float");
        this.number = number;
    }

    override string convertToString() {
        import std.string: format;
        // We want to control precision
        return format("%.1f", number);
    }
}

void main()
{
    Any[] anys = [
        new Integer(10),
        new Float(3.1415f)
        ];

    foreach (any; anys) {
        writeln("Type of any = ", any.getType());
        writeln("Content = ",
            any.convertToString());
    }
}

# Interfaces

D allows defining `interface`s which are technically like
`class` types but whose member functions must be implemented
by any class inheriting from the `interface`.

    interface Animal {
        void makeNoise();
    }

The `makeNoise` member function has to be implemented
by `Dog` because it inherits from the `Animal` interface.
Technically `makeNoise` behaves like an `abstract` member
function in a base class.

    class Dog: Animal {
        override makeNoise() {
            ...
        }
    }

    auto dog = new Animal;
    Animal animal = dog; // implicit cast to interface
    dog.makeNoise();

A `class` type can inherit from as many `interface`s it wishes
but just from *one* base class.

D easily enables the **NVI - non virtual interface** idiom by
allowing the definition of `final` functions in an `interface`
that aren't allowed to be overridden. This enforces specific
behaviours customized by overriding the other `interface`
functions.

    interface Animal {
        void makeNoise();
        final doubleNoise() /* NVI pattern */ {
            makeNoise();
            makeNoise();
        }
    }

### In-depth

- [Interfaces in D](https://dlang.org/spec/interface.html)

## {SourceCode}

import std.stdio;

interface Animal {
    // virtual function
    // which needs to be overridden!
    void makeNoise();

    // NVI pattern. Uses makeNoise internally
    // to customoze behaviour in inheriting
    // classes.
    final void multipleNoise(int n) {
        for(int i = 0; i < n; ++i) {
            makeNoise();
        }
    }
}

class Dog: Animal {
    override void makeNoise() {
        writeln("Bark!");
    }
}

class Cat: Animal {
    override void makeNoise() {
        writeln("Meeoauw!");
    }
}

void main() {
    Animal dog = new Dog;
    Animal cat = new Cat;
    Animal[] animals = [dog, cat];
    foreach(animal; animals) {
        animal.multipleNoise(5);
    }
}

# Functions, part II

A function can also be a parameter to another function:

    void doSomething(int function(int, int) doer) {
        // call passed function
        doer(5,5);
    }
    
    doSomething(add); // use global function `add` here
                      // add must have 2 int parameters

`doer` can then be called like any other normal function.

The above example uses the `function` type which is
a pointer to a global function. As soon as a member
function or a local function is referenced we'll have
to use the type `delegate`. It's a function pointer
that additionally contains information about its
context - or *enclosure*, thus also called **closure**
in other languages. For example a `delegate`
that points to a member function of a class also includes
the pointer to the class object. A local `delegate`
includes a link to the enclosing scope which is copied
automatically to the heap by the D compiler.

    void foo() {
        void local() {
            writeln("local");
        }
        auto f = &local; // f is of type delegate()
    }

The same function `doSomething` taking a `delegate`
would look like this:

    void doSomething(int delegate(int,int) doer);

`delegate` and `function` objects cannot be mixed. But the
standard function
[`std.functional.toDelegate`](https://dlang.org/phobos/std_functional.html#.toDelegate)
converts a `function` to a `delegate`.

Nameless function which are called *lambdas* can be defined in two ways:

    auto f = (int lhs, int rhs) {
        return lhs + rhs;
    };
    auto f = (lhs, rhs) => lhs + rhs;

The second form is a shorthand form for lambdas that consist
of just one line.

### In-depth

- [Delegate's specification](https://dlang.org/spec/function.html#closures)

## {SourceCode}
import std.stdio;

enum IntOps {
    add = 0,
    sub = 1,
    mul = 2,
    div = 3
}

/**
Provides a math calculuation
Params:
    op = selected math operation
Returns: delegate which does a math operation
*/
auto getMathOperation(IntOps op)
{
    // Define 4 lambda functions for
    // 4 different mathematical operations
    auto add = (int lhs, int rhs) => lhs + rhs;
    auto sub = (int lhs, int rhs) => lhs - rhs;
    auto mul = (int lhs, int rhs) => lhs * rhs;
    auto div = (int lhs, int rhs) => lhs / rhs;

    // we can ensure that the switch covers all cases
    final switch (op) {
        case IntOps.add:
            return add;
        case IntOps.sub:
            return sub;
        case IntOps.mul:
            return mul;
        case IntOps.div:
            return div;
    }
}

void main()
{
    int a = 10;
    int b = 5;

    auto func = getMathOperation(IntOps.add);
    writeln("The type of func is ",
        typeof(func).stringof, "!");

    // run the delegate func which does all the
    // real work for us!
    writeln("result: ", func(a, b));
}

# Templates

Like in C++ **D** allows defining templated functions which is a means
to define **generic** functions which work for any type
that compiles with the statements within the function's body:

    auto add(T)(T lhs, T rhs) {
        return lhs + rhs;
    }

The template parameter `T` is defined in a set of parentheses
in front of the actual function parameters. `T` is a placeholder
which is replaced by the compiler when actually *instantiating*
the function using the `!` operator:

    add!int(5, 10);
    add!float(5.0f, 10.0f);
    add!Animal(dog, cat); // won't compile; Animal doesn't implement +

If no template parameter is given for a templated function the compiler
tries to deduce the type using the parameters the function is fed:

    int a = 5; int b = 10;
    add(a, b); // T is to deduced to `int`
    float c = 5.0f;
    add(a, c); // ERROR: conflict because compiler
               // doesn't know what T should be

A function can have any number of template parameters which
are specified during instantiation using the `func!(T1, T2 ..)`
syntax. Template parameters can be of any basic type
including `string`s and floating point numbers.

Unlike generics in Java, templates in D are compile-time only, and yield
highly optimized code tailored to the specific set of types
used when actually calling the function

Of course, `struct`, `class` and `interface` types can be defined as template
types too.

    struct S(T) {
        // ...
    }

### In-depth

- [Tutorial to D Templates](https://github.com/PhilippeSigaud/D-templates-tutorial)
- [D Templates spec](https://dlang.org/spec/template.html)
- [Templates Revisited](http://dlang.org/templates-revisited.html):  Walter Bright writes about how D improves upon C++ templates.
- [Variadic templates](http://dlang.org/variadic-function-templates.html): Articles about the D idiom of implementing variadic functions with variadic templates

## {SourceCode}

import std.stdio;

/**
Template class that allows
generic implementation of animals.
Params:
    noise = string to write
*/
class Animal(string noise) {
    void makeNoise() {
        writeln(noise ~ "!");
    }
}

class Dog: Animal!("Bark") {
}

class Cat: Animal!("Meeoauw") {
}

/**
Template function which takes any
type T that implements a function
makeNoise.
Params:
    animal = object that can make noise
    n = number of makeNoise calls
*/
void multipleNoise(T)(T animal, int n) {
    for (int i = 0; i < n; ++i) {
        animal.makeNoise();
    }
}

void main() {
    auto dog = new Dog;
    auto cat = new Cat;
    multipleNoise(dog, 5);
    multipleNoise(cat, 5);
}

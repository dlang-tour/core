# D's Gems
# Uniform Function Call Syntax (UFCS)

**UFCS** is a special feature of D. It allows that any call to a free function
`fun(a)` can be also be be written as `a.fun()`.

If `a.fun()` is seen by the compiler and the type doesn't
have a member function called `fun()`, it tries to find a
global functions whose first parameter matches that of `a`.

This feature is especially useful when chaining complex
function calls. Instead of writing

    foo(bar(a))

It is possible to write

    a.bar().foo()

UFCS is especially important when dealing with
*ranges* where several algorithms can be put
together to perform complex operations, still allowing
to write clear and manageable code.

## {SourceCode}

import std.stdio;
import std.algorithm;
import std.range: iota;

void main()
{
    "Hello, %s".writefln("World");

    iota(1,11) // returns numbers from 1 to 10
      // filter for even numbers
      .filter!(a => a % 2 == 0)
      .writeln(); // writes them to stdout

    // Traditional style:
    writeln(filter!(a => a % 2 == 0)
    			   (iota(1,10)));
}

# Scope guards

Scope guards allow executing statements at certain conditions
if the current block is left:

* `scope(exit)` will always call the statements
* `scope(success)` statements are called when no exceptions
  have been thrown
* `scope(failure)` denotes statements that will be called when
  an exception has been thrown before the block's end

Using scope guards makes code much cleaner and allows to place
resource allocation and clean up code next to each other.
These little helpers also improve safety because they make sure
certain cleanup code is *always* called independent of which paths
are actually taken at runtime.

The D `scope` feature effectively replaces the RAII idiom
used in C++ which often leads to special scope guards objects
for special resources.

Scope guards are called in the reverse order they are defined.

## {SourceCode}

import std.stdio;

void main()
{
    writeln("<html>");
    scope(exit) writeln("</html>");

    {
        writeln("  <head>");
        scope(exit) writeln("  </head>");
        "    <title>%s</title>".writefln("Hello");
    } // the scope(exit) on the previous line
      // is executed here

    writeln("  <body>");
    scope(exit) writeln("  </body>");

    writeln("    <h1>Hello World!</h1>");
    
    // scope guards allow placing allocations
    // and their clean up code next to each
    // other
    import core.stdc.stdlib;
    int* p = malloc(int.sizeof);
    scope(exit) free(p);
}

# Range algorithms

The standard modules [std.range](http://dlang.org/phobos/std_range.html)
and [std.algorithm](http://dlang.org/phobos/std_algorithm.html)
provide a multitude of great functions that can be
composed to express complex operations in a still
readable way - based on *ranges* as building blocks.

The great thing with these algorithms is that you just
have to define your own range and you will directly
be able to profit from what already is in the standard
library.

### std.algorithm

`filter` - Given a lambda as template parameter,
 generate a new range that filters elements:

    filter!"a > 20"(range);
    filter!(a => a > 20)(range);

`map` - Generate a new range using the predicate
 defined as template parameter:

    [1, 2, 3].map!(x => to!string(x));

`each` - Poor man's `foreach` as a range crunching
function:

    [1, 2, 3].each!(a => writeln(a));

### std.range
`take` - Limit to *N* elements:

    theBigBigRange.take(10);

`zip` - iterates over two ranges
in parallel returning a tuple from both
ranges during iteration:

    assert(zip([1,2], ["hello","world"]).front
      == tuple(1, "hello"));

`generate` - takes a function and creates a range
which in turn calls it on each iteration, for example:

    alias RandomRange = generate!(x => uniform(1, 1000));

`cycle` - returns a range that repeats the given input range
forever.

    auto c = cycle([1]);
    // range will never be empty!
    assert(!c.empty);

### The documentation is awaiting your visit!

## {SourceCode}

// Hey come on, just get the whole army!
import std.algorithm: canFind, map,
  filter, sort, uniq, joiner, chunkBy, splitter;
import std.array: array, empty;
import std.range: zip;
import std.stdio: writeln;
import std.string: format;

void main()
{
    string text = q{This tour will give you an
overview of this powerful and expressive systems
programming language which compiles directly
to efficient, *native* machine code.};

    // splitting predicate
    alias pred = c => canFind(" ,.\n", c);
    // as a good algorithm it just works
    // lazily without allocating memory!
    auto words = text.splitter!pred
      .filter!(a => !a.empty);

    auto wordCharCounts = words
      .map!"a.count";

    // Output the character count
    // per word in a nice way
    // beginning with least chars!
    zip(wordCharCounts, words)
      // convert to array for sorting
      .array()
      .sort()
      // we don't need duplication, right?
      .uniq()
      // put all in one row that have the
      // same char count. chunkBy helps
      // us here by generating ranges
      // of range that are chunked by the length
      .chunkBy!(a => a[0])
      // those elments will be joined
      // on one line
      .map!(chunk => format("%d -> %s",
          chunk[0],
          // just the words
          chunk[1]
            .map!(a => a[1])
            .joiner(", ")))
      // joiner joins, but lazily!
      // and now the lines with the line
      // feed
      .joiner("\n")
      // pipe to stdout
      .writeln();
}

# Unittesting

D has unit-testing built-in right from the start. Anywhere
in a D module `unittest` blocks can be used to test
functionality of the source code.

    // Block for my function
    unittest
    {
        assert(myAbs(-1) == 1);
        assert(myAbs(1)  == 1);
    }

`unittest` blocks can contain arbitrary code which is just
compiled in and run when the command line flag `-unittest`
is passed to the DMD compiler. DUB also features compiling
and running unittest through the `dub test` command.

Typically `unittest`s contain `assert` expressions that test
the functionality of a given function. `unittest` blocks
are typically located near the definition of a function
which might be at the top level of the source, or even
within classes or structs.

## {SourceCode}

import std.stdio;

struct Vector3 {
    double x;
    double y;
    double z;

    double dot(Vector3 rhs) const {
        return x*rhs.x + y*rhs.y + z*rhs.z;
    }

    // That's okay!
    unittest {
        assert(Vector3(1,0,0).dot(
          Vector3(0,1,0) == 0);
    }

    string toString() const {
        import std.string: format;
        return format("x:%.1f y:%.1f z:%.1f",
          x, y, z);
    }

    // .. and that too!
    unittest {
        assert(Vector3(1,0,0).toString() ==
          "x:1.0 y:0.0 z:0.0");
    }
}

void main()
{
    Vector3 vec = Vector3(0,1,0);
    writeln(`This vector has been tested: `, vec);
}

// Or just somewhere else.
// Nothing is compiled in and just
// ignored in normal mode. Run dub test
// locally or compile with dmd -unittest
// to actually test your modules.
unittest {
    Vector3 vec;
    // .init a special built-in property that
    // returns the initial value of type.
    assert(vec.x == double.init);
}

# String Mixins

The `mixin` expression takes an arbitrary string and
compiles it and generates instructions accordingly. It
is purely a **compile-time** mechanism and can only work
on strings available during compilation - a comparison
with the evil JavaScript `eval` would be highly unfair.

    mixin("int b = 5");
    assert(b == 5); // compiles just fine

`mixin` also works with strings that are constructed
dynamically as long as the available information doesn't
depend on runtime values.

`mixin` together with **CTFE** from the next section allows
writing impressive libraries like [Pegged](https://github.com/PhilippeSigaud/Pegged)
which generates
a grammar parser from a grammar defined as a string
in the source code.

## {SourceCode}

import std.stdio;

auto calculate(string op, T)(T lhs, T rhs)
{
    return mixin("lhs " ~ op ~ " rhs");
}

void main()
{
    // A whole new approach to Hello World!
    mixin(`writeln("Hello World");`);

    // pass the operation to perform as a
    // template parameter.
    writeln("5 + 12 = ", calculate!"+"(5,12));
    writeln("10 - 8 = ", calculate!"-"(10,8));
    writeln("8 * 8 = ", calculate!"*"(8,8));
    writeln("100 / 5 = ", calculate!"/"(100,5));
}

# Compile Time Function Evaluation - CTFE

*Compile Time Function Evaluation (CTFE)* is a mechanism
which allows the compiler to execute functions
at **compile time**. There is no special set of the D
language necessary to use this feature - whenever
a function just depends on compile time known values
the D compiler might decide to interpret
it during compilation.

    // result will be calculated at compile
    // time. Check the machine code, it won't
    // contain a function call!
    static val = sqrt(50);

Keywords like `static` or `immutable` instruct
the compiler to use CTFE whenever possible.
The great thing about this technique is that
functions need not be rewritten to use
it, and the same code can perfectly be shared:

    int n = doSomeRuntimeStuff();
    // same function as above but this
    // time it is just called the classical
    // run-time way.
    auto val = sqrt(n);

One prominent example in D is the [std.regex](https://dlang.org/phobos/std_regex.html)
library. It provides at type `ctRegex` type which uses
*string mixins* and CTFE to generate a highly optimized
regular expression automaton that is generated during
compilation. The same code base is re-used for
the run-time version `regex` that allows to compile
regular expressions only available at run-time.

    auto ctr = ctRegex!(`^.*/([^/]+)/?$`);
    auto tr = regex(`^.*/([^/]+)/?$`);
    // ctr and tr can be used interchangely
    // but ctr will be faster!

Not all language features are available
during CTFE but the supported feature set is increased
with every compile release.

## {SourceCode}
import std.stdio: writeln;

/* Returns: square root of x using
 Newton's approximation scheme. */
auto sqrt(T)(T x) {
    // our epsilon when to stop the approximation
    // because we think the change isn't worth
    // another iteration.
    enum GoodEnough = 0.01;
    import std.math: abs;
    // choose a good starting value.
    T z = x*x, old = 0;
    int iter;
    while (abs(z - old) > GoodEnough) {
        old = z;
        z -= ((z*z)-x) / (2*z);
    }

    return z;
}

void main() {
    double n = 4.0;
    writeln("The sqrt of runtime 4 = ",
        sqrt(n));
    static cn = sqrt(4.0);
    writeln("The sqrt of compile time 4 = ",
        cn);
}

# Functional programming

D puts an emphasis on *functional programming* and provides
first-class support for development
in a functional style.

In D a function can be declared as `pure` which implies
that given the same input parameters, always the **same**
output is generated. `pure` functions cannot access or change
any mutable global state and are thus just allowed to call other
functions which are `pure` themselves.

    int add(int lhs, int rhs) pure {
        // ERROR: impureFunction();
        return lhs + rhs;
    }

This variant of `add` is called **strongely pure function**
because it returns a result dependent only on its input
parameters without modifying them. D also allows the
definition of **weakly pure functions** which might
have mutable parameters:

    void add(ref int result, int lhs, int rhs) pure {
        result = lhs + rhs;
    }

These functions are still considered pure and can't
access or change any mutable global state. Just passed-in
mutable parameters might be altered.

Due to the constraints imposed by `pure`, pure functions
are ideal for multi-threading environments to prevent
data races *by design*. Additionally pure functions
can be cached easily and allow a range of compiler
optimizations.

The attribute `pure` is automatically inferred
by the compiler for templated functions and `auto` functions,
where applicable (this is also true for `@safe`, `nothrow`,
and `@nogc`).

## {SourceCode}

// Calculates median of nums. This function
// is pure because it always returns the same
// result for the same set of numbers.
T median(T)(T[] nums) pure {
    import std.algorithm: sort;
    nums.sort();
    if (nums.length % 2)
        return nums[$ / 2];
    else
        return (nums[$ / 2 - 1]
            + nums[$ / 2]) / 2;
}

void main()
{
    import std.stdio: writeln;
    import std.functional: memoize;
    // memoize caches the result of the function
    // call depending on the input parameters.
    // pure functions are great for that!
    alias fastMedian = memoize!(median!int);

    writeln(fastMedian([7, 5, 3]));
    // result will be cached!
    writeln(fastMedian([7, 5, 3]));
}

# Contract programming

Contract programming in D includes a set of language constructs
that allow increasing the code quality by implementing
sanity checks that make sure that the code base
behaves as intended. All contracts presented here are
just available in **debug** mode and won't be run
in release mode.

The simplest form of contract programming in D is
the `assert(...)` expression that checks that a certain
condition is met - and aborts the program with
an `AssertionError` otherwise.

    assert(sqrt(4) == 2);
    // optional custom assertion error message
    assert(sqrt(16) == 4, "sqrt is broken!");

`in` and `out` allow to formalize contracts for input
parameters and return values of functions.

    long square_root(long x)
    in {
        assert(x >= 0);
    } out (result) {
        assert((result * result) <= x
            && (result+1) * (result+1) > x);
    } body {
        return cast(long)std.math.sqrt(cast(real)x);
    }

The content in the `in` block could also be expressed
within the function's body but the intent is much clearer
this way. In the `out` block the function's return
value can be captured with `out(result)` and
verified accordingly.

`invariant()` is a special member function of `struct`
and `class` types that allows sanity checking an object's
state during its whole lifetime:

* It's called after the constructor has run and before
  the destructor is called.
* It's called before entering a member function
* `invariant()` is called after exiting a member
  function.

## {SourceCode}

// Very simple Date type with a lot of
// flaws. Hint: don't use it!
struct Date {
    private {
        int year;
        int month;
        int day;
    }

    void setDate(int year, int month, int day) {
        this.year = year;
        this.month = month;
        this.day = day;
    }

    invariant() {
        assert(year >= 0);
        assert(month >= 1 && month <= 12);
        assert(day >= 1 && day <= 31);
    }

    // Initializes Date object from a
    // YYYY-MM-DD string.
    void fromString(string date)
    in {
        assert(date.length == 10);
    } body {
        import std.format: formattedRead;
        // formattedRead parses the format
        // given and writes the result to the
        // given variables
        formattedRead(date, "%d-%d-%d",
            &this.year,
            &this.month,
            &this.day);
    }
}

void main() {
    Date date;
    // invariant will not fail.
    date.setDate(2016, 2, 7);
    // This will make invariant fail.
    // Of course this should not be validated
    // inside a invariant! External data needs to
    // be checked in release mode too, and
    // be propgated through e.g. exceptions.
    date.fromString("2016-13-7");
}

# Subtyping

`struct` can't inherit from other `struct`s. But
for those poor `struct`s D provides another great
means to extend their functionality: **subtyping**.

A struct type can define one of its members as
`alias this`:

    struct SafeInt {
        private int theInt;
        alias theInt this;
    }

Any function or operation on `SafeInt` that can't
be handled by the type itself will be forwarded
to the `alias this`ed member. From the outside
`SafeInt` then looks like a normal integer.

This allows extending other types
with new functionality but with zero overhead
in terms of memory or runtime. The compiler
makes sure to do the right thing when
accessing the `alias this` member.

`alias this` work with classes too.

## {SourceCode}

import std.stdio: writeln;

struct Vector3 {
    private double[3] vec;
    alias vec this;

    double dot(Vector3 rhs) {
        return vec[0]*rhs.vec[0] +
          vec[1]*rhs.vec[1] + vec[2]*rhs.vec[2];
    }
}

void main()
{
    Vector3 vec;
    // we're basically talking with
    // double[] here.
    vec = [ 0.0, 1.0, 0.0 ];
    assert(vec.length == 3);
    assert(vec[$ - 1] == 0.0);

    auto vec2 = Vector3([1.0,0.0,0.0]);
    // but this functionality has been
    // extended!
    writeln("vec dot vec2 = ", vec.dot(vec2));
}

# Attributes

Functions can be attributed in various ways in D.
Let's have a look at two built-in attributes
as well as *user-defined attributes*. There
are also the built-ins `@safe`, `@system` and `@trusted`
which have been mentioned in the first chapter.

### `@property`

A function marked as `@property` looks like
a normal member to the outside world:

    struct Foo {
        @property bar() { return 10; }
        @property bar(int x) { writeln(x); }
    }
    
    Foo foo;
    writeln(foo.bar); // actually calls foo.bar()
    foo.bar = 10; // calls foo.bar(10);

### `@nogc`

When the D compiler encounters a function that is marked as `@nogc`
it will make sure that **no** memory allocations are done
within the context of that function. A `@nogc`
function is just allowed to call other `@nogc`
functions.


    void foo() @nogc {
      // ERROR:
        auto a = new A;
    }

### User-defined attributes (UDAs)

Any function or type in D can be attributed with user-defined
types:

    struct Bar { this(int x) {} }
    
    struct Foo {
      @("Hello") {
          @Bar(10) void foo() {
            ...
          }
      }
    }

Any type, built-in or user-defined, can be attributed
to functions. The function `foo()` in this example
will have the attributes `"Hello"` (type `string`)
and `Bar` (type `Bar` with value `10`). To get
the attributes of a function (or type) use
the built-in compiler *traits*
`__traits(getAttributes, Foo)` which returns
a [`TypeTuple`](https://dlang.org/phobos/std_typetuple.html).

UDAs allow to enhance generic code by giving user-defined
types another dimension that helps compile time
generators to adapt to that specific type.

# opDispatch & opApply

D allows overriding operators like `+`, `-` or
the call operator `()` for
[classes and structs](https://dlang.org/spec/operatoroverloading.html).
We will have a closer look at the two special
operator overloads `opDispatch` and `opApply`.

### opDispatch

`opDispatch` can be defined as a member function of either
`struct` or `class` types. Any unknown member function call
to that type is passed to `opDispatch`,
passing the unknown member function's name as `string`
template parameter. `opDispatch` is a *catch-all*
member function and allows another level of generic
programming - completely in **compile time**!

    struct C {
        void callA(int i, int j) { ... }
        void callB(string s) { ... }
    }
    struct CallLogger(C) {
        C content;
        void opDispatch(string name, T...)(T vals) {
            writeln("called ", name);
            mixin("content." ~ name)(vals);
        }
    }
    CallLogger!C l;
    l.callA(1, 2);
    l.callB("ABC");

### opApply

An alternative way to implementing a `foreach` traversal
instead of defining a user defined *range* is to implement
an `opApply` member function. Iterating with `foreach`
over such a type will call `opApply` with a special
delegate as a parameter:

    class Tree {
        Tree lhs;
        Tree rhs;
        int opApply(int delegate(Tree) dg) {
            if (lhs && lhs.opApply(dg)) return 1;
            if (dg(this)) return 1;
            if (rhs && rhs.opApply(dg)) return 1;
            return 0;
        }
    }
    Tree tree = new Tree;
    foreach(node; tree) {
        ...
    }

The compiler transform the `foreach` body to a special
delegate that is passed to the object. Its one and only
parameter will contain the current
iteration's value. The magic `int` return value
must be interpreted and if it is not `0`, the iteration
must be stopped.

## {SourceCode}

// A Variant is something that might contain
// any other type:
// https://dlang.org/phobos/std_variant.html
import std.variant: Variant;

/* Type that can be filled with opDispatch
   with any number of members. Like
   JavaScript's var.
*/
struct var {
    private Variant[string] values;

    @property
    Variant opDispatch(string name)() const {
        return values[name];
    }

    @property
    void opDispatch(string name, T)(T val) {
        values[name] = val;
    }
}

void main() {
    import std.stdio: writeln;

    var test;
    test.foo = "test";
    test.bar = 50;
    writeln("test.foo = ", test.foo);
    writeln("test.bar = ", test.bar);
    test.foobar = 3.1415;
    writeln("test.foobar = ", test.foobar);
    // ERROR because it doesn't exist
    // already
    // writeln("test.notthere = ", test.notthere);
}

# Documentation

D tries to integrate important parts of modern
software engineering directly into the language.
Besides *contract programming* and *unittesting*
D allows to natively generate [documentation](https://dlang.org/phobos/std_variant.html)
out of your source code.

Using a standard schema for documenting types
and functions the command `dmd -D` conveniently
generates HTML documentation based on the source
files passed on command line.
In fact the whole [Phobos library documentation](https://dlang.org/phobos)
has been generated with *DDoc*.

The following comment styles are considered
by DDoc for inclusion into the source code
documentation:

* `/// Three slashes before type or function`
* `/++ Multiline comment with two +  +/`
* `/** Multiline comment with two *  */`

Have a look at the source code example
to see some standardized documentation
sections.

## {SourceCode}

/**
  Calculates the square root of a number.

  Here could be a longer paragraph that
  elaborates on the great win for
  society for having a function that is actually
  able to calculate a square root of a given
  number.

  Example:
  -------------------
  double sq = sqrt(4);
  -------------------
  Params:
    number = the number the square root should
             be calculated from.

  License: use freely for any purpose
  Throws: throws nothing.
  Returns: the squrare root of the input.
*/
T sqrt(T)(T number) {
}

# Template meta programming

If you ever got in touch with *template meta programming*
in C++ you will be relieved what tools D offers to make
your life easier. Template meta programming is a technique
that enables decision-making depending on template type properties
and thus allows to make generic types even more flexible
based on the type they are going to be instantiated with.

### `static if` & `is`

Like the normal `if`, `static if` conditionally
compiles a code block based on a condition that can
be evaluated at compile time:

    static if(is(T == int))
        writeln("T is an int");
    static if (is(typeof(x) :  int))
        writeln("Variable x implicitely converts to int");

The [`is` expression](http://wiki.dlang.org/Is_expression) is
a generic helper that evaluates conditions at compile time.

    static if(is(T == int)) { // T is template parameter
        int x = 10;
    }

Braces are omitted if the condition is `true` - no new scope is created.
`{{` and `}}` explicitely create a new block.

`static if` can be used anywhere in the code - in functions,
at global scope or within type definitions.

### `mixin template`

Anywhere you see *boiler plate*, `mixin template`
is your friend:

    mixin template Foo(T) {
        T foo;
    }
    ...
    mixin Foo!int; // int foo available from here on.

`mixin template` might contain any number of
complex expressions that are inserted at the instantiation
point. Say good-bye to the
pre-processor if you're coming from C!

### Template constraints

A template might be defined with any number of
constraints that enforce what properties
a type must have:

    void foo(T)(T value)
      if (is(T : int)) { // foo!T only valid if T
                         // converts to int
    }

Constraints can be combined in boolean expression
and might even contain function calls that can be evaluated
at compile-time. For example `std.range.primitives.isRandomAccessRange`
checks whether a type is a range that supports
the `[]` operator.

## {SourceCode}

import std.traits: isFloatingPoint;
import std.uni: toUpper;
import std.string: format;
import std.stdio: writeln;

/// A Vector that just works for
/// numbers, integers or floating points.
struct Vector3(T)
  if (is(T: real))
{
private:
    T x,y,z;

    /// Generator for getter and setter because
    /// we really hate boiler plate!
    ///
    /// var -> T getVAR() and void setVAR(T)
    mixin template GetterSetter(string var) {
        // Use mixin to construct function
        // names
        mixin("T get%s() const { return %s; }"
          .format(var.toUpper, var));

        mixin("void set%s(T v) { %s = v; }"
          .format(var.toUpper, var));
    }

    // Easily generate our getX, setX etc.
    // functions with a mixin template.
    mixin GetterSetter!"x";
    mixin GetterSetter!"y";
    mixin GetterSetter!"z";

public:
    // We don't allow the dot function
    // for anything but floating points
    static if (isFloatingPoint!T) {
        T dot(Vector3!T rhs) {
            return x*rhs.x + y*rhs.y +
                z*rhs.z;
        }
    }
}

void main()
{
    auto vec = Vector3!double(3,3,3);
    // That doesn't work because of the template
    // constraint!
    // Vector3!string illegal;

    auto vec2 = Vector3!double(4,4,4);
    writeln("vec dot vec2 = ", vec.dot(vec2));

    auto vecInt = Vector3!int(1,2,3);
    // doesn't have the function dot because
    // we statically enabled it only for float's
    // vecInt.dot(Vector3!int(0,0,0));

    // generated getter and setters!
    vecInt.setX(3);
    vecInt.setZ(1);
    writeln(vecInt.getX, ",",
      vecInt.getY, ",", vecInt.getZ);
}



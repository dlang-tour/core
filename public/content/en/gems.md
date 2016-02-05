# D's Gems
# Uniform Function Call Syntax (UFCS)

**UFCS** is totally simple: any call to a free function 
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
    //
    //  writeln(filter!(a => a % 2 == 0)
    //    (iota(1,10)));
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
    }

    writeln("  <body>");
    scope(exit) writeln("  </body>");

    writeln("    <h1>Hello World!</h1>");
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

**std.algorithm**
 * `filter` - Given a lambda as template parameter,
 generate a new range that filters elements:
 `filter!"a > 20"(range)` or `filter!(a => a > 20)(range)`
 * `map` - Generate a new range using the predicate
 defined as template parameter:
 `[1, 2, 3].map!(x => to!string(x))`
 * `each` - Poor man's `foreach` as a range crunching
 function: `[1, 2, 3].each!(a => writeln(a))`

**std.range**
 * `take` - Limit to *N* elements:
 `theBigBigRange.take(10)`.
 * `zip` - iterates over two ranges
 in parallel returning a tuple from both
 ranges during iteration:
 `zip([1,2], ["hello","world"]).front == tuple(1, "hello")`
 * `generate` - takes a function and creates a range
 which in turn calls it on each iteration, for example
 `alias RandomRange = generate!(x => uniform(1, 1000))`
 * `cycle` - returns a range that repeats the given input range
 forever. `cycle([1])` is never `.empty`!

The documentation is awaiting your visit!

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

# Template meta programming

* Template constraints
* static if

# Functional programming

...

# Contract programming

* in
* out
* assert
* enforce

# Subtyping

* alias this

# Documentation

* ddox
* // Comment until end of line
*  /* Multiline comment */
*  /+ Multiline comment +/

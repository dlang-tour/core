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
      .filter!(a => a % 2 == 0) // filter for even numbers
      .writeln(); // writes them to stdout

    // Traditional style:
    //
    //  writeln(filter!(a => a % 2 == 0)(iota(1,10)));
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
        "    <title>%s</title>".writefln("Hello");
        scope(exit) writeln("</head>");
    }

    writeln("  <body>");
    scope(exit) writeln("  </body>");

    writeln("    <h1>Hello World!</h1>");
}

# Range algorithms

* filter
* map
* each


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
is passed to the DMD compiler. *DUB* also features compiling
and running unittest through the `dub test` command.

Typically `unittest`s contain `assert` expressions that test
the functionality of a given function. `unittest` blocks
are typically located near the definition of a function
which might be at the top level of the source, or even
within classes or structs.

## {SourceCode}

//TODO

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
    writeln("5 + 12 = ", calculate!"+"(5,12));
    writeln("10 - 8 = ", calculate!"-"(10,8));
    writeln("8 * 8 = ", calculate!"*"(8,8));
    writeln("100 / 5 = ", calculate!"/"(100,5));
}

# Compile Time Function Evaluation - CTFE

`ctRegex`
...

# Template meta programming

* Template constraints
* static if

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

# D's Gems
# Uniform Function Call Syntax (UFCS)

**UFCS** is totally simple: any call to a free function 
`fun(a)` can be also be be written as `a.fun()`.

If `a.fun()` is seen by the compiler and the type doesn't
have a member function called `fun()`, it tries to find a
*free* functions whose first parameter matches that of `a`.

This feature is especially useful when chaining complex
function calls. Instead of writing

    foo(bar(a))

It is possible to write

    a.bar().foo()

UFCS becomes especially important when dealing with
[Ranges](/tour/ranges/01) where several alorithms can be put
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
* `scope(success)` statements are called when **no** exceptions
  have been thrown
* `scope(failure)` denotes statements that will be called when
  an exception has been thrown before the block's end

Using scope guards makes code much cleaner and allows to place
resource allocation and clean up code next to each other.
These little helpers also improve saftey because they make sure
certain cleanup code is *always* called independent of which paths
are acutally taken at runtime.

The D `scope` feature effectively replaces the *RAII* idiom
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

...

# String Mixins

...

# Compile Time Function Evaluation - CTFE

`ctRegex`
...

# Template meta programming

...

# Contract programming

- in
- out
- assert
- enforce

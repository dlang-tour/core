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

### In-depth

- [UFCS in _Programming in D_](http://ddili.org/ders/d.en/ufcs.html)

## {SourceCode}

```d
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
```

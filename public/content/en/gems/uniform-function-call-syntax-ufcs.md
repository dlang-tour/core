# Uniform Function Call Syntax (UFCS)

**UFCS** is a key feature of D and enables code reusability
and scalability through well-defined encapsulation.

UFCS allows that any call to a free function
`fun(a)` can be written as member function call `a.fun()`.

If `a.fun()` is seen by the compiler and the type doesn't
have a member function called `fun()`, it tries to find a
global functions whose first parameter matches that of `a`.

This feature is especially useful when chaining complex
function calls. Instead of writing

    foo(bar(a))

It is possible to write

    a.bar().foo()

Moreover in D it is not necessary to use parenthesis for functions
without arguments, which means that _any_ function can be used
like a property:

    import std.uni : toLower;
    "D rocks".toLower; // "d rocks"

UFCS is especially important when dealing with
*ranges* where several algorithms can be put
together to perform complex operations, still allowing
to write clear and manageable code.

    import std.algorithm : group;
    import std.range : chain, retro, front, retro;
    [1, 2].chain([3, 4]).retro; // 4, 3, 2, 1
    [1, 1, 2, 2, 2].group.dropOne.front; // tuple(2, 3u)

### In-depth

- [UFCS in _Programming in D_](http://ddili.org/ders/d.en/ufcs.html)
- [_Uniform Function Call Syntax_](http://www.drdobbs.com/cpp/uniform-function-call-syntax/232700394) by Walter Bright
- [`std.range`](http://dlang.org/phobos/std_range.html)

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

# Welcome to D

Welcome to the interactive tour of the *D Programming language*.

{{#dmanmobile}}

This tour gives an overview of this __powerful__ and __expressive__
language which compiles directly to __efficient__, __native__ machine code.

{{/dmanmobile}}

### What is D?

D is the culmination of _decades of experience implementing compilers_
for many diverse languages and has a large number of
[unique features](http://dlang.org/overview.html):

{{#dmandesktop}}

- _high level_ constructs for great modeling power
- _high performance_, compiled language
- static typing
- evolution of C++ (without the mistakes)
- direct interface to the operating system API's and hardware
- blazingly fast compile-times
- allow memory-safe programming (SafeD)
- _maintainable_, _easy to understand_ code
- short learning curve (C-like syntax, similar to Java and others)
- compatible with C application binary interface
- multi-paradigm (imperative, structured, object oriented, generic, functional programming purity, and even assembly)
- built-in error prevention (contracts, unittests)

... and many more [features](http://dlang.org/overview.html).

{{/dmandesktop}}

### About the tour

Each section comes with a source code example that can be modified and used
to experiment with D's language features.
Click the run button (or `Ctrl-enter`) to compile and run it.

### Contributing

This tour is [open source](https://github.com/stonemaster/dlang-tour)
and we are glad about pull requests making this tour even better.

## {SourceCode}

```d
import std.stdio;

// Let's get going!
void main()
{
    writeln("Hello World!");
}
```

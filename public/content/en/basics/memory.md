# Memory

D is a system programming language and thus allows you to manually
manage. However manual memory management is very error-prone and thus
D uses a *garbage collector* per default to free unused memory.

D provides pointer types `T*` like in C:

    int a;
    int* b = &a; // b contains address of a
    auto c = &a; // c is int* and contains address of a

A new memory block on the heap is allocated using the
`new` expression, which returns a pointer to the managed
memory:

    int* a = new int;

As soon as the memory referenced by `a` isn't referenced anymore
through any variable in the program, the garbage collector
will free its memory.

D has three different security levels for functions: `@system`, `@trusted`, and `@safe`.
Unless specified otherwise, the default is `@system`.
`@safe` is a subset of D that prevents memory bugs by design.
`@safe` code can only call other `@safe` or `@trusted` functions.
Moreover explicit pointer arithmetic is forbidden in `@safe` Code:

    void main() @safe {
        int a = 5;
        int* p = &a;
        int* c = p + 5; // error
    }

`@trusted` functions are manually verified functions and allow to bridge the
world between SafeD and the underlying dirty low-level world.

### In-depth

* [SafeD](https://dlang.org/safed.html)

## {SourceCode}

```d
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
```

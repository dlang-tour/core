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
change. It is common for APIs to accept `const` types
to ensure they don't modify the input.

    immutable a = 10;
    int b = 5;
    const int* pa = &a;
    const int* pb = &b;
    *pa = 7; // disallowed

Both `immutable` and `const` are transitive which ensures that once
`const` is applied to a type, it applies recursively to every sub-component of that type.

### In-depth

#### Basic references

- [Immutable in _Programming in D_](http://ddili.org/ders/d.en/const_and_immutable.html)
- [Scopes in _Programming in D_](http://ddili.org/ders/d.en/name_space.html)

#### Advanced references

- [const(FAQ)](https://dlang.org/const-faq.html)
- [Type qualifiers D](https://dlang.org/spec/const3.html)

## {SourceCode}

```d
import std.stdio;

void main()
{
    immutable forever = 100;
    static assert(!__traits(compiles,
                  forever = 5;));
    writeln("forever: ",
        typeof(forever).stringof);

    const int* cForever = &forever;
    static assert(!__traits(compiles,
                  *cForever = 10;));
    writeln("const* forever: ",
        typeof(cForever).stringof);


    int mutable = 100;
    writeln("mutable: ",
        typeof(mutable).stringof);
    mutable = 10; // Fine
    const int* cMutable = &mutable;
    static assert(!__traits(compiles,
                  *cMutable = 100;));
    writeln("cMutable: ",
        typeof(cMutable).stringof);

    static assert(!__traits(compiles,
        immutable int* imMutable = &mutable; ));
}
```

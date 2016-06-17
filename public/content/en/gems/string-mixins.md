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

### In-depth

- [Mixins in D](https://dlang.org/spec/template-mixin.html)

## {SourceCode}

```d
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
```

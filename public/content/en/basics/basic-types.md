# Basic types

D provides a number of basic types which always have the same
size **regardless** of the platform - the only exception
is the `real` type which provides the highest possible floating point
precision. There is no difference
between the size of an integer regardless whether the application
is compiled for 32-bit or 64-bit systems.

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">bool</code></td> <td>8-bit</td></tr>
<tr><td><code class="prettyprint">byte, ubyte, char</code></td> <td>8-bit</td></tr>
<tr><td><code class="prettyprint">short, ushort, wchar</code></td> <td>16-bit</td></tr>
<tr><td><code class="prettyprint">int, uint, dchar</code></td> <td>32-bit</td></tr>
<tr><td><code class="prettyprint">long, ulong</code></td> <td>64-bit</td></tr>
</table>

#### Floating point types:

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">float</code></td> <td>32-bit</td></tr>
<tr><td><code class="prettyprint">double</code></td> <td>64-bit</td></tr>
<tr><td><code class="prettyprint">real</code></td> <td>depending on platform, 80-bit on Intel x86 32-bit</td></tr>
</table>

The prefix `u` denotes *unsigned* types. `char` translates to
UTF-8 characters, `wchar` is used in UTF-16 strings and `dchar`
in UTF-32 strings.

A conversion between variables of different types is only
allowed by the compiler if no precision is lost. A conversion
between floating point types (e.g `double` to `float`)
is allowed though.

A conversion to another type may be forced by using the
`cast(TYPE) var` expression. It needs to be used with great care though
as `cast` expression is allowed to break the type system.

The special keyword `auto` creates a variable and infers its
type from the right hand side of the expression. `auto var = 7`
will deduce the type `int` for `var`. Note that the type is still
set at compile-time and can't be changed - just like with any other
variable with an explicitly given type.

### Type properties

All data types have a property `.init` to which they are initialized.
For all integers this is `0` and for floating points it is `nan` (*not a number*).
Integral and floating point types have a `.min` and `.max` property for the lowest
and highest value they can represent. Floating point values have more properties
`.nan` (NaN-value), `.infinity` (infinity value), `.dig` (number of
decimal digits of precisions), `.mant_dig` (number of bits in mantissa) and more.

Every type also has a `.stringof` property which yields its name as a string.

### Indexes in D

In D indexes have usually the alias type `size_t` as it is a type that
is large enough to represent an offset into all addressible memory - that is
`uint` for 32-bit and `ulong` for 64-bit architectures.

`assert` is compiler built-in which verifies conditions in debug mode and aborts
with an `AssertionError` if it fails.

### In-depth

#### Basic references

- [Assignment](http://ddili.org/ders/d.en/assignment.html)
- [Variables](http://ddili.org/ders/d.en/variables.html)
- [Arithmetics](http://ddili.org/ders/d.en/arithmetic.html)
- [Floating Point](http://ddili.org/ders/d.en/floating_point.html)
- [Fundamental types in _Programming in D_](http://ddili.org/ders/d.en/types.html)

#### Advanced references

- [Overview of all basic data types in D](https://dlang.org/spec/type.html)
- [`auto` and `typeof` in _Programming in D_](http://ddili.org/ders/d.en/auto_and_typeof.html)
- [Type properties](https://dlang.org/spec/property.html)

## {SourceCode}

```d
import std.stdio;

void main()
{
    // Big numbers can be separated
    // with an underscore "_"
    // to enhance readability.
    int b = 7_000_000;
    short c = cast(short) b; // cast needed
    uint d = b; // fine
    int g;
    assert(g == 0);

    auto f = 3.1415f; // f denotes a float

    // typeid(VAR) returns the type information
    // of an expression.
    writeln("type of f is ", typeid(f));
    double pi = f; // fine
    // for floating-point types
    // implicit down-casting is allowed
    float demoted = pi;

    // access to type properties
    assert(int.init == 0);
    assert(int.sizeof == 4);
    assert(bool.max == 1);
    writeln(int.min, " ", int.max);
    writeln(int.stringof); // int
}
```

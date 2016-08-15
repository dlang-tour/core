# Traits

One of D's powers is its compile-time function evaluation (CTFE) system.
Combined with introspection, generic programs can be written and
heavy optimizations can be achieved.

## Explicit contracts

Traits allow to specify explicitly what input is accepted.
For example `splitIntoWords` can operate on any arbitrary string type:

```d
S[] splitIntoWord(S)(S input)
if (isSomeString!S)
```

This applies to template parameters as well and `myWrapper` can ensure that the
passed-in symbol is a callable function:

```d
void myWrapper(alias f)
if (isCallable!f)
```

As a simple example, [`commonPrefix`](https://dlang.org/phobos/std_algorithm_searching.html#.commonPrefix)
from `std.algorithm.searching`, which returns the common prefix of two ranges,
will be analyzed:

```d
auto commonPrefix(alias pred = "a == b", R1, R2)(R1 r1, R2 r2)
if (isForwardRange!R1
    isInputRange!R2 &&
    is(typeof(binaryFun!pred(r1.front, r2.front)))) &&
    !isNarrowString!R1)
```

This means that the function is only callable and thus compiles if:

- `r1` is save-able (guaranteed by `isForwardRange`)
- `r2` is iterable (guaranteed by `isInputRange`)
- `pred` is callable with element types of `r1` and `r2`
- `r1` isn't a narrow string (`char[]`, `string`, `wchar` or `wstring`) - for simplicity, otherwise decoding might be needed

### Specialization

Many APIs aim to be general-purpose, however they don't want to pay with extra
runtime for this generalization.
With the power of introspection and CTFE, it is possible to specialize a method
on compile-time to achieve the best performance given the input types.

A common problem is that in contrast to arrays you might not know the exact length
of a stream or list before walking through it.
Hence a simple implementation of the `std.range` method `walkLength`
which generalizes for any iterable type would be:

```d
static if (hasMember!(r, "length"))
    return r.length; // O(1)
else
    return r.walkLength; // O(n)
```

#### `commonPrefix`

The use of compile-time introspection is ubiquitous in Phobos. For example
`commonPrefix` differentiates between `RandomAccessRange`s
and linear iterable ranges because in `RandomAccessRange` it's possible to jump
between positions and thus speed-up the algorithm.

#### More CTFE magic

[std.traits](https://dlang.org/phobos/std_traits.html) wraps most of
D's [traits](https://dlang.org/spec/traits.html) except for some like
`compiles` that can't be wrapped as it would lead to an immediate compile error:

```d
__traits(compiles, obvious error - $%42); // false
```

#### Special keywords

Additionally for debugging purposes D provides a couple of special keywords:

```d
void test(string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__,
          string func = __FUNCTION__, string pretty = __PRETTY_FUNCTION__)
{
    writefln("file: '%s', line: '%s', module: '%s',\nfunction: '%s', pretty function: '%s'",
             file, line, mod, func, pretty);
}
```

With D's CLI evaluation one doesn't even need `time` - CTFE can be used!

```d
rdmd --force --eval='pragma(msg, __TIMESTAMP__);'
```

## In-depth

- [std.range.primitives](https://dlang.org/phobos/std_range_primitives.html)
- [std.traits](https://dlang.org/phobos/std_traits.html)
- [std.meta](https://dlang.org/phobos/std_meta.html)
- [Specification on Traits in D](https://dlang.org/spec/traits.html)

## {SourceCode}

```d
import std.functional: binaryFun;
import std.range;
import std.stdio;
import std.traits;

/**
Returns the common prefix of two ranges
without the auto-decoding special case.

Params:
    pred = Predicate for commonality comparison
    r1 = A forward range of elements.
    r2 = An input range of elements.

Returns:
A slice of r1 which contains the characters
that both ranges start with.
 */
auto commonPrefix(alias pred = "a == b", R1, R2)
                 (R1 r1, R2 r2)
if (isForwardRange!R1 && isInputRange!R2 &&
    !isNarrowString!R1 &&
    is(typeof(binaryFun!pred(r1.front,
                             r2.front))))
{
    import std.algorithm.comparison : min;
    static if (isRandomAccessRange!R1 &&
               isRandomAccessRange!R2 &&
               hasLength!R1 && hasLength!R2 &&
               hasSlicing!R1)
    {
        immutable limit = min(r1.length,
                              r2.length);
        foreach (i; 0 .. limit)
        {
            if (!binaryFun!pred(r1[i], r2[i]))
            {
                return r1[0 .. i];
            }
        }
        return r1[0 .. limit];
    }
    else
    {
        import std.range : takeExactly;
        auto result = r1.save;
        size_t i = 0;
        for (;
             !r1.empty && !r2.empty &&
             binaryFun!pred(r1.front, r2.front);
             ++i, r1.popFront(), r2.popFront())
        {}
        return takeExactly(result, i);
    }
}

void main()
{
    // prints: "hello, "
    writeln(commonPrefix("hello, world"d,
                         "hello, there"d));
}
```

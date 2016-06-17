# Functional programming

D puts an emphasis on *functional programming* and provides
first-class support for development
in a functional style.

In D a function can be declared as `pure` which implies
that given the same input parameters, always the **same**
output is generated. `pure` functions cannot access or change
any mutable global state and are thus just allowed to call other
functions which are `pure` themselves.

    int add(int lhs, int rhs) pure {
        // ERROR: impureFunction();
        return lhs + rhs;
    }

This variant of `add` is called **strongely pure function**
because it returns a result dependent only on its input
parameters without modifying them. D also allows the
definition of **weakly pure functions** which might
have mutable parameters:

    void add(ref int result, int lhs, int rhs) pure {
        result = lhs + rhs;
    }

These functions are still considered pure and can't
access or change any mutable global state. Just passed-in
mutable parameters might be altered.

Due to the constraints imposed by `pure`, pure functions
are ideal for multi-threading environments to prevent
data races *by design*. Additionally pure functions
can be cached easily and allow a range of compiler
optimizations.

The attribute `pure` is automatically inferred
by the compiler for templated functions and `auto` functions,
where applicable (this is also true for `@safe`, `nothrow`,
and `@nogc`).

### In depth

- [Functional DLang Garden](https://garden.dlang.io/)

## {SourceCode}

```d
import std.bigint;

/**
 * Computes the power of a base
 * with an exponent.
 *
 * Returns:
 *     Result of the power as an
 *     arbitrary-sized integer
 */
BigInt bigPow(uint base, uint power) pure
{
    BigInt result = 1;

    foreach (_; 0 .. power)
        result *= base;

    return result;
}

void main()
{
    import std.datetime: benchmark, to;
    import std.functional: memoize;
    import std.stdio;

    // memoize caches the result of the function
    // call depending on the input parameters.
    // pure functions are great for that!
    alias fastBigPow = memoize!(bigPow);

    void test()
    {
        writef(".uintLength() = %s ",
        	   fastBigPow(5, 10000).uintLength);
    }

    foreach (i; 0 .. 10)
        benchmark!test(1)[0]
        	.to!("msecs", double)
        	.writeln("took: miliseconds");
}
```

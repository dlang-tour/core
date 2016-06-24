# Contract programming

Contract programming in D includes a set of language constructs
that allow increasing the code quality by implementing
sanity checks that make sure that the code base
behaves as intended. Contracts are only available in
**debug** mode and won't be run in release mode.
Therefore they shouldn't be used to validate user input.

### `assert`

The simplest form of contract programming in D is
the `assert(...)` expression that checks that a certain
condition is met - and aborts the program with
an `AssertionError` otherwise.

    assert(sqrt(4) == 2);
    // optional custom assertion error message
    assert(sqrt(16) == 4, "sqrt is broken!");

### Function contracts

`in` and `out` allow to formalize contracts for input
parameters and return values of functions.

    long square_root(long x)
    in {
        assert(x >= 0);
    } out (result) {
        assert((result * result) <= x
            && (result+1) * (result+1) > x);
    } body {
        return cast(long)std.math.sqrt(cast(real)x);
    }

The content in the `in` block could also be expressed
within the function's body but the intent is much clearer
this way. In the `out` block the function's return
value can be captured with `out(result)` and
verified accordingly.

### Invariant checking

`invariant()` is a special member function of `struct`
and `class` types that allows sanity checking an object's
state during its whole lifetime:

* It's called after the constructor has run and before
  the destructor is called.
* It's called before entering a member function
* `invariant()` is called after exiting a member
  function.

### Validating user input

As all contracts will be removed in the release build, user input should not
be checked using contracts. Moreover `assert`s can still be used be in
`nothrow` functions, because they throw fatal `Errors`.
The runtime analog to `assert` is [`std.exception.enforce`](https://dlang.org/phobos/std_exception.html#.enforce),
which will throw catchable `Exceptions`.

### In-depth

- [`assert` and `enforce` in _Programming in D_](http://ddili.org/ders/d.en/assert.html)
- [Contract programming in _Programming in D_](http://ddili.org/ders/d.en/contracts.html)
- [Contract Programming for Structs and Classes in _Programming in D_](http://ddili.org/ders/d.en/invariant.html)
- [Contract programming in D spec](https://dlang.org/spec/contracts.html)
- [`std.exception`](https://dlang.org/phobos/std_exception.html)

## {SourceCode:incomplete}

```d
import std.stdio: writeln;

// Simplified Date type
// Use std.datetime instead
struct Date {
    private {
        int year;
        int month;
        int day;
    }

    this(int year, int month, int day) {
        this.year = year;
        this.month = month;
        this.day = day;
    }

    invariant() {
        assert(year >= 1900);
        assert(month >= 1 && month <= 12);
        assert(day >= 1 && day <= 31);
    }

    // Serializes Date object from a
    // YYYY-MM-DD string.
    void fromString(string date)
    in {
        assert(date.length == 10);
    }
    body {
        import std.format: formattedRead;
        // formattedRead parses the format
        // given and writes the result to the
        // given variables
        formattedRead(date, "%d-%d-%d",
            &this.year,
            &this.month,
            &this.day);
    }

    // Serializes Date object to YYYY-MM-DD
    string toString() const
    out (result) {
        import std.algorithm: all, count,
                              equal, map;
        import std.string: isNumeric;
        import std.array: split;

        // verify we return YYYY-MM-DD
        assert(result.count("-") == 2);
        auto parts = result.split("-");
        assert(parts.map!`a.length`
                    .equal([4, 2, 2]));
        assert(parts.all!isNumeric);
    }
    body {
        import std.format : format;
        return format("%.4d-%.2d-%.2d",
                      year, month, day);
    }
}

void main() {
    auto date = Date(2016, 2, 7);

    // This will make invariant fail.
    // Don't validate user input with contracts,
    // throw exceptions instead.
    date.fromString("2016-13-7");

    date.writeln;
}
```

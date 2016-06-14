# Contract programming

Contract programming in D includes a set of language constructs
that allow increasing the code quality by implementing
sanity checks that make sure that the code base
behaves as intended. Contracts are only available in
**debug** mode and won't be run in release mode.

#### `assert`

The simplest form of contract programming in D is
the `assert(...)` expression that checks that a certain
condition is met - and aborts the program with
an `AssertionError` otherwise.

    assert(sqrt(4) == 2);
    // optional custom assertion error message
    assert(sqrt(16) == 4, "sqrt is broken!");

#### Function contracts

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

#### Invariant checking

`invariant()` is a special member function of `struct`
and `class` types that allows sanity checking an object's
state during its whole lifetime:

* It's called after the constructor has run and before
  the destructor is called.
* It's called before entering a member function
* `invariant()` is called after exiting a member
  function.

### In-depth

- [Contract programming in D](https://dlang.org/spec/contracts.html)

## {SourceCode:incomplete}

```d
// Very simple Date type with a lot of
// flaws. Hint: don't use it!
struct Date {
    private {
        int year;
        int month;
        int day;
    }

    void setDate(int year, int month, int day) {
        this.year = year;
        this.month = month;
        this.day = day;
    }

    invariant() {
        assert(year >= 0);
        assert(month >= 1 && month <= 12);
        assert(day >= 1 && day <= 31);
    }

    // Initializes Date object from a
    // YYYY-MM-DD string.
    void fromString(string date)
    in {
        assert(date.length == 10);
    } body {
        import std.format: formattedRead;
        // formattedRead parses the format
        // given and writes the result to the
        // given variables
        formattedRead(date, "%d-%d-%d",
            &this.year,
            &this.month,
            &this.day);
    }
}

void main() {
    Date date;
    // invariant will not fail.
    date.setDate(2016, 2, 7);
    // This will make invariant fail.
    // Of course this should not be validated
    // inside a invariant! External data needs
    // to be checked in release mode too, and
    // be propgated through e.g. exceptions.
    date.fromString("2016-13-7");
}
```

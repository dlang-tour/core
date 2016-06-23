# Functions

One function has already been introduced: `main()` - the starting point of every
D program. A function may return a value - or be declared with
`void` if nothing is returned - and accept an arbitrary number of arguments:

    int add(int lhs, int rhs) {
        return lhs + rhs;
    }

### `auto` return types

If the return type is defined as `auto`, the D compiler infers the return
type automatically. Hence multiple `return` statements must return values with
compatible types.

    auto add(int lhs, int rhs) { // returns `int`
        return lhs + rhs;
    }

    auto lessOrEqual(int lhs, int rhs) { // returns `double`
        if (lhs <= rhs)
            return 0;
        else
            return 1.0;
    }

### Default arguments

Functions may optionally define default arguments.
This avoids the tedious work to declare redundant
overloads.

    void plot(string msg, string color = "red") {
        ...
    }
    plot("D rocks");
    plot("D rocks", "blue");

Once a default argument has been specified all following arguments
must be default arguments too.

### Local functions

Functions might even be declared inside others functions where they may be
used locally and aren't visible to the outside world.
These function can even have access to objects local to
the parent's scope:

    void fun() {
        int local = 10;
        int fun_secret() {
            local++; // that's legal
        }
        ...

Such nested functions are called delegates and they will be explained in more depth
[soon](basics/delegates).

### In-depth

- [Functions in _Programming in D_](http://ddili.org/ders/d.en/functions.html)
- [Function parameters in _Programming in D_](http://ddili.org/ders/d.en/function_parameters.html)
- [Function specification](https://dlang.org/spec/function.html)

## {SourceCode}

```d
import std.stdio;
import std.random;

void randomCalculator()
{
    // Define 4 local functions for
    // 4 different mathematical operations
    auto add(int lhs, int rhs) {
        return lhs + rhs;
    }
    auto sub(int lhs, int rhs) {
        return lhs - rhs;
    }
    auto mul(int lhs, int rhs) {
        return lhs * rhs;
    }
    auto div(int lhs, int rhs) {
        return lhs / rhs;
    }

    int a = 10;
    int b = 5;

    // uniform generates a number between START
    // and END, whereas END is NOT inclusive.
    // Depending on the result we call one of
    // the math operations.
    switch (uniform(0, 4)) {
        case 0:
            writeln(add(a, b));
            break;
        case 1:
            writeln(sub(a, b));
            break;
        case 2:
            writeln(mul(a, b));
            break;
        case 3:
            writeln(div(a, b));
            break;
        default:
            // special code which marks
            // UNREACHABLE code
            assert(0);
    }
}

void main()
{
    randomCalculator();
    // add(), sub(), mul() and div()
    // are NOT visible outside of their scope
    static assert(!__traits(compiles,
                            add(1, 2)));
}

```

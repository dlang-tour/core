# Functions

You've seen one function already: `main()` - the starting point of every
D program. A function may return something - or be declared with
`void` if nothing is returned - and an arbitrary number of parameters.

    int add(int lhs, int rhs) {
        return lhs + rhs;
    }

If the return type is defined as `auto` the D compiler infers the return
type automatically. If the types of different `return` statements within
the function's body don't match the compiler will certainly make you
aware of that.

    auto add(int lhs, int rhs) { // returns `int`
        return lhs + rhs;
    }

Functions might even be declared inside others functions where they may be
used locally and aren't visible to the outside world.
These function can even have access to objects local to
the parent's scope

    void fun() {
        int local = 10;
        int fun_secret() {
            local++; // that's legal
        }
        ...

## {SourceCode}

```d
import std.stdio;
import std.random;

void main()
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
    switch (uniform(0,4)) {
        case 0:
            writeln(add(a,b));
            break;
        case 1:
            writeln(sub(a,b));
            break;
        case 2:
            writeln(mul(a,b));
            break;
        case 3:
            writeln(div(a,b));
            break;
        default:
            // special code which marks
            // UNREACHABLE code
            assert(0);
    }
}

// NOTE:
//   add(), sub(), mul() and div()
//   are NOT visible outside of main!
```

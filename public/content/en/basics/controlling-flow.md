# Control flow

The application's flow can be controlled conditionally with `if` and `else`
statements:

    if (a == 5) {
        writeln("Condition is met");
    } else if (a > 10) {
        writeln("Another condition is met");
    } else {
        writeln("Nothing is met!");
    }

When an `if` or `else` block just contains one statement
the braces can be omitted.

D provides the same operators as C/C++ and Java for testing
variables for equality or comparing them:

* `==` and `!=` for testing equality and inequality
* `<`, `<=`, `>` and `>=` for testing less (- or equal) and greater (- or equal)

For combining multiple conditions the `||` operator represents
the logical *OR*, and `&&` the logical *AND*.

D also defines a `switch`..`case` statement which executes one case
depending on the value of *one* variable. `switch`
works with all basic types as well as strings!
It's even possible to define ranges for integral types
using the `case START: .. case END:` syntax. Make sure to
take a look at the source code example.

### In-depth

#### Basic references

- [Logical expressions in _Programming in D_](http://ddili.org/ders/d.en/logical_expressions.html)
- [If statement in _Programming in D_](http://ddili.org/ders/d.en/if.html)
- [Ternary expressions in _Programming in D_](http://ddili.org/ders/d.en/ternary.html)
- [`switch` and `case` in _Programming in D_](http://ddili.org/ders/d.en/switch_case.html)

#### Advanced references

- [Expressions in detail](https://dlang.org/spec/expression.html)
- [If Statement specification](https://dlang.org/spec/statement.html#if-statement)

## {SourceCode}

```d
import std.stdio;

void main()
{
    if (1 == 1)
        writeln("You can trust math in D");

    int c = 5;
    switch(c) {
        case 0: .. case 9:
            writeln(c, " is within 0-9");
            break; // necessary!
        case 10:
            writeln("A Ten!");
            break;
        default: // if nothing else matches
            writeln("Nothing");
            break;
    }
}
```

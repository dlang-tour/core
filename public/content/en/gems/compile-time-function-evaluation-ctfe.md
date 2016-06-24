# Compile Time Function Evaluation (CTFE)

CTFE is a mechanism which allows the compiler to execute
functions at **compile time**. There is no special set of the D
language necessary to use this feature - whenever
a function just depends on compile time known values
the D compiler might decide to interpret
it during compilation.

    // result will be calculated at compile
    // time. Check the machine code, it won't
    // contain a function call!
    static val = sqrt(50);

Keywords like `static`, `immutable` or `enum`
instruct the compiler to use CTFE whenever possible.
The great thing about this technique is that
functions don't need to be rewritten to use
it, and the same code can perfectly be shared:

    int n = doSomeRuntimeStuff();
    // same function as above but this
    // time it is just called the classical
    // run-time way.
    auto val = sqrt(n);

One prominent example in D is the [std.regex](https://dlang.org/phobos/std_regex.html)
library. It provides at type `ctRegex` type which uses
*string mixins* and CTFE to generate a highly optimized
regular expression automaton that is generated during
compilation. The same code base is re-used for
the run-time version `regex` that allows to compile
regular expressions only available at run-time.

    auto ctr = ctRegex!(`^.*/([^/]+)/?$`);
    auto tr = regex(`^.*/([^/]+)/?$`);
    // ctr and tr can be used interchangely
    // but ctr will be faster!

Not all language features are available
during CTFE but the supported feature set is increased
with every release of the compiler.

### In-depth

- [Introduction to regular expressions in D](https://dlang.org/regular-expression.html)
- [std.regex](https://dlang.org/phobos/std_regex.html)
- [Conditional compilation](https://dlang.org/spec/version.html)

## {SourceCode}

```d
import std.stdio: writeln;

/* Returns: square root of x using
 Newton's approximation scheme. */
auto sqrt(T)(T x) {
    // our epsilon when to stop the
    // approximation because we think the change
    // isn't worth another iteration.
    enum GoodEnough = 0.01;
    import std.math: abs;
    // choose a good starting value.
    T z = x*x, old = 0;
    int iter;
    while (abs(z - old) > GoodEnough) {
        old = z;
        z -= ((z*z)-x) / (2*z);
    }

    return z;
}

void main() {
    double n = 4.0;
    writeln("The sqrt of runtime 4 = ",
        sqrt(n));
    static cn = sqrt(4.0);
    writeln("The sqrt of compile time 4 = ",
        cn);
}
```

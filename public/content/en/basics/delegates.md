# Delegates

A function can also be a parameter to another function:

    void doSomething(int function(int, int) doer) {
        // call passed function
        doer(5,5);
    }

    doSomething(add); // use global function `add` here
                      // add must have 2 int parameters

`doer` can then be called like any other normal function.

The above example uses the `function` type which is
a pointer to a global function. As soon as a member
function or a local function is referenced, `delegate`'s
have to be used. It's a function pointer
that additionally contains information about its
context - or *enclosure*, thus also called **closure**
in other languages. For example a `delegate`
that points to a member function of a class also includes
the pointer to the class object. A local `delegate`
includes a link to the enclosing scope which is copied
automatically to the heap by the D compiler.

    void foo() {
        void local() {
            writeln("local");
        }
        auto f = &local; // f is of type delegate()
    }

The same function `doSomething` taking a `delegate`
would look like this:

    void doSomething(int delegate(int,int) doer);

`delegate` and `function` objects cannot be mixed. But the
standard function
[`std.functional.toDelegate`](https://dlang.org/phobos/std_functional.html#.toDelegate)
converts a `function` to a `delegate`.

Nameless function which are called *lambdas* can be defined in two ways:

    auto f = (int lhs, int rhs) {
        return lhs + rhs;
    };
    auto f = (int lhs, int rhs) => lhs + rhs;

The second form is a shorthand form for lambdas that consist
of just one line. Moreover if the type(s) of the lambda parameters
can be inferred by the context, they can be omitted too.

### In-depth

- [Delegate specification](https://dlang.org/spec/function.html#closures)

## {SourceCode}

```d
import std.stdio;

enum IntOps {
    add = 0,
    sub = 1,
    mul = 2,
    div = 3
}

/**
Provides a math calculuation
Params:
    op = selected math operation
Returns: delegate which does a math operation
*/
auto getMathOperation(IntOps op)
{
    // Define 4 lambda functions for
    // 4 different mathematical operations
    auto add = (int lhs, int rhs) => lhs + rhs;
    auto sub = (int lhs, int rhs) => lhs - rhs;
    auto mul = (int lhs, int rhs) => lhs * rhs;
    auto div = (int lhs, int rhs) => lhs / rhs;

    // we can ensure that the switch covers
    // all cases
    final switch (op) {
        case IntOps.add:
            return add;
        case IntOps.sub:
            return sub;
        case IntOps.mul:
            return mul;
        case IntOps.div:
            return div;
    }
}

void main()
{
    int a = 10;
    int b = 5;

    auto func = getMathOperation(IntOps.add);
    writeln("The type of func is ",
        typeof(func).stringof, "!");

    // run the delegate func which does all the
    // real work for us!
    writeln("result: ", func(a, b));
}
```

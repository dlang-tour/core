# Fibers

**Fibers** are a way to implemented concurrency
in a *cooperative* fashion. The class `Fiber`
is defined in the module [`core.thread`](https://dlang.org/phobos/core_thread.html).

The basic idea is that when a fiber
has nothing to do or waits for more input, it
*actively* gives away its possibility to
execute instructions by calling `Fiber.yield()`.
The parent context gains now power again but the
fiber's state - all variables on the stack - are
saved. The fiber can then be resumed
and will continue at the instruction right *after*
it called `Fiber.yield()`. Magic? Yes.

    void foo() {
        writeln("Hello");
        Fiber.yield();
        writeln("World");
    }
    // ...
    auto f = new Fiber(&foo);
    f.call(); // Prints Hello
    f.call(); // Prints World

This feature can be used to implement concurrency
where multiple fibers cooperatively share a single
core. The advantage of fibers compared to threads is
that there resource usage is lower because
no context switching is involved.

A very good usage of this technique can be seen in
the [vibe.d framework](http://vibed.org) which implements
non-blocking (or asynchronous) I/O operations
in terms of fibers leading to a much cleaner
code.

### In-depth

- [Fibers in _Programming in D_](http://ddili.org/ders/d.en/fibers.html)
- [Documentation of core.thread.Fiber](https://dlang.org/library/core/thread/fiber.html)

## {SourceCode}

```d
import core.thread: Fiber;
import std.stdio: write;
import std.range: iota;

/**
 * Iterates over $(D range) and applies
 * the function $(D Fnc) to each element x
 * and returns it in $(D result). Fiber yields
 * after each application.
 */
void fiberedRange(alias Fnc, R, T)(
    R range,
    ref T result)
{
    for(; !range.empty; range.popFront) {
        result = Fnc(range.front);
        Fiber.yield();
    }
}

void main()
{
    int squareResult, cubeResult;
    // Create a fiber that is initialized
    // with a delegate that generates a square
    // range.
    auto squareFiber = new Fiber({
        fiberedRange!(x => x*x)(
            iota(1,11), squareResult);
    });
    // .. and here is which creates cubes!
    auto cubeFiber = new Fiber({
        fiberedRange!(x => x*x*x)(
            iota(1,9), cubeResult);
    });

    // if state is TERM the fiber has finished
    // executing its associated function.
    squareFiber.call();
    cubeFiber.call();
    while (squareFiber.state
        != Fiber.State.TERM && cubeFiber.state
        != Fiber.State.TERM)
    {
        write(squareResult, " ", cubeResult);
        squareFiber.call();
        cubeFiber.call();
        write("\n");
    }

    // squareFiber could still be run because
    // it has finished yet!
}
```

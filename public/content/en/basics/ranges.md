# Ranges

If a `foreach` is encountered by the compiler

    foreach(element; range) {

.. it's rewritten to something equivalent to the following internally:

    for (; !range.empty; range.popFront()) {
        auto element = range.front;
        ...

Any object which fulfills the above interface is called a **range**
and is thus something that can be iterated over:

    struct Range {
        @property empty() const;
        void popFront();
        T front();
    }

The functions that are in the `std.range` and `std.algorithm` modules also provide
building blocks that make use of this interface. Ranges allow
to compose complex algorithms behind an object that
can be iterated with ease. And ranges allows to create **lazy**
objects that actually just perform a calculation when this
is really needed in an iteration e.g. when a range's
element is used.

### Exercise

Complete the source code to create the `FibonacciRange` range
that returns numbers of the
[Fibonacci sequence](https://en.wikipedia.org/wiki/Fibonacci_number).
Don't fool yourself into deleting the `assert`ions!

## {SourceCode:incomplete}

import std.stdio;

struct FibonacciRange
{
    @property empty() const
    {
        // So when does the Fibonacci sequence
        // end?!
    }

    void popFront()
    {
    }

    int front()
    {
    }
}

void main() {
    import std.range: take;
    import std.array: array;

    FibonacciRange fib;

    // `take` creates another range which
    // will return N elements at maximum.
    // This range is _lazy_ and just
    // touches the original range
    // if actually needed
    auto fib10 = take(fib, 10);

    // But we do want to touch all elements and
    // convert the range to array of integers.
    int[] the10Fibs = array(fib10);

    writeln("The 10 first Fibonacci numbers: ",
        the10Fibs);
    assert(the10Fibs ==
        [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
}


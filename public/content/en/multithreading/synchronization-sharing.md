# Synchronization & Sharing

Although the preferred way in D to do multi-threading
is to rely on `immutable` data and synchronize threads
using message passing, the language has built-in
support for *synchronization* primitives as well as
type system support with `shared` to mark objects
that are accessed from multiple threads.

The `shared` type identifier allows to mark variables
that are shared among different threads:

    shared(int)* p = new int;
    int* t = p; // ERROR

For example `std.concurrency.send` just allows to send either
`immutable` or `shared` data and copying the message
to be sent. `shared` is transitive so if a `class` or `struct`
is marked `shared` all its members will be too.
Note that `static` variables aren't `shared` by
default because they are implemented using
*thread local storage* (TLS) and each thread gets
its own variable.

`synchronized` blocks allow to instruct the compiler
to create  a critical section that can only be entered
by one thread at a time.

    synchronized {
        importStuff();
    }

Within `class` member functions these blocks might be
limited to different member objects *mutexes*
with `synchronized(member1, member2)` to reduce
contention. The D compiler inserts *critical
sections* automatically. A whole class can be marked
as `synchronized` as well and the compiler will
make sure that just one thread accesses a concrete
instance of it at a time.

Atomic operations on `shared` variables can be
performed using the `core.atomic.atomicOp`
helper:

    shared int test = 5;
    test.atomicOp!"+="(4);

### In-depth

- [Data Sharing Concurrency in _Programming in D_](http://ddili.org/ders/d.en/concurrency_shared.html)
- [`shared` type qualifier](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=11)
- [Lock-Based Synchronization with `synchronized`](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=13)
- [Deadlocks and `synchronized`](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=15)
- [`synchronized` specification](https://dlang.org/spec/statement.html#SynchronizedStatement)
- [Implicit conversions with `shared` data types](https://dlang.org/spec/const3.html#implicit_conversions)

## {SourceCode}

```d
import std.concurrency;
import core.atomic;

/// Queue that can be used safely among
/// different threads. All access to an
/// instance is automatically locked thanks to
/// synchronized keyword.
synchronized class SafeQueue(T)
{
    // Note: must be private in synchronized
    // classes otherwise D complains.
    private T[] elements;

    void push(T value) {
        elements ~= value;
    }

    /// Return T.init if queue empty
    T pop() {
        import std.array: empty;
        T value;
        if (elements.empty)
            return value;
        value = elements[0];
        elements = elements[1 .. $];
        return value;
    }
}

/// Safely print messages independent of
/// number of concurrent threads.
/// Note that variadic parameters are used
/// for args! That is args might be 0 .. N
/// parameters.
void safePrint(T...)(T args)
{
    // Just executed by one concurrently
    synchronized {
        import std.stdio: writeln;
        writeln(args);
    }
}

void threadProducer(shared(SafeQueue!int) queue,
    shared(int)* queueCounter)
{
    import std.range: iota;
    // Push values 1 to 11
    foreach (i; iota(1,11)) {
        queue.push(i);
        safePrint("Pushed ", i);
        atomicOp!"+="(*queueCounter, 1);
    }
}

void threadConsumer(Tid owner,
    shared(SafeQueue!int) queue,
    shared(int)* queueCounter)
{
    int popped = 0;
    while (popped != 10) {
        auto i = queue.pop();
        if (i == int.init)
            continue;
        ++popped;
        // safely fetch current value of
        // queueCounter using atomicLoad
        safePrint("Popped ", i,
            " (Consumer pushed ",
            atomicLoad(*queueCounter), ")");
    }

    // I'm done!
    owner.send(true);
}

void main()
{
    auto queue = new shared(SafeQueue!int);
    shared int counter = 0;
    spawn(&threadProducer, queue, &counter);
    auto consumer = spawn(&threadConsumer,
                    thisTid, queue, &counter);
    auto stopped = receiveOnly!bool;
    assert(stopped);
}
```

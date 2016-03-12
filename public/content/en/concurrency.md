# Concurrency
# Message Passing

Instead of dealing with threads and doing synchronization
yourself D allows to use *message passing* as a means
to leverage the power of multiple cores. Threads communicate
with *messages* - which are arbitrary values - to distribute
work and synchronize themselves. They don't share data
by design which avoids the common problems of
multi-threading.

All functions that implement message passing in D
can be found in the [`std.concurrency`](https://dlang.org/phobos/std_concurrency.html)
module. `spawn` creates a new *thread* based on a
user-defined function:

    auto threadId = spawn(&foo, thisTid);

`thisTid` is a `std.concurrency` built-in and references
the current thread which is needed for message passing. `spawn`
takes a function as first parameter and
additional parameters to that function as arguments.

    void foo(Tid parentTid) {
        receive(
          (int i) { writeln("An ", i, " was sent!"); }
        );
        
        send(parentTid, "Done");
    }

The `receive` function is like a `switch`-`case`
and dispatches the values it receives from other threads
to the passed `delegates` - depending on the received
value's type.

To send a message to a specific thread use the function `send`
and its id:

    send(42, threadId);

`receiveOnly` can be used to just receive a specified
type:

    string text = receiveOnly!string();
    assert(text == "Done");

The `receive` family functions block until something
has been sent to the thread's mailbox.

## {SourceCode}

import std.stdio: writeln;
import std.concurrency;

/// A custom struct that is used as a message
/// for a little thread army.
struct NumberMessage {
    int number;
    this(int i) {
        this.number = i;
    }
}

/// Message is used as a stop sign for other
/// threads
struct CancelMessage {
}

/// Acknowledge a CancelMessage
struct CancelAckMessage {
}

/// Our thread worker main
/// function which gets its parent id
/// passed as argument.
void worker(Tid parentId)
{
    bool canceled = false;
    writeln("Starting ", thisTid, "...");

    while (!canceled) {
      receive(
        (NumberMessage m) {
          writeln("Received int: ", m.number);
        },
        (string text) {
          writeln("Received string: ", text);
        },
        (CancelMessage m) {
          writeln("Stopping ", thisTid, "...");
          send(parentId, CancelAckMessage());
          canceled = true;
        }
      );
    }
}

void main()
{
    Tid threads[];
    // Spawn 10 little worker threads.
    for (size_t i = 0; i < 10; ++i) {
        threads ~= spawn(&worker, thisTid);
    }

    // Odd threads get a number, even threads
    // a string!
    foreach(int idx, ref tid; threads) {
        import std.string: format;
        if (idx  % 2)
            send(tid, NumberMessage(idx));
        else
            send(tid, format("T=%d", idx));
    }

    // And all threads get the cancel message!
    foreach(ref tid; threads) {
        send(tid, CancelMessage());
    }

    // And we wait until all threads have
    // acknowledged their stop request
    foreach(ref tid; threads) {
        receiveOnly!CancelAckMessage;
        writeln("Received CancelAckMessage!");
    }
}

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

## {SourceCode}

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

# std.parallelism

The module `std.parallelism` implements some very
nice high level primitives for concurrent programming.

### parallel

`std.parallelism.parallel` allows to automatically distribute
a `foreach`'s body to different threads:

    // parallel squaring of arr
    auto arr = iota(1,100).array;
    foreach(ref i; parallel(arr)) {
        i = i*i;
    }

`parallel` uses the `opApply` operator internally
to make this magic work. The global `parallel`  is
a shortcut to `taskPool.parallel` which is a
`TaskPool` that uses *total number of cpus - 1*
working threads. Creating your own instance allows
to control the degree of parallelism.

Beware that the body of a `parallel` iteration must
make sure that it doesn't modify items that another
working unit might have access to.

An optional `workingUnitSize` allows to specify the number
of elements a worker thread does in one go. This
is always transparent for your `foreach` user code!

### reduce

The function
[`std.algorithm.iteration.reduce`](http://dlang.org/phobos/std_algorithm_iteration.html#reduce) -
known from other functional contexts as *accumulate* or *foldl* -
calls a function `fun(acc, x)` for each element `x`
where `acc` is the previous result:

    // 0 is the "seed"
    auto sum = reduce!"a + b"(0, elements);

There is a parallel `Taskpool.reduce` version
of it:

    // Find the sum of a range in parallel, using the first
    // element of each work unit as the seed.
    auto sum = taskPool.reduce!"a + b"(nums);

`TaskPool.reduce` splits the range into
sub ranges that are reduced in parallel. Once these
results have been calculated the results are reduced
themselves.

### `task()`

`task` is a wrapper for a function
that might take longer or should be executed in
its own working thread. It can either be enqueued
in a taskpool:

    auto t = task!read("foo.txt");
    taskPool.put(t);

Or just be executed in its own thread:

    t.executeInNewThread();

To get a task's result call `yieldForce`
on it. It will block until the reuslt is available.

    auto fileData = t.yieldForce;

## {SourceCode}

import std.parallelism;
import std.array: array;
import std.stdio: writeln;
import std.range: iota;

string theTask()
{
    import core.thread;
    Thread.sleep( dur!("seconds")(1) );
    return "Hello World";
}

void main()
{
    // 2 threaded taskpool
    auto myTaskPool = new TaskPool(2);
    // Stopping the task pool is important!
    scope(exit) myTaskPool.stop();

    // Start long running task
    // and do some other stuff in the mean
    // time..
    auto task = task!theTask;
    myTaskPool.put(task);

    auto arr = iota(1, 10).array;
    foreach(ref i; myTaskPool.parallel(arr)) {
        i = i*i;
    }

    writeln(arr);

    import std.algorithm: map;
    // Use reduce to calculate the sum
    // of all squares in parallel.
    auto result = taskPool.reduce!"a+b"(
        0.0, iota(100).map!"a*a");
    writeln("Sum of squares: ", result);

    // Get our result we sent to background
    // earlier.
    writeln(task.yieldForce);
}

# Fibers

...

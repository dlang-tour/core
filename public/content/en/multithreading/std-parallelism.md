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

```d
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
```

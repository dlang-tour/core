# std.parallelism

The module `std.parallelism` implements
high level primitives for convenient concurrent programming.

### parallel

[`std.parallelism.parallel`](http://dlang.org/phobos/std_parallelism.html#.parallel) allows to automatically distribute
a `foreach`'s body to different threads:

    // parallel squaring of arr
    auto arr = iota(1,100).array;
    foreach(ref i; parallel(arr)) {
        i = i*i;
    }

`parallel` uses the `opApply` operator internally.
The global `parallel`  is a shortcut to `taskPool.parallel`
which is a `TaskPool` that uses *total number of cpus - 1*
working threads. Creating your own instance allows
to control the degree of parallelism.

Beware that the body of a `parallel` iteration must
make sure that it doesn't modify items that another
working unit might have access to.

The optional `workingUnitSize` specifies the number of elements processed
per worker thread.

### reduce

The function
[`std.algorithm.iteration.reduce`](http://dlang.org/phobos/std_algorithm_iteration.html#reduce) -
known from other functional contexts as *accumulate* or *foldl* -
calls a function `fun(acc, x)` for each element `x`
where `acc` is the previous result:

    // 0 is the "seed"
    auto sum = reduce!"a + b"(0, elements);

[`Taskpool.reduce`](http://dlang.org/phobos/std_parallelism.html#.TaskPool.reduce)
is the parallel analog to `reduce`:

    // Find the sum of a range in parallel, using the first
    // element of each work unit as the seed.
    auto sum = taskPool.reduce!"a + b"(nums);

`TaskPool.reduce` splits the range into
sub ranges that are reduced in parallel. Once these
results have been calculated, the results are reduced
themselves.

### `task()`

[`task`](http://dlang.org/phobos/std_parallelism.html#.task) is a wrapper for a function
that might take longer or should be executed in
its own working thread. It can either be enqueued
in a taskpool:

    auto t = task!read("foo.txt");
    taskPool.put(t);

Or directly be executed in its own, new thread:

    t.executeInNewThread();

To get a task's result call `yieldForce`
on it. It will block until the result is available.

    auto fileData = t.yieldForce;

### In-depth

- [Parallelism in _Programming in D_](http://ddili.org/ders/d.en/parallelism.html)
- [std.parallelism](http://dlang.org/phobos/std_parallelism.html)

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
    // taskpool with two threads
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

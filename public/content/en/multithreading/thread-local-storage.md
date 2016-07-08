# Thread local storage

The storage class `static` allows declaring objects
which are initialized only once. If the same
line is executed a second time, the initialization
will be omitted.
Every thread will get its own
`static` object (*TLS - thread local storage*)
and won't be able to read or modify another thread's
`static` object - although the variable name
stays the same. Thus `static` allows declaring an
object that holds state that is
is global for the *current* thread.

This is different to
e.g. C/C++ and Java where `static` indeed means global
for the application, entailing synchronization issues
in multi-threaded applications.

The value assigned to a `static` variable must
be evaluable at compile-time. It mustn't have
runtime dependencies! It's possible to initialize
`static` variables at runtime using a `static this()`
one-time constructor for structs, classes, and modules.

    static int b = 42;
    // b is just intialized once!
    // When run from different threads
    // each b will have see its
    // "own" b without interference from
    // other threds.

Moreover for declaration of a "classic" global variable that
every thread can see and modify,
use the storage class `__gshared` which is equivalent
to C's `static`.
Its ugly name is a friendly reminder to use it rarely.

    __gshared int b = 50;
    // Also intialized just once!
    // A truly global b which every thread
    // can read - and making it dangerous -
    // modify!

### In-depth

- [Thread-local storage on Wikipedia](https://en.wikipedia.org/wiki/Thread-local_storage)

## {SourceCode}

```d
import std.concurrency;

void worker(bool firstTime)
{
    import std.stdio: writeln;
    // theStatic is global to the current
    // thread only. No other thread will be
    // able to access it. Note that it
    // is initialized only the first time
    // the line is executed.
    static int threadState = 0;
    writeln("Thread ", thisTid,
        ": My state = ", threadState++);
    if (firstTime)
        worker(false);
}

void main()
{
    // Create 5 threads that call
    // worker(true,i) each.
    for (size_t i = 0; i < 5; ++i) {
        spawn(&worker, true);
    }
}
```

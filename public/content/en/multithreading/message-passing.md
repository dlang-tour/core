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

    send(threadId, 42);

`receiveOnly` can be used to just receive a specified
type:

    string text = receiveOnly!string();
    assert(text == "Done");

The `receive` family functions block until something
has been sent to the thread's mailbox.


### In-depth

- [Exchanging Messages between Threads](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=5)
- [Messaging passing concurrency](http://ddili.org/ders/d.en/concurrency.html)
- [Pattern Matching with receive](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=6)
- [Multi-threaded file copying](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=7)
- [Thread Termination](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=8)
- [Out-of-Band Communication](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=9)
- [Mailbox crowding](http://www.informit.com/articles/article.aspx?p=1609144&seqNum=10)

## {SourceCode}

```d
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
```

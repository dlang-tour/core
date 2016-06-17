# Basics & Asynchronous I/O

Using the default build parameters the `main()`
function of a vibe.d application is specified
by a special `shared static this()` module
constructor:

    import vibe.d;
    shared static this() {
        // Vibe.d code here
    }

A module constructor is executed
before `main()` and just run once. Vibe.d provides
its own `main()` and hides all the event loop and
housekeeping stuff from the user code.

Vibe.d uses *fibers* to implement asynchronous I/O:
every time a call to socket would block - because we don't
have any data for reading for example - the currently
running fiber `yield`s its current execution
context and leaves the field for another
operation. When the data is available we just
resume execution:

    // Might block but this is transparent.
    // If socket is ready vibe.d makes sure
    // we return here.
    line = connection.readLine();
    // Might block too
    connection.write(line);

Also the code looks like it is *synchronous* and
would block the current thread, but it doesn't!
The code looks clean and concise but it still
uses the power of asynchronous I/O allowing
thousands of connections on a single core.

All vibe.d features make use of fiber based
asynchronous socket operations so you don't have
to worry about that one single slow MongoDB server connection
blocks your whole application.

Make sure to check the example which shows how
to implement a simple TCP based echo server.

## {SourceCode:disabled}

```d
import vibe.d;

shared static this()
{
    // Listen on port 8080 (TCP).
    // Each time a new connection arrives
    // it is handled by the delegate
    // specified as 2nd parameter. conn
    // is the TCP connection object to the
    // client.
    listenTCP(8080, (TCPConnection conn) {
        string line;
        conn.write("ECHO server says Hi!\r\n");
        conn.write("Type 'quit' to close.\r\n");
        while (line != "quit") {
            line = cast(string) conn.readLine();
            conn.write("ECHO: " ~ line
              ~ "\r\n");
        }

        // Just exiting the delegate here
        // will close the client's connection.
    });
}
```

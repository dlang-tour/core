# Vibe.d
# Vibe.d web framework

[Vibe.d](http://vibed.org) is a very powerful web
framework which this tour for example has been written
with.

Based on a fiber based approach for *asynchronous I/O*
vibe.d allows to write high-performance HTTP(S) web servers
and web services. An
easy to use JSON interface generator and out-of-the-box
support for Redis and MongoDB make it easy to
write backend systems that have a good performance.
Generic TCP or UDP clients and servers can be
written as well using this framework.

Note that the examples in this chapter
can't be run online because they
would require network support which is disabled
for obvious security reasons.

The easiest way to create a vibe.d project is to install
`dub` and create a new project with *vibe.d* specified
as template:

    dub init <project-name> -t vibe.d

`dub` will make sure that vibe.d is downloaded and
available for building your vibe.d based project.

The book [D Web development](https://www.packtpub.com/web-development/d-web-development)
gives a thorough introduction into this great
framework.

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

import vibe.d;

shared static this()
{
    listenTCP(8080, (TCPConnection conn) {
        string line;
        conn.write("ECHO server says Hi!\r\n");
        conn.write("Type 'quit' to close.\r\n");
        while (line != "quit") {
            line = cast(string) conn.readLine();
            conn.write("ECHO: " ~ line ~ "\r\n");
        }
    });
}

# Web interface

...

# DIET Templates

...

# JSON REST Interface

...

# Database connectivity

...



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
            conn.write("ECHO: " ~ line ~ "\r\n");
        }

        // Just exiting the delegate here
        // will close the client's connection.
    });
}

# Web server

Vibe.d allows writing HTTP(S) web servers in no
time:

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    listenHTTP(settings, &foo);

This starts a web server on port 8080 where all
requests are handled by a `foo` function:

    void foo(HTTPServerRequest req,
        HTTPServerResponse res) { ... }

To ease typical usage patterns and the configuration
of different paths, a `URLRouter` class is provided
which either allows registering `GET`, `POST` etc.
handlers using the `.get("path", handler)`
and `.post("path", handler)` member functions, or
registering a custom *web interface* class which implements
web server paths as member functions:

    auto router = new URLRouter;
    router.registerWebInterface(new WebService);
    listenHTTP(settings, router);

The paths of the custom web interface `WebService`'s member functions
will automatically be deduced using a simple scheme:
* `index()` will handle`/index`
* `getName()` will handle the `GET` request `/name`
* `postUsername()` will handle to `POST` request
  to `/username`

Custom paths can be set by attributing a member
function with a `@path("/hello/world")` attribute.
Parameters for `POST` requests will be made available
to the function using `_` prefixed variable names. It is
also possible to specify parameters directly
in the path itself:

    @path("/my/api/:id")
    void foo(int _id)

You don't need to pass `HTTPServerResponse` and
`HTTPServerRequest` as parameter to each function.
Vibe.d statically checks whether it is in a function's parameter list
and just passes it if needed.

## {SourceCode}

import vibe.d;

class WebService
{
    /// session variable which will be available
    /// for the current client's session
    /// in other requests.
    private SessionVar!(string, "username")
        username_;

    /// Because of the function name the path
    /// will be induced to /.
    void index(HTTPServerResponse res)
    {
        auto contents = q{<html><head>
            <title>Tell me!</title>
        </head><body>
        <form action="/username" method="POST">
        Your name:
        <input type="text" name="username">
        <input type="submit" value="Submit">
        </form>
        </body>
        </html>};

        res.writeBody(contents,
                "text/html; charset=UTF-8");
    }

    /// Display the current client's
    /// session username.
    @path("/name")
    void getName(HTTPServerRequest req,
            HTTPServerResponse res)
    {
        import std.string: format;

        // Generate header info <li>
        // tags by inspecting the request's
        // headers property.
        string[] headers;
        foreach(key, value; req.headers) {
            headers ~=
                "<li>%s: %s</li>"
                .format(key, value);
        }
        auto contents = q{<html><head>
            <title>Tell me!</title>
        </head><body>
        <h1>Your name: %s</h1>
        <h2>Headers</h2>
        <ul>
        %s
        </ul>
        </body>
        </html>}.format(username_,
                headers.join("\n"));

        res.writeBody(contents,
                "text/html; charset=UTF-8");
    }

    void postUsername(string username,
            HTTPServerResponse res)
    {
        username_ = username;
        auto contents = q{<html><head>
            <title>Tell me!</title>
        </head><body>
        <h1>Your name: %s</h1>
        </body>
        </html>}.format(username_);

        res.writeBody(contents,
                "text/html; charset=UTF-8");
    }
}

void helloWorld(HTTPServerRequest req,
        HTTPServerResponse res)
{
    res.writeBody("Hello");
}

shared static this()
{
    auto router = new URLRouter;
    router.registerWebInterface(new WebService);
    router.get("/hello", &helloWorld);

    auto settings = new HTTPServerSettings;
    // Needed for SessionVar usage.
    settings.sessionStore = new MemorySessionStore;
    settings.port = 8080;
    listenHTTP(settings, router);
}

# DIET Templates

To make writing web pages easier vibe.d supports
[DIET templates](https://vibed.org/templates/diet)
which is a simplified syntax to write HTML pages.
DIET is based on
[Jade templates](http://jade-lang.com/).

    doctype html
    html(lang="en")
      head
        // D code is evaluated
        title #{pageTitle}
        // attributes
        script(type='text/javascript')
          if (foo) bar(1 + 5)
        // ID = body-id
        // style = the-style
        body#body-id.the-style
          h1 DIET template

The syntax is indentation-aware and the closing
tags don't have to be inserted.

All DIET templates are compiled and are held
in memory for maximum performance.
DIET templates allows using D code which is evaluated
when rendering the page. Single expressions
are enclosed in `#{ 1 + 1 }` and can be used anywhere
in the template. Whole D code lines are
prefixed with `-` on their own line:

    - foreach(title; titles)
      h1 #{title}

Complex expressions can be used that way, and
even functions may be defined that are used to
output final HTML.

DIET templates are compiled using **CTFE**
and have to reside in the `views` folder
in a standard vibe.d project. To actually render
a DIET template use the `render` function within
an URL handler:

    void foo(HTTPServerResponse res) {
        string pageTitle = "Hello";
        int test = 10;
        res.render!("my-template.dt", pageTitle, test);
    }

All D variables available to a DIET template
are passed as template parameters to `render`.

## {SourceCode}

doctype html
html
  head
    title D statement test
  body
    - import std.algorithm : min;
    p Four items ahead:
    - foreach( i; 0 .. 4 )
      - auto num = i+1;
      p Item
        b= num
    p Prints 8:
    p= min(10, 2*6, 8)

# JSON REST Interface

...

# Database connectivity

...



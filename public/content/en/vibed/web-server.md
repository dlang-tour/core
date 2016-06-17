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

## {SourceCode:disabled}

```d
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
    settings.sessionStore =
        new MemorySessionStore;
    settings.port = 8080;
    listenHTTP(settings, router);
}
```

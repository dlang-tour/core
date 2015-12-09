# D's Gems
# Uniform Function Call Syntax (UFCS)

*UFCS* is totally simple: any call to a free function 
`fun(a, ...)` can be also be called by writing `a.fun(...)`.



# Scope guards

Scope guards allow executing statements at certain conditions
if the current block is left:

* `scope(exit)` will always call the statements
* `scope(success)` statements are called when **no** exceptions
  have been thrown
* `scope(failure)` denotes statements that will be called when
  an exception has been thrown before the block's end

Using scope guards makes code much cleaner and allows to place
resource allocation and clean up code next to each other.
These little helpers also improve saftey because they make sure
certain clenaup code is *always* called independent of which paths
are acutally taken at runtime.

The D `scope` feature effectively replaces the *RAII* idiom
used in C++ which often leads to special scope guards objects
for special resources.

Scope guards are called in the reverse order they are defined.

## {SourceCode}

import std.stdio;

void main()
{
    writeln("<html>");
    scope(exit) writeln("</html>");

    {
        writeln("  <head>");
        "<title>%s</title>".writefln("Hello");
        scope(exit) writeln("</head>");
    }

    writeln("  <body>");
    scope(exit) writeln("  </body>");

    writeln("    <h1>Hello World!</h1>");
}

# Compile Time Function Evaluation - CTFE

`ctRegex`
...

# Template meta programming

...

# Contract programming

...

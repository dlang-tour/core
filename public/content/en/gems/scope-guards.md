# Scope guards

Scope guards allow executing statements at certain conditions
if the current block is left:

* `scope(exit)` will always call the statements
* `scope(success)` statements are called when no exceptions
  have been thrown
* `scope(failure)` denotes statements that will be called when
  an exception has been thrown before the block's end

Using scope guards makes code much cleaner and allows to place
resource allocation and clean up code next to each other.
These little helpers also improve safety because they make sure
certain cleanup code is *always* called independent of which paths
are actually taken at runtime.

The D `scope` feature effectively replaces the RAII idiom
used in C++ which often leads to special scope guards objects
for special resources.

Scope guards are called in the reverse order they are defined.

### In-depth

- [`scope` in _Programming in D_](http://ddili.org/ders/d.en/scope.html)

## {SourceCode}

```d
import std.stdio;

void main()
{
    writeln("<html>");
    scope(exit) writeln("</html>");

    {
        writeln("\t<head>");
        scope(exit) writeln("\t</head>");
        "\t<title>%s</title>".writefln("Hello");
    } // the scope(exit) on the previous line
      // is executed here

    writeln("\t<body>");
    scope(exit) writeln("\t</body>");

    writeln("\t\t<h1>Hello World!</h1>");

    // scope guards allow placing allocations
    // and their clean up code next to each
    // other
    import core.stdc.stdlib;
    int* p = cast(int*)malloc(int.sizeof);
    scope(exit) free(p);
}
```

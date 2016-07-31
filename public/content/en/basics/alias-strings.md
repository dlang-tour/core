# Alias & Strings

Now that we know what arrays are, have gotten in touch of `immutable`
and had a quick look at the basic types, it's time to introduce two
new constructs in one line:

    alias string = immutable(char)[];

The term `string` is defined by an `alias` expression which defines it
as a slice of `immutable(char)`'s. That is, once a `string` has been constructed
its content will never change again. And actually this is the second
introduction: welcome UTF-8 `string`!

Due to their immutablility `string`s can perfectly be shared among
different threads. As `string` is a slice, parts can be taken out of it without
allocating memory. The standard function `std.algorithm.splitter`
for example splits a string by newline without any memory allocations.

Beside the UTF-8 `string` there are two more types:

    alias wstring = immutable(wchar)[]; // UTF-16
    alias dstring = immutable(dchar)[]; // UTF-32

The variants are most easily converted between each other using
the `to` method from `std.conv`:

    dstring myDstring = to!dstring(myString);
    string myString   = to!string(myDstring);

Since `string`s are arrays, the same operations apply to them.
For example strings might be concatenated using the `~` operator.
In non-ASCII strings a character might be represented with multiple bytes,
hence e.g. the property `.length` does not yield the
number of character for encoded UTF (UCS Transformation Format) strings.
Therefore for encoded strings instead of `.length`,
[`std.utf.count`](http://dlang.org/phobos/std_utf.html#.count) needs to be used.
As dealing with encoded UTF strings can be tedious,
[`std.utf`](http://dlang.org/phobos/std_utf.html) provides further
methods that help dealing with decoding UTF strings. Unicode algorithms
can utilize [`std.uni`](http://dlang.org/phobos/std_uni.html).

To create multi-line strings use the `string str = q{ ... }` syntax.
Raw strings that don't require laborious escaping, can be declared using
either backticks (`` ` ... ` ``)
or the r(aw)-prefix (`r" ... "`).

    string multiline = q{ This
        may be a
        long document
    };
    string raw  =  `raw "string"`; \\ raw "string"
    string raw2 = r"raw "string""; \\ raw "string"

### In-depth

- [Characters in _Programming in D_](http://ddili.org/ders/d.en/characters.html)
- [Strings in _Programming in D_](http://ddili.org/ders/d.en/strings.html)
- [std.utf](http://dlang.org/phobos/std_utf.html) - UTF en-/decoding algorithms
- [std.uni](http://dlang.org/phobos/std_uni.html) - Unicode algorithms

## {SourceCode}

```d
import std.stdio;
import std.utf: count;
import std.string: format;

void main() {
    // format generates a string using a printf
    // like syntax. D allows native UTF string
    // handling!
    string str = format("%s %s", "Hellö",
        "Wörld");
    writeln("My string: ", str);
    writeln("Array length of string: ",
        str.length);
    writeln("Character length of string: ",
        count(str));

    // Strings are just normal arrays, so any
    // operation that works on arrays works here
    // too!
    import std.array: replace;
    writeln(replace(str, "lö", "lo"));
    import std.algorithm: endsWith;
    writefln("Does %s end with 'rld'? %s",
        str, endsWith(str, "rld"));

    import std.conv: to;
    // Convert to UTF-32
    dstring dstr = to!dstring(str);
    // .. which of course looks the same!
    writeln("My dstring: ", dstr);
}
```

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
different threads. Being a slice parts can be taken out of it without
allocating memory. The standard function `std.algorithm.splitter`
for example splits a string by newline without any memory allocations.

Beside the UTF-8 `string` there are two more:

    alias wstring = immutable(dchar)[]; // UTF-16
    alias dstring = immutable(wchar)[]; // UTF-32

The variants are most easily converted between each other using
the `to` method from `std.conv`:

    dstring myDstring = to!dstring(myString);
    string myString = to!string(myDstring);

Because `string`s are arrays the same operations apply to them
e.g. strings might be concatenated using the `~` operator for example.
The property `.length` isn't necessarily the number of characters
for UTF strings so in that case use the function `std.utf.count`.

To create multi-line strings use the
`string str = q{ ... }` syntax. For raw strings you can either use
backticks `` ` "unescaped string"` ``
or the r-prefix `r"string that "doesn't" need to be escaped"`.

## {SourceCode}

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


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

This means that plain `string` is defined as an array of 8-bit Unicode [code
units](http://unicode.org/glossary/#code_unit). All array operations can be
used with it but they will work on code unit level, not on character level. At
the same time standard library algorithms will interpret `string`s as sequences
of [code points](http://unicode.org/glossary/#code_point) and there is also an
option to treat the them as sequence of
[graphemes](http://unicode.org/glossary/#grapheme) by explicit usage of
[`std.uni.byGrapheme`](https://dlang.org/library/std/uni/by_grapheme.html).

This small example illustrates the difference in interpretation:

    string s = "\u0041\u0308"; // Ä

    writeln(s.length); // 3

    import std.range : walkLength;
    writeln(s.walkLength); // 2

    import std.uni : byGrapheme;
    writeln(s.byGrapheme.walkLength); // 1

Here actual array length of `s` is 3 because it contains one 3 code units -
`0x41`, `0x03` and `0x08`. Of those latter two define single code point
(combining diacritics character) and
[`walkLength`](https://dlang.org/library/std/range/primitives/walk_length.html)
(standard library function to calculate arbitrary range length) counts two code
points total. Finally, `byGrapheme` performs rather expensive calculations
to recognize that these two code points combine into single displayed
character.

Correct processing of Unicode can be very complicated but for most time D
developers can simply consider `string` variables as magical byte arrays and
rely on standard library algorithms to do the right job. Most of Unicode
functionality is provided by
[`std.uni`](https://dlang.org/library/std/uni.html) module with some more basic
primitives available in [`std.utf`](https://dlang.org/library/std/utf.html).

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
import std.range: walkLength;
import std.uni : byGrapheme;
import std.string: format;

void main() {
    // format generates a string using a printf
    // like syntax. D allows native UTF string
    // handling!
    string str = format("%s %s", "Hellö",
        "Wörld");
    writeln("My string: ", str);
    writeln("Array length (code unit count)"
        ~ " of string: ", str.length);
    writeln("Range length (code point count)"
        ~ " of string: ", str.walkLength);
    writeln("Character length (grapheme count)"
        ~ " of string: ",
        str.byGrapheme.walkLength);

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

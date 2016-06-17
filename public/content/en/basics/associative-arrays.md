# Associative Arrays

D has built-in *associative arrays* also known as hash maps.
An associative array with a key type of `int` and a value type
of `string` is declared as follows:

    int[string] arr;

The syntax follows the actual usage of the hashmap:

    arr["key1"] = 10;

To test whether a key is located in the associative array, use the
`in` expression:

    if ("key1" in arr)
        writeln("Yes");

The `in` expression actually returns a pointer to the value
which is not `null` when found:

    if (auto test = "key1" in arr)
        *test = 20;

Access to a key which doesn't exist yields an `RangeError`
that immediately aborts the application. For a safe access
with a default value, you can use `get(key, defaultValue)`.

AA's have the `.length` property like arrays and provide
a `.remove(val)` member to remove entries by their key.
It is left as an exercise to the reader to explore
the special `.byKeys` and `.byValues` ranges.

### In-depth

- [Associative arrays in _Programming in D_](http://ddili.org/ders/d.en/aa.html)
- [Associative arrays spec](https://dlang.org/spec/hash-map.html)
- [byPair](http://dlang.org/phobos/std_array.html#.byPair)

## {SourceCode}

```d
import std.stdio;

/**
Splits the given text into words and returns
an associative array that maps words to their
respective word counts.

Params:
    text = text to be splitted
*/
int[string] wordCount(string text)
{
    // The function splitter lazily splits the
    // input into a range
    import std.algorithm.iteration: splitter;
    import std.string: toLower;

    // Indexed by words and returning the count
    int[string] words;

    // Define a predicate to use for splitting
    // the string.
    alias pred = c => c == ' ' || c == '.'
      || c == ',' || c == '\n';

    // The parameter we pass behind ! is an
    // expression that marks the condition when
    // to split text
    foreach(word; splitter!pred(text.toLower()))
    {
        // Increment word count if word
        // has been found.
        // Integers are by default 0.
        words[word]++;
    }

    return words;
}

void main()
{
    string text = q{This tour will give you an
overview of this powerful and expressive systems
programming language which compiles directly
to efficient, *native* machine code.};

    writeln("Word counts: ", wordCount(text));
}
```

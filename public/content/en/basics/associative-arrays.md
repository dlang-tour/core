# Associative Arrays

D has built-in *associative arrays* also known as hash maps.
An associative array with a key type of `int` and a value type
of `string` is declared as follows:

    int[string] arr;

The value can be accessed by its key and thus be set:

    arr["key1"] = 10;

To test whether a key is located in the associative array, the
`in` expression can be used:

    if ("key1" in arr)
        writeln("Yes");

The `in` expression returns a pointer to the value
which is not `null` when found. Thus existence check
and writes can be conveniently combined:

    if (auto val = "key1" in arr)
        *val = 20;

Access to a key which doesn't exist yields an `RangeError`
that immediately aborts the application. For a safe access
with a default value, `get(key, defaultValue)` can be used.

AA's have the `.length` property like arrays and provide
a `.remove(val)` member to remove entries by their key.
It is left as an exercise to the reader to explore
the special `.byKeys` and `.byValues` ranges.

### In-depth

- [Associative arrays in _Programming in D_](http://ddili.org/ders/d.en/aa.html)
- [Associative arrays specification](https://dlang.org/spec/hash-map.html)
- [std.array.byPair](http://dlang.org/phobos/std_array.html#.byPair)

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

    foreach(word; splitter(text.toLower(), " "))
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
    string text = "D is a lot of fun";

    auto wc = wordCount(text);
    writeln("Word counts: ", wc);

    // possible iterations:
    // byKey, byValue, byKeyValue
    foreach (word; wc.byValue)
        writeln(word);
}
```

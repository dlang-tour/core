# Foreach

D features a `foreach` loop which makes iterating
through data less error-prone and easier to read.

Given an array `arr` of type `int[]` it is possible to
iterate through the elements using this `foreach` loop:

    foreach (int e; arr) {
        writeln(e);
    }

The first field in the `foreach` definition is the variable
name used in the loop iteration. Its type can be omitted
and is then induced automatically:

    foreach (e; arr) {
        // typoef(e) is int
        writeln(e);
    }

The second field must be an array - or a special iterable
object called a **range** which will be introduced in the next section.

Elements will be copied from the array or range during iteration -
this is okay for basic types but might be a problem for
large types. To prevent copying or enable *in-place
*mutation, use `ref`:

    foreach (ref e; arr) {
        e = 10; // overwrite value
    }

## {SourceCode}

```d
import std.stdio;

void main() {
    auto arr = [ [5, 15], // 20
          [2, 3, 2, 3], // 10
          [3, 6, 2, 9] ]; // 20

    // Iterate through array in reverse order
    import std.range: retro;
    foreach (row; retro(arr))
    {
        double accumulator = 0.0;
        foreach (c; row)
            accumulator += c;

        writeln("The average of ", row,
            " = ", accumulator / row.length);
    }
}
```

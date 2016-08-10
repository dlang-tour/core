# Arrays

There are two types of Arrays in D: **static** and **dynamic**
arrays. Access to arrays of any kind is always bounds checked -
a failed range check yields a `RangeError` which aborts the application.
The brave can disable this with the compiler flag `-boundschecks=off` to squeeze
the last cycles out of their binary.

#### Static arrays

Static arrays are stored on the stack if defined inside a function
or in static memory otherwise.  They have a fixed,
compile-time known length. A static array's type includes
the fixed size:

    int[8] arr;

`arr`'s type is `int[8]`. Note that the size of the array is denoted
near the type and not after the variable name like in C/C++.

#### Dynamic arrays

Dynamic arrays are stored on the heap and can be expanded
or shrunk at runtime. A dynamic array is created using a `new` expression
and its length:

    int size = 8; // run-time variable
    int[] arr = new int[size];

The type of `arr` is `int[]` which is a **slice**
and will be explained in more detail in the next section. Multi-dimensional
arrays can be created easily using the `auto arr = new int[3][3]` syntax.

#### Array operations and properties

Arrays can be concatenated using the `~` operator which
will create a new dynamic array.

Mathematical operations can
be applied to whole arrays using the `c[] = a[] + b[]` syntax,
which for example adds all elements of `a` and `b` so that
`c[0] = a[0] + b[0]`. `c[1] = a[1] + b[1]` etc. It is also possible
to perform operations on a whole array with a single
value:

    a[] *= 2; // multiple all elements by 2
    a[] %= 26; // calculate the modulo by 26 for all a's

Those operations might be optimized
by the compiler to use special processors instructions that
do the operations in one go.

Both static and dynamic array provide the property `.length`
which is read-only for static arrays but can be written to
in case of dynamic arrays to change its size dynamically. The
property `.dup` creates a copy of the array.

When indexing an array through the `arr[idx]` syntax the special
`$` syntax denotes an array's length. `arr[$ - 1]` thus
references the last element and is a short form for `arr[arr.length - 1]`.

### Exercise

Complete the function `encrypt` to decrypt the secret message.
The text should be encrypted using *Caesar encryption*
that shifts the characters in the alphabet using a certain index.
The to-be-encrypted text just contains characters in the range `a-z`
which should make things easier.

### In-depth

- [Arrays in _Programming in D_](http://ddili.org/ders/d.en/arrays.html)
- [Array specification](https://dlang.org/spec/arrays.html)

## {SourceCode:incomplete}

```d
import std.stdio;

/**
Shifts every character in the
array `input` for `shift` characters.
The character range is limited to `a-z`
and the next character after z is a.

Params:
    input = array to shift
    shift = shift length for each char
Returns:
    Shifted char array
*/
char[] encrypt(char[] input, char shift)
{
    auto result = input.dup;
    // ...
    return result;
}

void main()
{
    // We will now encrypt the message with
    // Caesar encryption and a
    // shift factor of 16!
    char[] toBeEncrypted = [ 'w','e','l','c',
      'o','m','e','t','o','d',
      // The last , is okay and will just
      // be ignored!
    ];
    writeln("Before: ", toBeEncrypted);
    auto encrypted = encrypt(toBeEncrypted, 16);
    writeln("After: ", encrypted);

    // Make sure we the algorithm works
    // as expected
    assert(encrypted == [ 'm','u','b','s','e',
            'c','u','j','e','t' ]);
}
```

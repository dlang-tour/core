# Multidimensional arrays

D provides support for multidimensional arrays directly in its standard library
Phobos. It allows fast iteration, access and manipulation of multidimensional
data. In comparison to popular software packages in other languages (e.g. `ndarray`
in NumPy or `Array` in Julia), it doesn't become slow for computations not
covered by preexisting functionality in a bound C-library nor forces the user
to escape into another language. Additionally, due to its compile-time introspection
capabilities, D enables further optimizations for superior performance.

## Slices

A `Slice` is a view on a multidimensional view on usually an underlying raw,
one-dimensional array. With the `sliced` function a multidimensional array can
be constructed - in this example a `2x3` matrix is created:

```d
auto arr = new double[6];       // allocate one-dimensional array
auto matrix = arr.sliced(2, 3); // construct view onto array
```

As specifying the size of the to-be-allocated array is tedious, `ndslice` provides
a `slice` function, which will automatically allocate:

```d
auto matrix = slice!int(2, 3);
```

### Row/column styles

For the more common row-first index-style (C, D) square brackets can be used `a[]`,
whereas the column-first index style (Matlab, Fortran) uses parenthesis `a()`.
A row or column is also a `Slice` and thus all operations that work on slices
work on selections, for example we can assign a value or values.

```d
// [0, 1, 2]
// [3, 4, 5]
// [6, 7, 8]
auto matrix = iotaSlice(3, 3).slice; // `slice` allocates from the iotaSlice
matrix[1]   = [0, 1, 0]; // row-access, [3, 4, 5]
matrix(1)[] = 42; // column-acces, [1, 4, 7]
```

For element access the same style exists:

```d
matrix[1, 0] = 42; // column-first, has value `3` before
matrix(1, 0) = 42; // row-first,    has value `1` before
```

### Selections

There's a [plethora](http://dlang.org/phobos/std_experimental_ndslice_selection.html)
of predefined selections for the `Slice` type - the most common ones are
`byElement` and `diagonal`.

## More features

Unfortunately is a sole section not enough to cover all the features of `ndslice`.
There are many [iteration methods](http://dlang.org/phobos/std_experimental_ndslice_iteration.html)
like [matrix transposition](http://dlang.org/phobos/std_experimental_ndslice_iteration.html#.transposed),
[rotation](http://dlang.org/phobos/std_experimental_ndslice_iteration.html#.rotated)
and many more. Moreover all routines (except `slice`) don't allocate and
thus can be used in `@nogc` code.

## In-depth

- [ndslice](http://dlang.org/phobos/std_experimental_ndslice.html)

## {SourceCode}

```d
import std.algorithm.comparison : equal;
import std.experimental.ndslice;
import std.range : iota;
import std.stdio : writeln;

void main()
{
    auto matrix = [
		0,  1,  2,
    	3,  4,  5,
    	6,  7,  8,
    	9, 10, 11,
	].sliced(4, 3);

	//
	writeln(matrix);

    assert(matrix.diagonal == [0, 4, 8]);
    // it's just a pointer
    matrix.diagonal[1] = 42;
    assert(matrix[1, 1] == 42);

    // change the shape
    // [ 0, 1,  2,  3]
    // [42, 5,  6,  7]
    // [ 8, 9, 10, 11]
    assert(matrix.reshape(3, 4)[1, 0] == 42);

    // flatten
    assert(matrix.byElement[2..5]
                  .equal([2, 3, 42]));

    // windowing
    // [
    //	 [0, 1]
    //   [1, 2]
	// ], [
    //	 [3, 42]
    // 	 [42, 5]
	// ], [
    // ...
	assert(matrix
		.windows(1, 2)[1, 0]
		.byElement
		.equal([3, 42]));
}
```

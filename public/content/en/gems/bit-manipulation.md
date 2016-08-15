# Bit manipulation

An excellent example of D's ability to generate code on compile-time with mixins,
is bit manipulation.

### Simple bit manipulation

D offers the following operators for bit manipulation:

- `&` bitwise and
- `|` bitwise or
- `~` bitwise negative
- `<<`  bitwise signed   left-shift
- `>>`  bitwise signed   right-shift (preserves the sign of the high-order bit)
- `>>>` bitwise unsigned right-shift

### A practical example

A common example for bit manipulation is to read the value of a bit.
D provides `core.bitop.bt` for most common tasks, however to get used to bit
manipulation, let's start with a verbose implementation of testing a bit:

```d
enum posA = 1;
enum maskA = (1 << posA);
bool getFieldA()
{
    return _data & maskA;
}
```

A generalization is to test for blocks that are longer than 1. Hence
a special read mask with the length of the block is needed
and the data block is shifted accordingly before applying the mask:

```d
enum posA = 1;
enum lenA = 3;
enum maskA = (1 << lenA) - 1; // ...0111
uint getFieldA()
{
    return (_data >> posA) & maskA;
}
```

Setting such a block can equivalently be defined by negating the mask and thus
only allowing writes within the specified block:

```d
void setFieldA(bool b);
{
    return (_data & ~maskAWrite) | ((b << aPos) & maskAWrite);
}
```

## `std.bitmanip` to the rescue

It's a lot of fun to write ones' custom bit manipulation code and
D provides the full toolbox to do so. However in most cases one doesn't want to
copy&paste such bit manipulation code as this is very error-prone and hard to maintain.
Hence in D `std.bitmanip` helps you to write maintainable, easy-to-read bit manipulations
with `std.bitmanip` and the power of mixins - without sacrificing performance.

Have a look at the exercise section. A `BitVector` is defined, but it still uses
just X bits and is nearly indistinguishable from a regular struct.

`std.bitmanip` and `core.bitop` contain more helpers that are greatly helpful
for applications that require low-memory consumption.

### Padding and alignment

As the compiler will add padding for variables with a size lower than the current
OS memory layout (`size_t.sizeof`) e.g. `bool`, `byte`, `char`, it is recommended
to start with fields of high alignments.

## In-depth

- [std.bitmanip](http://dlang.org/phobos/std_bitmanip.html) - Bit-level manipulation facilities
- [_Bit Packing like a Madman_](http://dconf.org/2016/talks/sechet.html)

## {SourceCode}

```d
struct BitVector
{
    import std.bitmanip : bitfields;
    // creates a private field with the
    // following proxies
    mixin(bitfields!(
        uint, "x",    2,
        int,  "y",    3,
        uint, "z",    2,
        bool, "flag", 1));
}

void main()
{
    import std.stdio;

    BitVector vec;
    vec.x = 2;
    vec.z = vec.x - 1;
    writefln("x: %d, y: %d, z: %d",
              vec.x, vec.y, vec.z);

    // only 8 bit - 1 byte are used
    writeln(BitVector.sizeof);

    struct Vector { int x, y, z; }
    // 4 bytes (int) per variable
    writeln(Vector.sizeof);

	struct BadVector
	{
		bool a;
		int x, y, z;
		bool b;
	}
	// due to padding,
	// 4 bytes are used for each field
	writeln(BadVector.sizeof);
}
```

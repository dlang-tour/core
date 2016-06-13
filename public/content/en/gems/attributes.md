# Attributes

Functions can be attributed in various ways in D.
Let's have a look at two built-in attributes
as well as *user-defined attributes*. There
are also the built-ins `@safe`, `@system` and `@trusted`
which have been mentioned in the first chapter.

### `@property`

A function marked as `@property` looks like
a normal member to the outside world:

    struct Foo {
        @property bar() { return 10; }
        @property bar(int x) { writeln(x); }
    }
    
    Foo foo;
    writeln(foo.bar); // actually calls foo.bar()
    foo.bar = 10; // calls foo.bar(10);

### `@nogc`

When the D compiler encounters a function that is marked as `@nogc`
it will make sure that **no** memory allocations are done
within the context of that function. A `@nogc`
function is just allowed to call other `@nogc`
functions.


    void foo() @nogc {
      // ERROR:
        auto a = new A;
    }

### User-defined attributes (UDAs)

Any function or type in D can be attributed with user-defined
types:

    struct Bar { this(int x) {} }
    
    struct Foo {
      @("Hello") {
          @Bar(10) void foo() {
            ...
          }
      }
    }

Any type, built-in or user-defined, can be attributed
to functions. The function `foo()` in this example
will have the attributes `"Hello"` (type `string`)
and `Bar` (type `Bar` with value `10`). To get
the attributes of a function (or type) use
the built-in compiler *traits*
`__traits(getAttributes, Foo)` which returns
a [`TypeTuple`](https://dlang.org/phobos/std_typetuple.html).

UDAs allow to enhance generic code by giving user-defined
types another dimension that helps compile time
generators to adapt to that specific type.

### In-depth

- [User Defined Attributes in _Programming in D_](http://ddili.org/ders/d.en/uda.html)
- [Attributes in D](https://dlang.org/spec/attribute.html)


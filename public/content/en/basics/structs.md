# Structs

One way to define compound or custom types in D is to
define them through a `struct`:

    struct Person {
        int age;
        int height;
        float ageXHeight;
    }

`struct`s are always constructed on the stack (unless created
with `new`) and are copied **by value** in assignments or
as parameters to function calls.

    auto p = Person(30, 180, 3.1415);
    auto t = p; // copy

When a new object of a `struct` type is created its members can be initialized
in the order they are defined in the `struct`. A custom constructor
is defined through a `this(...)` member function:

    struct Person {
        this(int age, int height) {
            this.age = age;
            this.height = height;
            this.ageXHeight = cast(float)age * height;
        }
            ...

    Person p(30, 180);

A `struct` might contain any number of member functions. Those
are per default `public` and accessible from the outside. They might
as well be `private` and thus only be callable by other
member functions of the same `struct` or other code in the same
module.

    struct Person {
        void doStuff() {
            ...
        private void privateStuff() {
            ...

    p.doStuff(); // call method doStuff
    p.privateStuff(); // forbidden

### Const member functions

If a member function is declared with `const`, it won't be allowed
to modify any of its members. This is enforced by the compiler.
Making a member function `const` makes it callable on any `const`
or `immutable` object, but also helps callers reason about the
code by offering a guarantee that the member function will never
change the state of the object.

### Static member functions

If a member function is declared as `static`, it will be callable
without an instantiated object e.g. `Person.myStatic()` but
isn't allowed to access any non-`static` members.  Use a `static`
member function when you want to work with all instances of a given
`struct`, rather than with one instance in particular, or when the
member function must be usable by callers that don't have an instance
available.  For example, a function that asked how many instances
existed would probably be `static`.

### Inheritance

Note that a `struct` can't inherit from another `struct`.
Hierachies of types can only be built using classes,
which we will see in a future section.
However with `alias this` or `mixins` one can easily achieve
polymorphic inheritance.

### In-depth

- [Structs in _Programming in D_](http://ddili.org/ders/d.en/struct.html)
- [In detail](https://dlang.org/spec/struct.html)

### Exercise

Given the `struct Vector3` implement the following functions and make
the example application successfully run:

* `length()` which returns the vector's length
* `dot(Vector3)` which returns the dot product of two vectors
* `toString()` which returns a string representation of this vector.
  We don't know strings yet but the function `std.string.format`
  conveniently returns a string using `printf`-like syntax:
  `format("MyInt = %d", myInt)`.

## {SourceCode:incomplete}

```d
struct Vector3 {
    double x;
    double y;
    double z;

    double length() const {
        import std.math: sqrt;
        return 0.0;
    }

    // rhs will be copied
    double dot(Vector3 rhs) const {
        return 0.0;
    }

    /**
    Returns: representation of the string in the
    special format. The output is restricted to
    a precision of one!
    "x: 0.0 y: 0.0 z: 0.0"
    */
    string toString() const {
        import std.string: format;
        // Hint: refer to the documentation of
        // std.format to see how to influence
        // output for floating point numbers.
        return format("");
    }
}

void main() {
    auto vec1 = Vector3(10.0, 0.0, 0.0);
    Vector3 vec2;
    vec2.x = 0.0;
    vec2.y = 20.0;
    vec2.z = 0.0;

    // If a member function has no parameters,
    // the calling braces () might be omitted
    assert(vec1.length == 10.0);
    assert(vec2.length == 20.0);

    // Test the functionality for dot product
    assert(vec1.dot(vec2) == 0.0);


    // Thanks to toString() we can now just
    // output our vector's with writeln
    import std.stdio: writeln, writefln;
    writeln("My vec1 = ", vec1);
    writefln("My vec2 = %s", vec2);

    // Check the string representation
    assert(vec1.toString() ==
        "x: 10.0 y: 0.0 z: 0.0");
    assert(vec2.toString() ==
        "x: 0.0 y: 20.0 z: 0.0");
}
```

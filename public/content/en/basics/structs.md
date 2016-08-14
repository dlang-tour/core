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
in the order they are defined in the `struct`. A custom constructor can be defined through
a `this(...)` member function. If needed to avoid name conflicts, the current instance
can be explicitly accessed with `this`:

    struct Person {
        this(int age, int height) {
            this.age = age;
            this.height = height;
            this.ageXHeight = cast(float)age * height;
        }
            ...

    Person p(30, 180); // initialization
    p = Person(30, 180);  // assignment to new instance

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
or `immutable` object, but also guarantee callers that
the member function will never change the state of the object.

### Static member functions

If a member function is declared as `static`, it will be callable
without an instantiated object e.g. `Person.myStatic()` but
isn't allowed to access any non-`static` members.  A `static`
member function can be used you to work to give access to all instances of a
`struct`, rather than the current instance, or when the
member function must be usable by callers that don't have an instance
available.  For example, Singleton's (only one instance is allowed)
use `static`.

### Inheritance

Note that a `struct` can't inherit from another `struct`.
Hierachies of types can only be built using classes,
which we will see in a future section.
However with `alias this` or `mixins` one can easily achieve
polymorphic inheritance.

### In-depth

- [Structs in _Programming in D_](http://ddili.org/ders/d.en/struct.html)
- [Struct specification](https://dlang.org/spec/struct.html)

### Exercise

Given the `struct Vector3` implement the following functions and make
the example application run successfully:

* `length()` - returns the vector's length
* `dot(Vector3)` - returns the dot product of two vectors
* `toString()` - returns a string representation of this vector.
  The function [`std.string.format`](https://dlang.org/phobos/std_format.html)
  returns a string using `printf`-like syntax:
  `format("MyInt = %d", myInt)`. Strings will be explained in detailed in a later
  section.

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
    auto vec1 = Vector3(10, 0, 0);
    Vector3 vec2;
    vec2.x = 0;
    vec2.y = 20;
    vec2.z = 0;

    // If a member function has no parameters,
    // the calling braces () may be omitted
    assert(vec1.length == 10);
    assert(vec2.length == 20);

    // Test the functionality for dot product
    assert(vec1.dot(vec2) == 0);

    // 1 * 1 + 2 * 1 + 3 * 1
    auto vec3 = Vector3(1, 2, 3);
    assert(vec3.dot(Vector3(1, 1, 1) == 6);

    // 1 * 3 + 2 * 2 + 3 * 1
    assert(vec3.dot(Vector3(3, 2, 1) == 10);

    // Thanks to toString() we can now just
    // output our vector's with writeln
    import std.stdio: writeln, writefln;
    writeln("vec1 = ", vec1);
    writefln("vec2 = %s", vec2);

    // Check the string representation
    assert(vec1.toString() ==
        "x: 10.0 y: 0.0 z: 0.0");
    assert(vec2.toString() ==
        "x: 0.0 y: 20.0 z: 0.0");
}
```

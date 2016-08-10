# Classes

D provides support for classes and interfaces like in Java or C++.

Any `class` type inherits from [`Object`](https://dlang.org/phobos/object.html) implicitly.

    class Foo { } // inherits from Object
    class Bar: Foo { } // Bar is a Foo too

Classes in D are generally instantiated on the heap using `new`:

    auto bar = new Bar;

Class objects are always references types and unlike `struct` aren't
copied by value.

    Bar bar = foo; // bar points to foo

The garbage collector will make sure the memory is freed
when no references to an object exist anymore.

#### Inheritance

If a member function of a base class is overridden, the keyword
`override` must be used to indicate that. This prevents unintentional
overriding of functions.

    class Bar: Foo {
        override functionFromFoo() {}
    }

In D, classes can only inherit from one class.

#### Final and abstract member functions

A function can be marked `final` in a base class to disallow overriding
it. A function can be declared as `abstract` to force base classes to override
it. A whole class can be declared as `abstract` to make sure
that it isn't instantiated. To access the base class,
use the special keyword `super`.

### In-depth

- [Classes in _Programming in D_](http://ddili.org/ders/d.en/class.html)
- [Inheritance in _Programming in D_](http://ddili.org/ders/d.en/inheritance.html)
- [Object class in _Programming in D_](http://ddili.org/ders/d.en/object.html)
- [Classes in D spec](https://dlang.org/spec/class.html)

## {SourceCode}

```d
import std.stdio;

// Fancy type which can be used for
// anything...
class Any {
    // protected is just seen by inheriting
    // classes
    protected string type;

    this(string type) {
        this.type = type;
    }

    // public is implicit by the way
    final string getType() {
        return type;
    }

    // This needs to be implemented!
    abstract string convertToString();
}

class Integer: Any {
    // just seen by Integer
    private {
        int number;
    }

    // constructor
    this(int number) {
        // call base class constructor
        super("integer");
        this.number = number;
    }

    // This is implicit. And another way
    // to specify the protection level
    public:

    override string convertToString() {
        import std.conv: to;
        // The swiss army knife of conversion.
        return to!string(number);
    }
}

class Float: Any {
    private float number;

    this(float number) {
        super("float");
        this.number = number;
    }

    override string convertToString() {
        import std.string: format;
        // We want to control precision
        return format("%.1f", number);
    }
}

void main()
{
    Any[] anys = [
        new Integer(10),
        new Float(3.1415f)
        ];

    foreach (any; anys) {
        writeln("any's type = ", any.getType());
        writeln("Content = ",
            any.convertToString());
    }
}
```

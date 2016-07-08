# Template meta programming

If you ever got in touch with *template meta programming*
in C++ you will be relieved what tools D offers to make
your life easier. Template meta programming is a technique
that enables decision-making depending on template type properties
and thus allows to make generic types even more flexible
based on the type they are going to be instantiated with.

### `static if` & `is`

Like the normal `if`, `static if` conditionally
compiles a code block based on a condition that can
be evaluated at compile time:

    static if(is(T == int))
        writeln("T is an int");
    static if (is(typeof(x) :  int))
        writeln("Variable x implicitely converts to int");

The [`is` expression](http://wiki.dlang.org/Is_expression) is
a generic helper that evaluates conditions at compile time.

    static if(is(T == int)) { // T is template parameter
        int x = 10;
    }

Braces are omitted if the condition is `true` - no new scope is created.
`{ {` and `} }` explicitely create a new block.

`static if` can be used anywhere in the code - in functions,
at global scope or within type definitions.

### `mixin template`

Anywhere you see *boiler plate*, `mixin template`
is your friend:

    mixin template Foo(T) {
        T foo;
    }
    ...
    mixin Foo!int; // int foo available from here on.

`mixin template` might contain any number of
complex expressions that are inserted at the instantiation
point. Say good-bye to the
pre-processor if you're coming from C!

### Template constraints

A template might be defined with any number of
constraints that enforce what properties
a type must have:

    void foo(T)(T value)
      if (is(T : int)) { // foo!T only valid if T
                         // converts to int
    }

Constraints can be combined in boolean expression
and might even contain function calls that can be evaluated
at compile-time. For example `std.range.primitives.isRandomAccessRange`
checks whether a type is a range that supports
the `[]` operator.

### In-depth

### Basics references

- [Tutorial to D Templates](https://github.com/PhilippeSigaud/D-templates-tutorial)
- [Conditional compilation](http://ddili.org/ders/d.en/cond_comp.html)
- [std.traits](https://dlang.org/phobos/std_traits.html)
- [More templates  _Programming in D_](http://ddili.org/ders/d.en/templates_more.html)
- [Mixins in  _Programming in D_](http://ddili.org/ders/d.en/mixin.html)

### Advanced references

- [Conditional compilation](https://dlang.org/spec/version.html)
- [Traits](https://dlang.org/spec/traits.html)
- [Mixin templates](https://dlang.org/spec/template-mixin.html)
- [D Templates spec](https://dlang.org/spec/template.html)

## {SourceCode}

```d
import std.traits: isFloatingPoint;
import std.uni: toUpper;
import std.string: format;
import std.stdio: writeln;

/// A Vector that just works for
/// numbers, integers or floating points.
struct Vector3(T)
  if (is(T: real))
{
private:
    T x,y,z;

    /// Generator for getter and setter because
    /// we really hate boiler plate!
    ///
    /// var -> T getVAR() and void setVAR(T)
    mixin template GetterSetter(string var) {
        // Use mixin to construct function
        // names
        mixin("T get%s() const { return %s; }"
          .format(var.toUpper, var));

        mixin("void set%s(T v) { %s = v; }"
          .format(var.toUpper, var));
    }

    // Easily generate our getX, setX etc.
    // functions with a mixin template.
    mixin GetterSetter!"x";
    mixin GetterSetter!"y";
    mixin GetterSetter!"z";

public:
    // We don't allow the dot function
    // for anything but floating points
    static if (isFloatingPoint!T) {
        T dot(Vector3!T rhs) {
            return x*rhs.x + y*rhs.y +
                z*rhs.z;
        }
    }
}

void main()
{
    auto vec = Vector3!double(3,3,3);
    // That doesn't work because of the template
    // constraint!
    // Vector3!string illegal;

    auto vec2 = Vector3!double(4,4,4);
    writeln("vec dot vec2 = ", vec.dot(vec2));

    auto vecInt = Vector3!int(1,2,3);
    // doesn't have the function dot because
    // we statically enabled it only for float's
    // vecInt.dot(Vector3!int(0,0,0));

    // generated getter and setters!
    vecInt.setX(3);
    vecInt.setZ(1);
    writeln(vecInt.getX, ",",
      vecInt.getY, ",", vecInt.getZ);
}
```

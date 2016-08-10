# Unittesting

Tests are an excellent way to ensure stable, bug-free applications.
They serve as an interactive documentation and allow to modify
code without fear to break functionality. D provides a convenient
and native syntax for `unittest` block as part of the D language.
Anywhere in a D module `unittest` blocks can be used to test
functionality of the source code.

    // Block for my function
    unittest
    {
        assert(myAbs(-1) == 1);
        assert(myAbs(1)  == 1);
    }

This allows straighforward [Test-driven development](https://en.wikipedia.org/wiki/Test-driven_development)
on demand.

### Run & execute `unittest` blocks

`unittest` blocks can contain arbitrary code which is just
compiled in and run when the command line flag `-unittest`
is passed to the DMD compiler. DUB also features compiling
and running unittest through the `dub test` command.

### Verify examples with `assert`

Typically `unittest`s contain `assert` expressions that test
the functionality of a given function. `unittest` blocks
are typically located near the definition of a function
which might be at the top level of the source, or even
within classes or structs.

### Increasing code coverage

Unittest are a powerful weapon to ensure bullet-proof applications.
A common measurement to check how much of a program
is being covered by tests, is the _code coverage_.
It is the ratio of executed versus existing lines of code.
The DMD compiler allows to easily generate code coverage reports
by adding `-cov`. For every module a `.lst` file, which contains
detailed statistics, will be generated.

As the compiler is able to infer attributes for templated code
automatically, it is a common pattern to add annotated unittests
to ensure such attributes for the tested code:

    unittest @safe @nogc nothrow pure
    {
        assert(myAbs() == 1);
    }

### In-depth

- [Unit Testing in _Programming in D_](http://ddili.org/ders/d.en/unit_testing.html)
- [Unittesting in D](https://dlang.org/spec/unittest.html)

## {SourceCode}

```d
import std.stdio;

struct Vector3 {
    double x;
    double y;
    double z;

    double dot(Vector3 rhs) const {
        return x*rhs.x + y*rhs.y + z*rhs.z;
    }

    // That's okay!
    unittest {
        assert(Vector3(1,0,0).dot(
          Vector3(0,1,0) == 0);
    }

    string toString() const {
        import std.string: format;
        return format("x:%.1f y:%.1f z:%.1f",
          x, y, z);
    }

    // .. and that too!
    unittest {
        assert(Vector3(1,0,0).toString() ==
          "x:1.0 y:0.0 z:0.0");
    }
}

void main()
{
    Vector3 vec = Vector3(0,1,0);
    writeln(`This vector has been tested: `,
      vec);
}

// Or just somewhere else.
// Nothing is compiled in and just
// ignored in normal mode. Run dub test
// locally or compile with dmd -unittest
// to actually test your modules.
unittest {
    Vector3 vec;
    // .init a special built-in property that
    // returns the initial value of type.
    assert(vec.x == double.init);
}
```

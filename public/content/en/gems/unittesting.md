# Unittesting

D has unit-testing built-in right from the start. Anywhere
in a D module `unittest` blocks can be used to test
functionality of the source code.

    // Block for my function
    unittest
    {
        assert(myAbs(-1) == 1);
        assert(myAbs(1)  == 1);
    }

`unittest` blocks can contain arbitrary code which is just
compiled in and run when the command line flag `-unittest`
is passed to the DMD compiler. DUB also features compiling
and running unittest through the `dub test` command.

Typically `unittest`s contain `assert` expressions that test
the functionality of a given function. `unittest` blocks
are typically located near the definition of a function
which might be at the top level of the source, or even
within classes or structs.

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

# Subtyping

`struct` can't inherit from other `struct`s. But
for those poor `struct`s D provides another great
means to extend their functionality: **subtyping**.

A struct type can define one of its members as
`alias this`:

    struct SafeInt {
        private int theInt;
        alias theInt this;
    }

Any function or operation on `SafeInt` that can't
be handled by the type itself will be forwarded
to the `alias this`ed member. From the outside
`SafeInt` then looks like a normal integer.

This allows extending other types
with new functionality but with zero overhead
in terms of memory or runtime. The compiler
makes sure to do the right thing when
accessing the `alias this` member.

`alias this` work with classes too.

## {SourceCode}

```d
import std.stdio: writeln;

struct Vector3 {
    private double[3] vec;
    alias vec this;

    double dot(Vector3 rhs) {
        return vec[0]*rhs.vec[0] +
          vec[1]*rhs.vec[1] + vec[2]*rhs.vec[2];
    }
}

void main()
{
    Vector3 vec;
    // we're basically talking with
    // double[] here.
    vec = [ 0.0, 1.0, 0.0 ];
    assert(vec.length == 3);
    assert(vec[$ - 1] == 0.0);

    auto vec2 = Vector3([1.0,0.0,0.0]);
    // but this functionality has been
    // extended!
    writeln("vec dot vec2 = ", vec.dot(vec2));
}
```

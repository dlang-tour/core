# Interfaces

D allows defining `interface`s which are technically like
`class` types but whose member functions must be implemented
by any class inheriting from the `interface`.

    interface Animal {
        void makeNoise();
    }

The `makeNoise` member function has to be implemented
by `Dog` because it inherits from the `Animal` interface.
Technically `makeNoise` behaves like an `abstract` member
function in a base class.

    class Dog: Animal {
        override makeNoise() {
            ...
        }
    }

    auto dog = new Animal;
    Animal animal = dog; // implicit cast to interface
    dog.makeNoise();

A `class` type can inherit from as many `interface`s it wishes
but just from *one* base class.

D easily enables the **NVI - non virtual interface** idiom by
allowing the definition of `final` functions in an `interface`
that aren't allowed to be overridden. This enforces specific
behaviours customized by overriding the other `interface`
functions.

    interface Animal {
        void makeNoise();
        final doubleNoise() /* NVI pattern */ {
            makeNoise();
            makeNoise();
        }
    }

### In-depth

- [Interfaces in _Programming in D_](http://ddili.org/ders/d.en/interface.html)
- [Interfaces in D](https://dlang.org/spec/interface.html)

## {SourceCode}

```d
import std.stdio;

interface Animal {
    // virtual function
    // which needs to be overridden!
    void makeNoise();

    // NVI pattern. Uses makeNoise internally
    // to customoze behaviour inheriting
    // classes.
    final void multipleNoise(int n) {
        for(int i = 0; i < n; ++i) {
            makeNoise();
        }
    }
}

class Dog: Animal {
    override void makeNoise() {
        writeln("Bark!");
    }
}

class Cat: Animal {
    override void makeNoise() {
        writeln("Meeoauw!");
    }
}

void main() {
    Animal dog = new Dog;
    Animal cat = new Cat;
    Animal[] animals = [dog, cat];
    foreach(animal; animals) {
        animal.multipleNoise(5);
    }
}
```

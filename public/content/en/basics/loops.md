# Loops

D provides four loop constructs.

#### 1) Classical `for` loop

The classical `for` loop known from C/C++ or Java
with _initiliazer_, _loop condition_ and _loop statement_:

    for (int i = 0; i < arr.length; ++i) {
        ...

#### 2) `while`

`while`  loops execute the given code block
while a certain condition is met:

    while (condition) {
        foo();
    }

#### 3) `do ... while`

The `do .. while` loops execute the given code block
while a certain condition is met, but in contrast to `while`
the _loop block_ is executed before the loop condition is
evaluated for the first time.

    do {
        foo();
    } while (condition);

#### 4) `foreach`

The `foreach` loop which will be introduced in the
next section.

#### Special keywords

The special keyword `break` will immediately abort the current loop.
If we are in a nested loop a label can be used to break any outer loop:

    outer: for (int i = 0; i < 10; ++i) {
        for (int j = 0; j < 5; ++j) {
            ...
            break outer;

The keyword `continue` starts with the next loop iteration.

### In-depth

- [`for` Loop in _Programming in D_](http://ddili.org/ders/d.en/for.html)
- [`while` Loop in _Programming in D_](http://ddili.org/ders/d.en/while.html)
- [`do while` Loop in _Programming in D_](http://ddili.org/ders/d.en/do_while.html)

## {SourceCode}

```d
import std.stdio;

/// Returns: average of array
double average(int[] array) {
    // The property .empty for arrays isn't
    // native in D but has to be made accessible
    // by importing the function from std.array
    import std.array: empty, front;

    double accumulator = 0.0;
    auto length = array.length;
    while (!array.empty) {
        // this could be also done with .front
        // with import std.array: front;
        accumulator += array[0];
        array = array[1 .. $];
    }

    return accumulator / length;
}

void main()
{
    auto testers = [ [5, 15], // 20
          [2, 3, 2, 3], // 10
          [3, 6, 2, 9] ]; // 20

    for (auto i = 0; i < testers.length; ++i) {
      writeln("The average of ", testers[i],
        " = ", average(testers[i]));
    }
}
```

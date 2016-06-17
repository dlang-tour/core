# Documentation

D tries to integrate important parts of modern
software engineering directly into the language.
Besides *contract programming* and *unittesting*
D allows to natively generate [documentation](https://dlang.org/phobos/std_variant.html)
out of your source code.

Using a standard schema for documenting types
and functions the command `dmd -D` conveniently
generates HTML documentation based on the source
files passed on command line.
In fact the whole [Phobos library documentation](https://dlang.org/phobos)
has been generated with *DDoc*.

The following comment styles are considered
by DDoc for inclusion into the source code
documentation:

* `/// Three slashes before type or function`
* `/++ Multiline comment with two +  +/`
* `/** Multiline comment with two *  */`

Have a look at the source code example
to see some standardized documentation
sections.

### In-depth

- [DDoc design](https://dlang.org/spec/ddoc.html)
- [Phobos standard library documentation](https://dlang.org/phobos)

## {SourceCode:incomplete}

```d
/**
  Calculates the square root of a number.

  Here could be a longer paragraph that
  elaborates on the great win for
  society for having a function that is actually
  able to calculate a square root of a given
  number.

  Example:
  -------------------
  double sq = sqrt(4);
  -------------------
  Params:
    number = the number the square root should
             be calculated from.

  License: use freely for any purpose
  Throws: throws nothing.
  Returns: the squrare root of the input.
*/
T sqrt(T)(T number) {
}
```

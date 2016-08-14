# Exceptions

This guide is only about User-`Exceptions` - System-`Errors` are usually fatal
and should __never__ be catched.

### Catching Exception

A common case for exceptions is to validate potentially invalid user input.
Once an exception is thrown, the stack will be unwound until the first matching exception
handler is found.

```d
try
{
    readText("dummyFile");
}
catch (FileException e)
{
    // ...
}
```

You can also have multiple `catch` blocks and a `finally` block that is executed
regardless of whether an error occurred. Exceptions are thrown with `throw`.

```d
try
{
    throw new StringException("You shall not pass.");
}
catch (FileException e)
{
    // ...
}
catch (StringException e)
{
    // ...
}
finally
{
    // ...
}
```

Remember that the scope guard is usually a better solution to the `try-finally`
pattern.

### Custom exceptions

One can easily inherit from `Exception` and create custom exceptions:

```d
class UserNotFoundException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
throw new UserNotFoundException("D-Man is on vacation");
```

### Enter a safe world with `nothrow`

The D compiler can ensure that a function can't cause catastrophic side-effects.
Such functions can be annotated with the `nothrow` keyword. The D compiler
statically forbids throwing exceptions in `nothrow` functions.

```d
bool lessThan(int a, int b) nothrow
{
    writeln("unsafe world"); // output can throw exceptions, thus this is forbidden
    return a < b;
}
```

Please note that the compiler is able to infer attributes for templated code
automatically.

### std.exception

It is important to avoid contract programming for user-input as the contracts
are removed when compiled in release mode. For convenience `std.exception` provides
`enforce` that can be used like `assert`, but throws `Exceptions`
instead of an `AssertError`.

```d
import std.exception: enforce;
float magic = 1_000_000_000;
enforce(magic + 42 - magic == 42, "Floating-point math is fun");

// throw custom exceptions
enforce!StringException('a' != 'A', "Case-sensitive algorithm");
```

However there's more in `std.exception`. For example when the error might not be
fatal, one can opt-in to `collect` it:

```d
import std.exception: collectException;
auto e = collectException(aDangerousOperation());
if (e)
    writeln("The dangerous operation failed with ", e);
```

To test whether an exception is thrown in tests, use `assertThrown`.

### In-depth

- [Exception Safety in D](https://dlang.org/exception-safe.html)
- [std.exception](https://dlang.org/phobos/std_exception.html)
- system-level [core.exception](https://dlang.org/phobos/core_exception.html)
- [object.Exception](https://dlang.org/library/object/exception.html) - base class of all exceptions that are safe to catch and handle.

## {SourceCode}

```d
import std.file;
import std.stdio;

void main()
{
    try
    {
        readText("dummyFile");
    }
    catch (FileException e)
    {
		writeln("Message:\n", e.msg);
		writeln("File: ", e.file);
		writeln("Line: ", e.line);
		writeln("Stack trace:\n", e.info);

		// Default formatting could be used too
		// writeln(e);
    }
}
```

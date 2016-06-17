# Welcome to D

Welcome to the online tour of the *D Programming language*.

This tour will give you an overview of this powerful and expressive systems
programming language which compiles directly to efficient, *native*
machine code.

### What is D

D has many [unique features](http://dlang.org/overview.html) and is a
general purpose systems and applications programming language.
It is a _high level language_, but retains the ability to write _high
performance_ code and interface directly with the _operating system API's_
and with hardware.
D is well suited to writing medium to large-scale programs.
D is _easy to learn_, provides many capabilities to aid the programmer,
and is well suited to aggressive compiler optimization technology.
D is not a scripting language, nor an interpreted language.
It doesn't come with a VM, a religion, or an overriding philosophy.
It's a _practical language for practical programmers_ who need to get the
job done _quickly_, _reliably_, and leave behind _maintainable_,
_easy to understand_ code.

D is the culmination of _decades of experience implementing compilers_
for many diverse languages,
and attempting to construct large projects using those languages.
D draws inspiration from those other languages (most especially C++)
and tempers it with experience and real world practicality.

### About the tour

The navigation bar at the top of the page allows quick access to the content
of this tour. The tour is divided into chapters with a number of sections.
Each chapter and section introduces a new feature or aspect of D. The bottom
panel allows navigation to the next or previous section.

Each section comes with a source code example that can be modified and used
to experiment with D's language features.
Click the run button (or `Shift-enter`) to compile and run it.

### Contributing

This tour is [open source](https://github.com/stonemaster/dlang-tour/tree/master/public/content/en)
and we are glad about pull requests making this tour even better.

## {SourceCode}

```d
import std.stdio;

// Let's get going!
void main() {
    writeln("Hello World!");
}
```

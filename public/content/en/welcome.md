# Welcome
# Welcome to D

Welcome to the online tour of the *D Programming language*.

This tour will give you an overview of this powerful and expressive systems
programming language which compiles directly to efficient, *native*
machine code.

The navigation bar at the top of the page allows quick access to the content
of this tour. The tour is divided into chapters with a number of sections.
Each chapter and section introduces a new feature or aspect of D. The bottom
panel allows navigation to the next or previous section.

The code editor contains D source code which can compiled and run online.
The program's output, or compile errors, are displayed in the box
beneath the code editor.

Each section comes with a source code example that can be modified and used
to experiment with D's language features.

Some sections contain exercises which invite using the introduced
features.

## {SourceCode}

import std.stdio;

void main() {
    writeln("Hello World!");
}

# Install D locally

On the D language's website [dlang.org](http://www.dlang.org) the most recent
compiler version of the reference compiler **DMD** (*Digital Mars D*)
can be downloaded and installed offline:

* There is a Windows installer available - or a ZIP file which
  contains the pre-compiled toolkit
* For Mac OS X there is a `.dmg` package. The most recent can also be installed
  with `brew install dmd` using *Homebrew*
* There are officially supported Linux packges for Fedora, OpenSuse and
  Debian/Ubuntu. For the latter a regularly updated repository exists
  at [d-apt.source-forge.net](http://d-apt.source-forge.net).

Besides the DMD reference compiler which uses its own backend, there are two
other compilers that can be fetched through the [dlang.org](http://www.dlang.org)
download section:

* **GDC** which uses the GCC backend
* **LDC** based on the LLVM backend

GDC and LDC are more likely behind the DMD frontend's versions but provide
better optimization levels as well as support for other platforms like e.g. ARM.

# Run D program locally

D's standard build tool is [dub](http://code.dlang.org). When dub is installed
locally a new project `test` can be created using the command line

    dub init test

Running `dub` inside this folder will fetch all dependencies, compile the
application and run it. `dub build` will just compile the project.

Given a D file `test.d` a binary can be created using *DMD* using the
following command:

    dmd test.d

The helper tool `rdmd` distributed with the DMD compiler
will make sure to compile all dependencies and automatically runs
the resulting app:

    rdmd test.d

On UNIX systems the shebang line `#!/usr/bin/env rdmd` can be put
on the first line of a executable D file to allow usages
like with other script langugaes.

# Documentation & Links

* API Documentation of standard library [Phobos](https://dlang.org/phobos)
* [Language reference](https://dlang.org/spec/)
* Repository of DUB libraries and applications: [code.dlang.org](http://code.dlang.org)
* Free E-Book by Ali Çehreli: [Programming in D](http://ddili.org/ders/d.en/). Also
  available as hard cover.

# Let's Go!

Congratulations for finishing the first chapter. You're now ready to dive
into the world of **D**.

Either use the navigation panel at the bottom or select the next chapter
using the top bar.

# Welcome
# Welcome to D

Welcome to the online tour of the *D Programming language*.

This tour will give you an overview of this powerful and expressive systems
programming language.

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

# Documentation & Further reading

* API Documentation
* Language reference
* Free E-Book
* Books:

# Let's Go!

Congratulations for finishing the first chapter. You're now ready to dive
into the world of **D**.

Either use the navigation panel at the bottom or select the next chapter
using the top bar.

# Welcome
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

## {SourceCode}

// The unix uniq command, in 4 lines of code
import std.stdio, std.algorithm;

void main() {
    stdin.byLine.uniq.each!writeln;
}

# Install D locally

On the D language's website [dlang.org](https://dlang.org) the most recent
compiler version of the reference compiler **DMD** (Digital Mars D)
can be downloaded and installed offline:

* There is a Windows installer available - or a ZIP file which
  contains the pre-compiled toolkit. Installing with
  [chocolatey](https://chocolatey.org/packages/dmd)
  is another option.
* For Mac OS X there is a `.dmg` package. The most recent can also be installed
  with `brew install dmd` using [Homebrew](http://brew.sh).
* There are officially supported Linux packages for Fedora, OpenSuse and
  Debian/Ubuntu. For the latter a regularly updated repository exists
  at [d-apt.source-forge.net](http://d-apt.sourceforge.net).
* On OSX, Linux, and FreeBSD a [script](https://dlang.org/install.sh) can
  be used to easily install different compilers and dub to `$HOME/dlang`.

  ```sh
  curl -fsS https://dlang.org/install.sh | bash -s dmd
  ```
  

Besides the DMD reference compiler which uses its own backend, there are
two other compilers that can be fetched through the
[dlang.org](https://dlang.org) download section:

* [**GDC**](http://gdcproject.org/downloads) which uses the GCC backend
* [**LDC**](https://github.com/ldc-developers/ldc#installation) based on the LLVM backend

GDC and LDC aren't always at the most recent DMD frontend's versions, 
but provide better optimization levels as well as support
for other platforms like e.g. ARM.

# Run D program locally

D's standard package manager is [dub](http://code.dlang.org). When dub is
installed locally a new project `test` can be created using
the command line

    dub init test

Running `dub` inside this folder will fetch all dependencies, compile the
application and run it. `dub build` will just compile the project.

Given a D file `test.d` a binary is created using *DMD* with this command:

    dmd test.d

The helper tool `rdmd` distributed with the DMD compiler
will make sure to compile all dependencies and automatically runs
the resulting application:

    rdmd test.d

On UNIX systems the shebang line `#!/usr/bin/env rdmd` can be put
on the first line of an executable D file to allow a script-like
usage.

# Links & Documentation

The best places to learn D are

* [Learning D as a beginner](http://ddili.org/ders/d.en/index.html)
* [Learning D for experienced programmers](http://wiki.dlang.org/Coming_From) coming from other languages
* The [D Wiki](https://wiki.dlang.org/), which contains a lot of information and links
* [D Tutorials](https://wiki.dlang.org/Tutorials)
* [Overview about D's unique features](http://dlang.org/overview.html)
* [FAQ](http://dlang.org/faq.html)
* [Articles about D](http://dlang.org/articles.html)
* [Books about D](https://wiki.dlang.org/Books), for an in-depth view

### Help

* Ask questions in the #d IRC channel on freenode ([web interface](https://kiwiirc.com/client/irc.freenode.net/d))
* Get help at [D.learn](http://forum.dlang.org/group/learn)
* Open an issue [at the D bugtracker](https://issues.dlang.org)

### In-depth

* Get familiar with the API of the standard library [Phobos](https://dlang.org/phobos)
* Read the [language reference](https://dlang.org/spec/)
* The [Forums](https://forum.dlang.org/) contain very active discussions
* Browse the [Dub Repository](https://code.dlang.org), hosting an ever growing list of 3rd-party D programs and libraries.
* Browse the source code on github ([dmd compiler](https://github.com/dlang/dmd), [Phobos standard library](https://github.com/dlang/phobos), [druntime](https://github.com/dlang/druntime))
* Follow the [DStyle](http://dlang.org/dstyle.html)
* See the D Language on [Rosetta code](http://rosettacode.org/wiki/Category:D)
* Explore [awesome-d](https://github.com/zhaopuming/awesome-d/blob/master/README.md) - A curated list of awesome D frameworks, libraries and software
* Get inspired by [Idioms for the D Programming Language](https://p0nce.github.io/d-idioms/)

### Contributing

This tour is [open source](https://github.com/stonemaster/dlang-tour/tree/master/public/content/en)
and we are glad about pull requests making this tour even better.

# Let's Go!

Congratulations for finishing the first chapter. You're now ready to dive
into the world of **D**.

Either use the navigation panel at the bottom or press the right arrow key.

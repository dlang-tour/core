# Run D program locally

D comes with a compiler `dmd`, an script-like run tool `rdmd` and
a package manager `dub`.

### DMD Compiler

Given a D file `test.d` a binary is created using *DMD* with this command:

    dmd test.d

Run `dmd --help` or browse the [online documentation](https://dlang.org/dmd-linux.html#switches)
for an overview of available flags.

### On-the-fly compilation with `rdmd`

The helper tool `rdmd` distributed with the DMD compiler
will make sure to compile all dependencies and automatically runs
the resulting application:

    rdmd test.d

On UNIX systems the shebang line `#!/usr/bin/env rdmd` can be put
on the first line of an executable D file to allow a script-like
usage.

Run `rdmd --help` or browse the [online documentation](https://dlang.org/rdmd.html)
for an overview of available flags.

### Package manager `dub`

D's standard package manager is [dub](http://code.dlang.org). When dub is
installed locally a new project `test` can be created using
the command line

    dub init test

Running `dub` inside this folder will fetch all dependencies, compile the
application and run it.
`dub build` will compile the project.

Run `dub help` or browse the [online documentation](https://code.dlang.org/docs/commandline)
for an overview of available commands and features.


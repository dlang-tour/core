# Run D program locally

D comes with a compiler `dmd`, an script-like run tool `rdmd` and
a package manager `dub`.

### DMD Compiler

The *DMD* compiler compiles D file(s) and creates a binary.
On the command line *DMD* can be invoked with the filename:

    dmd hello.d

There are many options that allow to modify the behavior of the *DMD* compiler.
Browse the [online documentation](https://dlang.org/dmd.html#switches) or run `dmd --help` for an overview of available flags.

### On-the-fly compilation with `rdmd`

The helper tool `rdmd`, distributed with the DMD compiler,
will make sure to compile all dependencies and automatically runs
the resulting application:

    rdmd hello.d

On UNIX systems the shebang line `#!/usr/bin/env rdmd` can be put
on the first line of an executable D file to allow a script-like
usage.

Browse the [online documentation](https://dlang.org/rdmd.html) or run `rdmd --help` for for an overview of available flags.

### Package manager `dub`

D's standard package manager is [`dub`](http://code.dlang.org). When `dub` is
installed locally, a new project `hello` can be created using
the command line:

    dub init hello

Running `dub` inside this folder will fetch all dependencies, compile the
application and run it.
`dub build` will compile the project.

Browse the [online documentation](https://code.dlang.org/docs/commandline) or run `dub help` for an overview of available commands and features.

All available dub packages can be browsed through dub's [web interface](https://code.dlang.org).

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


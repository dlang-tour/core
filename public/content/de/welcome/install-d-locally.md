# D lokal installieren

Auf der [Website der Programmiersprache](https://dlang.org) wird stets die neuste
Version des Referenzkompilers **DMD** (Digital Mars D) zum [Download](http://dlang.org/download.html)
angeboten und kann wie folgt installiert werden:

### Windows

* [Installer](http://downloads.dlang.org/releases/2.x/2.071.0/dmd-2.071.0.exe)
* oder: [Archive](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.windows.7z)
* mit [chocolatey](https://chocolatey.org/packages/dmd): `choco install dmd`

### Mac OS X

* `.dmg` [package](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.dmg)
* oder: [Archive](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.osx.tar.xz)
* mit [Homebrew](http://brew.sh): `brew install dmd`

### Linux / FreeBSD

DMD kann am schnellsten durch Ausführen von `curl -fsS https://dlang.org/install.sh | bash -s dmd`
in dem Benutzerverzeichnis installiert werden.

Für viele Distributionen werden auch Pakete angeboten:

* [ArchLinux](https://wiki.archlinux.org/index.php/D_(programming_language))
* [Debian/Ubuntu](http://d-apt.sourceforge.net).
* [Fedora/CentOS](http://dlang.org/download.html#dmd)
* [Gentoo](https://wiki.gentoo.org/wiki/Dlang)
* [OpenSuse](http://dlang.org/download.html#dmd)

### Andere Kompiler

Neben dem DMD Referenzkompiler, der sein eigenes Backend verwendet, gibt es noch
zwei weitere Kompiler die über die Downloadsektion auf [dlang.org](https://dlang.org)
heruntergeladen werden können:

* [**GDC**](http://gdcproject.org/downloads) - basierend auf dem GCC backend
* [**LDC**](https://github.com/ldc-developers/ldc#installation) - basierend auf dem LLVM backend

GDC und LDC verwenden nicht immer das neuste DMD Frontend, aber dafür
ermöglichen sie bessere Optimierung oder Unterstützungen für weitere Platformen
wie zum Beispiel ARM.

Weitere Informationen bietet das [DWiki](https://wiki.dlang.org/Compilers).

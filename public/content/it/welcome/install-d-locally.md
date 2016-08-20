# Come installare D sul proprio computer

All'interno del sito internet del linguaggio D [dlang.org](https://dlang.org) è possibile [scaricare](http://dlang.org/download.html) l'ultima versione del compilatore di riferimento **DMD** (Digital Mars D):

### Windows

* Tramite il [programma di installazione](http://downloads.dlang.org/releases/2.x/2.071.0/dmd-2.071.0.exe)
* oppure come [archivio compresso](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.windows.7z)
* o tramite [chocolatey](https://chocolatey.org/packages/dmd): `choco install dmd`

### Mac OS X

* Come [pacchetto `.dmg`](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.dmg)
* oppure come [archivio compresso](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.osx.tar.xz)
* o tramite [Homebrew](http://brew.sh): `brew install dmd`

### Linux / FreeBSD

Per installare DMD nella propria cartella `user` è sufficiente eseguire il comando `curl -fsS https://dlang.org/install.sh | bash -s dmd`.

Sono disponibili pacchetti per varie distribuzioni:

* [ArchLinux](https://wiki.archlinux.org/index.php/D_(programming_language))
* [Debian/Ubuntu](http://d-apt.sourceforge.net).
* [Fedora/CentOS](http://dlang.org/download.html#dmd)
* [Gentoo](https://wiki.gentoo.org/wiki/Dlang)
* [OpenSuse](http://dlang.org/download.html#dmd)

### Altri compilatori

Oltre al compilatore di riferimento DMD, che utilizza un proprio backend, esistono altri due compilatori che si possono anch'essi trovare nella sezione download di
[dlang.org](https://dlang.org):

* [**GDC**](http://gdcproject.org/downloads), che utilizza il backend di GCC
* [**LDC**](https://github.com/ldc-developers/ldc#installation) basato sul backend LLVM

GDC e LDC non sono sempre aggiornati alla versione più recente del frontend di DMD, ma forniscono maggiori livelli di ottimizzazione, oltre a supportare piattaforme differenti, come ad esempio ARM.

Per maggiori informazioni è possibile consultare la [wiki](https://wiki.dlang.org/Compilers).

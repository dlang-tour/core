# Installera D lokalt

På D språkets webbsida [dlang.org](https://dlang.org) kan den senaste kompilerar
versionen av referens kompilatorn **DMD** (Digital Mars D)
[laddas ned](http://dlang.org/download.html) och installeras:

### Windows

* [Installerare](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd-{{latest-release}}.exe)
* eller: [Arkiv](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd.{{latest-release}}.windows.7z)
* genom [chocolatey](https://chocolatey.org/packages/dmd): `choco install dmd`

### Mac OS X

* `.dmg` [fil](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd.{{latest-release}}.dmg)
* eller: [Arkiv](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd.{{latest-release}}.osx.tar.xz)
* genom [Homebrew](http://brew.sh): `brew install dmd`

### Linux / FreeBSD

För att snabbt installera dmd i användarens hemmapp, kör `curl -fsS
https://dlang.org/install.sh | bash -s dmd`

Paket för flera distributioner är:

* [ArchLinux](https://wiki.archlinux.org/index.php/D_(programming_language))
* [Debian/Ubuntu](http://d-apt.sourceforge.net).
* [Fedora/CentOS](http://dlang.org/download.html#dmd)
* [Gentoo](https://wiki.gentoo.org/wiki/Dlang)
* [OpenSuse](http://dlang.org/download.html#dmd)

### Andra kompilatorer

Förutom DMD referens kompilatorn vilket använder sitt egna 'backend', finns
det två andra kompilatorer som kan hämtas via [dlang.org](https://dlang.org)
nedladdningssektion:
* [**GDC**](http://gdcproject.org/downloads) vilket använder sig av GCCs 'backend'
* [**LDC**](https://github.com/ldc-developers/ldc#installation) baserat på LLVMs 'backend'

GDC och LDC är inte alltid vid den senaste DMDs 'frontend' version, men
ger bättre optimisering nivåer samt stöd för andra platformer, exempelvis ARM.

Se wiki för [mer information](https://wiki.dlang.org/Compilers)

# Installera D lokalt

På D språkets webbsida [dlang.org](https://dlang.org) kan den senaste
versionen av referens kompilatorn **DMD** (Digital Mars D)
[laddas ner](http://dlang.org/download.html) och installeras:

### Windows

* [Installationsfil](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd-{{latest-release}}.exe)
* [Arkiv](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd.{{latest-release}}.windows.7z)
* [chocolatey](https://chocolatey.org/packages/dmd): `choco install dmd`

### OS X

* [Installationsfil](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd.{{latest-release}}.dmg)
* [Arkiv](http://downloads.dlang.org/releases/2.x/{{latest-release}}/dmd.{{latest-release}}.osx.tar.xz)
* [Homebrew](http://brew.sh): `brew install dmd`

### Linux / FreeBSD

För att snabbt installera DMD i användarens hemkatalog, kör `curl -fsS
https://dlang.org/install.sh | bash -s dmd`

Paket för flera distributioner:

* [ArchLinux](https://wiki.archlinux.org/index.php/D_(programming_language))
* [Debian/Ubuntu](http://d-apt.sourceforge.net).
* [Fedora/CentOS](http://dlang.org/download.html#dmd)
* [Gentoo](https://wiki.gentoo.org/wiki/Dlang)
* [OpenSuse](http://dlang.org/download.html#dmd)

### Andra kompilatorer

Förutom DMD referens kompilatorn som använder sin egna 'backend', finns
det två andra kompilatorer som kan hämtas via [dlang.org](https://dlang.org)
nedladdningssektion:
* [**GDC**](http://gdcproject.org/downloads) vilket använder sig av GCCs 'backend'
* [**LDC**](https://github.com/ldc-developers/ldc#installation) baserat på LLVMs 'backend'

GDC och LDC är inte alltid vid den senaste DMDs 'frontend' version, men
ger bättre optimeringar samt stöd för andra platformer, exempelvis ARM.

Se wikin för [mer information](https://wiki.dlang.org/Compilers)

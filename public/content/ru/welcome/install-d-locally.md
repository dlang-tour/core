# Локальная установка D

Последняя версия референс-компилятора **DMD** (Digital Mars D) может быть
[загружена](http://dlang.org/download.html) и установлена с официального сайта
[dlang.org](https://dlang.org)

### Windows

* [Установщик](http://downloads.dlang.org/releases/2.x/2.071.0/dmd-2.071.0.exe)
* либо: [Архив](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.windows.7z)
* или используя [chocolatey](https://chocolatey.org/packages/dmd): `choco install dmd`

### Mac OS X

* `.dmg` [Пакет](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.dmg)
* либо: [Архив](http://downloads.dlang.org/releases/2.x/2.071.0/dmd.2.071.0.osx.tar.xz)
* или используя [Homebrew](http://brew.sh): `brew install dmd`

### Linux / FreeBSD

Для быстрой установки dmd в свою пользовательскую директорию, выполните:
`curl -fsS https://dlang.org/install.sh | bash -s dmd`

Также доступны ракеты для различных дистрибутивов:

* [ArchLinux](https://wiki.archlinux.org/index.php/D_(programming_language))
* [Debian/Ubuntu](http://d-apt.sourceforge.net).
* [Fedora/CentOS](http://dlang.org/download.html#dmd)
* [Gentoo](https://wiki.gentoo.org/wiki/Dlang)
* [OpenSuse](http://dlang.org/download.html#dmd)

### Другие компиляторы

Помимо референс-компилятора DMD, который использует свой собственный backend,
существует ещё два компилятора, которые можно найти на странице загрузок
[dlang.org](https://dlang.org):

* [**GDC**](http://gdcproject.org/downloads) который использует GCC backend
* [**LDC**](https://github.com/ldc-developers/ldc#installation) основанный на LLVM backend

GDC и LDC не всегда соответствуют самой последней frontend версии DMD, 
но предоставляют более высокие уровни оптимизации и возможность компиляции на
другие платформы, вроде ARM.

Подробности об компиляторах можно узнать из [вики](https://wiki.dlang.org/Compilers)

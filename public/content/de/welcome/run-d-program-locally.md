# D Programme lokal ausführen

Unter anderem beinhaltet D den Compiler `dmd`, ein Skripttool `rdmd` und den
Packetmanager `dub`.

### DMD Compiler

Der *DMD* Compiler kompiliert D Dateien und erstellt eine Binärdatei.
Auf der Kommandozeile kann *DMD* mit dem Dateinamen aufgerufen werden:

    dmd hallo.d

Es gibt viele Optionen, die das Verhalten des *DMD* Compilers verändern.
Durchstöbere die [Online-Dokumentation](https://dlang.org/dmd.html#switches)
oder führe `dmd --help` aus um einen Überblick über alle vorhandenen Optionen zu erlangen.

### Fliegende Kompilierung mit `rdmd`

Das Programm `rdmd`, welches zusammen mit dem DMD Compiler angeboten wird,
sorgt dafür, dass alle Abhängigkeiten kompiliert sind und führt die kompilierte
Datei automatisch aus:

    rdmd hallo.d

Auf UNIX System kann das Shebangkommando `#!/usr/bin/env rdmd` als erste Zeile
in einer D-Quelldatei mit Ausführberechtigungen eingefügt werden und erlaubt eine
Ausführung der Datei analog zu Skriptsprachen.

Durchstöbere die [Online-Dokumentation](https://dlang.org/rdmd.html)
oder führe `rdmd --help` aus um einen Überblick über alle vorhandenen Optionen zu erlangen.

### Paketmanager `dub`

Der Standardpaketmanager für D ist [dub](http://code.dlang.org). Wenn dub lokal
installiert ist, kann ein neues Project `hello` mit folgenden Kommando angelegt
werden:

    dub init hello

Das Ausführen von `dub` innerhalb eines Ordner wird alle Abhängigkeiten herunterladen,
kompilieren, mit der Anwendungen linken und anschließend ausführen.
`dub build` wird jediglich das Projekt kompilieren.

Durchstöbere die [Online-Dokumentation](https://code.dlang.org/docs/commandline)
oder führe `rdmd --help` aus um einen Überblick über alle vorhandenen Optionen und Fähigkeiten zu erlangen.

All vorhandene `dub` Pakete können durch das [Web portal](https://code.dlang.org)
von `dub` durchsucht werden.

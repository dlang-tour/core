# Imports und Module

Für ein einfaches "Hallo Welt" Program in D werden Imports benötigt.
Mit `import` werden alle öffentlichen Funktionen und Typen des __Modules__ verfügbar.

Die Standardbibliothek [Phobos](https://dlang.org/phobos/) ist unter
dem **Packet** `std` vorhanden und diese Module können per `import std.MODULE`
importiert werden.

Die `import` Anweisung kann auch selektiv genutzt werden um nur ausgewählte Symbole
eines Modules zu importieren. Dies verbessert die ohnehin geringe Kompilierzeit
von D Programmen:

    import std.stdio: writeln, writefln;

Eine `import` Anweisung muss nicht am Anfang einer Datei stehen, sondern kann
auch lokal innerhalb einer Funktion verwendet werden.

## {SourceCode}

```d
void main()
{
    import std.stdio;
    // oder import std.stdio: writeln;
    writeln("Hallo Welt!");
}
```

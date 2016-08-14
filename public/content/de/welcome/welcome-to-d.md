# Willkommen zu D

Herzlich willkommen zu der interaktiven Tour der Programmiersprache D.

{{#dmanmobile}}

Diese Tour wird dir einen Überblick über diese __mächtige__ und __ausdruckstarke__
Sprache, welche direkt zu __effizientem__, __nativem__ Maschinencode kompiliert.

{{/dmanmobile}}

### Was ist D?

D ist die Akkumulation von Jahrzehnten an Erfahrung im Compilerbau
für viele verschiedene Sprachen und D hat eine Vielzahl an einzigartigen
[Fähigkeiten](http://dlang.org/overview.html):

{{#dmandesktop}}

- _Kontrukte auf _hoher Ebene_ für eine bedeutende Modellierfähigkeiten
- _hoch performante_, kompilierte Sprache
- statische Typen
- Evolution von C++ (ohne die Fehler)
- Direktes Interface zu den Betriebssystem API's und Hardware
- Schnelle Kompilierzeiten
- sicherer Zugriff auf den Speicher (SafeD)
- _wartbarer_, _einfach zu verstehender_ Code
- geringe Lernkurve (sehr änhliche Syntax zu C, C++, Java u.a.)
- kompatibel mit der C Binärschnittstelle
- verschiedene Paradigmen (imperativ, strukturiert, objektorientiert, generisch, funktional and selbst Assembler)
- eingebaute Fehlerkorrektur (Verträge, Unittests)

... und [viele weitere Besonderheiten](http://dlang.org/overview.html).

{{/dmandesktop}}

### Über diese Tour

Jede Lektion beinhaltet ein Beispiel mit Quellcode, welches bearbeitet werden kann
und so zum Experimentieren mit den Fähigkeiten von D verwendet werden kann.
Klicke auf den Run-Button (oder drücke `Umschalt-Enter`) um das Programm zu kompilieren
und auszuführen.

### Mitmachen

Diese Tour ist [open source](https://github.com/stonemaster/dlang-tour)
und wir freuen uns über Pull Requests, die diese Tour noch besser machen.

## {SourceCode}

```d
import std.stdio;

// Lass uns anfangen
void main()
{
    writeln("Hallo Welt!");
}
```

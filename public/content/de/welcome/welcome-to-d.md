# Willkommen zu D

Glückwunsch! Du hast es zu der interaktiven Tour der Programmiersprache D geschafft.

{{#dmanmobile}}

Diese Tour wird dir einen Überblick über diese __mächtige__ und __expressive__
Sprache, welche direkt zu __effizientem__, __nativem__ Maschinencode kompiliert.

{{/dmanmobile}}

### Was ist D?

D ist die Akkumulation von Jahrzehnten an Erfahrung im Bau von Kompilierer
für viele verschiedene Sprachen und D at eine Vielzahl an einzigartigen
[Fähigkeiten](http://dlang.org/overview.html):

{{#dmandesktop}}

- _Kontrukte auf _hoher Ebene_ für eine bedeutende Modellierfähigkeiten
- _hoch performante, kompilierte Sprache
- statische Typen
- Evolution von C++ (ohne die Fehler)
- Direkte Interface zu dem Betriebssystem API's und Hardware
- Auffallend schnelle Kompilierzeiten
- sicheres Zugriff auf den Speicher (SafeD)
- allow memory-safe programming (SafeD)
- _wartbarer_, _einfach zu verstehender_ Code
- geringe Lernkurve (sehr änhliche Syntax zu C, C++, Java und andere)
- kompatible mit der C Binärschnittstelle
- multiple Paradigmen (imperativ, strukturiert, Objekt orientiert, generisch, funktionale Reinheit and selbst Assembler)
- eingebaute Fehlerkorrektur (Verträge, Unittests)

... und [viele weitere Besonderheiten](http://dlang.org/overview.html).

{{/dmandesktop}}

### Über diese Tour

Jede Lektion beinhaltet einen Beispiel mit Quellcode, welches bearbeitet werden kann
und so zum Experimentieren mit den Fähigkeiten von D verwendet werden kann.
Klicke auf den Run-Button (oder drücke `Umschalt-Enter) um das Programm zu kompilieren
und auszuführen.

### Mitmachen

Diese Tour ist [open source](https://github.com/stonemaster/dlang-tour/tree/master/public/content/en)
und wir freuen uns über Pull Requests die diese Tour noch besser machen.

## {SourceCode}

```d
import std.stdio;

// Lass uns anfangen
void main()
{
    writeln("Hallo Welt!");
}
```

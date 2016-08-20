# Datenfluss

Der Datenfluss einer Anwendung kann bedingt mit `if` und `else` Anweisungen
kontrolliert werden:

    if (a == 5) {
        writeln("Kondition erfüllt!");
    } else if (a > 10) {
        writeln("Andere Kondition erfüllt!");
    } else {
        writeln("Keine Kondition ist erfüllt!");
    }

Falls ein `if` oder `else` Block nur eine Anweisung beinhaltet, können die
geschweiften Klammern weggelassen werden.

D bietet die gleichen Operatoren wie in C/C++ und Java für das Testen der Gleichheit
oder den Vergleich von Variablen:

* `==` und `!=` für Gleichheit- und Ungleichheittests
* `<`, `<=`, `>` and `>=` für Vergleiche mit kleiner (oder gleich) und größer (oder gleich)

Für das Kombinieren mehrerer Bedingungen stehen die logischen Operatoren
`||`, das logische *OR*, und `&&`, das logische *UND* zur Verfügung.

D besitzt auch eine `switch` .. `case` Anweisung, welche einen Fall abhängig
von einer Variable ausführt. `switch` funktioniert mit allen grundlegenden Typen
und auch strings!
Es ist sogar möglich Bereiche für Ganzzahlen mit der `case ANFANG: .. case ENDE:` Syntax
zu definieren, dies wird am besten durch das Beispiel gezeigt.

### In-depth

#### Grundlegende Referenzen

- [Logische Ausdrücke in _Programmieren in D_](http://ddili.org/ders/d.en/logical_expressions.html)
- [If Anweisung in _Programmieren in D_](http://ddili.org/ders/d.en/if.html)
- [Ternäre Anweisungen in _Programmieren in D_](http://ddili.org/ders/d.en/ternary.html)
- [`switch` und `case` in _Programmieren in D_](http://ddili.org/ders/d.en/switch_case.html)

#### Weiterführende Referenzen

- [Ausdrücke im Details](https://dlang.org/spec/expression.html)
- [Spezifikation der If Anweisung](https://dlang.org/spec/statement.html#if-statement)

## {SourceCode}

```d
import std.stdio;

void main()
{
    if (1 == 1)
        writeln("Arithmetik funktioniert auch in D.");

    int c = 5;
    switch(c) {
        case 0: .. case 9:
            writeln(c, " ist zwischen 0-9");
            break; // notwendig
        case 10:
            writeln("Eine Zehn!");
            break;
        default: // falls kein anderer Fall zutrifft
            writeln("Nichts.");
            break;
    }
}
```

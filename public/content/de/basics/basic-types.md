# Elementare Datentypen

D bietet eine Vielzahl an elementaren Datentypen, die immer die gleiche Größe haben -
**unabhängig** von der Platform.
Die einzige Ausnahme ist der Typ `real` für welchen der Kompiler
die höchstmöglichste Genauigkeit für Gleitkommazahlen wählt.
Es besteht kein Unterschied zwischen der Große einer Ganzzahl - unabhängig davon
ob die Anwendung für eine 32-bit oder 64-bit Architektur kompiliert wird.

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">bool</code></td> <td>8-bit</td></tr>
<tr><td><code class="prettyprint">byte, ubyte, char</code></td> <td>8-bit</td></tr>
<tr><td><code class="prettyprint">short, ushort, wchar</code></td> <td>16-bit</td></tr>
<tr><td><code class="prettyprint">int, uint, dchar</code></td> <td>32-bit</td></tr>
<tr><td><code class="prettyprint">long, ulong</code></td> <td>64-bit</td></tr>
</table>

#### Gleitkommatypen

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">float</code></td> <td>32-bit</td></tr>
<tr><td><code class="prettyprint">double</code></td> <td>64-bit</td></tr>
<tr><td><code class="prettyprint">real</code></td> <td>abhängig von der Platform, 80-bit für Intel x86 32-bit</td></tr>
</table>

Der Präfix `u` kennzeichnet Typen ohne Vorzeichen (vom Englischen `unsigned`).
Ein `char` ist ein UTF-8 Zeichen, `wchar` ein UTF-16 Zeichen and `dchar`
ein UTF-32 Zeichen.

Eine Umwandlung zwischen Variablen ist nur erlaubt wenn keine Präzision verloren
gehen kann, obgleich die Umwandlung von Gleitkommatypen (z. B. `double` zu `float`)
erlaubt ist.

Eine Umwandlung zu einem anderen Typ kann durch den Ausdruck
`cast(TYPE) <varName>` erzwungen werden. Dieser Ausdruck sollte aber mit großer
Vorsicht verwenden werden, da mit `cast` Ausdrücken das Typsystem ausgeschaltet
wird.

Das spezielle Schlüsselwort `auto` erzeugt eine Variable und inferiert ihren Typ
automatisch an Hand des Ausdruck of the rechten Seite. Zum Beispiel wird
`auto i = 7` den Typ `int` deduzieren. Es sollte beachtet werden, dass `auto` Typen trotzdem
statisch während der Kompilierphase festgelegt werden und den Typ nachträglich nicht
ändern können, wie für jede andere Variable mit explizitem Typ.

### Eigenschaften eines Typen

Alle Datentypen haben die Eigenschaft `.init`, welche dem Initialwert gleicht.
Für alle Ganzzahlen ist dies `0` und für Gleitkommazahlen ist es `nan` (vom Englischen
"not a number"). Sowohl Ganzzahl- als auch Gleitkommatypen haben eine `.min` und
`.max` Eigenschaft für die kleinste und größte Zahl, die der Typ darstellen kann.
Gleitkommatypen besitzen noch weitere Eigenschaften: `nan` (der invalide Zustand),
`infinity` (unendlich), `.dig` (Anzahl der dezimalen Stellen der Präzision) und
`.mant_dig` (Anzahl an Bits der Mantisse) und Weitere.

Zusätzlich besitzt jeder Typ die `.stringof` Eigenschaft welche seinen Namen als
String zurückgibt.

### Indizes in D

In D haben Indizes den Aliasnamen `size_t` welcher groß genug ist um den alle
Speicherzellen adressieren zu können, d.h. für ein 32-bit System `uint` und für
ein 64-bit System `ulong`.

`assert` ist eine eingebaute Anweisung welche Ausdrücke im Debugmodus validiert
und mit einen `AssertionError` wirft, wenn die Evaluation des Ausdruck `false`
liefert.

### In der Tiefe

#### Grundlegende Referenzen

- [Anweisungen](http://ddili.org/ders/d.en/assignment.html)
- [Variablen](http://ddili.org/ders/d.en/variables.html)
- [Arithmetik](http://ddili.org/ders/d.en/arithmetic.html)
- [Gleitkommazahlen](http://ddili.org/ders/d.en/floating_point.html)
- [Grundlegende Typen in _Programmieren in D_](http://ddili.org/ders/d.en/types.html)

#### Weitergehende Referenzen

- [Übersicht aller elementaren Datentypen in D](https://dlang.org/spec/type.html)
- [`auto` und `typeof` in _Programmieren in D_](http://ddili.org/ders/d.en/auto_and_typeof.html)
- [Eigenschaften eines Typen](https://dlang.org/spec/property.html)

## {SourceCode}

```d
import std.stdio;

void main()
{
    // Zahlen können zur Verbesserung
    // der Lesbarkeit mit einem
    // Unterstrich '_' separariert werden
    int b = 7_000_000;
    short c = cast(short) b; // cast benötigt
    uint d = b; // größerer Typ
    int g;
    assert(g == 0);

    auto f = 3.1415f; // f steht für float

    // typeid(VAR) liefert die Typinformation
    // eines Ausdruckes
    writeln("Typ von f ist:  ", typeid(f));
    double pi = f; // größerer Typ
    // Für Gleitkommazahlen ist
    // eine implizite Umwandlung in Typen
    // mit geringerer Präzision erlaubt
    float demoted = pi;

    // Zugriff auf die Eigenschaften eines Types
    assert(int.init == 0);
    assert(int.sizeof == 4);
    assert(bool.max == 1);
    writeln(int.min, " ", int.max);
    writeln(int.stringof); // int
}
```

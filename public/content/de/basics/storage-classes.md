# Speicherklassen

D besitzt eine statische Typisierung. Wenn eine Variable deklariert wurde, kann der
Typ nicht mehr verändert werden. Dies erlaubt dem Kompiler viele Fehler früh
zu erkennen und Restriktionen können schon während der Kompilierung erkannt werden.
Ein gutes Typsystem leistet die benötigte Unterstützung um große Programme
sicher und leichter zu warten zu machen.

### `immutable`

Zusätzlich zu der statischen Typisierung, stellt D Speicherklassen bereit
welche weitere Beschränkungen erlauben. Zum Beispiel kann ein `immutable` (unveränderbares)
Objekt nur einmal initialisiert werden und kann danach nicht mehr verändert werden.

    immutable int err = 5;
    // oder: immutable arr = 5 (der Typ int wird automatisch inferriert)
    err = 5; // FEHLER

Wegen ihrer Unveränderbarkeit, können `immutable` Objekte sicher zwischen
Threads geteilt werden. Dies impliziert auch das `immutable` Objekte perfekt
gecacht werden können.

### `const`

`const` Objekte können ebenfalls nicht verändert werden. Diese Restriktion ist
jedoch nur für den aktuellen Geltungsbereich gültig. Ein `const` Zeiger
kann von sowohl einem `immutable` als auch _veränderbaren_ Objekt erzeugt werden.
Das bedeutet, dass die Restriktion nur für den aktuellen Bereich gilt. Die Variable
aber in der Zukunft verändert werden könnte. Nur mit `immutable` ist garantiert
das der Wert sich niemals ändern kann. Es ist typisch für APIs `const` Objekte
zu akzeptieren, da so garantiert wird, dass keine Modifikation stattfindet.

    immutable a = 10;
    int b = 5;
    const int* pa = &a;
    const int* pb = &b;
    *pa = 7; // FEHLER

Sowohl `immutable` als auch `const` sind _transitiv_. Dies gewährleistet, dass
sobald ein Typ `const` ist alle Subkomponenten dieses Types ebenfalls `const` sind.

### In der Tiefe

#### Grundlegende Referenzen

- [Immutable in _Programmieren in D_](http://ddili.org/ders/d.en/const_and_immutable.html)
- [Bereiche in _Programmieren in D_](http://ddili.org/ders/d.en/name_space.html)

#### Weiterführende Referenzen

- [const(FAQ)](https://dlang.org/const-faq.html)
- [Typqualifizierer in D](https://dlang.org/spec/const3.html)

## {SourceCode}

```d
import std.stdio;

void main()
{
    immutable forever = 100;
    // FEHLER
    // forever = 5;
    writeln("forever: ",
        typeof(forever).stringof);

    const int* cForever = &forever;
    // FEHLER:
    // *cForever = 10;
    writeln("const* forever: ",
        typeof(cForever).stringof);

    int mutable = 100;
    writeln("veraenderbar: ",
        typeof(veraenderbar).stringof);
    veraenderbar = 10; // OK
    const int* cVeraenderbar = &veraenderbar; // OK
    // FEHLER:
    // *cVeranderbar = 100;
    writeln("cMutable: ",
        typeof(cVeraenderbar).stringof);

    // FEHLER:
    // immutable int* imVeraenderbar = &veraenderbar;
}
```

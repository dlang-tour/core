# Funktionen

Eine Funktion wurde bereits vorgestellt: `main()` - der Startpunkt jedes
D Programmes. Eine Funktion kann einen Wert zurückgeben oder mit `void` deklariert
werden, wenn kein Wert zurückgegeben wird. Zusätzlich kann eine Funktion beliebig
viele Argumente akzeptieren:

    int addiere(int links, int rechts) {
        return links + rechts;
    }

### `auto` Rückgabetyp

Wenn der Rückgabetyp als `auto` definiert wird, versucht der D Compiler den
Rückgabetyp automatisch zu inferieren. Falls mehrere `return` Anweisungen
verwendet werden, müssen diese Ausdrücke kompatible Typen haben.

    auto addiere(int links, int rechts) { // gibt `int` zurück
        return links + rechts;
    }

    auto kleinerOderGleich(int links, int rechts) { // gibt `double` zurück
        if (links <= rechts)
            return 0;
        else
            return 1.0;
    }

### Standardargumente

Funktionen können optional Standardargumente definieren.
Dies erspart die mühsame Arbeit mehrere Funktionen zu deklarieren.

    void plot(string text, string farbe = "rot") {
        ...
    }
    plot("D ist großartig.");
    plot("D ist großartig.", "blau");

Sobald ein Argument einen Standardwert hat, müssen alle folgenden Argumente
ebenso einen Standardwert besitzen.

### Lokale Funktionen

Funktionen können auch innerhalb anderer Funktionen deklariert werden. Diese
Funktionen können lokal verwendet werden und sind nicht sichtbar für Andere.
Des Weiteren haben diese Funktionen Zugriff auf den Elternbereich:

    void fun() {
        int lokal = 10;
        int geheimeFunktion () {
            lokal++; // erlaubt
        }
        ...

Solche verschachtelten Funktionen heißen Delegates und werden bald
[in Tiefe](basics/delegates) erklärt.

### In der Tiefe

- [Funktionen in _Programmieren in D_](http://ddili.org/ders/d.en/functions.html)
- [Parameter von Funktionen in _Programmieren in D_](http://ddili.org/ders/d.en/function_parameters.html)
- [Spezifikation von Funktionen](https://dlang.org/spec/function.html)

## {SourceCode}

```d
import std.stdio;
import std.random;

void zufallsGenerator()
{
    // Definiert 4 lokale Funktionen für
    // 4 verschiedene mathematische Operationen
    auto addiere(int rhs, int rhs) {
        return rhs + rhs;
    }
    auto subtrahiere(int rhs, int rhs) {
        return rhs - rhs;
    }
    auto multipliziere(int rhs, int rhs) {
        return rhs * rhs;
    }
    auto dividiere(int rhs, int rhs) {
        return rhs / rhs;
    }

    int a = 10;
    int b = 5;

    // uniform erzeugt Zahlen zwischen START
    // und ENDE, wobei ENDE nicht
    // eingeschlossen ist.
    // Abhängig von dem Ergebnis, wird eine
    // mathematische Operation angewendet
    // the math operations.
    switch (uniform(0, 4)) {
        case 0:
            writeln(addiere(a, b));
            break;
        case 1:
            writeln(subtrahiere(a, b));
            break;
        case 2:
            writeln(multipliziere(a, b));
            break;
        case 3:
            writeln(dividiere(a, b));
            break;
        default:
            // Spezielle Anweisung für
            // UNEREICHBAREN code
            assert(0);
    }
}

void main()
{
    zufallsGenerator();
    // addiere(), subtrahiere(),
    // multipliziere() and dividiere()
    // sind nicht sichtbar außerhalb
    // ihres Bereiches
    static assert(!__traits(compiles,
                            addiere(1, 2)));
}

```

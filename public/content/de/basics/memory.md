# Speicher

D ist eine Systemprogrammiersprache und erlaubt daher manuellen Zugriff auf den Systemspeicher.
Manueller Zugriff impliziert jedoch, dass Fehler sehr leicht entstehen können, daher
verwendet D standardmäßig einen *Garbage Collector* um Speicher freizugeben.

D verfügt über Adressstypen (aka Pointer) `T*` wie in C:

    int a;
    int* b = &a; // b beinhaltet die Adresse zu a
    auto c = &a; // c hat den Typp int* und beinhaltet die Adresse zu a

Mit dem `new` Ausdruck kann ein neuer Speicherblock auf dem Heap alloziert
werden. Der `new` Ausdruck gibt einen Pointer zu den allozierten Speicher zurück:

    int* a = new int;

Sobald der Speicher, welcher durch `a` adressiert wird, von keiner Variable des Programmes mehr referenziert wird,
wird der Speicher durch den Garbage Collector freigegeben.

In D gibt es drei Sicherheitsstufen für Funktionen: `@system`, `@safe` und `@trusted`.
Außer explizit angeben, werden Funktionen als `@system` behandelt.
`@safe` ist ein Subset von D, welches _per Definition_ Speicherfehler verhindert.
`@safe` Code kann nur andere `@safe` Funktionen oder Funktionen denen explizit
mit `@trusted` vertraut wird, aufrufen. Manuelle Adressarithmetik ist in `@safe`
Code verboten.

    void main() @safe {
        int a = 5;
        int* p = &a;
        int* c = p + 5; // Fehler
    }

`@trusted` Funktionen müssen manuell verifiziert werden und erlauben die Brücke
zwischen SafeD und der zugrundeliegenden unsicheren, low-level Welt.

### In der Tiefe

* [SafeD](https://dlang.org/safed.html)

## {SourceCode}

```d
import std.stdio;

void sichereFunktion() @safe
{
    writeln("Hallo Welt");
    // Speicherallokation mit dem GC ist sicher
    int* p = new int;
}

void unsichereFunktion()
{
    int* p = new int;
    int* speicherArithmetik = p + 5;
}

void main()
{
    sichereFunktion();
    unsichereFunktion();
}
```

# Speicher

D ist eine Systemprogrammiersprache und erlaubt daher manuellen Zugriff. Manueller
Zugriff impliziert jedoch das Fehler sehr leicht entstehen können, daher
verwendet D per Default einen *Garbage Collector* um Speicher freizugeben.

D verfügt über Adressstypen `T*` wie in C:

    int a;
    int* b = &a; // b beinhaltet die Adresse zu a
    auto c = &a; // c hat den Typp int* und beinhaltet die Adresse zu a

Mit dem `new` Ausdruck kann ein neuer Speicherblock kann auf dem Heap alloziert
werden. Der `new` Ausdruck gibt einen Pointer zu den allozierten Speicher zurück:

    int* a = new int;

Sobald der Speicher, welcher durch `a` adressierbar ist, nicht mehr durch ein
einzige Variable in dem Program referenziert wird, wird der Garabage Collector den
Speicher freigeben.

D erlaubt auch Adressarithmetik, außer in Code der als `@safe` markiert wurde:

    void main() @safe {
        int a = 5;
        int* p = &a;
        int* c = p + 5; // Fehler
    }

Außer explizit angeben, haben Funktionen die `@system` Annotation.
`@safe` ist ein Subset von D, welches _per Definition_ Memoryfehler verhindert.
`@safe` Code kann nur andere `@safe` Funktionen oder Funktionen, denen explizit
mit `@trusted` vertraut wird, aufrufen.
`@trusted` Funktionen müssen manuell verifiziert werden und erlauben die Brücke
zwischen SafeD und der zugrundeliegenden unsichere, low-level Welt.

### In der Tiefe

* [SafeD](https://dlang.org/safed.html)

## {SourceCode}

```d
import std.stdio;

void sichereFunktion() @safe
{
    writeln("Hallo Welt");
    // Memoryallokation mit dem GC ist sicher
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

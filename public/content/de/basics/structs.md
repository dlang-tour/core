# Strukturen

Ein Weg einen Verbundtyp oder eigenen Typ in D zu definieren ist durch Strukturen,
welche mit der Anweisung `struct` definiert werden:

    struct Person {
        int alter;
        int groeese;
        float alterXGroeese;
    }

Strukturen werden immer auf den Stack alloziert (außer wenn sie explizit mit `new` erzeugt werden)
und werden bei Zuweisungen oder Parametern in Funktionsaufrufen immer **kopiert**.

    auto p = Person(30, 180, 3.1415);
    auto t = p; // Kopie

Wenn ein neues Objekt des `struct` Types erzeugt wird, können die Elemente in
ihrer Reihenfolge, in der sie in der Struktur definiert sind, initialisiert werden.
Ein eigener Konstruktor kann durch eine `this(...)` Elementfunktion definiert werden.
Um Namenskonflikte zu vermeiden, kann die aktuelle Instanz explizit mir `this`
adressiert werden:

    struct Person {
        this(int alter, int groesse) {
            this.alter = alter;
            this.groesse = groesse;
            this.alterXGroesse = cast(float)alter * groesse;
        }
            ...

    Person p(30, 180); // Initialisierung
    p = Person(30, 180);  // Zuweisung einer neuen Instanz

Ein `struct` kann beliebig viele Elementfunktionen beinhalten. Diese sind
standardmäßig `public` und von Anderen erreichbar. Es ist jedoch möglich
auch das Zugriffslevel auf `private` zu setzen. `private` Funktionen sind nur
von Elementfunktionen der gleichen Struktur erreichbar oder
im gleichen Modul erreichbar:

    struct Person {
        void erledigeAufgaben() {
            ...
        private void geheimeAufgabe() {
            ...

    p.erledigeAufgaben(); // Aufruf der Methode
    p.geheimeAufgabe(); // FEHLER

### Konstante Elementfunktionen

Wenn eine Elementfunktion mitn `const` deklariert wird, ist es ihr nicht
erlaubt Inhalte der Struktur zu verändern. Dies prüft der Compiler.
Wenn eine Funktion als `const` markiert wurde, ist sie von einem `const`
oder `immutable` Objekt aus aufrufbar, aber garantiert dem Aufrufer auch, dass
die Funktion den Zustand der Struktur niemals ändern wird.

### Statische Elementfunktionen

Wenn eine Elementfunktion als `static` (statisch) deklariert wird, ist sie
auch ohne eine Objektinstanz aufrufbar, z.B. `Person.statischeAufgabe` kann direkt
aufgerufen werden, jedoch haben statische Elementfunktionen keinen Zugriff
auf nicht-statische Elemente. Eine statische Elementfunktion kann zum Beispiel
den Zugriff auf alle Instanzen ermöglichen. Das bekannte _Singleton_
Entwurfsmuster verwendet ebenso `static`.

### Vererbung

Es sollte beachtet werden, dass ein `struct` nicht von einem anderen `struct` erben kann.
Hierarchien von Typen können nur mit Klassen konstruiert werden, welche in der
folgenden Lektion vorgestellt werden. Es ist jedoch möglich mit `alias this`
oder `mixins` polymorphe Vererbung zu erreichen.

### In der Tiefe

- [Strukturen in _Programmieren in D_](http://ddili.org/ders/d.en/struct.html)
- [Spezifikation von Strukturen](https://dlang.org/spec/struct.html)

### Aufgabe

Gegeben ist ´struct Vector3`. Implementiere die folgenden Funktionen und lasse
so die Anwendung erfolgreich laufen:

* `laenge()` - gibt die Länge des Vektors zurück
* `skalar(Vector3)` - ermittelt das Skalarprodukt von zwei Vektoren
* `toString()` - gibt die Repräsentation des Vektors als String
  Die Funktion [`std.string.format`](https://dlang.org/phobos/std_format.html)
  welche einen String mit `printf`-ähnlicher Syntax (`format("zahl = %d", zahl)`
  wird in einer späterer Lektion erklärt

## {SourceCode:incomplete}

```d
struct Vector3 {
    double x;
    double y;
    double z;

    double laenge() const {
        import std.math: sqrt;
        return 0.0;
    }

    // rechts beinhaltet eine Kopie
    double skalar(Vector3 rechts) const {
        return 0.0;
    }

    /**
    Returns: Repräsentation als String.
    Die Werte haben genau eine Nachkommastelle
    als Präzision.
    "x: 0.0 y: 0.0 z: 0.0"
    */
    string toString() const {
        import std.string: format;
        // Tip: Schlage in der Dokumentation
        // von std.format nach.
        // Gleitkommazahlen haben einen eigenen
        // Spezifikator
        return format("");
    }
}

void main() {
    auto vec1 = Vector3(10.0, 0.0, 0.0);
    Vector3 vec2;
    vec2.x = 0.0;
    vec2.y = 20.0;
    vec2.z = 0.0;

    // Wenn eine Elementfunktion keine
    // Parameter hat, können die Klammern
    // weggelassen werden
    assert(vec1.laenge == 10.0);
    assert(vec2.laenge == 20.0);

    // Testet das Skalarprodukt
    assert(vec1.skalar(vec2) == 0.0);

    // Durch toString, können wir den Inhalt
    // eines Vektors direkt ausgeben
    import std.stdio: writeln, writefln;
    writeln("vec1 = ", vec1);
    writefln("vec2 = %s", vec2);

    // Überprüft die Stringrepräsentation
    assert(vec1.toString() ==
        "x: 10.0 y: 0.0 z: 0.0");
    assert(vec2.toString() ==
        "x: 0.0 y: 20.0 z: 0.0");
}
```

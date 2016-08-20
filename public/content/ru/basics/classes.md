# Классы

D предоставляет поддержку классам и интерфейсам подобно Java или C++.
Любой тип `class` неявно наследует от [`Object`](https://dlang.org/phobos/object.html).

    class Foo { } // наследует от Object
    class Bar: Foo { } // Bar тоже является Foo

Классы в D, как правило, создаются в куче, используя `new`:

    auto bar = new Bar;

Объекты классов всегда являются ссылочным типом и, в отличии от структур, не
копируются по значению.

    Bar bar = foo; // bar - это указатель на foo

Сборщик мусора позаботится о том, чтобы память была освобождена, если ссылок на
объект больше не существует.

#### Наследование

Если функция-член основного класса переопределяется, нужно использовать ключевое
слово `override`, чтобы обозначить это. Это предотвращает случайное
переопределение функций.

    class Bar: Foo {
        override functionFromFoo() {}
    }

В D, классы могут наследовать только от одного класса.

#### Конечные и абстрактные функции-члены

Функция может быть помечена как `final` в основном классе, чтобы запретить
её переопределение. Функция может быть объявлена абстрактной (`abstract`), чтобы
заставить наследующие классы реализовать её. Весь класс может быть объявлен
`abstract`, чтобы гарантировать, что не будет создан его экземпляр. Для доступа
к основному классу используется ключевое слово `super`.

### Подробнее

- [Классы в _Programming in D_](http://ddili.org/ders/d.en/class.html)
- [Наследование в _Programming in D_](http://ddili.org/ders/d.en/inheritance.html)
- [Object class в _Programming in D_](http://ddili.org/ders/d.en/object.html)
- [Классы в D spec](https://dlang.org/spec/class.html)

## {SourceCode}

```d
import std.stdio;

// Воображаемый тип, который может быть
// использован для чего угодно...
class Any {
    // protected, доступно только наследуемым
    // классам
    protected string type;

    this(string type) {
        this.type = type;
    }

    // кстати, public подразумевается
    final string getType() {
        return type;
    }

    // Это должно быть реализовано!
    abstract string convertToString();
}

class Integer: Any {
    // just seen by Integer
    private {
        int number;
    }

    // конструктор
    this(int number) {
        // вызов конструктора основного класса
        super("integer");
        this.number = number;
    }

    // Это неявно. И ещё один способ
    // указания уровня защиты
    public:

    override string convertToString() {
        import std.conv: to;
        // «Швейцарский нож» преобразования.
        return to!string(number);
    }
}

class Float: Any {
    private float number;

    this(float number) {
        super("float");
        this.number = number;
    }

    override string convertToString() {
        import std.string: format;
        // Мы хотим контролировать точность
        return format("%.1f", number);
    }
}

void main()
{
    Any[] anys = [
        new Integer(10),
        new Float(3.1415f)
        ];

    foreach (any; anys) {
        writeln("any's type = ", any.getType());
        writeln("Content = ",
            any.convertToString());
    }
}
```

# Интерфейсы

D позволяет определять интерфейсы (`interface`), которые технически похожи на
типы `class`, но их функции-члены должны быть реализованы любым классом,
наследующим от интерфейса.

    interface Animal {
        void makeNoise();
    }

Функция-член `makeNoise` реализуется классом `Dog`, потому что наследуется от
интерфейса `Animal`. По сути, `makeNoise` работает подобно абстрактной
функции-члену основного класса.

    class Dog: Animal {
        override makeNoise() {
            ...
        }
    }

    auto dog = new Animal;
    Animal animal = dog; // неявное
                // преобразование к интерфейсу
    dog.makeNoise();

Количество интерфейсов класса, которое можно реализовать, не ограничено, но они
могут наследоваться только от *одного* основного класса.

Шаблон [**NVI (невиртуальный интерфейс)**](https://en.wikipedia.org/wiki/Non-virtual_interface_pattern)
предотвращает нарушение обычного выполнения шаблона путём разрешения
_невиртуальных_ методов для обычного интерфейса.
D легко позволяет использовать NVI шаблоны путём разрешения определения
`final` функций в `interface`, которые не могут быть переопределены. Это
обеспечивает специфические формы поведения, изменяемые переопределением других
функций интерфейса.

    interface Animal {
        void makeNoise();
        final doubleNoise() // шаблон NVI
        {
            makeNoise();
            makeNoise();
        }
    }

### Подробнее

- [Интерфейсы в _Programming in D_](http://ddili.org/ders/d.en/interface.html)
- [Интерфейсы в D](https://dlang.org/spec/interface.html)

## {SourceCode}

```d
import std.stdio;

interface Animal {
    // виртуальная функция, которая
    // должна быть переопределена!
    void makeNoise();

    // шаблон NVI. Внутренне использует
    // makeNoise чтобы изменять поведение
    // наследующих классов.
    final void multipleNoise(int n) {
        for(int i = 0; i < n; ++i) {
            makeNoise();
        }
    }
}

class Dog: Animal {
    override void makeNoise() {
        writeln("Bark!");
    }
}

class Cat: Animal {
    override void makeNoise() {
        writeln("Meeoauw!");
    }
}

void main() {
    Animal dog = new Dog;
    Animal cat = new Cat;
    Animal[] animals = [dog, cat];
    foreach(animal; animals) {
        animal.multipleNoise(5);
    }
}
```

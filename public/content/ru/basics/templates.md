# Шаблоны

Подобно C++ и Java, **D** позволяет определять шаблонные функции, которые
означают определение **универсальных** функций или объектов, которые работают с
любым типом, который компилируется с выражениями в теле функции:

    auto add(T)(T lhs, T rhs) {
        return lhs + rhs;
    }

Параметр шаблона `T` определяется в паре скобок, перед параметрами вызова
функции. `T` - это просто метка, которая заменяется компилятором,
непосредственно при *инстанцировании* (создании экземпляра) функции,
использующей оператор `!`:

    add!int(5, 10);
    add!float(5.0f, 10.0f);
    // следующая строка не скомпилируется, так
    // как Animal не реализует +
    add!Animal(dog, cat);

Если шаблонная функция не получает параметра шаблона, компилятор пробует вывести
тип используя входные параметры, с которыми функция вызывается:

    int a = 5; int b = 10;
    add(a, b); // T выводится как `int`
    float c = 5.0f;
    add(a, c); // ОШИБКА из-за конфликта, так
               // как компилятор не знает, чем
               // должен быть T

Функция может иметь любое число параметров шаблона, заданных при
инстанцировании, используя синтаксис `func!(T1, T2 ..)`. Параметры шаблона могут
быть любого основного типа, включая `string`и и числа с плавающей запятой.

В отличии от generics в Java, шаблоны в D исключительно compile-time, и дают
высокооптимизированный код, адаптированный под конкретный набор типов,
используемый при фактическом вызове функции

Конечно же, типы `struct`, `class` и `interface`, также могут быть определены
как шаблонные типы.

    struct S(T) {
        // ...
    }

### Подробнее

- [Руководство по шаблонам в D](https://github.com/PhilippeSigaud/D-templates-tutorial)
- [Шаблоны в _Programming in D_](http://ddili.org/ders/d.en/templates.html)

#### Дополнительно

- [D Templates spec](https://dlang.org/spec/template.html)
- [Templates Revisited](http://dlang.org/templates-revisited.html):  Walter Bright writes about how D improves upon C++ templates.
- [Variadic templates](http://dlang.org/variadic-function-templates.html): Articles about the D idiom of implementing variadic functions with variadic templates

## {SourceCode}

```d
import std.stdio;

/**
Шаблонный класс, который разрешает универсальную
реализацию animals.
Параметры:
    noise = string to write
*/
class Animal(string noise) {
    void makeNoise() {
        writeln(noise ~ "!");
    }
}

class Dog: Animal!("Bark") {
}

class Cat: Animal!("Meeoauw") {
}

/**
Шаблонная функция, которая принимает любой тип
T, который реализует функцию makeNoise.
Параметры:
    animal = объект, который может создавать шум
    n = количество вызовов makeNoise
*/
void multipleNoise(T)(T animal, int n) {
    for (int i = 0; i < n; ++i) {
        animal.makeNoise();
    }
}

void main() {
    auto dog = new Dog;
    auto cat = new Cat;
    multipleNoise(dog, 5);
    multipleNoise(cat, 5);
}
```

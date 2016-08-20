# Диапазоны

Если компилятор встречает `foreach`

    foreach(element; range) {

оно внутри заменяется на подобное этому:

    for (; !range.empty; range.popFront()) {
        auto element = range.front;
        ...

Любой объект, поддерживающий такой интерфейс, называется **range** (диапазон)
и, таким образом, является типом, который можно перебирать:

    struct Range {
        @property empty() const;
        void popFront();
        T front();
    }

Функции в `std.range` и `std.algorithm` предоставляют строительные блоки,
которые используют этот интерфейс. Диапазоны позволяют составлять сложные
алгоритмы, стоящие за объектами, которые легко могут быть перебраны.
Более того, диапазоны позволяют создавать **ленивые** объекты, которые выполняют
вычисления только когда это действительно необходимо при переборе (например,
при доступе к следующему элементу диапазона).
Особый алгоритм диапазонов будет представлен позже в разделе [D's Gems](gems/range-algorithms).

### Упражнение

Завершите исходный код, чтобы создать `FibonacciRange` диапазон,
который возвращает числа [Последовательности Фибоначчи](https://ru.wikipedia.org/wiki/Числа_Фибоначчи).
Не занимайтесь самообманом, удаляя `assert`ы!

### Подробнее

- [`std.algorithm`](http://dlang.org/phobos/std_algorithm.html)
- [`std.range`](http://dlang.org/phobos/std_range.html)

## {SourceCode:incomplete}

```d
import std.stdio;

struct FibonacciRange
{
    @property empty() const
    {
        // Итак, когда последовательность
        // Фибоначчи заканчивается?!
    }

    void popFront()
    {
    }

    int front()
    {
    }
}

void main() {
    import std.range: take;
    import std.array: array;

    FibonacciRange fib;

    // `take` создаёт другой диапазон, который
    // вернёт N элементов как максимум.
    // Этот диапазон является _ленивым_ и просто
    // затрагивает оригинальный диапазон, если
    // это действительно необходимо
    auto fib10 = take(fib, 10);

    // Но мы хотим потрогать все элементы и
    // конвертировать диапазон в массив целых
    // чисел.
    int[] the10Fibs = array(fib10);

    writeln("The 10 first Fibonacci numbers: ",
        the10Fibs);
    assert(the10Fibs ==
        [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
}
```

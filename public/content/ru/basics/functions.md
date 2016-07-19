# Функции

С одной функцией мы уже знакомы: `main()` - начальная точка каждой программы на
языке D. Функция может возвращать значение, либо быть объявленной с `void`, если
ничего возвращать не нужно, и принимать произвольное число аргументов:

    int add(int lhs, int rhs) {
        return lhs + rhs;
    }

### Возвращаемый тип `auto`

Если возвращаемый тип задан как `auto`, компилятор D выведет возвращаемый тип
автоматически. Следовательно, множественные операторы `return` должны возвращать
значения совместимых типов.

    // возвращает `int`
    auto add(int lhs, int rhs) {
        return lhs + rhs;
    }

    // возвращает `double`
    auto lessOrEqual(int lhs, int rhs) {
        if (lhs <= rhs)
            return 0;
        else
            return 1.0;
    }

### Аргументы по умолчанию

По желанию, функции могут задать аргументам значения, используемые по умолчанию.
Это позволяет избежать утомительного объявления избыточных перегрузок.

    void plot(string msg, string color = "red") {
        ...
    }
    plot("D rocks");
    plot("D rocks", "blue");

После того, как было задано значение для аргумента, все последующие аргументы
также должны содержать значения по умолчанию.

### Локальные функции

Функции могут быть объявлены даже внутри других функций, где они могут быть
использованы локально и будут недоступны извне. Эти функции даже могут иметь
доступ к родительской области видимости:

    void fun() {
        int local = 10;
        int fun_secret() {
            local++; // это допустимо
        }
        ...

Такие вложенные функции называются делегатами и более подробно они будут
рассмотрены [немного позже](basics/delegates).

### Подробнее

- [Functions in _Programming in D_](http://ddili.org/ders/d.en/functions.html)
- [Function parameters in _Programming in D_](http://ddili.org/ders/d.en/function_parameters.html)
- [Function specification](https://dlang.org/spec/function.html)

## {SourceCode}

```d
import std.stdio;
import std.random;

void randomCalculator()
{
    // Определение 4 локальных функций для
    // 4 различных математических операций
    auto add(int lhs, int rhs) {
        return lhs + rhs;
    }
    auto sub(int lhs, int rhs) {
        return lhs - rhs;
    }
    auto mul(int lhs, int rhs) {
        return lhs * rhs;
    }
    auto div(int lhs, int rhs) {
        return lhs / rhs;
    }

    int a = 10;
    int b = 5;

    // uniform генерирует число между START
    // и END, но НЕ включающий в себя END.
    // В зависимости от результата, мы вызываем
    // одну из математических операций.
    switch (uniform(0, 4)) {
        case 0:
            writeln(add(a, b));
            break;
        case 1:
            writeln(sub(a, b));
            break;
        case 2:
            writeln(mul(a, b));
            break;
        case 3:
            writeln(div(a, b));
            break;
        default:
            // специальный код, помечающий
            // НЕДОСТИЖИМЫЙ код
            assert(0);
    }
}

void main()
{
    randomCalculator();
    // add(), sub(), mul() and div()
    // НЕ видимы вне области их видимости
    static assert(!__traits(compiles,
                            add(1, 2)));
}

```

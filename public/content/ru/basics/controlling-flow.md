# Управление потоком

Ход выполнения приложения можно контролировать условно с помощью `if` и `else`
операторов:

    if (a == 5) {
        writeln("Condition is met");
    } else if (a > 10) {
        writeln("Another condition is met");
    } else {
        writeln("Nothing is met!");
    }

Когда блок `if` или `else` содержит только один оператор, фигурные скобки могут
быть опущены.

Для проверки равенства переменных и их сравнения, D предоставляет такие же
операторы, как и C/C++ и Java:

* `==` и `!=` для проверки равенства и неравенства
* `<`, `<=`, `>` и `>=` для проверки, что значение меньше (- или равно) или
больше (- или равно)

Для комбинирования множества условий, оператор `||` представляет логическое
*ИЛИ*, а `&&` логическое *И*.

Также D определяет оператор `switch`..`case`, который исполняет один case, в
зависимости от значения *одной* переменной. `switch` работает со всем основными
типами также хорошо, как и со строками! Для целочисленных типов также возможно
задавать диапазоны, используя синтаксис `case НАЧАЛО: .. case КОНЕЦ:`. Убедитесь
в том, что посмотрели пример исходного кода.

### Подробнее

#### Основные ссылки

- [Logical expressions in _Programming in D_](http://ddili.org/ders/d.en/logical_expressions.html)
- [If statement in _Programming in D_](http://ddili.org/ders/d.en/if.html)
- [Ternary expressions in _Programming in D_](http://ddili.org/ders/d.en/ternary.html)
- [`switch` and `case` in _Programming in D_](http://ddili.org/ders/d.en/switch_case.html)

#### Дополнительные ссылки

- [Expressions in detail](https://dlang.org/spec/expression.html)
- [If Statement specification](https://dlang.org/spec/statement.html#if-statement)

## {SourceCode}

```d
import std.stdio;

void main()
{
    if (1 == 1)
        writeln("You can trust math in D");

    int c = 5;
    switch(c) {
        case 0: .. case 9:
            writeln(c, " is within 0-9");
            break; // необходимо!
        case 10:
            writeln("A Ten!");
            break;
        default: // если ничего не совпало
            writeln("Nothing");
            break;
    }
}
```

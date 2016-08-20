# Основные типы

D предоставляет ряд основных типов, которые всегда имеют одинаковый размер,
**независимо** от платформы. Единственным исключением является тип `real`,
который предоставляет максимально возможную точность для чисел с плавающей
запятой. Также нет разницы в размере целого числа, было ли приложение
скомпилировано для 32-битных или 64-битных систем.

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">bool</code></td> <td>8 бит</td></tr>
<tr><td><code class="prettyprint">byte, ubyte, char</code></td> <td>8 бит</td></tr>
<tr><td><code class="prettyprint">short, ushort, wchar</code></td> <td>16 бит</td></tr>
<tr><td><code class="prettyprint">int, uint, dchar</code></td> <td>32 бита</td></tr>
<tr><td><code class="prettyprint">long, ulong</code></td> <td>64 бита</td></tr>
</table>

#### Типы с плавающей запятой:

<table class="table table-hover">
<tr><td width="250px"><code class="prettyprint">float</code></td> <td>32 бита</td></tr>
<tr><td><code class="prettyprint">double</code></td> <td>64 бита</td></tr>
<tr><td><code class="prettyprint">real</code></td> <td>Зависит от платформы, 80 бит на 32-битной Intel x86</td></tr>
</table>

Префикс `u` обозначает *unsigned* (беззнаковые) типы. `char` преобразует в UTF-8
символы, `wchar` используется для UTF-16 строк и `dchar` для UTF-32 строк.

Преобразование между переменными разного типа допускается компилятором только
если не будет потери точности. Хотя преобразование между числами с плавающей
запятой (например, `double` в `float`) допускается.

Преобразование в другой тип может быть выполнено принудительно с помощью
выражения `cast(ТИП) переменная`.

Специальное ключевое слово `auto` создаёт переменную и выводит её тип из правой
части выражения. `auto var = 7` переменной var будет присвоен тип `int`.
Обратите внимание, что типы по-прежнему устанавливаются во время компиляции и не
могут быть изменены - подобно любым другим переменным с явно указанным типом.

### Свойства типов

У всех типов есть свойство `.init`, которым они инициализируются. Для всех целых
типов это `0`, а для типов с плавающей запятой это `NaN` (*not a number*, не
число).

У целочисленных типов и типов с плавающей запятой есть свойства `.min` и `.max`,
показывающие наименьшее и наибольшее значения, которые могут быть представлены
этим типом. У типы с плавающей запятой имеются также свойства `.nan`
(NaN-значение), `.infinity` (бесконечное значение), `.dig` (количество
десятичных знаков, задающих точность), `.mant_dig` (число бит мантиссы) и
другие.

Каждый тип также имеет свойство `.stringof`, которое отдаёт имя типа в виде
строки.

### Индексы в D

В D индексы имеют обычный alias тип `size_t`, так как он достаточно большой,
чтобы представить смещение во всей адресуемой памяти - `uint` для 32-битной и
`ulong` для 64-битной архитектур.

`assert` это встроенное в компилятор выражение, которое в отладочном режиме
проверяет условие и прерывает выполнение с ошибкой `AssertionError`, если оно
не верно.

### Подробнее

#### Основные ссылки

- [Assignment](http://ddili.org/ders/d.en/assignment.html)
- [Variables](http://ddili.org/ders/d.en/variables.html)
- [Arithmetics](http://ddili.org/ders/d.en/arithmetic.html)
- [Floating Point](http://ddili.org/ders/d.en/floating_point.html)
- [Fundamental types in _Programming in D_](http://ddili.org/ders/d.en/types.html)

#### Дополнительные ссылки

- [Overview of all basic data types in D](https://dlang.org/spec/type.html)
- [`auto` and `typeof` in _Programming in D_](http://ddili.org/ders/d.en/auto_and_typeof.html)
- [Type properties](https://dlang.org/spec/property.html)

## {SourceCode}

```d
import std.stdio;

void main()
{
    // Большие числа могут быть разделены
    // подчёркиванием "_"
    // для улучшения читаемости.
    int b = 7_000_000;
    short c = cast(short) b; // требуется cast
    uint d = b; // отлично
    int g;
    assert(g == 0);

    auto f = 3.1415f; // .f обозначает тип float

    // typeid(VAR) возвращает информацию типа
    // заданного выражения.
    writeln("type of f is ", typeid(f));
    double pi = f; // отлично
    // для типов с плавающей запятой
    // допускается неявное понижающее приведение
    float demoted = pi;

    // доступ к свойствам типа
    assert(int.init == 0);
    assert(int.sizeof == 4);
    assert(bool.max == 1);
    writeln(int.min, " ", int.max);
    writeln(int.stringof); // int
}
```

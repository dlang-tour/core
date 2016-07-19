# Делегаты

### Функции как аргументы

Функция также может быть параметром другой функции:

    void doSomething(int function(int, int) doer) {
        // вызов переданной функции
        doer(5,5);
    }

    doSomething(add); // здесь используется
                      // глобальная функция 
                      // `add`, где суммирование
                      // должно иметь два
                      // параметра int

Затем `doer` может быть вызвана подобно любой другой обычной функции.

### Локальные функции с контекстом

Пример выше использует тип `function`, который является указателем на глобальную
функцию. При ссылках на функцию-член или локальную функцию, нужно использовать
делегаты (`delegate`). Это указатель на функцию, который дополнительно содержит
информацию об контексте, или *enclosure*, также называемое **closure**
(замыкание) в других языках. Например, `delegate`, указывающий на функцию-член
класса, также содержит указатель на объёкт класса. Локальный `delegate` содержит
ссылку на область видимости окружения, которое автоматически копируется в кучу D
компилятором.

    void foo() {
        void local() {
            writeln("local");
        }
        auto f = &local; // Тип f - delegate()
    }

Такая же функция `doSomething`, принимающая `delegate`, выглядела бы так:

    void doSomething(int delegate(int,int) doer);

Объекты `delegate` и `function`не могут быть смешаны. Но стандартная функция
[`std.functional.toDelegate`](https://dlang.org/phobos/std_functional.html#.toDelegate)
преобразует `function` в `delegate`.

### Анонимные функции и лямбды

Поскольку функции могут быть сохранены как переменные и переданы в другие
функции, будет утомительно давать им собственное имя и определять их. Поэтому
допускает безымянные функции и однострочные _лямбды_.

    auto f = (int lhs, int rhs) => lhs + rhs;
    // Лямбда - внутренне преобразовывается в
    // следующее:

    auto f = (int lhs, int rhs) {
        return lhs + rhs;
    };
    

Также возможно передавать строки как аргумент шаблона в функциональные части
стандартной библиотеки языка D. Например, они предлагают удобный способ
определения свёртки списка (folding, также известной как reducer):

    [1, 2, 3].reduce!`a + b`; // 6

Строковые функции возможны только для _одного или двух_ аргументов тогда
используется `a` как первый аргумент и `b` как второй аргумент.

### Подробнее

- [Delegate specification](https://dlang.org/spec/function.html#closures)

## {SourceCode}

```d
import std.stdio;

enum IntOps {
    add = 0,
    sub = 1,
    mul = 2,
    div = 3
}

/**
Обеспечивает математические вычисления
Параметры:
    op = выбранная математическая операция
Возвращает: делегат, который выполняет
математическую операцию
*/
auto getMathOperation(IntOps op)
{
    // Определяет 4 лямбда-функции для
    // 4 различных математических операций
    auto add = (int lhs, int rhs) => lhs + rhs;
    auto sub = (int lhs, int rhs) => lhs - rhs;
    auto mul = (int lhs, int rhs) => lhs * rhs;
    auto div = (int lhs, int rhs) => lhs / rhs;

    // мы можем убедиться, что switch охватывает
    // все случаи
    final switch (op) {
        case IntOps.add:
            return add;
        case IntOps.sub:
            return sub;
        case IntOps.mul:
            return mul;
        case IntOps.div:
            return div;
    }
}

void main()
{
    int a = 10;
    int b = 5;

    auto func = getMathOperation(IntOps.add);
    writeln("The type of func is ",
        typeof(func).stringof, "!");

    // запуск функции-делегата, который
    // выполняет для нас всю настоящую работу!
    writeln("result: ", func(a, b));
}
```

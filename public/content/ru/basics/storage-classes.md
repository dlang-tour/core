# Storage classes

D является статически типизированным языком: начиная с момента объявления
переменной, её тип не может быть изменен. Это позволяет компилятору
предотвращать ошибки на раннем этапе и обеспечивать соблюдение ограничений во
время компиляции. Хорошая типобезопасность обеспечивает вам необходимую
поддержку, чтобы сделать большие программы более безопасными и более лёгкими в
обслуживании.

### `immutable`

В дополнение к статической системе типов, D предоставляет классы для хранения
данных, обеспечивая соблюдение дополнительных ограничений на определённые
объекты. Например, `immutable` объект может быть только инициализирован однажды,
после чего любые изменения запрещены.

    immutable int err = 5;
    // либо:
    // immutable arr = 5; и int будет выведен.
    err = 5; // не скомпилируется

Таким образом, `immutable` объекты могут быть безопасно доступны из разных
потоков, так как они никогда не меняются, вследствие дизайна. Это означает, что
`immutable` объекты прекрасно кешируются.

### `const`

`const` объекты также не могут быть изменены. Это ограничение действительно
только для текущей области видимости. `const` указатель может быть создан как из
*mutable*, так и из `immutable` объекта. Это означает, что объект является
`const` для текщей области видимости, но кто-то ещё может изменить его в
будущем. Просто с `immutable` вы будете уверены, что значения объекта никогда не
будут изменены. Общепринято, что API принимают `const` объекты, для гарантии,
что они не изменяют входные данные..

    immutable a = 10;
    int b = 5;
    const int* pa = &a;
    const int* pb = &b;
    *pa = 7; // запрещено

И `immutable` и `const` _транзитивны_, обеспечивая, что если однажды `const`
было применено к типу, оно рекурсивно применяется к каждому субкомпоненту этого
типа.

### Подробнее

#### Основные ссылки

- [Immutable in _Programming in D_](http://ddili.org/ders/d.en/const_and_immutable.html)
- [Scopes in _Programming in D_](http://ddili.org/ders/d.en/name_space.html)

#### Дополнительные ссылки

- [const(FAQ)](https://dlang.org/const-faq.html)
- [Type qualifiers D](https://dlang.org/spec/const3.html)

## {SourceCode}

```d
import std.stdio;

void main()
{
    immutable forever = 100;
    // ERROR:
    // forever = 5;
    writeln("forever: ",
        typeof(forever).stringof);

    const int* cForever = &forever;
    // ERROR:
    // *cForever = 10;
    writeln("const* forever: ",
        typeof(cForever).stringof);

    int mutable = 100;
    writeln("mutable: ",
        typeof(mutable).stringof);
    mutable = 10; // Fine
    const int* cMutable = &mutable; // Fine
    // ERROR:
    // *cMutable = 100;
    writeln("cMutable: ",
        typeof(cMutable).stringof);

    // ERROR:
    // immutable int* imMutable = &mutable;
}
```

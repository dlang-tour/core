# Alias & Строки

Теперь, когда мы знаем, что из себя представляют массивы, узнали про `immutable`
и пробежались по основным типам, пришло время ввести две новые конструкции в
одной строке:

    alias string = immutable(char)[];

Понятие строка (`string`) задано как выражение `alias`, которое определяет его
как срез `immutable(char)`'ов. То есть, как только строка построена, её
содержимое никогда не может быть изменено. И на самом деле, это второе
вступление: добро пожаловать в UTF-8 `string`!

Из-за своей неизменности, строки могут быть прекрасно разделены между разными
потоками. Так как строки являются срезами, их части могут быть взяты без
дополнительного выделения памяти. Например, стандартная функция
`std.algorithm.splitter` разделяет строку на отдельные части без каких-либо
выделений памяти.

Помимо UTF-8 строк, есть ещё два типа:

    alias wstring = immutable(dchar)[]; // UTF-16
    alias dstring = immutable(wchar)[]; // UTF-32

Разные варианты проще всего преобразуются между собой с помощью метода `to`
из `std.conv`:

    dstring myDstring = to!dstring(myString);
    string myString   = to!string(myDstring);

Поскольку строки являются массивами, то к ним применимы те же самые действия.
Например, строки могут быть объединены с помощью оператора `~`. В не-ASCII
строках, символ может быть представлен несколькими байтами, из чего следует, что
свойство `.length` не отображает число символов в UTF (UCS Transformation
Format) строках. Поэтому для закодированных строк вместо свойства `.length`,
нужно использовать [`std.utf.count`](http://dlang.org/phobos/std_utf.html#.count).
Так как работа с UTF строками может быть утомительной, [`std.utf`](http://dlang.org/phobos/std_utf.html)
предоставляет вспомогательные методы, которые облегчают работу с закодированными
в UTF строками. Алгоритмы Unicode могут использовать [`std.uni`](http://dlang.org/phobos/std_uni.html).

Для создания многострочных строк, можно использовать синтаксис
`string str = q{ ... }`. Raw-строки, которые не требуют кропотливого
экранирования, можно объявить используя обратные апострофы (`` ` ... ` ``), либо
префикс r(aw) (`r" ... "`).

    string multiline = q{ This
        may be a
        long document
    };
    string raw  =  `raw "string"`;\\raw "string"
    string raw2 = r"raw "string"";\\raw "string"

### Подробнее

- [Символы в _Programming in D_](http://ddili.org/ders/d.en/characters.html)
- [Строки в _Programming in D_](http://ddili.org/ders/d.en/strings.html)
- [std.utf](http://dlang.org/phobos/std_utf.html) - UTF en-/decoding algorithms
- [std.uni](http://dlang.org/phobos/std_uni.html) - Unicode algorithms

## {SourceCode}

```d
import std.stdio;
import std.utf: count;
import std.string: format;

void main() {
    // format генерирует строку, используя
    // подобный printf синтаксис. D позволяет
    // нативную обработку UTF строк!
    string str = format("%s %s", "Hellö",
        "Wörld");
    writeln("My string: ", str);
    writeln("Array length of string: ",
        str.length);
    writeln("Character length of string: ",
        count(str));

    // Строки являются обычными массивами,
    // поэтому любые операции, применимые к
    // массивам, здесь также работают!
    import std.array: replace;
    writeln(replace(str, "lö", "lo"));
    import std.algorithm: endsWith;
    writefln("Does %s end with 'rld'? %s",
        str, endsWith(str, "rld"));

    import std.conv: to;
    // Преобразование в строку UTF-32
    dstring dstr = to!dstring(str);
    // .. которая, конечно же, выглядит так же!
    writeln("My dstring: ", dstr);
}
```

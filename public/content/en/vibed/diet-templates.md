# DIET Templates

To make writing web pages easier vibe.d supports
[DIET templates](https://vibed.org/templates/diet)
which is a simplified syntax to write HTML pages.
DIET is based on
[Jade templates](http://jade-lang.com/).

    doctype html
    html(lang="en")
      head
        // D code is evaluated
        title #{pageTitle}
        // attributes
        script(type='text/javascript')
          if (foo) bar(1 + 5)
        // ID = body-id
        // style = the-style
        body#body-id.the-style
          h1 DIET template

The syntax is indentation-aware and the closing
tags don't have to be inserted.

All DIET templates are compiled and are held
in memory for maximum performance.
DIET templates allows using D code which is evaluated
when rendering the page. Single expressions
are enclosed in `#{ 1 + 1 }` and can be used anywhere
in the template. Whole D code lines are
prefixed with `-` on their own line:

    - foreach(title; titles)
      h1 #{title}

Complex expressions can be used that way, and
even functions may be defined that are used to
output final HTML.

DIET templates are compiled using **CTFE**
and have to reside in the `views` folder
in a standard vibe.d project. To actually render
a DIET template use the `render` function within
an URL handler:

    void foo(HTTPServerResponse res) {
        string pageTitle = "Hello";
        int test = 10;
        res.render!("my-template.dt", pageTitle, test);
    }

All D variables available to a DIET template
are passed as template parameters to `render`.

## {SourceCode:disabled}

```d
doctype html
html
  head
    title D statement test
  body
    - import std.algorithm : min;
    p Four items ahead:
    - foreach( i; 0 .. 4 )
      - auto num = i+1;
      p Item
        b= num
    p Prints 8:
    p= min(10, 2*6, 8)
```

# Contributing

Welcome to the D community and thanks for your interest in contributing!

## Tour contents

The directory `public/content` contains the contents of the Dlang online tour.

### Structure

The folder structure is very simple:

	language1/
	    index.yml
		chapter1/
		    index.yml
		    section1.md
		    section2.md
		chapter2/
		    index.yml
		    section1.md
		.
		.
	language2/
		...

Each language folder contains chapters which in turn contain the individual
section files. The special `index.yml` files allow configuration of the content
like specifiying the title and the ordering of the individual sections and chapters.
A chapter is prominently shown in the navigation bar of the D tour.
A chapter consists of a number of sections where each section might
contain a source code subsection that will be used for the online code
editor. The content is written in standard *markdown*. The filename minus
the extension of each chaper denotes the internal chapter ID used
for constructing URLs.

Within the content source code examples can be inserted by indenting each line by **4 whitespaces**:

   writeln("hello");

_Make sure to also indent empty lines by 4 whitespaces otherwise two separate code
boxes will be rendered_. Code is automatically highlighted as D code.

The order of chapters in the table of contents is specified in `index.yml`. A new chapter
has to be added here otherwise the tour will throw an error at startup.

Each section should have a first level heading (`#`). A 2nd level section with title `{SourceCode}`
contains the source code of that section. Every section might contain as many
\>=3 level headings as needed (and useful). Source code is optional.

If a section contains source code that shouldn't be run
online (the Run button is not visible on that tour
page) mark the source code with a 2nd level title
`{SourceCode:disabled}` instead of just `{SourceCode}`.

If source code doesn't compile from the start and the user is
supposed to complete the example code, mark the source code
section title with `{SourceCode:incomplete}`. A sanity
check is implemented which automatically checks source code
examples for validity and those source code examples
are just ignored.

### Source Code formatting

* Source code examples should be indented with 4 spaces.
* To prevent dynamic word wrap of code examples on mobile
  devices make sure to have a line length for source code of 48
  characters.

### Writing style guide

* Use the _present_ tense (except for historic facts)
* Use a _neutral_ tone (No strong narrator = no first-person ("I", "we") nor second-person ("you"))
* Use a _formal_ style (No slang)
* Provide many references and links
* Pay attention to spelling

See also the [Wikipedia guide on writing better articles](https://en.wikipedia.org/wiki/Wikipedia:Writing_better_articles).

### Custom Mustache macros

The dlang tour allows to define custom macros which allow to generate
advanced HTML using the [Mustache](http://mustache.github.io/) template
engine. Mustache is very simple and allows replacing a variable
`{{foo}}` by some text. Note that the tour's markdown supports
HTML directly so it is possible to define mustache variables
using HTML.

The file `public/content/template.yml` stores the definition
of Mustache variables:

	variables:
		foo: bar
		bar: foo
	wrappers:
		test: <h1>{{content}}</h1>


There are two types of replacements implemented at the moment:

- **Variales**: simple text replacements which are defined in the `variables`
  section of `template.yml`. The tag `{{foo}}` will then be replace by _bar_.
- **Wrappers**: are what mustache calls _functions_. They are used
  as `{{#test}}hello{{/test}}` and the special tag `{{content}}`
  is replaced by the content located between the start and end tag. So the above
  would yield `<h1>hello</h1>`. Wrappers might contain other wrappers
  and variables.

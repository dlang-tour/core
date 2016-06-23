# Contributing

Welcome to the D community and thanks for your interest in contributing!

## Tour contents

This directory contains the contents of the Dlang online tour.

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
* Use a _formal_ (No slang)
* Provide many references and links
* Pay attention to spelling

See also the [Wikipedia guide on writing better articles](https://en.wikipedia.org/wiki/Wikipedia:Writing_better_articles).

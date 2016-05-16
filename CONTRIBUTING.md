# Contributing

Welcome to the D community and thanks for your interest in contributing!

## Tour contents

This directory contains the contents of the Dlang online tour.

### Structure

The folder structure is very simple:

	language1/
		chapter1.md
		chapter2.md
		.
		.
	language2/
		...

Each file in a language folder denotes a single chapter of the tour.
A chapter is prominently shown in the navigation bar of the D tour.
A chapter consists of a number of sections where each section might
contain a source code subsection that will be used for the online code
editor. The content is written in standard *markdown*. The filename minus
the extension of each chaper denotes the internal chapter ID used
for constructing URLs.

The order of chapters in the table of contents is determined by the ChapterOrdering
member of the class `ContentProvider` in `contentprovider.d`. A new chapter
has to be added here otherwise the tour will throw an error at startup.

The first section that is empty determines a chapter's overall title.

Each section should have a first level heading (`#`). Only one type of 2nd level heading (`##`)
is allowed, that with title `{SourceCode}`). This section
contains the source code of that section. Every section might contain as many
\>=3 level headings as needed (and useful).

If a section contains source code that shouldn't be run
online (the Run button is not visible on that tour
page) mark the source code with a 2nd level title
`{SourceCode:disabled}` instead of just `{SourceCode}`.

### Source Code formatting

* Source code examples should be indented with 4 spaces.
* To prevent dynamic word wrap of code examples on mobile
  devices make sure to have a line length for source code of 48
  characters.

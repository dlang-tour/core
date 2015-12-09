# Tour contents

This directory contains the contents of the Dlang online tour.

## Structure

The folder structure is very simple:

	language1/
		chapter1.md
		chapter2.md
		.
		.
	language2/
		...

Each file in a language folder denotes a single Chapter of the tour.
A chapter is prominently shown in the navigation bar of the D tour.
A chapter consists of a number of sections where each section might
contain a source code subsection that will be used for the online code
editor. The content is written in standard *markdown*. The filename minus
the extension of each chaper denotes the internal chapter ID used
for constructing URLs.

The order of chapters in the table of contens is determined by the ChapterOrdering
member of the class `ContentProvier` in `contentprovider.d`. A new chapter
has to be added here otherwise the tour will throw an error at startup.

The first section that is empty determines a chapter's overall title.

Each section should have a first level heading (`#`). Only one type of subsection
is allowed: that of 2nd level (`##`) with title `{SourceCode}`). This section
contains the source code of that section.

Source code examples should be indented with 4 spaces.

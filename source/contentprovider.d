import vibe.d;

import std.typecons;
import std.file;
import std.string;
import std.algorithm;
import std.array;
import std.conv;
import std.typecons;
import std.exception;

/++
	Manages the mark down files found in public/content
	and holds them as prepared logical structures that
	contain the associated source code as well as
	the rendered HTML for output on the online tour.
+/
class ContentProvider
{
	private immutable MarkdownExtension = "md";
	private immutable SourceCodeSectionTitle ="{SourceCode}";
	/// Determines ordering of chapters as displayed
	/// in TOC
	private immutable ChapterOrdering = [
		"welcome",
		"basics",
		"gems",
		"concurrency",
		"vibed",
	];

	private {
		struct Content {
			string sourceCode;
			string html;
			string title;
		}

		/// language, chapter, section
		Content[int][string][string] content_;
		/// overall chapter title indexed by language and internal chapter name
		string[string][string] chapterTitle_;
	}


	/// Create or update Content structure
	private Content* updateContent(string language, string chapter, int section)
	{
		Content* content;
		if (auto l = language in content_) {
			if (auto c = chapter in *l) {
				content = section in *c;
			}
		}
		if (!content) {
			content_[language][chapter][section] = Content();
			content = &content_[language][chapter][section];
		}
		return content;
	}

	this(string contentDirectory)
	{
		foreach(string filename; dirEntries(contentDirectory, SpanMode.depth)) {
			if (isDir(filename))
				continue;
			auto parts = filename[contentDirectory.length .. $]
					.split('/').filter!(x => !x.empty)
					.array;
			logInfo("Found content file '%s'", parts);

			// ignore README's and hidden files
			if (parts[$ - 1] == "README.md" || parts[$ - 1][0] == '.')
				continue;
			enforce(parts.length == 2,
					new Exception("Content has wrong structure (language/chapter.md): %s".format(filename)));

			auto chapterFile = parts[1].split('.');
			enforce(chapterFile.length == 2 && chapterFile[1] == MarkdownExtension,
				new Exception("Chapter file invalid: %s".format(parts[1])));

			auto language = parts[0], chapter = chapterFile[0];
			auto currentSection = 0;
			foreach (ref section; splitMarkdownBySection(readText(filename))) {
				if (section.title == SourceCodeSectionTitle) {
					enforce(section.level == 2, new Exception("%s: %s section expected to be on 2nd level"
								.format(filename, SourceCodeSectionTitle)));
					auto content = updateContent(language, chapter, currentSection);
					enforce(!content.html.empty, new Exception("%s: %s section must be within existing section."
								.format(filename, SourceCodeSectionTitle)));
					enforce(content.sourceCode.empty, new Exception("%s: Double %s section in '%s'"
								.format(filename, SourceCodeSectionTitle, content.title)));
					content.sourceCode = section.bodyOnly;
				} else if (section.level == 1) {
					if (section.bodyOnly.empty) {
						enforce(null is (language in chapterTitle_) || null is (chapter in chapterTitle_[language]),
								new Exception("%s: Just one empty chapter title allowed: %s".format(filename, section.title)));
						chapterTitle_[language][chapter] = section.title;
					} else {
						auto content = updateContent(language, chapter, ++currentSection);
						content.title = section.title;
						content.html = vibe.textfilter.markdown.filterMarkdown(section.content,
							MarkdownFlags.backtickCodeBlocks | MarkdownFlags.vanillaMarkdown);
					}
				} else if (section.level >= 3) {
					enforce(currentSection != 0, new Exception("%s: level 3 section can't be first (%s)".format(filename, section.title)));
					auto content = updateContent(language, chapter, currentSection);
					content.html ~= vibe.textfilter.markdown.filterMarkdown(section.content,
							MarkdownFlags.backtickCodeBlocks | MarkdownFlags.vanillaMarkdown);
				} else {
					throw new Exception("%s: Illegal section %s".format(filename, section.title));
				}
			}
		}
	}

	/++
		Returns: result object with
		- $(D content) pointer if found
		- $(D sectionCount)
	+/
	auto getContent(string language, string chapter, int section)
	{
		struct Result {
			Content* content;
			ulong sectionCount;
		}

		Result res;

		if (auto l = language in content_) {
			if (auto c = chapter in *l) {
				if (null != (res.content = section in *c)) {
					res.sectionCount = c.length;
				}
			}
		}

		return res;
	}

	/++
		Returns logical structure of chapters and sections. Ordering definied in ContentProvider
		is adhered to.

		Returns:
		The following array of objects is returned:
		[] {
			string title;
			string chapterId;
			[] {
				string title;
				int section;
			} sections;
		}
	+/
	auto getTOC(string language) const
	{
		auto chapterTitles = language in chapterTitle_;
		enforce(chapterTitles !is null, new Exception("%s not known.".format(language)));
		enforce(ChapterOrdering.length == content_[language].length,
				new Exception("Chapter ordering doesn't match chapters on disk!"));

		struct Chapter {
			string title;
			string chapterId;
			Tuple!(string, "title", int, "sectionId")[] sections;
		}
		
		auto toc = new Chapter[content_[language].length];
		
		foreach (chapterId, sections; content_[language]) {
			auto idx = ChapterOrdering.countUntil(chapterId);
			enforce(idx != -1, new Exception("%s chapter not in included in ordering.".format(chapterId)));
			auto chapter = &toc[idx];
			chapter.chapterId = chapterId;
			chapter.title = (*chapterTitles)[chapterId];
			chapter.sections.length = sections.length;
			foreach(sectionIdx, ref content; sections) {
				auto section = &chapter.sections[sectionIdx - 1];
				section.title = content.title;
				section.sectionId = sectionIdx;
			}
		}

		return toc;
	}

	string[] getLanguages() const
	{
		return content_.byKey().array;
	}

} // class ContentProvider

/++
	Splits markdown file by sections.
	
	Returns: an array which contains information objects
	for each section with the following properties:
		- string content: the full mark down content of the section (will be stripped)
		- string bodyOnly: just the body of section (will be stripped)
		- string title: the parsed title of the section
		- int level: level of section starting at 1
+/
private auto splitMarkdownBySection(string contents)
{
	alias Section = Tuple!(string, "content", string, "bodyOnly", string, "title",
			int, "level", immutable(char)*, "_contentStart", immutable(char)*, "_bodyOnlyStart");

	Section[] sections;

	if (contents.empty)
		return sections;

	void fillSection(immutable(char)* nextStart) {
		if (sections.empty)
			return;
		// calculate the correct slice length based upon
		// the start pointer of the next section
		auto lastsec = &sections[$-1];
		assert(lastsec.content.ptr < nextStart);
		lastsec.content = lastsec._contentStart[0 .. nextStart - lastsec._contentStart].strip();
		assert(lastsec.bodyOnly.ptr <= nextStart);
		lastsec.bodyOnly = lastsec._bodyOnlyStart[0 .. nextStart - lastsec._bodyOnlyStart].strip();
	}

	// Assuming lineSplitter just operates on the data pointer at
	// contents we can use pointer magic to calculate the section
	// extensions
	foreach(line; lineSplitter(contents)) {
		if (line.empty)
			continue;
		if (line[0] == '#') {
			fillSection(&line[0]);
			sections ~= Section();
			auto lastsec = &sections[$-1];
			auto level = 1 + cast(int)line[1 .. $].countUntil!"a != b"('#');
			lastsec.level = level;
			lastsec.title = line[level .. $].strip();
			// set start pointers of content and bodyOnly tags which
			// will be completed by fillSection later on.
			lastsec._contentStart = &line[0];
			lastsec._bodyOnlyStart = line.ptr + line.length;
		}
	}
	// fill last remaining section
	// with contents' end pointer
	fillSection(contents.ptr + contents.length);

	return sections;
}

/// Unittest for splitMarkdownBySection
unittest
{
	assert(splitMarkdownBySection("").length == 0);

	string markdown = q{
#Hello World

This is a test!

## 2nd level
### 3rd level

My third level text.
# First level

Hello

## Guten Tag};

	auto sections = splitMarkdownBySection(markdown);
	assert(sections.length == 5, "%s".format(sections));
	assert(sections[0].title == "Hello World");
	assert(sections[0].level == 1);
	assert(sections[1].title == "2nd level");
	assert(sections[1].level == 2);
	assert(sections[1].bodyOnly.empty);
	assert(sections[2].title == "3rd level");
	assert(sections[2].level == 3);
	assert(sections[3].title == "First level");
	assert(sections[3].level == 1);
	assert(sections[4].title == "Guten Tag");
	assert(sections[4].level == 2);
	assert(sections[4].bodyOnly.empty);
}



import vibe.core.log: logInfo;
import vibe.textfilter.markdown;

import std.file;
import std.algorithm: splitter, filter, countUntil;
import std.array: array, empty;
import std.string: split, strip;
import std.typecons: Tuple;
import std.exception: enforce;
import std.string: format;
import std.path: buildPath;

import yaml;
import mustache;

alias MustacheEngine!(string) Mustache;

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
	private immutable SourceCodeDisabledSectionTitle =
		"{SourceCode:disabled}";
	private immutable SourceCodeIncompleteSectionTitle =
		"{SourceCode:incomplete}";
	private immutable SourceCodeMaxCharsPerLine = 48;

	private {
		/// root content directory
		string contentDirectory;

		struct Content {
			string sourceCode;
			bool sourceCodeEnabled = true;
			bool sourceCodeIncomplete = false;
			///< flag whether the source code is supposed NOT to compile (false);
			/// true otherwise (the default)
			string html;
			string title;
			string language;
			size_t _id;
		}

		/// language, chapter, section
		Content[string][string][string] content_;

		struct ChapterMeta {
			size_t id;
			string title;
		}
		/// chapter ordering: language, chapter
		ChapterMeta[string][string] chapter_;

		struct ChapterAndSection {
			string chapter;
			string section;
			this(string s)
			{
				auto arr = s.split("/");
				enforce(arr.length == 2, "Invalid start page given");
				chapter = arr[0];
				section = arr[1];
			}
		}
		struct LanguageMeta {
			ChapterAndSection start;
			string title;
		}
		/// general language-wide information
		LanguageMeta[string] language_;

		auto mustacheContext_ = new Mustache.Context;
	}

	/// Create or update Content structure
	private Content* updateContent(string language, string chapter, string section)
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
			content.language = language;
		}
		return content;
	}

	private bool isValidLink(string link, string language)
	{
		import std.algorithm.searching : count;
		if (link.count("/") != 1)
			return false;

		// check for existence in file system
		import std.array : split;
		auto parts = link.split("/");
		string fileName = buildPath(contentDirectory, language, parts[0], parts[1] ~ ".md");
		import std.stdio;
		return exists(fileName);
	}

	this(string contentDirectory)
	{
		this.contentDirectory = contentDirectory;
		// parse mustache template file
		setupMustacheMacros(readText(buildPath(contentDirectory, "template.yml")),
			mustacheContext_);
		foreach(string filename; dirEntries(contentDirectory, SpanMode.depth)) {
			if (isDir(filename))
				continue;
			auto parts = filename[contentDirectory.length .. $]
					.split('/').filter!(x => !x.empty)
					.array;

			// ignore any top level files
			if (parts.length == 1) {
				continue;
			}

			// search for language-specific root file
			auto language = parts[0];
			if (parts[1] != "index.yml")
				continue;
			auto root = Loader(filename).load();

			// language meta information
			enforce("start" in root, "'start' point required in language-specific yaml");
			enforce(isValidLink(root["start"].as!string, language), "The start page must be formatted as chapter/section");

			enforce("title" in root, "'title' point required in language-specific yaml");
			language_[language] = LanguageMeta(ChapterAndSection(root["start"].as!string), root["title"].as!string);

		    auto i = 0;
			foreach (string chapter; root["ordering"])
			{
				auto chapterDir = buildPath(filename[0 .. contentDirectory.length],
					language, chapter);
				chapter_[language][chapter] = ChapterMeta(i++, "");
				addChapter(chapter, chapterDir, language);
			}
		}
	}

	private void addChapter(string chapter, string chapterDir, string language)
	{
		auto configFile = buildPath(chapterDir, "index.yml");
		auto root = Loader(configFile).load();
		// TODO: add title
		enforce("title" in root, "title required for chapter");
		chapter_[language][chapter].title = root["title"].as!string;

		auto i = 0;
		foreach (string section; root["ordering"])
		{
			auto filename = buildPath(chapterDir, section ~ ".md");
			Content* content = addSection(filename, chapter, section, language);
			content._id = i++;
		}
	}

	private Content* addSection(string filename, string chapter, string currentSection, string language)
	{
		Content* content = updateContent(language, chapter, currentSection);
		enforce(exists(filename), "couldn't find " ~ filename);
		foreach (ref section; splitMarkdownBySection(readText(filename))) {
			if (section.title == SourceCodeSectionTitle ||
				section.title == SourceCodeDisabledSectionTitle ||
				section.title == SourceCodeIncompleteSectionTitle) {
				enforce(section.level == 2, new Exception("%s: %s section expected to be on 2nd level"
							.format(filename, SourceCodeSectionTitle)));
				enforce(!content.html.empty, new Exception("%s: %s section must be within existing section."
							.format(filename, SourceCodeSectionTitle)));
				enforce(content.sourceCode.empty, new Exception("%s: Double %s section in '%s'"
							.format(filename, SourceCodeSectionTitle, content.title)));
				content.sourceCode = section.bodyOnly;
				// ignore markdown code blocks
				if (content.sourceCode[0..3] == "```")
				{
                    // allow additional code language specifiers
					auto startPos = content.sourceCode.countUntil("\n");
					assert(content.sourceCode.length > 10, "source code file too small");
	                // remove three first and last backticks
					content.sourceCode = content.sourceCode[startPos + 1 .. $ - 4];
				}
				content.sourceCodeEnabled = section.title != SourceCodeDisabledSectionTitle;
				content.sourceCodeIncomplete = section.title == SourceCodeIncompleteSectionTitle;
				checkSourceCodeLineWidth(content.sourceCode, content.title);
			} else if (section.level == 1) {
					enforce(content.title.length == 0,
							new Exception("%s: Just one chapter title allowed: %s".format(filename, section.title)));
					content.title = section.title;
					content.html = processMarkdown(section.content, language);
			} else if (section.level >= 2) {
				enforce(content.title.length != 0, new Exception("%s: level 3 section can't be first (%s)".format(filename, section.title)));
				content.html ~= processMarkdown(section.content, language);
			} else {
				throw new Exception("%s: Illegal section %s".format(filename, section.title));
			}
		}
		return content;
	}



	/++
		Parses the given markdown and adds content filters

		Returns:
			Processed markdown in form of HTML
	+/
	private string processMarkdown(string content, string language)
	{
		auto processed = expandMacros(content, mustacheContext_);
		auto settings = new MarkdownSettings;
		settings.flags = MarkdownFlags.backtickCodeBlocks | MarkdownFlags.vanillaMarkdown;
		settings.urlFilter = (string link, bool) {
			import std.algorithm.searching : startsWith;
			if (link.startsWith("http") || link.startsWith("https") || link.startsWith("irc") || link[0] != '/')
				return link;
			else
			{
				enforce(isValidLink(link, language), "Invalid link given: " ~ link);
				return "/tour/%s/%s".format(language, link);
			}
		};
		return filterMarkdown(processed, settings);
	}

	/++
		Checks whether the provided source code adheres
		to the SourceCodeMaxCharsPerLine bytes per lines
		restriction.

		Throws: Exception when contraint doesn't apply.
	+/
	private void checkSourceCodeLineWidth(string sourceCode, string sectionTitle)
	{
		import std.algorithm: all;
		import std.range.primitives : walkLength;
		import std.uni : byGrapheme;
		auto lineNo = 0;
		foreach (line; splitter(sourceCode, '\n')) {
			++lineNo;
			if (line.byGrapheme.walkLength(SourceCodeMaxCharsPerLine + 1) > SourceCodeMaxCharsPerLine) {
				throw new Exception("Source code line length exceeds %d limit in '%s': %s"
						.format(SourceCodeMaxCharsPerLine, sectionTitle, line));
			}
		}
	}

	/++
		Returns: result object with
		- $(D content) pointer if found
		- $(D sectionCount)
	+/
	auto getContent(string language, string chapter, string section)
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
		Returns logical structure of chapters and sections. Ordering defined in ContentProvider
		is adhered to.

		Returns:
		The following array of objects is returned:
		[] {
			string title;
			string chapterId;
			[] {
				string title;
				int sectionId;
			} sections;
		}
	+/
	auto getTOC(string language) const
	{
		struct Chapter {
			string title;
			string chapterId;
			Tuple!(string, "title", string, "sectionId")[] sections;
		}
		auto chapterMeta = language in chapter_;
		enforce(chapterMeta !is null, new Exception("%s not known.".format(language)));
		Chapter[] toc = new Chapter[content_[language].length];

		foreach (chapterId, sections; content_[language]) {
			Chapter* chapter = &toc[(*chapterMeta)[chapterId].id];
			chapter.chapterId = chapterId;
			chapter.title = (*chapterMeta)[chapterId].title;
			chapter.sections.length = sections.length;
			foreach(sectionIdx, ref content; sections) {
				auto section = &chapter.sections[content._id];
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

	/++
	Returns: range that allows iterating
	  over the whole content, regardless of language. Content
	  doesn't guarantee any order.
	+/
	LanguageMeta getMeta(string language) const
	{
		enforce(language in language_, "Invalid language");
		return language_[language];
	}

	/++
	Returns: range that allows iterating
	  over the whole content, regardless of language. Content
	  doesn't guarantee any order.
	+/
	auto getContent() const
	{
		alias Element = const(Content)*;
		Element[] range;
		foreach(ref chapters; content_) {
			foreach(ref sections; chapters) {
				foreach(ref content; sections) {
					range ~= &content;
				}
			}
		}
		return range;
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
	foreach(line; splitter(contents, '\n')) {
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


/++
	Process all mustache definitions that are defined in the YAML
	declaration in $(D ymlDescription)

	The file must have the following format:
	``
	variables:
		var1: "hello world"
	functions:
		func1: |
			<h1>{{content}}</h1>
	``

	Variables are one by one replacements of the given
	text. Functions have a pre-defined variable {{content}}
	that is replaced by the contents of that macro block.

	The mustache replacements follow the standard
	mustache patterns.
+/
private void setupMustacheMacros(string ymlDescription, Mustache.Context context)
{
	auto reserved =  [ "content": 1 ];

	auto root = Loader.fromString(cast(char[])ymlDescription.dup).load();
	if ("variables" in root) {
		foreach (string tag, string content; root["variables"]) {
			enforce(tag !in reserved, "tag '" ~ tag ~ "' is reserved as a variable name");
			context[tag] = content;
		}
	}
	if ("wrappers" in root) {
		foreach (string tag, string content; root["wrappers"]) {
			enforce(tag !in reserved, "tag '" ~ tag ~ "' is reserved as a wrapper name");
			context[tag] = (string inner) {
				Mustache mustache;
				context["content"] = inner;
				return mustache.renderString(content, context);
			};
		}
	}
}

/++
	Processes the passed $(D content) using the mustache
	template engine.

	See $(D setupMustacheMacros) for description of the required
	format and the possibilites used here for text replacement.
+/
private string expandMacros(string content, Mustache.Context context)
{
	Mustache.Option options;
	options.handler = (string tag) {
		throw new Exception("Unknown template tag " ~ tag);
	};
	auto mustache = Mustache(options);
	return mustache.renderString(content, context);
}

unittest
{
	Mustache mustache;

	// test case 0 (must throw)
	{
		auto context = new Mustache.Context;
		try {
			expandMacros("{{unknown}}", context);
			assert(false, "Unknown tag was ignored.");
		}
		catch (Exception) {
			assert(true);
		}
	}

	// test case 1 (variables)
	{
		string description = q{
variables:
    test: "test 123"
};


		auto context = new Mustache.Context;
		setupMustacheMacros(description, context);
		auto expand = expandMacros("{{test}}", context);
		assert(expand == "test 123", "test case 1 failure: '" ~ expand ~ "'");
	}

	// test case 2 (variables)
	{
		string description = q{
variables:
   one: hello
   two: world
};

		auto context = new Mustache.Context;
		setupMustacheMacros(description, context);
		auto expand = expandMacros("{{one}} {{two}}", context);
		assert(expand == "hello world", "test case 2 failure: '" ~ expand ~ "'");
	}

	// test case 3 (wrappers)
	{
		string description = q{
wrappers:
   wrap: "<h1>{{content}}</h1>"
};

		auto context = new Mustache.Context;
		setupMustacheMacros(description, context);
		auto expand = expandMacros("{{#wrap}}hello{{/wrap}}", context);
		assert(expand == "<h1>hello</h1>", "test case 3 failure: '" ~ expand ~ "'");
	}

	// test case 4 (wrappers)
	{
		string description = q{
variables:
   test: hello
wrappers:
   complex: |
      <div>
      {{test}} {{content}}
      </div>
};

		auto context = new Mustache.Context;
		setupMustacheMacros(description, context);
		auto expand = expandMacros("{{#complex}}world{{/complex}}", context);
		assert(expand == "<div>\nhello world\n</div>\n", "test case 4 failure: '" ~ expand ~ "'");
	}
}


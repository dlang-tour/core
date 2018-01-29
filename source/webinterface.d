import vibe.d;

import std.algorithm: countUntil;
import std.string: format;
import std.traits: ReturnType;
import std.typecons: Tuple;

import contentprovider;

/++
	Main entry point for user visible content
+/
class WebInterface
{
	private {
		ContentProvider contentProvider_;
		alias Toc = ReturnType!(ContentProvider.getTOC);
		Toc[string] toc_;
		alias DeltaSection = ReturnType!deltaSection;
		alias LinkCache = Tuple!(DeltaSection, "previousSection",
			DeltaSection, "nextSection");
		LinkCache[string][string][string] sectionLinkCache_;
			///< language, chapter and section indexing
		string googleAnalyticsId_; ///< ID for google analytics
		string defaultLang = "en";
	}

	this(ContentProvider contentProvider,
		string googleAnalyticsId, string defaultLang)
	{
		this.contentProvider_ = contentProvider;
		this.googleAnalyticsId_ = googleAnalyticsId;
		this.defaultLang = defaultLang;

		// Fetch all table-of-contents for all supported
		// languages (just 'en' for now) and generate
		// the previous/next link cache for each tour page.
		foreach(lang; contentProvider.getLanguages()) {
			auto toc = toc_[lang] = contentProvider_.getTOC(lang);
			foreach(ref chapter; toc) {
				foreach(ref section; chapter.sections) {
					sectionLinkCache_[lang][chapter.chapterId][section.sectionId] =
						LinkCache(
							previousSection(toc, lang, chapter.chapterId, section.sectionId),
							nextSection(toc, lang, chapter.chapterId, section.sectionId));
				}
			}
		}
	}

	private {
		/++
			Returns the information about the next or previous section (depending on
			$(D move)) of the current position. Handles overflow to next or
			previous chapter acccordingly. An empty string mean "dead-end".

			Parameters:
			$(D move) either +1 or -1.
			$(D chapter) and $(D section) specify current positon.

			Returns: struct witht the following information:
			{
				string link; // empty if none
				string title;
			}
		+/
		static auto deltaSection(ref Toc toc, string language, string chapter,
			string section, int move) pure
		{
			alias R = Tuple!(string, "link", string, "title");
			auto chapterIdx = toc.countUntil!"a.chapterId == b"(chapter);
			if (chapterIdx == -1)
				return R("", "");

			auto sectionIdx = toc[chapterIdx].sections.countUntil!"a.sectionId == b"(section);
			if (sectionIdx == -1)
				return R("", "");

			sectionIdx += move;
			if (sectionIdx < 0) {
				if (--chapterIdx >= 0)
					sectionIdx = toc[chapterIdx].sections.length - 1;
				else
					return R("", "");
			} else if (sectionIdx >= toc[chapterIdx].sections.length) {
				if (++chapterIdx < toc.length)
					sectionIdx = 0;
				else
					return R("", "");
			}

			auto sec = toc[chapterIdx].sections[sectionIdx];

			return R("/tour/%s/%s/%s".format(
						language,
						toc[chapterIdx].chapterId,
						sec.sectionId),
						sec.title);
		}

		auto previousSection(ref Toc toc, string language, string chapter, string section) pure {
			return deltaSection(toc, language, chapter, section, -1);
		}
		auto nextSection(ref Toc toc, string language, string chapter, string section) pure {
			return deltaSection(toc, language, chapter, section, +1);
		}
	}

	void index(HTTPServerRequest req, HTTPServerResponse res)
	{
		// support "standalone" mode of the editor
		if (req.host == "run.dlang.io")
			getEditor(req, res);
		else
			getStart(req, res, defaultLang);
	}

	@path("/tour/:language")
	void getStart(HTTPServerRequest req, HTTPServerResponse res, string _language)
	{
		auto startPoint = contentProvider_.getMeta(_language).start;
		getTour(req, res, _language, startPoint.chapter, startPoint.section);
	}

	/+
		Returns: tuple containing .tourData and .linkCache
		for specified chapter and section.
	+/
	private auto getTourDataAndValidate(string language, string chapter, string section)
	{
		auto _tourData = contentProvider_.getContent(language, chapter, section);
		if (_tourData.content == null) {
			throw new HTTPStatusException(404,
				"Couldn't find tour data for chapter '%s', section %s".format(chapter, section));
		}
		enforce(language in sectionLinkCache_, "Language not found");
		auto _linkCache = &sectionLinkCache_[language][chapter][section];

		struct Ret {
			typeof(_tourData) tourData;
			typeof(_linkCache) linkCache;
		}

		return Ret(_tourData, _linkCache);
	}

	@path("/tour/:language/:chapter/:section")
	void getTour(HTTPServerRequest req, HTTPServerResponse res, string _language, string _chapter, string _section)
	{
		auto language = _language;
		auto sec = getTourDataAndValidate(_language, _chapter, _section);
		auto htmlContent = sec.tourData.content.html;
		auto chapterId = _chapter;
		auto hasSourceCode = !sec.tourData.content.sourceCode.empty;
		auto sourceCodeEnabled = hasSourceCode && sec.tourData.content.sourceCodeEnabled;
		auto section = _section;
		auto sectionId =  sec.tourData.content._id;
		auto sectionCount = sec.tourData.sectionCount;
		auto toc = toc_[_language];
		auto previousSection = sec.linkCache.previousSection;
		auto nextSection = sec.linkCache.nextSection;
		auto googleAnalyticsId = googleAnalyticsId_;
		auto title = sec.tourData.content.title ~ " - " ~ contentProvider_.getMeta(_language).title;
		auto meta = contentProvider_.getMeta(_language);
		auto githubRepo = meta.repo;
		auto translations = meta.translator;
		const name = "DLang Tour";
		const topHelpLink = "https://github.com/dlang-tour/core/issues/new";
		render!("tour.dt", htmlContent, language, section, sectionId,
				sectionCount, chapterId, hasSourceCode, sourceCodeEnabled,
				nextSection, previousSection, googleAnalyticsId,
				toc, title, githubRepo, translations, name, topHelpLink)();
	}

	private static auto buildDlangToc()
	{
		import std.typecons : Flag;
		alias HasDivider = Flag!"hasDivider";
		static struct TocSection
		{
			string title;
			string url;
			HasDivider hasDivider;
		}
		struct TocChapter
		{
			string title;
			TocSection[] sections;
			string url;
			string chapterId = "not-selected-stub";
		}

		TocChapter documentation = {
			title: "Documentation",
			sections: [
				TocSection("Language Reference", "https://dlang.org/spec/spec.html"),
				TocSection("Library Reference", "https://dlang.org/phobos/index.html"),
				TocSection("Command-line Reference", "https://dlang.org/dmd.html"),
				TocSection("Feature Overview", "https://dlang.org/comparison.html", HasDivider.yes),
				TocSection("Articles", "https://dlang.org/articles.html"),
			]
		};
		TocChapter downloads = {
			title: "Downloads",
			url: "https://dlang.org/download.html"
		};
		TocChapter packages = {
			title: "Packages",
			url: "https://code.dlang.org"
		};
		TocChapter community = {
			title: "Community",
			sections: [
				TocSection("Blog", "https://dlang.org/blog"),
				TocSection("Orgs using D", "https://dlang.org/orgs-using-d.html"),
				TocSection("Twitter", "https://twitter.com/search?q=%23dlang"),
				TocSection("Forums", "https://forum.dlang.org", HasDivider.yes),
				TocSection("IRC", "irc://irc.freenode.net/d"),
				TocSection("Wiki", "https://wiki.dlang.org"),
				TocSection("GitHub", "https://github.com/dlang", HasDivider.yes),
				TocSection("Issues", "https://dlang.org/bugstats.php"),
				TocSection("Foundation", "https://dlang.org/foundation.html", HasDivider.yes),
				TocSection("Donate", "https://dlang.org/donate.html"),
			]
		};
		TocChapter resources = {
			title: "Resources",
			sections: [
				TocSection("Books", "https://wiki.dlang.org/Books"),
				TocSection("Tutorials", "https://wiki.dlang.org/Tutorials"),
				TocSection("Tools", "https://wiki.dlang.org/Development_tools", HasDivider.yes),
				TocSection("Editors", "https://wiki.dlang.org/Editors"),
				TocSection("IDEs", "https://wiki.dlang.org/IDEs"),
				TocSection("VisualD", "http://rainers.github.io/visuald/visuald/StartPage.html"),
				TocSection("Acknowledgments", "https://dlang.org/acknowledgements.html", HasDivider.yes),
				TocSection("D Style", "https://dlang.org/dstyle.html"),
				TocSection("Glossary", "https://dlang.org/glossary.html"),
				TocSection("Sitemap", "https://dlang.org/sitemap.html"),
			]
		};
		return [
			documentation,
			downloads,
			packages,
			community,
			resources,
		];
	}

	@path("/editor")
	void getEditor(HTTPServerRequest req, HTTPServerResponse res)
	{
		import std.base64;
		string sourceCode;
		if (auto s = "source" in req.query) {
			sourceCode = Base64.encode(cast(ubyte[]) *s);
		} else if (auto s = "b64source" in req.query) {
			sourceCode = *s;
		} else {
			auto sourceCodeRaw = "import std.stdio;\nvoid main()\n{\n    writeln(\"Hello D\");\n}";
			sourceCode = Base64.encode(cast(ubyte[]) sourceCodeRaw);
		}
		auto googleAnalyticsId = googleAnalyticsId_;
        showEditor(sourceCode);
	}

	@path("/gist/:gist")
	void getGist(string _gist)
	{
	    getGist("anonymous", _gist);
	}

	@path("/gist/:user/:gist")
	void getGist(string _user, string _gist)
	{
	    import std.stdio;
		import std.base64;
	    auto sourceCode = requestHTTP("https://gist.githubusercontent.com/%s/%s/raw".format(_user, _gist))
	                .bodyReader
	                .readAllUTF8;
        showEditor(Base64.encode(sourceCode.representation));
	}

	void showEditor(string sourceCode) {
	    string googleAnalyticsId = googleAnalyticsId_;
		const title = "Editor";
		const chapterId = "";
		const language = "en";
		const name = "run.dlang.io";
		static immutable toc = buildDlangToc();
		string topHelpLink = "https://github.com/dlang-tour/core/wiki/run.dlang.io";
		render!("editor.dt", googleAnalyticsId, title, toc, chapterId, language, sourceCode, name, topHelpLink)();
	}

	@path("/is/:id")
	void getEditor(string _id, HTTPServerRequest req, HTTPServerResponse res)
	{
		res.redirect("https://is.gd/" ~ _id);
	}
}

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

	// for compatibility with old urls
	// @@@@DEPRECATED_2016-12@@@ - will be removed in December 2016
	@path("/tour/:chapter/:section")
	void getTour(HTTPServerRequest req, HTTPServerResponse res, string _chapter, string _section)
	{
		res.redirect("/tour/en/" ~ _chapter ~ "/" ~ _section);
	}

	@path("/tour/:language/:chapter/:section")
	void getTour(HTTPServerRequest req, HTTPServerResponse res, string _language, string _chapter, string _section)
	{
		// for compatibility with integer-based ids
		// @@@@DEPRECATED_2016-12@@@ - will be removed in December 2016
		import std.string : isNumeric;
		if (_section.isNumeric)
		{
			auto nr = _section.to!int;
			auto chapters = contentProvider_.getTOC(_language);
			foreach (chapter; chapters)
			{
				if (chapter.chapterId == _chapter)
					_section = chapter.sections[nr].sectionId;
			}
		}
		auto language = _language;
		auto sec = getTourDataAndValidate(_language, _chapter, _section);
		auto htmlContent = sec.tourData.content.html;
		auto chapterId = _chapter;
		auto hasSourceCode = !sec.tourData.content.sourceCode.empty;
		auto sourceCodeEnabled = hasSourceCode && sec.tourData.content.sourceCodeEnabled;
		auto section = _section;
		auto sectionId =  sec.tourData.content._id;
		auto sectionCount = sec.tourData.sectionCount;
		auto toc = &toc_[_language];
		auto previousSection = sec.linkCache.previousSection;
		auto nextSection = sec.linkCache.nextSection;
		auto googleAnalyticsId = googleAnalyticsId_;
		auto title = sec.tourData.content.title ~ " - " ~ contentProvider_.getMeta(_language).title;
		auto githubRepo = contentProvider_.getMeta(_language).repo;
		render!("tour.dt", htmlContent, language, section, sectionId,
				sectionCount, chapterId, hasSourceCode, sourceCodeEnabled,
				nextSection, previousSection, googleAnalyticsId,
				toc, title, githubRepo)();
	}
}

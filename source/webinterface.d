import vibe.d;

import std.string: format;
import std.traits: ReturnType;
import std.algorithm: countUntil;

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
		LinkCache[int][string][string] sectionLinkCache_;
			///< language, chapter and section indexing
		string googleAnalyticsId_; ///< ID for google analytics
	}

	this(ContentProvider contentProvider,
		string googleAnalyticsId)
	{
		this.contentProvider_ = contentProvider;
		this.googleAnalyticsId_ = googleAnalyticsId;
		// Fetch all table-of-contents for all supported
		// languages (just 'en' for now) and generate
		// the previous/next link cache for each tour page.
		foreach(lang; ["en"]) {
			auto toc = toc_[lang] = contentProvider_.getTOC(lang);
			foreach(ref chapter; toc) {
				foreach(ref section; chapter.sections) {
					sectionLinkCache_[lang][chapter.chapterId][section.sectionId] =
						LinkCache(
							previousSection(toc, chapter.chapterId, section.sectionId),
							nextSection(toc, chapter.chapterId, section.sectionId));
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
		static auto deltaSection(ref Toc toc, string chapter,
			int section, int move) pure
		{
			alias R = Tuple!(string, "link", string, "title");
			auto chapterIdx = toc.countUntil!"a.chapterId == b"(chapter);
			if (chapterIdx == -1)
				return R("", "");

			section += move;
			if (section < 1) {
				if (--chapterIdx >= 0)
					section = toc[chapterIdx].sections[$ - 1].sectionId;
				else
					return R("", "");
			} else if (section > toc[chapterIdx].sections[$ - 1].sectionId) {
				if (++chapterIdx < toc.length)
					section = 1;
				else
					return R("", "");
			}

			auto sectionTitle = toc[chapterIdx].sections[section - 1].title;

			return R("/tour/%s/%d".format(
						toc[chapterIdx].chapterId,
						section),
					sectionTitle);
		}

		auto previousSection(ref Toc toc, string chapter, int section) pure {
			return deltaSection(toc, chapter, section, -1);
		}
		auto nextSection(ref Toc toc, string chapter, int section) pure {
			return deltaSection(toc, chapter, section, +1);
		}
	}

	void index(HTTPServerRequest req, HTTPServerResponse res)
	{
		getTour(req, res, "welcome", 1);
	}

	/+
		Returns: tuple containing .tourData and .linkCache
		for specified chapter and section.
	+/
	private auto getTourDataAndValidate(string chapter, int section)
	{
		auto tourData = contentProvider_.getContent("en", chapter, section);
		if (tourData.content == null) {
			throw new HTTPStatusException(404,
				"Couldn't find tour data for chapter '%s', section %d".format(chapter, section));
		}

		auto linkCache = &sectionLinkCache_["en"][chapter][section];

		return tuple!("tourData", "linkCache")(tourData, linkCache);
	}

	@path("/tour/:chapter/:section")
	void getTour(HTTPServerRequest req, HTTPServerResponse res, string _chapter, int _section)
	{
		auto sec = getTourDataAndValidate(_chapter, _section);
		auto htmlContent = sec.tourData.content.html;
		auto chapterId = _chapter;
		auto hasSourceCode = !sec.tourData.content.sourceCode.empty;
		auto sourceCodeEnabled = sec.tourData.content.sourceCodeEnabled;
		auto section = _section;
		auto sectionCount = sec.tourData.sectionCount;
		auto toc = &toc_["en"];
		auto previousSection = sec.linkCache.previousSection;
		auto nextSection = sec.linkCache.nextSection;
		auto googleAnalyticsId = googleAnalyticsId_;
		render!("tour.dt", htmlContent, section,
				sectionCount, chapterId, hasSourceCode, sourceCodeEnabled,
				nextSection, previousSection, googleAnalyticsId,
				toc)();
	}

	/+
		GET /api/v1/next/CHAPTER/SECTION
		GET /api/v1/previous/CHAPTER/SECTION

		Returns: the URL ({ location: "xxx"}) of the next or
		previous section based the chapter and section parameters.
	+/
	private struct Location
	{
		string location;
	}
	@method(HTTPMethod.GET)
	@path("/next-section/:chapter/:section")
	void getNextSection(HTTPServerResponse res, string _chapter, int _section)
	{
		auto sec = getTourDataAndValidate(_chapter, _section);
		if (sec.linkCache.nextSection.link.empty)
			throw new HTTPStatusException(404,
				"Couldn't find next section chapter '%s', section %d".format(_chapter, _section));
		res.writeJsonBody(Location(sec.linkCache.nextSection.link));
	}

	@method(HTTPMethod.GET)
	@path("/previous-section/:chapter/:section")
	void getPreviousSection(HTTPServerResponse res, string _chapter, int _section)
	{
		auto sec = getTourDataAndValidate(_chapter, _section);
		if (sec.linkCache.previousSection.link.empty)
			throw new HTTPStatusException(404,
				"Couldn't find previous section chapter '%s', section %d".format(_chapter, _section));
		res.writeJsonBody(Location(sec.linkCache.previousSection.link));
	}
}

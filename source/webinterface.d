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
		alias LinkCache = Tuple!(string, "previousSectionLink",
			string, "nextSectionLink");
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
							previousSectionLink(toc, chapter.chapterId, section.sectionId),
							nextSectionLink(toc, chapter.chapterId, section.sectionId));
				}
			}
		}
	}

	private {
		/++
			Returns the the link to the next or previous section (depending on
			$(D move)) of the current position. Handles overflow to next or
			previous chapter acccordingly. An empty string mean "dead-end".

			Parameters:
			$(D move) either +1 or -1.
			$(D chapter) and $(D section) specify current positon.
		+/
		static string deltaSectionLink(ref Toc toc, string chapter,
			int section, int move) pure
		{
			auto chapterIdx = toc.countUntil!"a.chapterId == b"(chapter);
			if (chapterIdx == -1)
				return "";

			section += move;
			if (section < 1) {
				if (--chapterIdx >= 0)
					section = toc[chapterIdx].sections[$ - 1].sectionId;
				else
					return "";
			} else if (section > toc[chapterIdx].sections[$ - 1].sectionId) {
				if (++chapterIdx < toc.length)
					section = 1;
				else
					return "";
			}

			return "/tour/%s/%d".format(toc[chapterIdx].chapterId,
					section);
		}

		auto previousSectionLink(ref Toc toc, string chapter, int section) pure {
			return deltaSectionLink(toc, chapter, section, -1);
		}
		auto nextSectionLink(ref Toc toc, string chapter, int section) pure {
			return deltaSectionLink(toc, chapter, section, +1);
		}
	}

	void index(HTTPServerRequest req, HTTPServerResponse res)
	{
		getTour(req, res, "welcome", 1);
	}

	@path("/tour/:chapter/:section")
	void getTour(HTTPServerRequest req, HTTPServerResponse res, string _chapter, int _section)
	{
		auto tourData = contentProvider_.getContent("en", _chapter, _section);
		if (tourData.content == null) {
			throw new HTTPStatusException(404,
				"Couldn't find tour data for chapter '%s', section %d".format(_chapter, _section));
		}

		auto linkCache = &sectionLinkCache_["en"][_chapter][_section];

		auto htmlContent = tourData.content.html;
		auto chapterId = _chapter;
		auto hasSourceCode = !tourData.content.sourceCode.empty;
		auto sourceCodeEnabled = tourData.content.sourceCodeEnabled;
		auto section = _section;
		auto sectionCount = tourData.sectionCount;
		auto toc = &toc_["en"];
		auto previousLink = linkCache.previousSectionLink;
		auto nextLink = linkCache.nextSectionLink;
		auto googleAnalyticsId = googleAnalyticsId_;
		render!("tour.dt", htmlContent, section,
				sectionCount, chapterId, hasSourceCode, sourceCodeEnabled,
				nextLink, previousLink, googleAnalyticsId,
				toc)();
	}
}

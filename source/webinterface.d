import vibe.d;
import std.string;
import std.traits;
import std.algorithm;

import contentprovider;

class WebInterface 
{
	private {
		ContentProvider contentProvider_;
		ReturnType!(ContentProvider.getTOC) toc_;
	}

	this(ContentProvider contentProvider)
	{
		this.contentProvider_ = contentProvider;
		toc_ = contentProvider_.getTOC("en");
	}

	private {
		/++
			Parameters:
			$(D move) either +1 or -1.
			$(D chapter) and $(D section) specify current positon.
		+/
		string deltaSectionLink(string chapter, int section, int move) pure
		{
			auto chapterIdx = toc_.countUntil!"a.chapterId == b"(chapter);
			if (chapterIdx == -1)
				return "";

			section += move;
			if (section < 1) {
				if (--chapterIdx >= 0)
					section = toc_[chapterIdx].sections[$ - 1].sectionId;
				else
					return "";
			} else if (section > toc_[chapterIdx].sections[$ - 1].sectionId) {
				if (++chapterIdx < toc_.length)
					section = 1;
				else
					return "";
			}

			return "/tour/%s/%d".format(toc_[chapterIdx].chapterId,
					section);
		}

		auto previousSectionLink(string chapter, int section) pure {
			return deltaSectionLink(chapter, section, -1);
		}
		auto nextSectionLink(string chapter, int section) pure {
			return deltaSectionLink(chapter, section, +1);
		}
	}

	void index(HTTPServerRequest req, HTTPServerResponse res)
	{
		redirect("/tour/welcome/01");
	}

	@path("/tour/:chapter/:section")
	void getTour(HTTPServerRequest req, HTTPServerResponse res, string _chapter, int _section)
	{
		auto tourData = contentProvider_.getContent("en", _chapter, _section);
		if (tourData.content == null) {
			throw new HTTPStatusException(404,
				"Couldn't find tour data for chapter '%s', section %d".format(_chapter, _section));
		}

		auto htmlContent = tourData.content.html;
		auto sourceCode = tourData.content.sourceCode;
		auto chapterId = _chapter;
		auto section = _section;
		auto sectionCount = tourData.sectionCount;
		auto toc = &toc_;
		auto previousLink = previousSectionLink(_chapter, _section);
		auto nextLink = nextSectionLink(_chapter, _section);
		render!("tour.dt", htmlContent, sourceCode, section,
				sectionCount, chapterId,
				nextLink, previousLink,
				toc)();
	}

	@path("/toc")
	void getTOC(HTTPServerResponse res)
	{
		res.writeJsonBody(toc_);
	}
}

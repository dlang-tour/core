module rest.iapiv1;

import vibe.d;

/++
	Interface definition for JSON REST  API.
+/
interface IApiV1
{
	/+
		POST /api/v1/run
		{
			source: "...",
			compiler: "dmd" (available: ["dmd-nightly", "dmd-beta", "dmd", "ldc-beta", "ldc", "gdc"])
		}

		Returns: output of compiled D program with success
		flag and parsed errors and warnings (if any
		and success is false).
		{
			output: "Program Output",
			success: true/false
		}
	+/
	struct RunOutput
	{
		string output;
		bool success;
		struct Message {
			int line;
			string message;
		}
		Message[] errors;
		Message[] warnings;
	}
	@method(HTTPMethod.POST)
	@path("/api/v1/run")
	RunOutput run(string source, string compiler = "dmd");

	/+
		POST /api/v1/format
		{
			source: "..."
		}

		Returns: formatted source code of given D source
		with success flag
		{
			source: "void main() {}",
			success: true/false
		}
	+/
	struct FormatOutput
	{
		string source;
		bool success;
	}
	@method(HTTPMethod.POST)
	@path("/api/v1/format")
	FormatOutput format(string source);

	/+
		POST /api/v1/shorten
		{
			source: "..."
		}

		Returns: short url to given D source
		with success flag
		{
			source: "https://is.gd/abc",
			success: true/false
		}
	+/
	struct ShortenOutput
	{
		string url;
		bool success;
	}
	@method(HTTPMethod.POST)
	@path("/api/v1/shorten")
	ShortenOutput shorten(string source);

	/+
		GET /api/v1/source/CHAPTER/SECTION

		Returns: source code (or empty if none) for the given
		chapter and section. Also returns changed source code
		if user switched between sections.
		{
			sourceCode: "..."
		}
	+/
	struct SourceOutput
	{
		string sourceCode;
	}
	@method(HTTPMethod.GET)
	@path("/api/v1/source/:language/:chapter/:section")
	SourceOutput getSource(string _language, string _chapter, string _section);
}

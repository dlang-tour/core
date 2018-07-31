module rest.iapiv1;

import vibe.web.rest;
import vibe.data.serialization;
import vibe.http.common;

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

	struct RunInput
	{
		string source;
		@optional string compiler = "dmd";
		@optional string stdin;
		@optional string args;
		@optional bool color;
	}

	@bodyParam("input")
	@method(HTTPMethod.POST)
	@path("/api/v1/run")
	RunOutput run(RunInput input);

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
			source: "...",
			compiler: "dmd" (available: ["dmd-nightly", "dmd-beta", "dmd", "ldc-beta", "ldc", "gdc"]),
			args: ""
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
	ShortenOutput shorten(string source, string compiler, string args);

	/+
		POST /api/v1/gi
		{
			source: "...",
			compiler: "dmd" (available: ["dmd-nightly", "dmd-beta", "dmd", "ldc-beta", "ldc", "gdc"]),
			args: ""
		}

		Returns: short url to given D source
		with success flag
		{
			id: "abcdef",
			url: "/gist/abcdef",
			htmlUrl: "http://gist.github.com/abcdef",
		}
	+/

	struct GistOutput
	{
		string id;
		string url;
		string htmlUrl;
	}
	@method(HTTPMethod.POST)
	@path("/api/v1/gist")
	GistOutput gist(string source, string compiler, string args);

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

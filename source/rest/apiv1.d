module rest.apiv1;

import vibe.d;
import rest.iapiv1;
import exec.iexecprovider;
import contentprovider;

class ApiV1: IApiV1
{
	private IExecProvider execProvider_;
	private ContentProvider contentProvider_;

	this(IExecProvider execProvider, ContentProvider contentProvider)
	{
		this.execProvider_ = execProvider;
		this.contentProvider_ = contentProvider;
	}

	/++
		Parses the message contained in $(D output)
		and fills the appropriate errors and warnings
		arrays.
		Note: parsing s just done when $(D output.success)
		is false.
	+/
	private static void parseErrorsAndWarnings(ref RunOutput output)
	{
		import std.regex;
		import std.algorithm: splitter;
		import std.conv: to;

		static ctr = ctRegex!
			`^[^(]+\(([0-9]+)(,[0-9]+)?\): ([a-zA-Z]+): (.*)$`;

		foreach(line; splitter(output.output, '\n')) {
			auto m = line.matchFirst(ctr);
			if (m.empty)
				continue;
			auto lineNumber = to!int(m[1]);
			string type = m[3];
			string message = m[4];

			switch (type) {
				case "Warning":
				case "Deprecation":
					output.warnings ~= RunOutput.Message(lineNumber,
						message);
					break;
				default:
					output.errors ~= RunOutput.Message(lineNumber,
						message);
			}
		}
	}

	RunOutput run(string source, string compiler)
	{
		if (source.length > 4 * 1024) {
			return RunOutput("ERROR: source code size is above limit.", false);
		}

		auto result = execProvider_.compileAndExecute(source, compiler);
		auto output = RunOutput(result.output, result.success);
		parseErrorsAndWarnings(output);
		return output;
	}

	FormatOutput format(string source)
	{
		// https://github.com/dlang-community/dfmt/blob/master/src/dfmt/config.d
		import dfmt.config : Config;
		import dfmt.formatter : format;
		import std.array : appender;
		import std.range.primitives;

		FormatOutput output;
		ubyte[] buffer;
		buffer = cast(ubyte[]) source;

		Config formatterConfig;
		formatterConfig.initializeWithDefaults();
		auto app = appender!string;
		format(source, buffer, app, &formatterConfig);
		output.source = app.data;
		if (output.source.back == '\n')
			output.source.popBack;
		return output;
	}

	ShortenOutput shorten(string source)
	{
		import std.format : format;
		import std.uri : encodeComponent;

		ShortenOutput output;
		auto url = "https://run.dlang.io?source=%s".format(source.encodeComponent);
		auto isURL= "https://is.gd/create.php?format=simple&url=%s".format(url.encodeComponent);
		output.url = requestHTTP(isURL, (scope req) {
			req.method = HTTPMethod.POST;
		}).bodyReader.readAllUTF8;
		output.success = true;
		return output;
	}

unittest
{
	string source = `void main() {}`;
	ApiV1 api = new ApiV1(null, null);
	auto res = api.format(source);
	assert(res == FormatOutput("void main()\n{\n}", false));
}

	SourceOutput getSource(string _language, string _chapter, string _section)
	{
		auto tourData = contentProvider_.getContent(_language, _chapter, _section);
		if (tourData.content == null) {
			throw new HTTPStatusException(404,
				"Couldn't find tour data for chapter '%s', section %d".format(_language, _chapter, _section));
		}

		return SourceOutput(tourData.content.sourceCode);
	}
}

unittest {
	string run1 = `onlineapp.d(6): Error: found '}' when expecting ';' following statement
onlineapp.d(6): Error: found 'EOF' when expecting '}' following compound statement
Failed: ["dmd", "-v", "-o-", "onlineapp.d", "-I."]`;

	auto test2 = ApiV1.RunOutput(run1, false);
	ApiV1.parseErrorsAndWarnings(test2);
	assert(test2.errors.length == 2);
	assert(test2.errors[0].line == 6);
	assert(test2.errors[0].message[0 .. 9] == "found '}'");
	assert(test2.errors[1].line == 6);
	assert(test2.errors[1].message[0 .. 11] == "found 'EOF'");

	string run2 = `dlang-tour ~master: building configuration "executable"...
../.dub/packages/dyaml-0.5.2/source/dyaml/dumper.d(15,8): Deprecation: module std.stream is deprecated - It will be removed from Phobos in October 2016. If you still need it, go to https://github.com/DigitalMars/undeaD
../.dub/packages/dyaml-0.5.2/source/dyaml/emitter.d(21,8): Deprecation: module std.stream is deprecated - It will be removed from Phobos in October 2016. If you still need it, go to https://github.com/DigitalMars/undeaD
../.dub/packages/dyaml-0.5.2/source/dyaml/representer.d(679,8): Deprecation: module std.stream is deprecated - It will be removed from Phobos in October 2016. If you still need it, go to https://github.com/DigitalMars/undeaD
../.dub/packages/dyaml-0.5.2/source/dyaml/loader.d(171,16): Deprecation: module std.stream is deprecated - It will be removed from Phobos in October 2016. If you still need it, go to https://github.com/DigitalMars/undeaD`;
	auto test3 = ApiV1.RunOutput(run2, false);
	ApiV1.parseErrorsAndWarnings(test3);
	assert(test3.warnings.length == 4);
	import std.algorithm: all;
	assert(test3.warnings.all!(x => x.message[0 .. 31] == "module std.stream is deprecated"));
	assert(test3.warnings[0].line == 15);
	assert(test3.warnings[1].line == 21);
	assert(test3.warnings[2].line == 679);
	assert(test3.warnings[3].line == 171);
}

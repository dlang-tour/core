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

	RunOutput run(string source)
	{
		if (source.length > 4 * 1024) {
			return RunOutput("ERROR: source code size is above limit.", false);
		}

		auto result = execProvider_.compileAndExecute(source);
		return RunOutput(result.output, result.success);
	}

	SourceOutput getSource(string _chapter, int _section)
	{
		auto tourData = contentProvider_.getContent("en", _chapter, _section);
		if (tourData.content == null) {
			throw new HTTPStatusException(404,
				"Couldn't find tour data for chapter '%s', section %d".format(_chapter, _section));
		}

		return SourceOutput(tourData.content.sourceCode);
	}
}

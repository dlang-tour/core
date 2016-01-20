module rest.apiv1;

import rest.iapiv1;
import exec.iexecprovider;

class ApiV1: IApiV1
{
	private IExecProvider execProvider_;

	this(IExecProvider execProvider)
	{
		this.execProvider_ = execProvider;
	}

	RunOutput run(string source)
	{
		if (source.length > 4 * 1024) {
			return RunOutput("ERROR: source code size is above limit.", false);
		}

		auto result = execProvider_.compileAndExecute(source);
		return RunOutput(result.output, result.success);
	}
}

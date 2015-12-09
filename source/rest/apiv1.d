module rest.apiv1;

import vibe.d;

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
		auto result = execProvider_.compileAndExecute(source);
		return RunOutput(result.output, result.success);
	}
}

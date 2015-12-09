module exec.cache;

import exec.iexecprovider;
import std.typecons;

class Cache: IExecProvider
{
	private IExecProvider realExecProvider_;
	private string[long] sourceHashToOutput_;

	this(IExecProvider realExecProvider)
	{
		this.realExecProvider_ = realExecProvider;
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(string source)
	{
		return typeof(return)("", false);
	}
}

private long getSourceCodeHash(string source)
{
	return 0;
}

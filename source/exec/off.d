module exec.off;

import exec.iexecprovider;

import std.typecons: Tuple;

class Off: IExecProvider
{
	Tuple!(string, "output", bool, "success") compileAndExecute(string source, string compiler = "dmd")
	{
		return typeof(return)("Service currently unavailable", false);
	}
}

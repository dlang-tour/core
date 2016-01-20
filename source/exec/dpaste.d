module exec.dpaste;

import exec.iexecprovider;

import std.typecons: Tuple;

class DPaste: IExecProvider
{
	Tuple!(string, "output", bool, "success") compileAndExecute(string source)
	{
		return typeof(return)("", false);
	}
}

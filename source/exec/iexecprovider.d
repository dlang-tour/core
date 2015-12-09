module exec.iexecprovider;

import std.typecons;

interface IExecProvider
{
	Tuple!(string, "output", bool, "success") compileAndExecute(string source);
}

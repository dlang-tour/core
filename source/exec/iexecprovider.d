module exec.iexecprovider;

import std.typecons: Tuple;

/++
	Interface for exec providers that take source code
	and output the compiled program's output.
+/
interface IExecProvider
{
	Tuple!(string, "output", bool, "success") compileAndExecute(string source, string compiler = "dmd");
}

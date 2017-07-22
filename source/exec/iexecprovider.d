module exec.iexecprovider;

import std.typecons: Tuple;

/++
	Interface for exec providers that take source code
	and output the compiled program's output.
+/
interface IExecProvider
{
	struct RunInput
	{
		string source;
		string compiler = "dmd";
		string args;
		string stdin;
	}
	Tuple!(string, "output", bool, "success") compileAndExecute(RunInput input);
}

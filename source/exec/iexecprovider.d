module exec.iexecprovider;

import std.typecons: Tuple;

alias Package = Tuple!(string, "name", string, "version_");

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
		bool color;
	}
	Tuple!(string, "output", bool, "success") compileAndExecute(RunInput input);


	// returns a list of all installed DUB packages
	Package[] installedPackages();
}

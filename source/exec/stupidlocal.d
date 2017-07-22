module exec.stupidlocal;

import exec.iexecprovider;

import vibe.core.core: sleep, runTask;
import core.time : msecs;
import vibe.core.log : logInfo;

import std.process;
import std.typecons: Tuple;
import std.file: exists, remove, tempDir;
import std.stdio: File;
import std.random: uniform;
import std.string: format;

// searches the local system for valid D compilers
private string findDCompiler()
{
	string dCompiler = "dmd";
	foreach (compiler; ["dmd", "ldmd2", "gdmd"])
	{
		try {
			if (execute([compiler, "--version"]).status == 0)
			{
				dCompiler = compiler;
				break;
			}
		} catch (ProcessException) {}
	}
	return dCompiler;
}

/++
	Stupid local executor which just runs rdmd and passes the source to it
	and outputs the executes binary's output.

	Warning:
		UNSAFE BECUASE CODE IS RUN UNFILTERED AND NOT IN A SANDBOX
+/
class StupidLocal: IExecProvider
{
	string dCompiler = "dmd";
	this() {
		dCompiler = findDCompiler();
	    logInfo("Selected %s as D compiler", dCompiler);
	}

	private File getTempFile()
	{
		auto tempdir = tempDir();

		static string randomName()
		{
			enum Length = 10;
			char[Length] res;
			foreach (ref c; res) {
				c = cast(char)('a' + uniform(0, 'z'-'a'));
			}
			return res.idup;
		}

		string tempname;
		do {
			tempname = "%s/temp_dlang_tour_%s.d".format(tempdir, randomName());
		} while (exists(tempname));

		File tempfile;
		tempfile.open(tempname, "wb");
		return tempfile;
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(RunInput input)
	{
		import std.array : split;
		typeof(return) result;
		auto task = runTask(() {
			auto tmpfile = getTempFile();
			scope(exit) tmpfile.name.remove;

			tmpfile.write(input.source);
			tmpfile.close();
			auto args = [dCompiler];
			args ~= input.args.split(" ");
			args ~= "-run";
			args ~= tmpfile.name;
			auto rdmd = args.execute;
			result.success = rdmd.status == 0;
			result.output = rdmd.output;
		});

		while (task.running)
			sleep(10.msecs);

		return result;
	}
}

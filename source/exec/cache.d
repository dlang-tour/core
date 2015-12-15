module exec.cache;

import exec.iexecprovider;
import std.typecons;
import std.traits;

import vibe.d;

class Cache: IExecProvider
{
	private IExecProvider realExecProvider_;

	private enum HashTableSize = 109;
	private alias ResultTuple = ReturnType!compileAndExecute;
	private Tuple!(ResultTuple, "result", ReturnType!getSourceCodeHash, "hash")[HashTableSize]
		sourceHashToOutput_;

	this(IExecProvider realExecProvider)
	{
		this.realExecProvider_ = realExecProvider;
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(string source)
	{
		auto hash = getSourceCodeHash(source);
		auto entry = &sourceHashToOutput_[hash % HashTableSize];
		if (entry.hash == hash) {
			logInfo("Re-using cache entry with hash %s", hash);
			return entry.result;
		}
		
		auto result = realExecProvider_.compileAndExecute(source);
		entry.hash = hash;
		entry.result = result;
		return result;
	}
}

private size_t getSourceCodeHash(string source)
{
	import std.digest.md: md5Of;
	auto md5 = md5Of(source);
	return hashOf(md5);
}

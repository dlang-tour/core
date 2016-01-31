module exec.cache;

import exec.iexecprovider;
import std.typecons: Tuple;
import std.traits: ReturnType;

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
			return entry.result;
		}
		
		auto result = realExecProvider_.compileAndExecute(source);
		entry.hash = hash;
		entry.result = result;
		return result;
	}
}

private uint getSourceCodeHash(string source)
{
	import std.digest.crc: crc32Of;
	auto crc = crc32Of(source);
	return cast(size_t)*crc.ptr;
}

unittest
{
	auto hash1 = getSourceCodeHash("test123");
	auto hash2 = getSourceCodeHash("void main() {}");
	auto hash3 = getSourceCodeHash("12838389349493");

	assert(hash1 != hash2);
	assert(hash2 != hash3);
}

module exec.cache;

import exec.iexecprovider;
import std.typecons: Tuple, tuple;
import std.traits: ReturnType;
import std.algorithm: map, sort;
import std.datetime : Clock, SysTime;

/++
 Execution provider that implements caching
 for an allowed white list of source code files.
+/
class Cache: IExecProvider
{
	private
	{
		IExecProvider realExecProvider_;

		alias ResultTuple = Tuple!(ReturnType!compileAndExecute, "source", SysTime, "time");
		alias HashType = ReturnType!getSourceCodeHash;
		ResultTuple[HashType] sourceHashToOutput_;

		size_t maximumCacheSize;
	}

	/++
	Params:
	  realExecProvider = the execution provider if cache
	                     can't give the answer
	  maximumCacheSize = maximal elements allowed to be in the cahce
	+/
	this(IExecProvider realExecProvider, long maximumCacheSize)
	{
		this.realExecProvider_ = realExecProvider;
		this.maximumCacheSize = maximumCacheSize;
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(string source)
	{
		import std.range: assumeSorted;
		import std.algorithm: canFind;
		auto hash = getSourceCodeHash(source);

		if (auto cache = hash in sourceHashToOutput_) {
			cache.time = Clock.currTime;
			return cache.source;
		} else {
			auto result = realExecProvider_.compileAndExecute(source);
			sourceHashToOutput_[hash] = ResultTuple(result, Clock.currTime);
			testCacheSize();
			return result;
		}
	}

	void testCacheSize()
	{
		import std.stdio;
		import std.array : array, byPair;
		if (sourceHashToOutput_.length > maximumCacheSize)
		{
			// throw away the older half
			foreach (entry; sourceHashToOutput_
								.byPair
								.map!(a => tuple!("key", "time")(a[0], a[1].time))
								.array
								.sort!((a, b) => a.time < b.time)[0 .. $ / 2])
				sourceHashToOutput_.remove(entry.key);
		}
	}
}

private uint getSourceCodeHash(string source)
{
	import std.digest.crc: crc32Of;
	auto crc = crc32Of(source);
	return (cast(uint)crc[0])
		| ((cast(uint)crc[1]) << 8)
		| ((cast(uint)crc[2]) << 16)
		| ((cast(uint)crc[3]) << 24);
}

unittest
{
	auto sourceCode1 = "void main() {} ";
	auto sourceCode2 = "void main() {}";
	auto sourceCode3 = "void main()  {}";
	import std.stdio: writeln;
	auto hash1 = getSourceCodeHash(sourceCode1);
	writeln("hash1 = ", hash1);
	auto hash2 = getSourceCodeHash(sourceCode2);
	writeln("hash2 = ", hash2);
	auto hash3 = getSourceCodeHash(sourceCode3);
	writeln("hash3 = ", hash3);

	assert(hash1 != hash2);
	assert(hash2 != hash3);

	class DummyExecProvider : IExecProvider
	{
		alias ResultType = Tuple!(string, "output", bool, "success");
		ResultType compileAndExecute(string source)
		{
			return ResultType(".dummy output.", true);
		}
	}

	auto cache = new Cache(new DummyExecProvider(), 2);
	assert(cache.maximumCacheSize == 2);
	import std.algorithm: canFind;
	bool isInCache(uint hash)
	{
		return (hash in cache.sourceHashToOutput_) !is null;
	}

	cache.compileAndExecute(sourceCode1);
	assert(isInCache(hash1));
	cache.compileAndExecute(sourceCode2);
	assert(isInCache(hash2));

	cache.compileAndExecute(sourceCode3);
	// hash1 got popped from the cache
	assert(!isInCache(hash1));
	assert(isInCache(hash2));
	assert(isInCache(hash3));

	// renew timestamp for hash2
	cache.compileAndExecute(sourceCode2);
	cache.compileAndExecute(sourceCode1);
	assert(isInCache(hash1));
	assert(isInCache(hash2));
	// hash3 was the oldest -> removed
	assert(!isInCache(hash3));
}

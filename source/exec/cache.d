module exec.cache;

import exec.iexecprovider;
import std.typecons: Tuple;
import std.traits: ReturnType;
import std.algorithm: sort;

import vibe.core.core : sleep;
import core.time : msecs;

/++
 Execution provider that implements caching
 for an allowed white list of source code files.
+/
class Cache: IExecProvider
{
	private IExecProvider realExecProvider_;

	private alias ResultTuple = ReturnType!compileAndExecute;
	private alias HashType = ReturnType!getSourceCodeHash;
	private ResultTuple[HashType] sourceHashToOutput_;
	private HashType[] allowedSources_; ///< Hash of allowed source code contents
	private uint minDelayMs_, maxDelayMs_;

	/++
	Params:
	  realExecProvider = the execution provider if cache
	                     can't give the answer
	  minDelayMs = minimum delay to add randomly for each
	               cache reply
	  maxDelayMs = maximum delay to add randomly for each
	               cache reply
	  sourceCodeWhitelist = raw source code only allowed
	                        to be cached
	+/
	this(IExecProvider realExecProvider,
		uint minDelayMs,
		uint maxDelayMs,
		string[] sourceCodeWhitelist)
	{
		import std.algorithm: map;
		import std.array: array;
		this.realExecProvider_ = realExecProvider;
		this.allowedSources_ = sourceCodeWhitelist
			.map!(x => x.getSourceCodeHash)
			.array;
		sort(this.allowedSources_);
		assert(sourceCodeWhitelist.length == this.allowedSources_.length);

		this.minDelayMs_ = minDelayMs;
		this.maxDelayMs_ = maxDelayMs;
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(string source)
	{
		import std.range: assumeSorted;
		import std.algorithm: canFind;
		auto hash = getSourceCodeHash(source);
		import vibe.core.log: logInfo;
		logInfo("Got hash %d", hash);

		if (!assumeSorted(this.allowedSources_).canFind(hash)) {
			auto result = realExecProvider_.compileAndExecute(source);
			return result;
		} else if (auto cache = hash in sourceHashToOutput_) {
			import std.random: uniform;
			auto delay = uniform(minDelayMs_, maxDelayMs_);
			sleep(delay.msecs);
			logInfo("Found cached entry for %d", hash);
			return *cache;
		} else {
			auto result = realExecProvider_.compileAndExecute(source);
			sourceHashToOutput_[hash] = result;
			return result;
		}
	}
}

private uint getSourceCodeHash(string source)
{
	import std.digest.crc: crc32Of;
	auto crc = crc32Of(source);
	return crc[0] | crc[1] >> 8 | crc[2] >> 16 | crc[3] >> 24;
}

unittest
{
	auto sourceCode1 = "test123";
	auto sourceCode2 = "void main() {}";
	auto sourceCode3 = "12838389349493";
	auto hash1 = getSourceCodeHash(sourceCode1);
	auto hash2 = getSourceCodeHash(sourceCode2);
	auto hash3 = getSourceCodeHash(sourceCode3);

	assert(hash1 != hash2);
	assert(hash2 != hash3);

	auto cache = new Cache(null, 0, 0,
		[ sourceCode1, sourceCode2, sourceCode3 ]);
	assert(cache.allowedSources_.length == 3);
	import std.algorithm: canFind;
	assert(cache.allowedSources_.canFind(hash1));
	assert(cache.allowedSources_.canFind(hash2));
	assert(cache.allowedSources_.canFind(hash3));
}


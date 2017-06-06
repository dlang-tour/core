module exec.cache;

import exec.iexecprovider;
import std.typecons: Tuple;
import std.traits: ReturnType;
import std.algorithm: sort;

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

	/++
	Params:
	  realExecProvider = the execution provider if cache
	                     can't give the answer
	  sourceCodeWhitelist = raw source code only allowed
	                        to be cached
	+/
	this(IExecProvider realExecProvider,
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
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(string source)
	{
		import std.range: assumeSorted;
		import std.algorithm: canFind;
		auto hash = getSourceCodeHash(source);

		if (!assumeSorted(this.allowedSources_).canFind(hash)) {
			auto result = realExecProvider_.compileAndExecute(source);
			return result;
		} else if (auto cache = hash in sourceHashToOutput_) {
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
	return (cast(uint)crc[0])
		| ((cast(uint)crc[1]) << 8)
		| ((cast(uint)crc[2]) << 16)
		| ((cast(uint)crc[3]) << 24);
}

unittest
{
	auto sourceCode1 = "test123";
	auto sourceCode2 = "void main() {}";
	auto sourceCode3 = "12838389349493";
	import std.stdio: writeln;
	auto hash1 = getSourceCodeHash(sourceCode1);
	writeln("hash1 = ", hash1);
	auto hash2 = getSourceCodeHash(sourceCode2);
	writeln("hash2 = ", hash2);
	auto hash3 = getSourceCodeHash(sourceCode3);
	writeln("hash3 = ", hash3);

	assert(hash1 != hash2);
	assert(hash2 != hash3);

	auto cache = new Cache(null,
		[ sourceCode1, sourceCode2, sourceCode3 ]);
	assert(cache.allowedSources_.length == 3);
	import std.algorithm: canFind;
	assert(cache.allowedSources_.canFind(hash1));
	assert(cache.allowedSources_.canFind(hash2));
	assert(cache.allowedSources_.canFind(hash3));
}

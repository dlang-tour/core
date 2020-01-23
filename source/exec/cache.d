module exec.cache;

import exec.iexecprovider;
import std.typecons: Tuple;
import std.traits: ReturnType;
import std.algorithm: sort;

import vibe.core.log;

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
		// allowedSources is no longer used
		//this.allowedSources_ = sourceCodeWhitelist
			//.map!(x => x.getSourceCodeHash)
			//.array;
		//sort(this.allowedSources_);
		//assert(sourceCodeWhitelist.length == this.allowedSources_.length);
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(RunInput input)
	{
		import std.range: assumeSorted;
		import std.algorithm: min, canFind;
		auto hash = getSourceCodeHash(input);

		// allowedSources is no longer used
		//if (!assumeSorted(this.allowedSources_).canFind(hash)) {
			//auto result = realExecProvider_.compileAndExecute(input);
			//return result;
		if (auto cache = hash in sourceHashToOutput_) {
			logInfo("Fetching '%s...' from cache", input.source[0 .. min($, 20)]);
			return *cache;
		} else {
			auto result = realExecProvider_.compileAndExecute(input);
			sourceHashToOutput_[hash] = result;
			return result;
		}
	}

	Package[] installedPackages()
	{
		return realExecProvider_.installedPackages;
	}
}

private uint getSourceCodeHash(IExecProvider.RunInput input)
{
	import std.string : representation;
	import std.digest.crc : CRC32;
	CRC32 crc;
	crc.put(input.source.representation);
	crc.put(input.compiler.representation);
	crc.put(input.stdin.representation);
	crc.put(input.args.representation);
	crc.put(input.runtimeArgs.representation);
	crc.put(input.color);
	union view {
		ubyte[4] source;
		uint uint_;
	}
	view ret = cast(view) crc.finish;
	return ret.uint_ ;
}

unittest
{
	auto sourceCode1 = "test123";
	auto sourceCode2 = "void main() {}";
	auto sourceCode3 = "12838389349493";

	auto getSourceCodeHash2(string source)
	{
		IExecProvider.RunInput input = {source: source};
		return input;
	}

	import std.stdio: writeln;
	auto hash1 = getSourceCodeHash2(sourceCode1);
	writeln("hash1 = ", hash1);
	auto hash2 = getSourceCodeHash2(sourceCode2);
	writeln("hash2 = ", hash2);
	auto hash3 = getSourceCodeHash2(sourceCode3);
	writeln("hash3 = ", hash3);

	assert(hash1 != hash2);
	assert(hash2 != hash3);

	// allowedSources is no longer used
	//auto cache = new Cache(null,
		//[ sourceCode1, sourceCode2, sourceCode3 ]);
	//assert(cache.allowedSources_.length == 3);
	//import std.algorithm: canFind;
	//assert(cache.allowedSources_.canFind(hash1));
	//assert(cache.allowedSources_.canFind(hash2));
	//assert(cache.allowedSources_.canFind(hash3));
}

// #668 - different compilers should not use the same hash
unittest
{
	import std.stdio: writeln;
	IExecProvider.RunInput input;
	auto hash1 = getSourceCodeHash(input);
	writeln("hash1 = ", hash1);

	input.source = "aa";
	auto hash2 = getSourceCodeHash(input);
	writeln("hash2 = ", hash2);

	input.compiler = "ldc";
	auto hash3 = getSourceCodeHash(input);
	writeln("hash3 = ", hash3);

	assert(hash1 != hash2 && hash2 != hash3 && hash1 != hash3);

	IExecProvider.RunInput input2 = {
		source: "aa"
	};
	auto hash4 = getSourceCodeHash(input2);
	assert(hash4 == hash2);
}

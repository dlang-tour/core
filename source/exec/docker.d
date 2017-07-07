module exec.docker;

import exec.iexecprovider;
import std.process;
import vibe.core.core : sleep;
import core.time : msecs;
import vibe.core.log: logInfo;
import std.base64;
import std.datetime;
import std.typecons: Tuple;
import std.exception: enforce;
import std.conv: to;

/+
	Execution provider that uses the Docker iamge
	stonemaster/dlang-tour-rdmd to compile and run
	the resulting binary.
+/
class Docker: IExecProvider
{
	private immutable BaseDockerImage = "dlangtour/core-exec";
	private immutable DockerImages = [
		BaseDockerImage ~ ":dmd",
		BaseDockerImage ~ ":dmd-beta",
		BaseDockerImage ~ ":dmd-nightly",
		BaseDockerImage ~ ":ldc",
		BaseDockerImage ~ ":ldc-beta",
		//BaseDockerImage ~ ":gdc"
	];

	private int timeLimitInSeconds_;
	private int maximumOutputSize_;
	private int maximumQueueSize_;
	private int queueSize_;
	private int memoryLimitMB_;
	private string dockerBinaryPath_;


	this(int timeLimitInSeconds, int maximumOutputSize,
			int maximumQueueSize, int memoryLimitMB,
			string dockerBinaryPath)
	{
		this.timeLimitInSeconds_ = timeLimitInSeconds;
		this.maximumOutputSize_ = maximumOutputSize;
		this.queueSize_ = 0;
		this.maximumQueueSize_ = maximumQueueSize;
		this.memoryLimitMB_ = memoryLimitMB;
		this.dockerBinaryPath_ = dockerBinaryPath;

		logInfo("Initializing Docker driver");
		logInfo("Time Limit: %d", timeLimitInSeconds_);
		logInfo("Maximum Queue Size: %d", maximumQueueSize_);
		logInfo("Memory Limit: %d MB", memoryLimitMB_);
		logInfo("Output size limit: %d B", maximumQueueSize_);

		foreach (dockerImage; DockerImages)
		{

			logInfo("Checking whether Docker is functional and updating Docker image '%s'", dockerImage);
			logInfo("Using docker binary at '%s'", dockerBinaryPath);

			auto docker = execute([this.dockerBinaryPath_, "ps"]);
			if (docker.status != 0) {
				throw new Exception("Docker doesn't seem to be functional. Error: '"
						~ docker.output ~ "'. RC: " ~ to!string(docker.status));
			}

			auto dockerPull = execute([this.dockerBinaryPath_, "pull", dockerImage]);
			if (docker.status != 0) {
				throw new Exception("Failed pulling RDMD Docker image. Error: '" ~ docker.output
						~ "'. RC: " ~ to!string(docker.status));
			}

			logInfo("Pulled Docker image '%s'.", dockerImage);
			logInfo("Verifying functionality with 'Hello World' program...");
			auto result = compileAndExecute(q{void main() { import std.stdio; write("Hello World"); }});
			enforce(result.success && result.output == "Hello World",
					new Exception("Compiling 'Hello World' wasn't successful: " ~ result.output));
		}
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(string source, string compiler = "dmd")
	{
		import std.string: format;
		import std.algorithm.searching : canFind, find;

		if (queueSize_ > maximumQueueSize_) {
			return typeof(return)("Maximum number of parallel compiles has been exceeded. Try again later.", false);
		}

		++queueSize_;
		scope(exit)
			--queueSize_;

		auto encoded = Base64.encode(cast(ubyte[])source);
		// try to find the compiler in the available images
		auto r = DockerImages.find!(d => d.canFind(compiler));
		// use dmd as fallback
		const dockerImage = (r.length > 0) ? r[0] : DockerImages[0];

		auto docker = pipeProcess([this.dockerBinaryPath_, "run", "--rm",
				"--net=none", "--memory-swap=-1",
				"-m", to!string(memoryLimitMB_ * 1024 * 1024),
				dockerImage, encoded],
				Redirect.stdout | Redirect.stderrToStdout | Redirect.stdin);
		docker.stdin.write(encoded);
		docker.stdin.flush();
		docker.stdin.close();

		bool success;
		auto startTime = Clock.currTime();
		// Don't block and give away current time slice
		// by sleeping for a certain time until child process has finished. Kill process if time limit
		// has been reached.
		while (true) {
			auto result = tryWait(docker.pid);
			if (Clock.currTime() - startTime > timeLimitInSeconds_.seconds) {
				// send SIGKILL 9 to process
				kill(docker.pid, 9);
				return typeof(return)("Compilation or running program took longer than %d seconds. Aborted!".format(timeLimitInSeconds_),
						false);
			}
			if (result.terminated) {
				success = result.status == 0;
				break;
			}

			sleep(300.msecs);
		}

		string output;
		foreach (chunk; docker.stdout.byChunk(4096)) {
			output ~= chunk;
			if (output.length > maximumOutputSize_) {
				return typeof(return)("Program's output exceeds limit of %d bytes.".format(maximumOutputSize_),
						false);
			}
		}

		return typeof(return)(output, success);
	}
}

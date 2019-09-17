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
	dlangtour/core-exec to compile and run
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
		"dlangtour/core-dreg:latest",
	];

	private int timeLimitInSeconds_;
	private int maximumOutputSize_;
	private int maximumQueueSize_;
	private shared int queueSize_;
	private int memoryLimitMB_;
	private string dockerBinaryPath_;


	this(int timeLimitInSeconds, int maximumOutputSize,
			int maximumQueueSize, int memoryLimitMB,
			string dockerBinaryPath, bool waitUntilPulled)
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

		import std.algorithm.iteration : filter;
		import std.concurrency : ownerTid, receiveOnly, send, spawn;
		import std.parallelism : parallel;

		// Temporarily share the DockerExecProvider across all threads
		__gshared typeof(this) inst;
		inst = this;
		// updating the docker images should happen in the background
		spawn((string dockerBinaryPath, in string[] dockerImages) {
			// core-dreg is a very large Docker image (> 3 GB)
			// Thus constantly pulling it on every CI build is problematic
			foreach (dockerImage; dockerImages.filter!(a => a != "dlangtour/core-dreg:latest").parallel)
			{

				logInfo("Checking whether Docker is functional and updating Docker image '%s'", dockerImage);
				logInfo("Using docker binary at '%s'", dockerBinaryPath);

				auto docker = execute([dockerBinaryPath, "ps"]);
				if (docker.status != 0) {
					throw new Exception("Docker doesn't seem to be functional. Error: '"
							~ docker.output ~ "'. RC: " ~ to!string(docker.status));
				}

				auto dockerPull = execute([dockerBinaryPath, "pull", dockerImage]);
				if (docker.status != 0) {
					throw new Exception("Failed pulling RDMD Docker image. Error: '" ~ docker.output
							~ "'. RC: " ~ to!string(docker.status));
				}
				logInfo("Pulled Docker image '%s'.", dockerImage);

				logInfo("Verifying functionality with 'Hello World' program...");
				RunInput input = {
					source: q{void main() { import std.stdio; write("Hello World"); }}
				};
				auto result = inst.compileAndExecute(input);
				enforce(result.success && result.output == "Hello World",
						new Exception("Compiling 'Hello World' wasn't successful: " ~ result.output));
			}
			// Remove previous, untagged images
			//executeShell("docker images --no-trunc | grep '<none>' | awk '{ print $3 }' | xargs -r docker rmi");
			ownerTid.send(true);
		}, this.dockerBinaryPath_, DockerImages);
		if (waitUntilPulled)
			assert(receiveOnly!bool, "Docker pull failed");
	}

	Tuple!(string, "output", bool, "success") compileAndExecute(RunInput input)
	{
		import std.string: format;
		import std.algorithm.searching : canFind, find;

		if (queueSize_ > maximumQueueSize_) {
			return typeof(return)("Maximum number of parallel compiles has been exceeded. Try again later.", false);
		}

		import core.atomic : atomicOp;
		atomicOp!"+="(queueSize_, 1);
		scope(exit) atomicOp!"-="(queueSize_, 1);


		auto encoded = Base64.encode(cast(ubyte[]) input.source);
		// try to find the compiler in the available images
		auto r = DockerImages.find!(d => d.canFind(input.compiler));
		// use dmd as fallback
		const dockerImage = (r.length > 0) ? r[0] : DockerImages[0];

        auto env = [
            "DOCKER_FLAGS": input.args,
            "DOCKER_COLOR": input.color ? "on" : "off",
        ];

        auto args = [this.dockerBinaryPath_, "run", "--rm",
		    "-e", "DOCKER_COLOR",
		    "-e", "DOCKER_FLAGS",
			"--net=none", "--memory-swap=-1",
			"-m", to!string(memoryLimitMB_ * 1024 * 1024),
			dockerImage, encoded];
		if (input.stdin) {
			args ~= Base64.encode(cast(ubyte[]) input.stdin);
		}

		auto docker = pipeProcess(args,
				Redirect.stdout | Redirect.stderrToStdout | Redirect.stdin, env);
		docker.stdin.write(encoded);
		docker.stdin.flush();
		docker.stdin.close();

		bool success;
		auto startTime = MonoTime.currTime();

		logInfo("Executing Docker image %s with env='%s'", dockerImage, env);

		string output;
		enum bufReadLength = 4096;
		// returns true if the maximum output limit has been exceeded
		bool readFromPipe() {
            while (true) {
                auto buf = docker.stdout.rawRead(new char[bufReadLength]);
                output ~= buf;
				if (output.length > maximumOutputSize_) {
					output ~= "\n\n---Program's output exceeds limit of %d bytes.---".format(maximumOutputSize_);
					return true;
				}
				if (buf.length < bufReadLength)
				    break;
			}
			return false;
		}

		// Don't block and give away current time slice
		// by sleeping for a certain time until child process has finished. Kill process if time limit
		// has been reached.
		while (true) {
			auto result = tryWait(docker.pid);
			if (MonoTime.currTime() - startTime > timeLimitInSeconds_.seconds) {
				// send SIGKILL 9 to process
				kill(docker.pid, 9);
				return typeof(return)("Compilation or running program took longer than %d seconds. Aborted!".format(timeLimitInSeconds_), false);
			}
			if (result.terminated) {
				success = result.status == 0;
				break;
			}

			sleep(50.msecs);
			if (readFromPipe())
				return typeof(return)(output, success);
		}
		readFromPipe();

		return typeof(return)(output, success);
	}

	Package[] installedPackages()
	{
		import std.array : array;
		import std.algorithm.iteration : filter, joiner, map, splitter;
		import std.range : empty, dropOne;
		import std.functional;

		auto res = execute([dockerBinaryPath_, "run", "--rm", "--entrypoint=/bin/cat", DockerImages[0], "/installed_packages"]);
		enforce(res.status == 0, "Error:" ~ res.output);
		return res.output
			.splitter("\n")
			.filter!(not!empty)
			.map!((l){
				auto ps = l.splitter(":");
				return Package(ps.front, ps.dropOne.front.filter!(a => a != '"').to!string);
			})
			.array;
	}
}

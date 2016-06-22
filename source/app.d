import vibe.d;

import webinterface;
import contentprovider;
import config;

import rest.apiv1;

import exec.cache;
import exec.stupidlocal;
import exec.iexecprovider;
import exec.off;
import exec.docker;

/++ Factory method that returns an execution provider
    depending on the configuration settings.
+/
private IExecProvider createExecProvider(Config config,
		ContentProvider contentProvider)
{
	IExecProvider execProvider;

	logInfo("Using execution driver '%s'", config.execProvider);

	switch (config.execProvider) {
		case "stupidlocal":
			execProvider = new StupidLocal;
			break;
		case "off":
			return new Off;
		case "docker":
			execProvider = new Docker(config.dockerExecConfig.timeLimit,
					config.dockerExecConfig.maximumOutputSize,
					config.dockerExecConfig.maximumQueueSize,
					config.dockerExecConfig.memoryLimit);
			break;
		default:
			throw new Exception("Unknown exec provider %s".format(config.execProvider));
	}

	logInfo("Caching enabled: %b", config.enableExecCache);

	if (config.enableExecCache) {
		import std.algorithm: map;
		auto allowedSources = contentProvider.getContent()
			.map!(x => x.sourceCode.idup)
			.array;
		return new Cache(execProvider, 500, 2000, allowedSources);
	}
	return execProvider;
}

/++
	Checks all source code example that are fetched from
	$(D contentProvider). If a source code examples doesn't
	compile an exception is thrown.
+/
private void doSanityCheck(ContentProvider contentProvider, IExecProvider execProvider)
{
	import std.exception: enforce;

	auto content = contentProvider.getContent();
	foreach (section; content) {
		if (section.sourceCode.empty) {
			logInfo("[%s] Sanity check: Ignoring source code for section '%s' because it is empty.",
					section.language, section.title);
			continue;
		}

		if (!section.sourceCodeEnabled) {
			logInfo("[%s] Sanity check: Ignoring source code for section '%s' because it is disabled.",
					section.language, section.title);
			continue;
		}

		if (section.sourceCodeIncomplete) {
			logInfo("[%s] Sanity check: Ignoring source code for section '%s' because it is incomplete.",
					section.language, section.title);
			continue;
		}

		logInfo("[%s] Doing sanity check for section '%s'...",
				section.language, section.title);
		auto result = execProvider.compileAndExecute(section.sourceCode);
		enforce(result.success,
			"[%s] Sanity check: Source code for section '%s' doesn't compile:\n%s"
			.format(section.language, section.title, result.output));
	}
}

shared static this()
{
	string configFile = "config.yml";
	readOption("c|config", &configFile, "Configuration file");
	bool sanityCheck = false;
	readOption("sanitycheck", &sanityCheck,
		"Runs sanity check before starting that checks whether all source code examples actually compile; doesn't start the service");
	auto config = new Config(configFile);

	auto contentProvider = new ContentProvider(config.publicDir ~ "/content");
	auto execProvider = createExecProvider(config, contentProvider);

	if (sanityCheck) {
		doSanityCheck(contentProvider, execProvider);
		import std.c.stdlib: exit;
		exit(0);
	}

	logInfo("Starting Dlang-tour on %s, port %d", config.bindAddresses, config.port);
	logInfo("Google Analytics ID: %s", config.googleAnalyticsId);

	auto settings = new HTTPServerSettings;
	settings.port = config.port;
	settings.bindAddresses = config.bindAddresses;
	settings.useCompressionIfPossible = true;
	settings.errorPageHandler = (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error) {
		auto t = contentProvider.getTOC("en");
		auto toc = &t;
		auto googleAnalyticsId = config.googleAnalyticsId;
		auto chapterId = "";
		auto language = "en";
		res.render!("error.dt", req, error, language, googleAnalyticsId, chapterId, toc)();
		res.finalize();
	};

	auto urlRouter = new URLRouter;
	auto fsettings = new HTTPFileServerSettings;
	fsettings.serverPathPrefix = "/static";
	urlRouter
		.registerWebInterface(new WebInterface(contentProvider, config.googleAnalyticsId))
		.registerRestInterface(new ApiV1(execProvider, contentProvider))
		.get("/static/*", serveStaticFiles(config.publicDir ~ "/static/", fsettings));

	listenHTTP(settings, urlRouter);
}

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

shared static this()
{
	string configFile = "config.yml";
	readOption("c|config", &configFile, "Configuration file");
	auto config = new Config(configFile);

	logInfo("Starting Dlang-tour on %s, port %d", config.bindAddresses, config.port);

	auto settings = new HTTPServerSettings;
	settings.port = config.port;
	settings.bindAddresses = config.bindAddresses;

	auto contentProvider = new ContentProvider(config.publicDir ~ "/content");
	auto execProvider = createExecProvider(config, contentProvider);

	auto urlRouter = new URLRouter;
	auto fsettings = new HTTPFileServerSettings;
	fsettings.serverPathPrefix = "/static";
	urlRouter
		.registerWebInterface(new WebInterface(contentProvider))
		.registerRestInterface(new ApiV1(execProvider, contentProvider))
		.get("/static/*", serveStaticFiles(config.publicDir ~ "/static/", fsettings));

	listenHTTP(settings, urlRouter);
}

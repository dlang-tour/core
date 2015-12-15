import vibe.d;
import std.algorithm;

import webinterface;
import contentprovider;
import config;

import rest.apiv1;

import exec.cache;
import exec.stupidlocal;
import exec.dpaste;
import exec.iexecprovider;
import exec.off;

private IExecProvider createExecProvider(Config config)
{
	IExecProvider execProvider;

	switch (config.execProvider) {
		case "stupidlocal":
			execProvider = new StupidLocal;
			break;
		case "dpaste":
			execProvider = new DPaste;
			break;
		case "off":
			return new Off;
		default:
			throw new Exception("Unknown exec provider %s".format(config.execProvider));
	}

	if (config.enableExecCache)
		return new Cache(execProvider);
	return execProvider;
}

shared static this()
{
	string configFile = "config.yml";
	readOption("c|config", &configFile, "Configuration file");
	auto config = new Config(configFile);

	logInfo("Starting Dlang-tour with configuration: %s", config);

	auto settings = new HTTPServerSettings;
	settings.port = config.port;
	settings.bindAddresses = config.bindAddresses;

	auto execProvider = createExecProvider(config);

	auto contentProvider = new ContentProvider("public/content");
	auto urlRouter = new URLRouter;
	auto fsettings = new HTTPFileServerSettings;
	fsettings.serverPathPrefix = "/static";
	urlRouter
		.registerWebInterface(new WebInterface(contentProvider))
		.registerRestInterface(new ApiV1(execProvider))
		.get("/static/*", serveStaticFiles("public/static/", fsettings));

	listenHTTP(settings, urlRouter);
}

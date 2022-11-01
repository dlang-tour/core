import vibe.core.log;
import vibe.core.args : readOption;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;
import vibe.stream.tls;
import vibe.web.rest;
import vibe.web.web;

import std.array: array;
import std.format: format;
import std.range: empty;

import webinterface;
import contentprovider;
import config;

import rest.apiv1;

import exec.cache;
import exec.stupidlocal;
import exec.iexecprovider;
import exec.off;
import exec.docker;

bool waitUntilPulled;

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
					config.dockerExecConfig.memoryLimit,
					config.dockerExecConfig.dockerBinaryPath,
					waitUntilPulled);
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
		return new Cache(execProvider, allowedSources);
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

	void runChecks(R)(R range)
	{
		foreach (section; range) {
			if (section.sourceCode.empty) {
				logInfo("[%s] Sanity check: Ignoring source code for section '%s' in %s because it is empty.",
						section.language, section.title, section.filename);
				continue;
			}

			if (!section.sourceCodeEnabled) {
				logInfo("[%s] Sanity check: Ignoring source code for section '%s' in %s because it is disabled.",
						section.language, section.title, section.filename);
				continue;
			}

			if (section.sourceCodeIncomplete) {
				logInfo("[%s] Sanity check: Ignoring source code for section '%s' in %s because it is incomplete.",
						section.language, section.title, section.filename);
				continue;
			}

			logInfo("[%s] Doing sanity check for section '%s'...",
					section.language, section.title);

			IExecProvider.RunInput input = {
				source: section.sourceCode,
				color: false,
			};
			auto result = execProvider.compileAndExecute(input);
			enforce(result.success,
				"[%s] Sanity check: Source code for section '%s' in %s doesn't compile:\n%s"
				.format(section.language, section.title, section.filename, result.output));
		}
	}

	import std.parallelism : parallel;

	auto content = contentProvider.getContent();

	if (cast(Docker) execProvider)
		runChecks(content.parallel);
	else
		runChecks(content);
}

version(unittest) {} else
shared static this()
{
	import std.file : thisExePath;
	import std.path;

	string rootDir = thisExePath.dirName;
	string configFile = buildPath(rootDir, "config.yml");
	bool sanityCheck = false;
	string customLangDirectory;
	string defaultLang = "en";

	readOption("c|config", &configFile, "Configuration file");
	readOption("wait-until-pulled", &waitUntilPulled, "Wait until all docker images have been pulled.");
	readOption("sanitycheck", &sanityCheck,
	    "Runs sanity check before starting that checks whether all source code examples actually compile; doesn't start the service");
	readOption("lang-dir|l", &customLangDirectory, "Language directory");

	auto config = new Config(configFile);

	string publicDir = config.publicDir.isAbsolute ? config.publicDir : rootDir.buildPath(config.publicDir);
	string contentDir = publicDir.buildPath("content");

	auto contentProvider = new ContentProvider(contentDir);
	// If the user provides a custom language directory we only add this language to the Tour
	if (!customLangDirectory.empty)
	{
		string langDir = customLangDirectory.absolutePath.buildNormalizedPath;
		contentProvider.addLanguage(langDir);
		defaultLang = langDir.baseName;
	}
	else
		contentProvider.addLanguages(contentDir);

	auto execProvider = createExecProvider(config, contentProvider);

	if (sanityCheck) {
		doSanityCheck(contentProvider, execProvider);
		import core.stdc.stdlib: exit;
		exit(0);
	}

	logInfo("Starting Dlang-tour on %s, port %d", config.bindAddresses, config.port);
	logInfo("Google Analytics ID: %s", config.googleAnalyticsId);
	logInfo("GitHub Token: %s", config.githubToken);

	auto settings = new HTTPServerSettings;
	settings.port = config.port;
	settings.bindAddresses = config.bindAddresses;
	settings.useCompressionIfPossible = true;
	settings.errorPageHandler = (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error) {
		auto title = "Page not found";
		auto toc = contentProvider.getTOC(defaultLang);
		auto googleAnalyticsId = config.googleAnalyticsId;
		auto chapterId = "";
		auto language = "en";
		const name = "DLang Tour";
		const topHelpLink = "https://github.com/dlang-tour/core/issues/new";
		res.render!("error.dt", req, error, language, googleAnalyticsId, chapterId, toc, title, name, topHelpLink)();
		res.finalize();
	};

	auto httpsSettings = settings.dup;
	import std.file: exists;
	auto startHTTPS = exists(config.tlsCaChainFile) && exists(config.tlsPrivateKeyFile);
	if (startHTTPS) {
		httpsSettings.port = config.tlsPort;
		httpsSettings.tlsContext = createTLSContext(TLSContextKind.server);
		httpsSettings.tlsContext.useCertificateChainFile(config.tlsCaChainFile);
		httpsSettings.tlsContext.usePrivateKeyFile(config.tlsPrivateKeyFile);
		logInfo("Starting HTTPs server.");
	} else {
		logInfo("NOT starting HTTPs server because no valid TLS files given.");
	}

	auto urlRouter = new URLRouter;
	auto fsettings = new HTTPFileServerSettings;
	fsettings.serverPathPrefix = "/static";

	void cors(HTTPServerRequest req, HTTPServerResponse res)
	{
		import std.algorithm: among, equal, until;
		if (req.host.until(":").among!equal("tour.dlang.org", "tour.dlang.io", "run.dlang.io",
					"dlang.org", "dtest.dlang.io", "127.0.0.1", "localhost"))
		{
			res.headers["Access-Control-Allow-Origin"] = "*";
		}
		// parse json sent via text/plain to avoid an additional preflight OPTIONS request
		// https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#Preflighted_requests
		if (req.contentType == "text/plain")
			req.contentType = "application/json; charset=UTF-8";
	}

	// refresh the list of DUB packages installed once on the start
	auto installedPackages = execProvider.installedPackages();
	logInfo("Installed DUB Packages: %s", installedPackages);
	urlRouter
		.any("/api/*", &cors)
		.registerWebInterface(new WebInterface(contentProvider, config.googleAnalyticsId, defaultLang, installedPackages))
		.registerRestInterface(new ApiV1(execProvider, contentProvider, config.githubToken))
		.get("/static/*", serveStaticFiles(publicDir.buildPath("static"), fsettings));

	if (startHTTPS) {
		// redirect all HTTP to HTTPS
		listenHTTP(settings, (req, res) {
			auto url = req.fullURL;
			url.schema = "https";
			url.port = 443;
			res.redirect(url);
		});
		listenHTTP(httpsSettings, urlRouter);
	} else {
		listenHTTP(settings, urlRouter);
	}
}

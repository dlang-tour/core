import vibe.d;
import std.algorithm;

import webinterface;
import contentprovider;

import rest.apiv1;

import exec.cache;
import exec.stupidlocal;

shared static this()
{
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	auto execProvider = new StupidLocal;

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

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Hello, World!");
}

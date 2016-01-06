module rest.iapiv1;

import vibe.d;

/++
	Interface definition for JSON REST  API.
+/
interface IApiV1
{
	struct RunOutput
	{
		string output;
		bool success;
	}

	@method(HTTPMethod.POST)
	@path("/api/v1/run")
	RunOutput run(string source);
}

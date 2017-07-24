private string[string] defaultLanguage;
static this()
{
	defaultLanguage = [
		"editor.run": "Run",
		"editor.reset": "Reset",
		"editor.format": "Format",
		"editor.keyboard_shortcuts": "Keyboard Shortcuts",
		"editor.export": "Export",

		"hotkeys.help_title": "Keyboard Shortcuts",
		"hotkeys.show_hide_help": "Show / hide this help menu",
		"hotkeys.previous_section": "Go to previous section",
		"hotkeys.next_section": "Go to next section",
		"hotkeys.run_source_code": "Run source code",
		"hotkeys.reset_source_code": "Reset source code",
		"hotkeys.format_source_code": "Format source code",
	];
}

/**
Allows per-language overwrites of UI text
*/
class Translator
{
	string[string] translations;

	// in case no translation is found
	this() {}

	this(string[string] translations)
	{
		this.translations = translations;
	}

	// uses default language as fallback
	string opIndex(string key) const
	{
		if (auto value = key in translations)
			return *value;

		return defaultLanguage[key];
	}

	auto toJson() const
	{
		import vibe.data.json : Json;
		Json json = Json.emptyObject;
		foreach (k, v; defaultLanguage)
			json[k] = this[k];

		return json;
	}
}

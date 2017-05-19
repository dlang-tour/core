private string[string] defaultLanguage;
static this()
{
	defaultLanguage = [
		"editor.run": "Run",
		"editor.reset": "Reset",
		"editor.format": "Format",
		"editor.keyboard_shortcuts": "Keyboard Shortcuts",
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
}

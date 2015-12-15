import yaml;
import std.algorithm;

class Config
{
	private ushort port_;
	private string[] bindAddresses_;
	private string execProvider_;
	private bool enableExecCache_;

	@property ushort port() { return port_; }
	@property string[] bindAddresses() { return bindAddresses_; }
	@property string execProvider() { return execProvider_; }
	@property bool enableExecCache() { return enableExecCache_; }
	
	this(string configFile)
	{
		auto root = Loader(configFile).load();
		port_ = root["port"].as!ushort();
		foreach (string address; root["listen"])
			bindAddresses_ ~= address;
		execProvider_ = root["exec"]["driver"].as!string();
		enableExecCache_ = root["exec"]["cache"].as!bool();
	}

	string toString() const
	{
		import std.string: format;
		return q{- Listening on %s
- Port %d
- Execution Driver: %s
- Caching enabled: %b}.format(bindAddresses_, port_, execProvider_, enableExecCache_);
	}
}

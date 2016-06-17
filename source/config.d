import yaml;

/++
	Maps values of config.yml to properties.
+/
class Config
{
	private ushort port_;
	private string[] bindAddresses_;
	private string execProvider_;
	private bool enableExecCache_;
	private string publicDir_;
	private string googleAnalyticsId_;

	private struct DockerConfig {
		private int memoryLimit_;
		private int maximumQueueSize_;
		private int timeLimit_;
		private int maximumOutputSize_;

		private this(Node yamlNode)
		{
			memoryLimit_ = yamlNode["memory_limit"].as!int();
			maximumQueueSize_ = yamlNode["maximum_queue_size"].as!int();
			timeLimit_ = yamlNode["time_limit"].as!int();
			maximumOutputSize_ = yamlNode["maximum_output_size"].as!int();
		}

		@property int memoryLimit() const { return memoryLimit_; }
		@property int maximumQueueSize() const { return maximumQueueSize_; }
		@property int timeLimit() const { return timeLimit_; }
		@property int maximumOutputSize() const { return maximumOutputSize_; }
	}
	private DockerConfig dockerConfig_;

	@property ushort port() { return port_; }
	@property string[] bindAddresses() { return bindAddresses_; }
	@property string execProvider() { return execProvider_; }
	@property auto dockerExecConfig() {
		assert(execProvider == "docker");
		return dockerConfig_;
	}
	@property bool enableExecCache() { return enableExecCache_; }
	@property string publicDir() { return publicDir_; }
	@property string googleAnalyticsId() { return googleAnalyticsId_; }
	
	this(string configFile)
	{
		auto root = Loader(configFile).load();
		port_ = root["port"].as!ushort();
		foreach (string address; root["listen"])
			bindAddresses_ ~= address;
		execProvider_ = root["exec"]["driver"].as!string();
		enableExecCache_ = root["exec"]["cache"].as!bool();
		publicDir_ = root["public_dir"].as!string();
		googleAnalyticsId_ = root["google_analytics_id"].as!string();

		if (execProvider_ == "docker") {
			dockerConfig_ = DockerConfig(root["exec"]["config"]);
		}
	}
}

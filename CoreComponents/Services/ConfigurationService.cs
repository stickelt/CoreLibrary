using Microsoft.Extensions.Configuration;

namespace CoreComponents.Services
{
    /// <summary>
    /// Service to handle configuration for components in the library
    /// </summary>
    public interface IConfigurationService
    {
        /// <summary>
        /// Gets a configuration value by key
        /// </summary>
        string GetConfigValue(string key);

        /// <summary>
        /// Gets a configuration section
        /// </summary>
        IConfigurationSection GetSection(string sectionName);
    }

    /// <summary>
    /// Implementation of IConfigurationService that wraps IConfiguration
    /// </summary>
    public class ConfigurationService : IConfigurationService
    {
        private readonly IConfiguration _configuration;

        public ConfigurationService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GetConfigValue(string key)
        {
            return _configuration[key];
        }

        public IConfigurationSection GetSection(string sectionName)
        {
            return _configuration.GetSection(sectionName);
        }
    }
}

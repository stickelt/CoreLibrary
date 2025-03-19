using Microsoft.Extensions.Configuration;

namespace Stickelt.CoreComponents.Services
{
    /// <summary>
    /// Service to handle configuration for components in the library
    /// </summary>
    public interface IConfigurationService
    {
        /// <summary>
        /// Gets a configuration section from the app settings
        /// </summary>
        IConfigurationSection GetSection(string sectionName);
    }

    /// <summary>
    /// Concrete implementation of IConfigurationService
    /// </summary>
    public class ConfigurationService : IConfigurationService
    {
        private readonly IConfiguration _configuration;

        public ConfigurationService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        /// <inheritdoc/>
        public IConfigurationSection GetSection(string sectionName)
        {
            return _configuration.GetSection(sectionName);
        }
    }
}

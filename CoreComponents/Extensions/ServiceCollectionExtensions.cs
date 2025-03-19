using Stickelt.CoreComponents.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Stickelt.CoreComponents.Extensions
{
    /// <summary>
    /// Extension methods for IServiceCollection to register CoreComponents services
    /// </summary>
    public static class ServiceCollectionExtensions
    {
        /// <summary>
        /// Adds CoreComponents services to the specified IServiceCollection
        /// </summary>
        public static IServiceCollection AddCoreComponents(this IServiceCollection services)
        {
            // Register the ConfigurationService
            services.AddScoped<IConfigurationService, ConfigurationService>();
            
            return services;
        }
    }
}

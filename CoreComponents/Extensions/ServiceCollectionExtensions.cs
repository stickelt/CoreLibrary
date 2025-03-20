using Stickelt.CoreComponents.Services;
using Microsoft.Extensions.DependencyInjection;

namespace CoreComponents.Extensions
{
    /// <summary>
    /// Extension methods for IServiceCollection to register CoreComponents services
    /// </summary>
    public static class ServiceCollectionExtensions
    {
        /// <summary>
        /// Adds CoreComponents services to the service collection
        /// </summary>
        public static IServiceCollection AddCoreComponents(this IServiceCollection services)
        {
            // Register the ConfigurationService
            services.AddScoped<IConfigurationService, ConfigurationService>();
            
            // Register the DynamicRouteService
            services.AddScoped<IDynamicRouteService, DynamicRouteService>();
            
            return services;
        }
    }
}

namespace Stickelt.CoreComponents.Extensions
{
    /// <summary>
    /// Extension methods for IServiceCollection to register CoreComponents services
    /// </summary>
    public static class ServiceCollectionExtensions
    {
        /// <summary>
        /// Adds CoreComponents services to the service collection
        /// </summary>
        public static IServiceCollection AddCoreComponents(this IServiceCollection services)
        {
            // Register the ConfigurationService
            services.AddScoped<IConfigurationService, ConfigurationService>();
            
            // Register the DynamicRouteService
            services.AddScoped<IDynamicRouteService, DynamicRouteService>();
            
            return services;
        }
    }
}

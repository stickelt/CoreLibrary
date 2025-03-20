using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Stickelt.CoreComponents.Components;

namespace Stickelt.CoreComponents.Services
{
    /// <summary>
    /// Interface for the dynamic route service
    /// </summary>
    public interface IDynamicRouteService
    {
        /// <summary>
        /// Gets the component type for a given route
        /// </summary>
        Type GetComponentTypeForRoute(string route);
        
        /// <summary>
        /// Gets the configuration for a given route
        /// </summary>
        PageConfiguration GetConfigurationForRoute(string route);
        
        /// <summary>
        /// Gets all available routes
        /// </summary>
        IEnumerable<string> GetAvailableRoutes();
    }
    
    /// <summary>
    /// Service for handling dynamic routes and component loading
    /// </summary>
    public class DynamicRouteService : IDynamicRouteService
    {
        private readonly Dictionary<string, Type> _routeComponentMap;
        private readonly Dictionary<string, PageConfiguration> _routeConfigMap;
        
        public DynamicRouteService(IConfiguration configuration)
        {
            // Initialize the route-to-component map
            _routeComponentMap = new Dictionary<string, Type>(StringComparer.OrdinalIgnoreCase);
            _routeConfigMap = new Dictionary<string, PageConfiguration>(StringComparer.OrdinalIgnoreCase);
            
            // Load dynamic routes from CoreComponents assembly
            LoadDynamicRoutes();
            
            // Load configurations from appsettings.json
            LoadConfigurations(configuration);
        }
        
        private void LoadDynamicRoutes()
        {
            // Find all components with RouteAttribute in the CoreComponents assembly
            var componentTypes = typeof(DynamicPage1).Assembly
                .GetTypes()
                .Where(t => t.IsClass && !t.IsAbstract && t.IsSubclassOf(typeof(Microsoft.AspNetCore.Components.ComponentBase)))
                .ToList();
                
            // Map the component name to Type
            foreach (var componentName in new [] { "DynamicPage1", "DynamicPage2", "DynamicPage3" })
            {
                var componentType = componentTypes.FirstOrDefault(t => t.Name == componentName);
                if (componentType != null)
                {
                    string route = $"/{componentName.ToLowerInvariant()}";
                    _routeComponentMap[route] = componentType;
                }
            }
        }
        
        private void LoadConfigurations(IConfiguration configuration)
        {
            // Get the DynamicPages section from configuration
            var dynamicPagesSection = configuration.GetSection("DynamicPages");
            if (dynamicPagesSection == null) return;
            
            // Process each route configuration
            foreach (var routeSection in dynamicPagesSection.GetChildren())
            {
                string route = routeSection.Key;
                if (!route.StartsWith("/")) route = "/" + route;
                
                // Map configuration to PageConfiguration object
                var pageConfig = new PageConfiguration
                {
                    Title = routeSection["Title"],
                    Description = routeSection["Description"],
                    ShowDetails = routeSection.GetValue<bool>("ShowDetails")
                };
                
                // Load any custom data
                var customDataSection = routeSection.GetSection("CustomData");
                if (customDataSection != null)
                {
                    foreach (var item in customDataSection.GetChildren())
                    {
                        pageConfig.CustomData[item.Key] = item.Value;
                    }
                }
                
                _routeConfigMap[route] = pageConfig;
            }
        }
        
        /// <summary>
        /// Gets the component type for a given route
        /// </summary>
        public Type GetComponentTypeForRoute(string route)
        {
            if (string.IsNullOrEmpty(route)) route = "/";
            return _routeComponentMap.TryGetValue(route, out var componentType) ? componentType : null;
        }
        
        /// <summary>
        /// Gets the configuration for a given route
        /// </summary>
        public PageConfiguration GetConfigurationForRoute(string route)
        {
            if (string.IsNullOrEmpty(route)) route = "/";
            return _routeConfigMap.TryGetValue(route, out var config) ? config : null;
        }
        
        /// <summary>
        /// Gets all available routes
        /// </summary>
        public IEnumerable<string> GetAvailableRoutes()
        {
            return _routeComponentMap.Keys;
        }
    }
} 
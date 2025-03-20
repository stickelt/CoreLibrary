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
            // Directly map routes to component types for simplicity and reliability
            // This avoids issues with type discovery and ensures consistent behavior
            var assembly = typeof(DynamicPage1).Assembly;
            
            // Map routes directly to fully-qualified component types
            _routeComponentMap["/dynamicpage1"] = assembly.GetType("Stickelt.CoreComponents.Components.DynamicPage1");
            _routeComponentMap["/dynamicpage2"] = assembly.GetType("Stickelt.CoreComponents.Components.DynamicPage2");
            _routeComponentMap["/dynamicpage3"] = assembly.GetType("Stickelt.CoreComponents.Components.DynamicPage3");
            
            // Log all mapped routes
            foreach (var entry in _routeComponentMap)
            {
                System.Diagnostics.Debug.WriteLine($"Registered route: {entry.Key} -> {entry.Value?.FullName ?? "null"}");
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
            
            // Normalize route by ensuring it starts with /
            if (!route.StartsWith("/")) route = "/" + route;
            
            // Debug information 
            System.Diagnostics.Debug.WriteLine($"Looking for route: {route}");
            foreach (var key in _routeComponentMap.Keys)
            {
                System.Diagnostics.Debug.WriteLine($"Available route: {key}");
            }
            
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
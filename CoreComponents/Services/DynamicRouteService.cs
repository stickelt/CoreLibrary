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
            // Debug configuration access
            System.Diagnostics.Debug.WriteLine("Loading DynamicPages configuration");
            
            // Get the DynamicPages section from configuration
            var dynamicPagesSection = configuration.GetSection("DynamicPages");
            
            // Log whether we found the section
            System.Diagnostics.Debug.WriteLine($"DynamicPages section found: {dynamicPagesSection.Exists()}");
            
            // If no configuration found, create default values
            if (!dynamicPagesSection.Exists() || !dynamicPagesSection.GetChildren().Any())
            {
                System.Diagnostics.Debug.WriteLine("Using default configurations since none were found");
                
                // Default configurations
                _routeConfigMap["/dynamicpage1"] = new PageConfiguration 
                { 
                    Title = "Default Dynamic Page 1", 
                    Description = "This is a default configuration", 
                    ShowDetails = true 
                };
                
                _routeConfigMap["/dynamicpage2"] = new PageConfiguration 
                { 
                    Title = "Default Dynamic Page 2", 
                    Description = "This is a default configuration with custom data", 
                    ShowDetails = true,
                    CustomData = new System.Collections.Generic.Dictionary<string, string>
                    {
                        { "DefaultKey1", "DefaultValue1" },
                        { "DefaultKey2", "DefaultValue2" }
                    }
                };
                
                _routeConfigMap["/dynamicpage3"] = new PageConfiguration 
                { 
                    Title = "Default Dynamic Page 3", 
                    Description = "This is a default configuration with details", 
                    ShowDetails = true 
                };
                
                return;
            }
            
            // Process each route configuration from the config file
            foreach (var routeSection in dynamicPagesSection.GetChildren())
            {
                string route = routeSection.Key;
                if (!route.StartsWith("/")) route = "/" + route;
                
                System.Diagnostics.Debug.WriteLine($"Processing configuration for route: {route}");
                
                // Map configuration to PageConfiguration object
                var pageConfig = new PageConfiguration
                {
                    Title = routeSection["Title"],
                    Description = routeSection["Description"],
                    ShowDetails = routeSection.GetValue<bool>("ShowDetails")
                };
                
                System.Diagnostics.Debug.WriteLine($"Loaded config - Title: {pageConfig.Title}, ShowDetails: {pageConfig.ShowDetails}");
                
                // Load any custom data
                var customDataSection = routeSection.GetSection("CustomData");
                if (customDataSection != null && customDataSection.Exists())
                {
                    foreach (var item in customDataSection.GetChildren())
                    {
                        pageConfig.CustomData[item.Key] = item.Value;
                        System.Diagnostics.Debug.WriteLine($"Added custom data: {item.Key} = {item.Value}");
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
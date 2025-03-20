using System;

namespace Stickelt.CoreComponents
{
    /// <summary>
    /// Attribute to mark components with their associated routes
    /// </summary>
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class RouteAttribute : Attribute
    {
        /// <summary>
        /// The route path for this component
        /// </summary>
        public string Route { get; }
        
        /// <summary>
        /// Creates a new RouteAttribute
        /// </summary>
        /// <param name="route">The route path for this component</param>
        public RouteAttribute(string route)
        {
            Route = route;
        }
    }
} 
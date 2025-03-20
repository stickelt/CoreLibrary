using System.Collections.Generic;

namespace Stickelt.CoreComponents
{
    /// <summary>
    /// Configuration for dynamic pages
    /// </summary>
    public class PageConfiguration
    {
        /// <summary>
        /// The title of the page
        /// </summary>
        public string Title { get; set; }
        
        /// <summary>
        /// Description text for the page
        /// </summary>
        public string Description { get; set; }
        
        /// <summary>
        /// Flag to show detailed information
        /// </summary>
        public bool ShowDetails { get; set; }
        
        /// <summary>
        /// Custom data for the page
        /// </summary>
        public Dictionary<string, string> CustomData { get; set; } = new Dictionary<string, string>();
    }
} 
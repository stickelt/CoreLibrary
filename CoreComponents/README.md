# CoreComponents

A .NET 8 Razor Class Library containing reusable UI components for Blazor applications.

## Overview

This library provides a set of reusable Blazor components that can be used in both Blazor Server and Blazor WebAssembly applications. The components are designed to be simple, customizable, and easy to use.

## Getting Started

### Prerequisites

- .NET 8 SDK

### Installation

1. Add a reference to the CoreComponents NuGet package in both your Server and Client projects:

```xml
<PackageReference Include="Stickelt.CoreComponents" Version="1.0.0" />
```

2. For the Client project, modify the package reference to exclude content files to avoid ambiguous paths:

```xml
<PackageReference Include="Stickelt.CoreComponents" Version="1.0.0">
  <ExcludeAssets>contentFiles</ExcludeAssets>
</PackageReference>
```

3. Register the CoreComponents services in your Server's Program.cs file:

```csharp
using CoreComponents.Extensions;

// Add this line to register CoreComponents services
builder.Services.AddCoreComponents();
```

4. Register the CoreComponents services in your Client's Program.cs file:

```csharp
using CoreComponents.Extensions;

// Add this line to register CoreComponents services
builder.Services.AddCoreComponents();
```

5. Import the components namespace in your _Imports.razor file (in both Server and Client projects):

```razor
@using CoreComponents
@using CoreComponents.Components
```

## Configuration Handling

The components in this library that require configuration (like Home.razor) use a special `IConfigurationService` to handle configuration access. This service is automatically registered when you call `AddCoreComponents()` in your application.

Components can access configuration values in two ways:

1. Through the `IConfigurationService` injected into the component
2. Through parameters passed to the component

For example, the Home component can be used like this:

```razor
<Home ApplicationName="My Custom App Name" />
```

Or it will automatically use the configuration value from `AppSettings:ApplicationName` if available.

## Available Components

- **Home**: A home page component that displays the application name from configuration
- **Button**: A customizable button component with support for click events and custom styling

## Adding New Components

To add new components to this library:

1. Create a new .razor file in the Components folder
2. Define your component with the `@namespace CoreComponents.Components`
3. Add any necessary CSS in a corresponding .razor.css file
4. If your component needs configuration, inject `IConfigurationService` instead of directly using `IConfiguration`

## Troubleshooting

### NullReferenceException with Configuration

If you encounter a NullReferenceException related to configuration, make sure you've registered the CoreComponents services using `AddCoreComponents()` in both your Server and Client projects.

### Ambiguous Paths

If you encounter ambiguous path errors, make sure you've added the `ExcludeAssets="contentFiles"` to the package reference in your Client project as shown in the Installation section.

### Component Not Found

If a component can't be found, ensure you've added the correct `@using` directives in your _Imports.razor file.

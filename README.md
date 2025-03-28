# CoreLibrary and CoreComponents

This solution contains two .NET libraries that provide shared functionality for Blazor applications:

1. **CoreLibrary** - A core library containing shared interfaces, base functionality, and UI components.
2. **CoreComponents** - A Razor Class Library containing reusable UI components for Blazor applications.

## Versioning

Both packages share a centralized versioning system that ensures they always have the same version number.

### How it works:

1. The master version is stored in two places:
   - `Directory.Build.props` contains the default version (1.0.1)
   - `Version.props` contains the incremented version created by the script

2. To increment the version:
   ```
   powershell -ExecutionPolicy Bypass -File Increment-Version.ps1 -IncrementVersion
   ```

3. Release builds will produce packages with clean version numbers (1.0.2)

4. Debug builds add a -local suffix (1.0.2-local)

### Automated version increments

When you build in Release mode, the version is automatically incremented. This happens because:

1. CoreLibrary project calls the increment script before the build starts
2. The script creates/updates Version.props with the new version
3. Both projects read this version number during build
4. Result: both packages always have identical version numbers

## Consuming the Packages

### From Local Development

When working locally, packages are generated in the `C:\dev\LocalNuGet` folder. To consume these packages:

1. Add the local folder as a package source in your NuGet.Config:

```xml
<configuration>
  <packageSources>
    <add key="Local" value="C:\dev\LocalNuGet" />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
</configuration>
```

2. Reference the packages in your project file:

```xml
<ItemGroup>
  <PackageReference Include="Stickelt.CoreLibrary" Version="1.0.2" />
  <!-- Or -->
  <PackageReference Include="Stickelt.CoreComponents" Version="1.0.2" />
</ItemGroup>
```

### From GitHub Packages

When consuming from GitHub Packages:

1. Add the GitHub package source to your NuGet.Config:

```xml
<configuration>
  <packageSources>
    <add key="GitHub" value="https://nuget.pkg.github.com/stickelt/index.json" />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
  <packageSourceCredentials>
    <GitHub>
      <add key="Username" value="YOUR_GITHUB_USERNAME" />
      <add key="ClearTextPassword" value="YOUR_GITHUB_PAT" />
    </GitHub>
  </packageSourceCredentials>
</configuration>
```

2. Reference the packages as shown above.

## Features

- Base repository pattern interfaces for data access
- Common entity models with built-in auditing properties
- Standardized service response objects
- Utility extensions and helpers

## Installation

You can install this package via NuGet Package Manager:

```shell
dotnet add package Stickelt.CoreLibrary
Set-Content -Path "README.md" -Value @"
# CoreLibrary

CoreLibrary is a foundational .NET library that provides common interfaces, base classes, and utilities for building enterprise applications.

## Features

- Base repository pattern interfaces for data access
- Common entity models with built-in auditing properties
- Standardized service response objects
- Utility extensions and helpers

## Installation

You can install this package via NuGet Package Manager:
## Dependencies

This library uses these packages (versions managed centrally):
- Dapper
- Microsoft.EntityFrameworkCore
- Polly
- Serilog

## License

[MIT](https://choosealicense.com/licenses/mit/)

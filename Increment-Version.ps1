# Define params (must be at the top of the script)
param(
    [switch]$IncrementVersion = $true,  # Force increment by default
    [switch]$VisualStudioBuild = $false # Flag to indicate VS is building
)

# Define common paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$versionPropsPath = Join-Path $scriptDir "Version.props"
$lockFilePath = Join-Path $scriptDir "VersionUpdate.lock"
$localNugetPath = "C:\dev\LocalNuGet"

# Create a function to write output
function Write-Output {
    param([string]$message)
    Write-Host $message
}

Write-Output "Starting version increment..."

# Check if environment variable is set (Visual Studio sets this)
$envVars = Get-ChildItem env:
if ($envVars -match "VisualStudio") {
    Write-Output "Visual Studio build detected"
    $VisualStudioBuild = $true
}

# Use a lock file to prevent multiple runs, but skip lock check for VS rebuilds
if (-not $VisualStudioBuild -and (Test-Path $lockFilePath)) {
    $lockAge = [datetime]::Now - (Get-Item $lockFilePath).LastWriteTime
    if ($lockAge.TotalMinutes -lt 5) {
        Write-Output "Script already ran in the last 5 minutes. Skipping."
        exit 0
    }
    Remove-Item $lockFilePath -Force
}

# Create lock file
"Lock" | Out-File -FilePath $lockFilePath -Force

# Set a default version to increment
$currentVersion = "1.0.1"

# Try to read the current version from Directory.Build.props
$buildPropsPath = Join-Path $scriptDir "Directory.Build.props"
if (Test-Path $buildPropsPath) {
    $content = Get-Content $buildPropsPath -Raw
    $versionMatch = [regex]::Match($content, '<Version[^>]*>(\d+\.\d+\.\d+)</Version>')
    if ($versionMatch.Success) {
        $currentVersion = $versionMatch.Groups[1].Value
        Write-Output "Found version $currentVersion in Directory.Build.props"
    }
}

# Try to read existing version from Version.props if it exists
if (Test-Path $versionPropsPath) {
    $content = Get-Content $versionPropsPath -Raw
    $versionMatch = [regex]::Match($content, '<VersionFromProps>(\d+\.\d+\.\d+)</VersionFromProps>')
    if ($versionMatch.Success) {
        $currentVersion = $versionMatch.Groups[1].Value
        Write-Output "Found version $currentVersion in Version.props"
    }
}

# Parse the version into components
$versionParts = $currentVersion.Split('.')
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$patch = [int]$versionParts[2]

# Increment patch version
$patch += 1
$newVersion = "$major.$minor.$patch"
Write-Output "Incrementing version from $currentVersion to $newVersion"

# Create a new Version.props file
$versionPropsContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Project>
  <PropertyGroup>
    <VersionFromProps>$newVersion</VersionFromProps>
  </PropertyGroup>
</Project>
"@

# Write the new version file
$versionPropsContent | Out-File -FilePath $versionPropsPath -Encoding utf8 -Force
Write-Output "Created Version.props with version $newVersion"

# Also create a plain version.txt file for easier reading
$newVersion | Out-File -FilePath (Join-Path $scriptDir "version.txt") -Force
Write-Output "Created version.txt with version $newVersion"

# After building packages and copying them to the LocalNuget folder, 
# Create symbolic links for -dev packages
Write-Output "Looking for packages in $localNugetPath..."
$coreLibraryPackages = Get-ChildItem -Path $localNugetPath -Filter "Stickelt.CoreLibrary.$newVersion*.nupkg"
$coreComponentsPackages = Get-ChildItem -Path $localNugetPath -Filter "Stickelt.CoreComponents.$newVersion*.nupkg"

# Create 'latest-dev' package symbolic links (will be overwritten each time)
if ($coreLibraryPackages) {
    $latestCorePath = Join-Path $localNugetPath "Stickelt.CoreLibrary.latest-dev.nupkg"
    $wildcardCorePath = Join-Path $localNugetPath "Stickelt.CoreLibrary.1.0.nupkg"
    $latestCoreLibrary = $coreLibraryPackages | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    # Remove old symbolic link if it exists
    if (Test-Path $latestCorePath) {
        Remove-Item $latestCorePath -Force
    }
    
    # Remove old wildcard package if it exists
    if (Test-Path $wildcardCorePath) {
        Remove-Item $wildcardCorePath -Force
    }
    
    # Create copy (not symlink, as NuGet doesn't handle symlinks well)
    Copy-Item $latestCoreLibrary.FullName -Destination $latestCorePath -Force
    Copy-Item $latestCoreLibrary.FullName -Destination $wildcardCorePath -Force
    Write-Output "Created latest-dev package: $latestCorePath"
    Write-Output "Created wildcard package: $wildcardCorePath"
}

if ($coreComponentsPackages) {
    $latestComponentsPath = Join-Path $localNugetPath "Stickelt.CoreComponents.latest-dev.nupkg"
    $wildcardComponentsPath = Join-Path $localNugetPath "Stickelt.CoreComponents.1.0.nupkg"
    $latestCoreComponents = $coreComponentsPackages | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    # Remove old symbolic link if it exists
    if (Test-Path $latestComponentsPath) {
        Remove-Item $latestComponentsPath -Force
    }
    
    # Remove old wildcard package if it exists
    if (Test-Path $wildcardComponentsPath) {
        Remove-Item $wildcardComponentsPath -Force
    }
    
    # Create copy (not symlink, as NuGet doesn't handle symlinks well)
    Copy-Item $latestCoreComponents.FullName -Destination $latestComponentsPath -Force
    Copy-Item $latestCoreComponents.FullName -Destination $wildcardComponentsPath -Force
    Write-Output "Created latest-dev package: $latestComponentsPath"
    Write-Output "Created wildcard package: $wildcardComponentsPath"
}

# Create fixed version packages for easier referencing
$latestCoreLibraryPackage = Get-ChildItem -Path "C:\dev\2025development\CoreLibrary\bin\Release\*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$latestCoreComponentsPackage = Get-ChildItem -Path "C:\dev\2025development\CoreComponents\bin\Release\*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Define fixed version package paths
$fixedVersionCoreLibraryPath = "C:\dev\LocalNuGet\Stickelt.CoreLibrary.1.0.0.nupkg"
$fixedVersionCoreComponentsPath = "C:\dev\LocalNuGet\Stickelt.CoreComponents.1.0.0.nupkg"

# Create fixed version packages (overwriting any existing ones)
if ($latestCoreLibraryPackage) {
    Write-Host "Creating fixed version package for CoreLibrary at $fixedVersionCoreLibraryPath"
    Copy-Item -Path $latestCoreLibraryPackage.FullName -Destination $fixedVersionCoreLibraryPath -Force
}

if ($latestCoreComponentsPackage) {
    Write-Host "Creating fixed version package for CoreComponents at $fixedVersionCoreComponentsPath" 
    Copy-Item -Path $latestCoreComponentsPackage.FullName -Destination $fixedVersionCoreComponentsPath -Force
} 
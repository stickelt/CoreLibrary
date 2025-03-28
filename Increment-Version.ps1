# Define params (must be at the top of the script)
param(
    [switch]$IncrementVersion = $true,  # Force increment by default
    [switch]$VisualStudioBuild = $false # Flag to indicate VS is building
)

# Define common paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$versionPropsPath = Join-Path $scriptDir "Version.props"
$lockFilePath = Join-Path $scriptDir "VersionUpdate.lock"

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
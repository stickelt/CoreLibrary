# Define paths
$csprojPath = ".\CoreLibrary.csproj"
$versionPropsPath = ".\Version.props"
$logFilePath = ".\VersionSync.log"

# Function to write log messages
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFilePath -Encoding ascii
    Write-Host $message
}

Write-Log "Starting Version.props sync script..."

# Ensure .csproj file exists
if (-Not (Test-Path $csprojPath)) {
    Write-Log "ERROR: .csproj file NOT found!"
    exit 1
}

# Function to create a new Version.props XML structure
function New-VersionPropsXml {
    $newXml = New-Object System.Xml.XmlDocument
    $declaration = $newXml.CreateXmlDeclaration("1.0", "utf-8", $null)
    $newXml.AppendChild($declaration) | Out-Null

    $projectNode = $newXml.CreateElement("Project")
    $propertyGroupNode = $newXml.CreateElement("PropertyGroup")
    $projectNode.AppendChild($propertyGroupNode) | Out-Null
    $newXml.AppendChild($projectNode) | Out-Null

    return $newXml
}

# Ensure Version.props exists, or create an empty XML structure
if (-Not (Test-Path $versionPropsPath)) {
    Write-Log "Version.props not found, creating a new one."
    $versionPropsXml = New-VersionPropsXml
    $versionPropsXml.Save($versionPropsPath)
}

# Load XML content
[xml]$csprojXml = Get-Content $csprojPath -Encoding utf8
[xml]$versionPropsXml = Get-Content $versionPropsPath -Encoding utf8

# Ensure Version.props has a valid structure
if (-not $versionPropsXml.Project -or -not $versionPropsXml.Project.PropertyGroup) {
    Write-Log "ERROR: Invalid Version.props structure. Recreating..."
    $versionPropsXml = New-VersionPropsXml
    $versionPropsXml.Save($versionPropsPath)
}

# Get the PropertyGroup node in Version.props
$versionPropsPropertyGroup = $versionPropsXml.SelectSingleNode("//PropertyGroup")
if (-not $versionPropsPropertyGroup) {
    Write-Log "ERROR: Could not find PropertyGroup node in Version.props"
    exit 1
}

# Remove all existing properties in Version.props to ensure correct order
$versionPropsPropertyGroup.RemoveAll()

# Use an **ordered list** to store package references in the exact `.csproj` order
$csprojPackages = New-Object System.Collections.ArrayList
foreach ($itemGroup in $csprojXml.Project.ItemGroup) {
    foreach ($package in $itemGroup.PackageReference) {
        $packageName = $package.Include -replace "[^a-zA-Z0-9]", ""  # Normalize name for XML
        $packageVersion = $package.Version
        if ($packageName -and $packageVersion) {
            $csprojPackages.Add([PSCustomObject]@{ Name = $packageName; Version = $packageVersion }) | Out-Null
        }
    }
}

# Insert packages **exactly in the order they appeared in .csproj**
foreach ($package in $csprojPackages) {
    Write-Log "Syncing package: $($package.Name) - $($package.Version)"
    $newNode = $versionPropsXml.CreateElement($package.Name)
    $newNode.InnerText = $package.Version
    $versionPropsPropertyGroup.AppendChild($newNode) | Out-Null
}

# Save the updated Version.props with proper formatting
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = "    "
$settings.OmitXmlDeclaration = $false
$settings.NewLineOnAttributes = $true
$settings.Encoding = [System.Text.Encoding]::ASCII

$xmlWriter = [System.Xml.XmlWriter]::Create($versionPropsPath, $settings)
$versionPropsXml.Save($xmlWriter)
$xmlWriter.Close()

Write-Log "Version.props sync completed successfully, preserving order from .csproj."

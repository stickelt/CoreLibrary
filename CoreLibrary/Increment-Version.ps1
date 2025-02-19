# Define paths
$csprojPath = ".\CoreLibrary.csproj"
$logFilePath = ".\VersionUpdate.log"

# Create log entry function
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFilePath
    Write-Host $message
}

Write-Log "Starting version increment script..."

# Ensure .csproj file exists
if (-Not (Test-Path $csprojPath)) {
    Write-Log "Error: Could not find $csprojPath"
    exit 1
}

# Read the current .csproj file
[xml]$xml = Get-Content $csprojPath

# Locate the <Version> tag inside <PropertyGroup>
$versionNode = $xml.Project.PropertyGroup.Version

if (-not $versionNode) {
    Write-Log "Error: Could not find the <Version> tag inside <PropertyGroup> in $csprojPath"
    exit 1
}

# Extract version text safely
$versionText = [string]$versionNode

# Log extracted version for debugging
Write-Log "Raw extracted version: '$versionText'"

# Handle incorrect format
if (-not $versionText -match "^\d+\.\d+\.\d+$") {
    Write-Log "Error: Version format is incorrect: '$versionText'"
    exit 1
}

# Increment the patch version
$versionParts = $versionText -split "\."
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$patch = [int]$versionParts[2]

$oldVersion = "$major.$minor.$patch"
$patch += 1
$newVersion = "$major.$minor.$patch"

#  Correct Way to Modify XML Property
$versionNode.Value = $newVersion

#  Properly Save the XML File With Formatting
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true                 # Keep indentation
$settings.IndentChars = "    "            # Use spaces for indentation
$settings.OmitXmlDeclaration = $false     # Keep XML declaration

$xmlWriter = [System.Xml.XmlWriter]::Create($csprojPath, $settings)
$xml.Save($xmlWriter)
$xmlWriter.Close()

Write-Log "Version updated from $oldVersion to $newVersion"
Write-Log "Script execution completed."

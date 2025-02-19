# Define paths
$csprojPath = ".\CoreLibrary.csproj"
$logFilePath = ".\VersionUpdate.log"

# Create log entry function
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFilePath -Encoding ascii
    Write-Host $message
}

Write-Log "Starting version increment script..."

# Ensure .csproj file exists BEFORE modifying it
if (-Not (Test-Path $csprojPath)) {
    Write-Log "ERROR: .csproj file NOT found!"
    exit 1
}

# Backup the original .csproj file BEFORE making changes
$backupPath = "$csprojPath.bak"
Copy-Item -Path $csprojPath -Destination $backupPath -Force
Write-Log "Backup created at: $backupPath"

# Read the .csproj XML
[xml]$xml = Get-Content $csprojPath -Encoding utf8

# Select the first PropertyGroup node (where Version is located)
$propertyGroup = $xml.SelectSingleNode("//PropertyGroup")

# Get the Version node
$versionNode = $propertyGroup.SelectSingleNode("Version")

if (-not $versionNode) {
    Write-Log "ERROR: Could not find <Version> tag in $csprojPath!"
    exit 1
}

# Extract version text safely
$versionText = $versionNode.InnerText.Trim()
Write-Log "Extracted version: '$versionText'"

# Ensure the version format is correct
if (-not $versionText -match "^\d+\.\d+\.\d+$") {
    Write-Log "ERROR: Invalid version format: '$versionText'"
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

# Update the version
$versionNode.InnerText = $newVersion

# PROPERLY SAVE XML WITHOUT UNICODE
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = "    "  # Use spaces for indentation
$settings.OmitXmlDeclaration = $false  # Ensure XML declaration is kept
$settings.NewLineOnAttributes = $true
$settings.Encoding = [System.Text.Encoding]::ASCII  # NO UNICODE

$xmlWriter = [System.Xml.XmlWriter]::Create($csprojPath, $settings)
$xml.Save($xmlWriter)
$xmlWriter.Close()

Write-Log "Version updated from $oldVersion to $newVersion"
Write-Log "Script execution completed."

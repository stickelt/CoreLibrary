# Define common log file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFilePath = Join-Path $scriptDir "VersionUpdate.log"

# Create log entry function
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFilePath -Encoding ascii
    Write-Host $message
}

# Function to increment version in a csproj file
function Increment-ProjectVersion {
    param (
        [string]$projectPath,
        [string]$baseVersion = $null
    )
    
    Write-Log "Processing project: $projectPath"
    
    # Ensure project file exists
    if (-Not (Test-Path $projectPath)) {
        Write-Log "ERROR: Project file NOT found at $projectPath!"
        return $false
    }
    
    # Backup the original file
    $backupPath = "$projectPath.bak"
    Copy-Item -Path $projectPath -Destination $backupPath -Force
    Write-Log "Backup created at: $backupPath"
    
    # Read the project XML
    [xml]$xml = Get-Content $projectPath -Encoding utf8
    
    # Select the first PropertyGroup node
    $propertyGroup = $xml.SelectSingleNode("//PropertyGroup")
    
    # Get the Version node
    $versionNode = $propertyGroup.SelectSingleNode("Version")
    
    if (-not $versionNode) {
        Write-Log "ERROR: Could not find <Version> tag in $projectPath!"
        return $false
    }
    
    # Extract version text
    $versionText = $versionNode.InnerText.Trim()
    Write-Log "Extracted version: '$versionText'"
    
    # If baseVersion is provided, use it
    if ($baseVersion) {
        $newVersion = $baseVersion
        Write-Log "Setting version to: $newVersion (from baseVersion parameter)"
    } else {
        # Increment the patch version
        if (-not $versionText -match "^\d+\.\d+\.\d+$") {
            Write-Log "ERROR: Invalid version format: '$versionText'"
            return $false
        }
        
        $versionParts = $versionText -split "\."
        $major = [int]$versionParts[0]
        $minor = [int]$versionParts[1]
        $patch = [int]$versionParts[2]
        $oldVersion = "$major.$minor.$patch"
        $patch += 1
        $newVersion = "$major.$minor.$patch"
    }
    
    # Update the version
    $versionNode.InnerText = $newVersion
    
    # Save XML properly
    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Indent = $true
    $settings.IndentChars = "    "
    $settings.OmitXmlDeclaration = $false
    $settings.NewLineOnAttributes = $true
    $settings.Encoding = [System.Text.Encoding]::ASCII
    
    $xmlWriter = [System.Xml.XmlWriter]::Create($projectPath, $settings)
    $xml.Save($xmlWriter)
    $xmlWriter.Close()
    
    Write-Log "Updated version to: $newVersion in $projectPath"
    return $newVersion
}

Write-Log "Starting consolidated version increment script..."

# Process CoreLibrary
$coreLibraryPath = Join-Path $scriptDir "CoreLibrary\CoreLibrary.csproj"
$newLibraryVersion = Increment-ProjectVersion -projectPath $coreLibraryPath

# Process CoreComponents with the same version
$coreComponentsPath = Join-Path $scriptDir "CoreComponents\CoreComponents.csproj"
Increment-ProjectVersion -projectPath $coreComponentsPath -baseVersion $newLibraryVersion

Write-Log "Consolidated script execution completed." 
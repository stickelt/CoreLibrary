# Define paths
$csprojPath = ".\CoreLibrary.csproj"
$versionPropsPath = ".\Version.props"
$logFilePath = ".\VersionSync.log"

# Create log entry function
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

# Function to ensure proper XML structure
function New-VersionPropsXml {
    $newXml = New-Object System.Xml.XmlDocument
    $declaration = $newXml.CreateXmlDeclaration("1.0", "utf-8", $null)
    $newXml.AppendChild($declaration) | Out-Null
    
    $projectNode = $newXml.CreateElement("Project")
    $itemGroupNode = $newXml.CreateElement("ItemGroup")
    $projectNode.AppendChild($itemGroupNode) | Out-Null
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
if (-not $versionPropsXml.Project -or -not $versionPropsXml.Project.ItemGroup) {
    Write-Log "ERROR: Invalid Version.props structure. Recreating..."
    $versionPropsXml = New-VersionPropsXml
    $versionPropsXml.Save($versionPropsPath)
}

# Get the ItemGroup node in Version.props
$versionPropsItemGroup = $versionPropsXml.SelectSingleNode("//ItemGroup")
if (-not $versionPropsItemGroup) {
    Write-Log "ERROR: Could not find ItemGroup node in Version.props"
    exit 1
}

# Get all PackageReferences from .csproj
$csprojPackages = @{}
foreach ($itemGroup in $csprojXml.Project.ItemGroup) {
    foreach ($package in $itemGroup.PackageReference) {
        $packageName = $package.Include
        $packageVersion = $package.Version
        if ($packageName -and $packageVersion) {
            $csprojPackages[$packageName] = $packageVersion
        }
    }
}

# Get all PackageVersion entries from Version.props
$versionPropsPackages = @{}
$existingPackages = $versionPropsItemGroup.SelectNodes("PackageVersion")
if ($existingPackages) {
    foreach ($packageNode in $existingPackages) {
        $packageName = $packageNode.GetAttribute("Include")
        $packageVersion = $packageNode.GetAttribute("Version")
        if ($packageName -and $packageVersion) {
            $versionPropsPackages[$packageName] = $packageVersion
        }
    }
}

# Insert/Update packages in Version.props
foreach ($package in $csprojPackages.Keys) {
    $existingNode = $versionPropsItemGroup.SelectSingleNode("PackageVersion[@Include='$package']")
    if ($existingNode) {
        $currentVersion = $existingNode.GetAttribute("Version")
        if ($currentVersion -ne $csprojPackages[$package]) {
            Write-Log "Updating $package from $currentVersion to $($csprojPackages[$package])"
            $existingNode.SetAttribute("Version", $csprojPackages[$package])
        }
    } else {
        Write-Log "Inserting new package: $package - $($csprojPackages[$package])"
        $newNode = $versionPropsXml.CreateElement("PackageVersion")
        $newNode.SetAttribute("Include", $package)
        $newNode.SetAttribute("Version", $csprojPackages[$package])
        $versionPropsItemGroup.AppendChild($newNode) | Out-Null
    }
}

# Delete packages from Version.props that no longer exist in .csproj
$nodesToRemove = $versionPropsItemGroup.SelectNodes("PackageVersion") | 
    Where-Object { -not $csprojPackages.ContainsKey($_.GetAttribute("Include")) }
foreach ($node in $nodesToRemove) {
    Write-Log "Deleting package: $($node.GetAttribute("Include")) (not found in .csproj)"
    $versionPropsItemGroup.RemoveChild($node) | Out-Null
}

# Save the updated Version.props with formatting
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = "    "
$settings.OmitXmlDeclaration = $false
$settings.NewLineOnAttributes = $true
$settings.Encoding = [System.Text.Encoding]::ASCII

$xmlWriter = [System.Xml.XmlWriter]::Create($versionPropsPath, $settings)
$versionPropsXml.Save($xmlWriter)
$xmlWriter.Close()

Write-Log "Version.props sync completed successfully."

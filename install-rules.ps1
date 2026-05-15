param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("codex", "cursor", "windsurf", "claude", "copilot", "aider", "all")]
    [string]$Agent,

    [Parameter(Mandatory = $true)]
    [string]$SourceBaseUrl,

    [string]$InstallPath = ".",

    [switch]$Force
)

# install-rules.ps1
# Example:
# powershell -ExecutionPolicy Bypass -File install-rules.ps1 -Agent codex -SourceBaseUrl https://raw.githubusercontent.com/OWNER/REPO/main
# SourceBaseUrl also accepts a local repository path for offline installs and tests.

$ErrorActionPreference = "Stop"

function Normalize-BaseUrl {
    param([string]$Source)

    if (Test-Path $Source) {
        return (Resolve-Path -Path $Source).Path
    }

    return $Source.TrimEnd("/")
}

function Test-HttpSource {
    param([string]$Source)

    return $Source -match "^https?://"
}

function Get-TargetPath {
    param(
        [string]$Root,
        [string]$RelativePath
    )

    $NormalizedRelativePath = $RelativePath -replace "/", [System.IO.Path]::DirectorySeparatorChar
    return Join-Path -Path $Root -ChildPath $NormalizedRelativePath
}

function Download-RepoFile {
    param(
        [string]$BaseUrl,
        [string]$RelativePath,
        [string]$DestinationRoot,
        [bool]$Overwrite
    )

    $SourcePath = $RelativePath -replace "\\", "/"
    $TargetPath = Get-TargetPath -Root $DestinationRoot -RelativePath $RelativePath
    $TargetDirectory = Split-Path -Path $TargetPath -Parent

    if ($TargetDirectory) {
        New-Item -ItemType Directory -Force -Path $TargetDirectory | Out-Null
    }

    if ((Test-Path $TargetPath) -and (-not $Overwrite)) {
        Write-Host "Skipped existing $RelativePath. Use -Force to overwrite."
        return
    }

    if (Test-HttpSource -Source $BaseUrl) {
        $Uri = "$BaseUrl/$SourcePath"
        Invoke-WebRequest -Uri $Uri -OutFile $TargetPath -UseBasicParsing
    }
    else {
        $LocalSourcePath = Get-TargetPath -Root $BaseUrl -RelativePath $RelativePath

        if (-not (Test-Path $LocalSourcePath)) {
            throw "Source file not found: $LocalSourcePath"
        }

        Copy-Item -LiteralPath $LocalSourcePath -Destination $TargetPath -Force
    }

    Write-Host "Installed $RelativePath"
}

function Get-Manifest {
    param(
        [string]$BaseUrl,
        [string]$DestinationRoot,
        [bool]$Overwrite
    )

    $ManifestRelativePath = ".ai/manifest.json"
    Download-RepoFile -BaseUrl $BaseUrl -RelativePath $ManifestRelativePath -DestinationRoot $DestinationRoot -Overwrite $Overwrite

    $ManifestPath = Get-TargetPath -Root $DestinationRoot -RelativePath $ManifestRelativePath
    $ManifestContent = Get-Content -Path $ManifestPath -Raw -Encoding UTF8
    return $ManifestContent | ConvertFrom-Json
}

$ResolvedInstallPath = Resolve-Path -Path $InstallPath -ErrorAction SilentlyContinue

if (-not $ResolvedInstallPath) {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
    $ResolvedInstallPath = Resolve-Path -Path $InstallPath
}

$InstallRoot = $ResolvedInstallPath.Path
$BaseUrl = Normalize-BaseUrl -Source $SourceBaseUrl
$Manifest = Get-Manifest -BaseUrl $BaseUrl -DestinationRoot $InstallRoot -Overwrite $Force.IsPresent

$SharedFiles = @($Manifest.sharedFiles) | Where-Object { $_ -ne ".ai/manifest.json" }

foreach ($file in $SharedFiles) {
    Download-RepoFile -BaseUrl $BaseUrl -RelativePath $file -DestinationRoot $InstallRoot -Overwrite $Force.IsPresent
}

if ($Agent -eq "all") {
    $SelectedAgents = @($Manifest.nativeAdapters.PSObject.Properties.Name)
}
else {
    $SelectedAgents = @($Agent)
}

foreach ($agentKey in $SelectedAgents) {
    $AdapterProperty = $Manifest.nativeAdapters.PSObject.Properties[$agentKey]

    if (-not $AdapterProperty) {
        throw "Unknown agent '$agentKey' in manifest."
    }

    $Adapter = $AdapterProperty.Value

    Download-RepoFile -BaseUrl $BaseUrl -RelativePath $Adapter.path -DestinationRoot $InstallRoot -Overwrite $Force.IsPresent
}

Write-Host ""
Write-Host "Installed AI rules for agent: $Agent"
Write-Host "Target: $InstallRoot"

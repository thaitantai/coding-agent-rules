param(
    [ValidateSet("all", "codex", "cursor", "windsurf", "claude", "copilot", "aider")]
    [string]$Agent = "all"
)

# sync-rules.ps1
# Chay: powershell -ExecutionPolicy Bypass -File sync-rules.ps1 -Agent codex

$RulesDir = ".ai\rules"
$CoreFile = ".ai\agent-core.md"
$RulesIndexFile = ".ai\rules-index.md"
$ReferenceIndexFile = ".ai\reference-index.md"
$ManifestFile = ".ai\manifest.json"

if (-not (Test-Path $RulesDir)) {
    Write-Host "Khong tim thay thu muc $RulesDir" -ForegroundColor Red
    Write-Host "Hay chay script nay tu thu muc goc cua project." -ForegroundColor Yellow
    exit 1
}

$RequiredFiles = @($CoreFile, $RulesIndexFile, $ReferenceIndexFile, $ManifestFile)

foreach ($file in $RequiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "Khong tim thay file bat buoc $file" -ForegroundColor Red
        exit 1
    }
}

$RuleFiles = Get-ChildItem "$RulesDir\*.md" | Sort-Object Name

if ($RuleFiles.Count -eq 0) {
    Write-Host "Khong co file .md nao trong $RulesDir" -ForegroundColor Red
    exit 1
}

$AdapterContent = @'
# AI Agent Native Adapter

This file is intentionally short. It is the native entrypoint for this coding agent.
Do not treat it as the full rulebook.

## Load Protocol
Before changing files:

1. Read `.ai/agent-core.md`.
2. Infer the task from user intent, likely touched files, and implementation risk.
3. Read `.ai/rules-index.md`.
4. Load only the matching rule modules from `.ai/rules/*.md`.
5. Read `.ai/reference-index.md` only when mature reference repositories would improve architecture or code-quality judgment.
6. If the task is ambiguous, inspect relevant files first, then select the smallest safe rule set.

## Hard Requirements
- Do not load every rule module by default.
- Do not edit generated native adapter files manually.
- Edit `.ai/agent-core.md`, `.ai/rules-index.md`, `.ai/reference-index.md`, or `.ai/rules/*.md`, then run `sync-rules.ps1`.
- Treat `.ai/reference-index.md` as advisory knowledge, not mandatory policy.
- If a rule was not loaded and later becomes relevant, load it before continuing.
'@

$NativeTargets = [ordered]@{
    "codex" = @{
        Path = "AGENTS.md"
        Name = "OpenAI Codex"
    }
    "cursor" = @{
        Path = ".cursorrules"
        Name = "Cursor"
    }
    "windsurf" = @{
        Path = ".windsurfrules"
        Name = "Windsurf"
    }
    "claude" = @{
        Path = ".claude\CLAUDE.md"
        Name = "Claude Code"
    }
    "copilot" = @{
        Path = ".github\copilot-instructions.md"
        Name = "GitHub Copilot"
    }
    "aider" = @{
        Path = "CONVENTIONS.md"
        Name = "Aider"
    }
}

$GeneratedMirrorTargets = @(
    ".codex\AGENT.md",
    ".cursor\AGENT.md",
    ".windsurf\AGENT.md",
    ".claude\AGENT.md",
    ".copilot\AGENT.md",
    ".aider\AGENT.md"
)

foreach ($target in $GeneratedMirrorTargets) {
    if (Test-Path $target) {
        Remove-Item -Path $target -Force
    }
}

$GeneratedMirrorDirectories = @(".codex", ".cursor", ".windsurf", ".copilot", ".aider")

foreach ($directory in $GeneratedMirrorDirectories) {
    if ((Test-Path $directory) -and ((Get-ChildItem -Force -Path $directory).Count -eq 0)) {
        Remove-Item -Path $directory -Force
    }
}

$SelectedAgents = if ($Agent -eq "all") {
    $NativeTargets.Keys
}
else {
    @($Agent)
}

foreach ($agentKey in $SelectedAgents) {
    $target = $NativeTargets[$agentKey].Path
    $Directory = Split-Path -Path $target -Parent

    if ($Directory) {
        New-Item -ItemType Directory -Force -Path $Directory | Out-Null
    }

    $AdapterContent | Set-Content -Path $target -Encoding UTF8
    Write-Host "Synced $target ($($NativeTargets[$agentKey].Name))"
}

Write-Host ""
Write-Host "Native adapter sync complete." -ForegroundColor Green

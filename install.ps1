[CmdletBinding()]
param(
    [switch]$Codex,
    [switch]$Claude,
    [switch]$Cursor,
    [switch]$Kiro,
    [switch]$LegacyCodex,
    [switch]$Yes,
    [string]$InstallHome
)

$ErrorActionPreference = "Stop"
$DefaultRepoArchiveUrl = "https://github.com/tbladh/engram-skill/archive/refs/heads/main.zip"
$ArchiveTempDir = $null
$RenderRoot = $null

function Read-Defaults {
    param([string]$Path)

    $values = @{}
    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if (!$trimmed -or $trimmed.StartsWith("#")) {
            continue
        }
        $key, $value = $trimmed -split "=", 2
        if (!$value) {
            throw "Invalid config line: $line"
        }
        $values[$key.Trim()] = $value.Trim()
    }
    return $values
}

function Resolve-RepoRoot {
    $localRoot = $PSScriptRoot
    if ($localRoot -and (Test-Path -LiteralPath (Join-Path $localRoot "config/defaults.env"))) {
        return $localRoot
    }

    $archiveUrl = if ($env:ENGRAM_REPO_ARCHIVE_URL) { $env:ENGRAM_REPO_ARCHIVE_URL } else { $DefaultRepoArchiveUrl }
    $script:ArchiveTempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("engram-install-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $script:ArchiveTempDir | Out-Null
    $archivePath = Join-Path $script:ArchiveTempDir "repo.zip"

    Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath
    Expand-Archive -LiteralPath $archivePath -DestinationPath $script:ArchiveTempDir
    $root = Get-ChildItem -LiteralPath $script:ArchiveTempDir -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "config/defaults.env") } |
        Select-Object -First 1
    if (!$root) {
        throw "Could not find an Engram repository in $archiveUrl."
    }
    return $root.FullName
}

function Invoke-Python {
    param([string[]]$Arguments)

    $candidates = @(
        @{ Command = "python3"; Prefix = @() },
        @{ Command = "python"; Prefix = @() },
        @{ Command = "py"; Prefix = @("-3") }
    )
    foreach ($candidate in $candidates) {
        if (Get-Command $candidate.Command -ErrorAction SilentlyContinue) {
            & $candidate.Command @($candidate.Prefix + $Arguments)
            if ($LASTEXITCODE -ne 0) {
                throw "Python failed with exit code $LASTEXITCODE."
            }
            return
        }
    }
    throw "Engram installer needs Python 3, but no Python launcher was found on PATH."
}

function Confirm-Replace {
    param([string]$Harness, [string]$Path)

    if (!(Test-Path -LiteralPath $Path) -or $Yes) {
        return $true
    }
    if (![Environment]::UserInteractive) {
        Write-Warning "Skipped ${Harness}: installer input is not interactive. Rerun with -Yes to replace $Path."
        return $false
    }
    try {
        if ([Console]::IsInputRedirected) {
            Write-Warning "Skipped ${Harness}: installer input is not interactive. Rerun with -Yes to replace $Path."
            return $false
        }
    } catch {
        Write-Warning "Skipped ${Harness}: installer input could not be checked. Rerun with -Yes to replace $Path."
        return $false
    }
    $reply = Read-Host "Replace existing $Harness install at $Path? [y/N]"
    return $reply -match "^(y|yes)$"
}

function Install-One {
    param(
        [string]$Harness,
        [string]$RootDir,
        [string]$SkillName,
        [string]$RenderedSkillDir
    )

    New-Item -ItemType Directory -Force -Path $RootDir | Out-Null
    $destination = Join-Path $RootDir $SkillName
    if (!(Confirm-Replace -Harness $Harness -Path $destination)) {
        Write-Output "Skipped $Harness."
        return
    }

    $stage = Join-Path $RootDir (".$SkillName.new.$PID")
    $backup = Join-Path $RootDir (".$SkillName.previous.$PID")
    Remove-Item -LiteralPath $stage, $backup -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -LiteralPath $RenderedSkillDir -Destination $stage -Recurse -Force

    if (Test-Path -LiteralPath $destination) {
        Move-Item -LiteralPath $destination -Destination $backup
    }
    try {
        Move-Item -LiteralPath $stage -Destination $destination
    } catch {
        if (Test-Path -LiteralPath $backup) {
            Move-Item -LiteralPath $backup -Destination $destination
        }
        throw "Could not install $Harness; restored the previous install."
    }

    Remove-Item -LiteralPath $backup -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "Installed ${Harness}: $destination"
}

try {
    if ([string]::IsNullOrWhiteSpace($InstallHome)) {
        $InstallHome = if ($env:ENGRAM_INSTALL_HOME) { $env:ENGRAM_INSTALL_HOME } else { [Environment]::GetFolderPath("UserProfile") }
    }

    $repoRoot = Resolve-RepoRoot
    $config = Read-Defaults -Path (Join-Path $repoRoot "config/defaults.env")
    $RenderRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("engram-render-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $RenderRoot | Out-Null
    $renderArgs = @(
        (Join-Path $repoRoot "scripts/render_skill.py"),
        "--repo-root", $repoRoot,
        "--output-dir", $RenderRoot
    )
    $renderedSkillDir = ((Invoke-Python -Arguments $renderArgs | Select-Object -Last 1) -as [string]).Trim()
    if (!(Test-Path -LiteralPath $renderedSkillDir -PathType Container)) {
        throw "Rendered skill directory not found: $renderedSkillDir"
    }

    $targets = @()
    if ($Codex) { $targets += "codex" }
    if ($Claude) { $targets += "claude" }
    if ($Cursor) { $targets += "cursor" }
    if ($Kiro) { $targets += "kiro" }
    if (!$targets) { $targets = @("codex", "claude", "cursor", "kiro") }

    foreach ($target in $targets) {
        switch ($target) {
            "codex" { Install-One -Harness "Codex" -RootDir (Join-Path $InstallHome ".agents/skills") -SkillName $config.PRODUCT_NAME -RenderedSkillDir $renderedSkillDir }
            "claude" { Install-One -Harness "Claude" -RootDir (Join-Path $InstallHome ".claude/skills") -SkillName $config.PRODUCT_NAME -RenderedSkillDir $renderedSkillDir }
            "cursor" { Install-One -Harness "Cursor" -RootDir (Join-Path $InstallHome ".cursor/skills") -SkillName $config.PRODUCT_NAME -RenderedSkillDir $renderedSkillDir }
            "kiro" { Install-One -Harness "Kiro" -RootDir (Join-Path $InstallHome ".kiro/skills") -SkillName $config.PRODUCT_NAME -RenderedSkillDir $renderedSkillDir }
        }
    }

    if ($LegacyCodex) {
        $legacyBase = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $InstallHome ".codex" }
        Install-One -Harness "Codex legacy" -RootDir (Join-Path $legacyBase "skills") -SkillName $config.PRODUCT_NAME -RenderedSkillDir $renderedSkillDir
    }
} finally {
    if ($ArchiveTempDir) { Remove-Item -LiteralPath $ArchiveTempDir -Recurse -Force -ErrorAction SilentlyContinue }
    if ($RenderRoot) { Remove-Item -LiteralPath $RenderRoot -Recurse -Force -ErrorAction SilentlyContinue }
}

[CmdletBinding()]
param(
    [string]$Profile = "core",
    [ValidateSet("claude", "antigravity", "gemini", "agents", "codex", "copilot", "")]
    [string]$Client = "",
    [string]$Target = "",
    [ValidateSet("link", "plugin")]
    [string]$Mode = "link",
    [string]$PluginName = "sk-engineering-toolbox",
    [switch]$Prune,
    [switch]$Force,
    [switch]$List,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ProfilesPath = Join-Path $RepoRoot "profiles.json"
$SkillsRoot = Join-Path $RepoRoot "skills"
$RulesCorePath = Join-Path $RepoRoot "rules\sk-core.md"

if (-not (Test-Path -LiteralPath $ProfilesPath)) {
    Write-Error "profiles.json not found at $ProfilesPath"
    exit 1
}

$Config = Get-Content -LiteralPath $ProfilesPath -Raw -Encoding UTF8 | ConvertFrom-Json

$PillarMap = @{}
foreach ($p in $Config.pillars) {
    $PillarMap[[int]$p.number] = @($p.skills)
}

$ProfileMap = @{}
foreach ($prop in $Config.profiles.PSObject.Properties) {
    $ProfileMap[$prop.Name] = $prop.Value
}

function Get-SkillMeta {
    param([string]$SkillName)
    $mdPath = Join-Path $SkillsRoot "$SkillName\SKILL.md"
    $descLen = 0
    $isExplicit = $false
    if (Test-Path -LiteralPath $mdPath) {
        $raw = [System.IO.File]::ReadAllText($mdPath, [System.Text.Encoding]::UTF8)
        if ($raw -match "(?s)^---\r?\n(.*?)\r?\n---") {
            $fm = $Matches[1]
            foreach ($line in ($fm -split "\r?\n")) {
                if ($line -match "^\s*description:\s*(.+)$") {
                    $val = $Matches[1].Trim()
                    if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
                        if ($val.Length -ge 2) {
                            $val = $val.Substring(1, $val.Length - 2)
                        }
                    }
                    $descLen = $val.Length
                }
                elseif ($line -match "^\s*disable-model-invocation:\s*true\s*$") {
                    $isExplicit = $true
                }
            }
        }
    }
    return [PSCustomObject]@{
        Name       = $SkillName
        DescChars  = $descLen
        IsExplicit = $isExplicit
    }
}

$MetaCache = @{}
Get-ChildItem -LiteralPath $SkillsRoot -Directory -Filter "sk-*" | Sort-Object Name | ForEach-Object {
    $MetaCache[$_.Name] = Get-SkillMeta -SkillName $_.Name
}

function Resolve-SingleProfile {
    param(
        [string]$Name,
        [System.Collections.Generic.HashSet[string]]$Visiting,
        [System.Collections.Generic.List[string]]$Ordered,
        [System.Collections.Generic.HashSet[string]]$Seen
    )
    if (-not $ProfileMap.ContainsKey($Name)) {
        throw "Unknown profile '$Name'. Run with -List to see available profiles."
    }
    if (-not $Visiting.Add($Name)) {
        throw "Cycle detected while resolving profile '$Name'."
    }
    $prof = $ProfileMap[$Name]

    if ($prof.PSObject.Properties.Match("extends").Count -gt 0 -and $prof.extends) {
        foreach ($parent in $prof.extends) {
            Resolve-SingleProfile -Name $parent -Visiting $Visiting -Ordered $Ordered -Seen $Seen
        }
    }
    if ($prof.PSObject.Properties.Match("pillars").Count -gt 0 -and $prof.pillars) {
        foreach ($pNum in $prof.pillars) {
            $num = [int]$pNum
            if (-not $PillarMap.ContainsKey($num)) {
                throw "Unknown pillar '$num' in profile '$Name'."
            }
            foreach ($sk in $PillarMap[$num]) {
                if ($Seen.Add($sk)) { [void]$Ordered.Add($sk) }
            }
        }
    }
    if ($prof.PSObject.Properties.Match("skills").Count -gt 0 -and $prof.skills) {
        foreach ($sk in $prof.skills) {
            if ($Seen.Add($sk)) { [void]$Ordered.Add($sk) }
        }
    }
    [void]$Visiting.Remove($Name)
}

function Resolve-ProfileSpec {
    param([string]$Spec)
    $parts = @($Spec -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
    if ($parts.Count -eq 0) {
        throw "Profile parameter cannot be empty."
    }
    $ordered = New-Object 'System.Collections.Generic.List[string]'
    $seen = New-Object 'System.Collections.Generic.HashSet[string]'
    $visiting = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($p in $parts) {
        Resolve-SingleProfile -Name $p -Visiting $visiting -Ordered $ordered -Seen $seen
    }
    return @($ordered)
}

function Get-TokenStats {
    param([string[]]$Skills)
    $impChars = 0
    $impCount = 0
    $expCount = 0
    foreach ($sk in $Skills) {
        if ($MetaCache.ContainsKey($sk)) {
            $m = $MetaCache[$sk]
            if ($m.IsExplicit) {
                $expCount++
            }
            else {
                $impCount++
                $impChars += $m.DescChars
            }
        }
    }
    $tokens = [int][math]::Round($impChars / 3.7)
    return [PSCustomObject]@{
        Total         = $Skills.Count
        Implicit      = $impCount
        Explicit      = $expCount
        ImplicitChars = $impChars
        Tokens        = $tokens
    }
}

if ($List) {
    Write-Host "=== 5 Pillars ==="
    foreach ($p in ($Config.pillars | Sort-Object number)) {
        $tag = if ($p.explicitOnly) { " [explicit-only]" } else { "" }
        Write-Host ("Pillar {0}: {1} ({2} skills){3}" -f $p.number, $p.name, $p.skills.Count, $tag)
        Write-Host ("  Skills: {0}" -f ($p.skills -join ", "))
    }
    Write-Host ""
    Write-Host "=== Profiles ==="
    foreach ($prop in $Config.profiles.PSObject.Properties) {
        $resolved = Resolve-ProfileSpec -Spec $prop.Name
        $stats = Get-TokenStats -Skills $resolved
        Write-Host ("{0,-22} | {1,2} skills ({2,2} impl, {3,1} expl) | ~{4,4} tok/turn | {5}" -f `
            $prop.Name, $stats.Total, $stats.Implicit, $stats.Explicit, $stats.Tokens, $prop.Value.description)
    }
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Target) -and [string]::IsNullOrWhiteSpace($Client)) {
    Write-Error "Specify -Client <claude|antigravity|gemini|agents|codex|copilot> or -Target <path> (or run -List)."
    exit 1
}

if (-not [string]::IsNullOrWhiteSpace($Target)) {
    $ResolvedTarget = $Target
}
else {
    switch ($Mode) {
        "link" {
            switch ($Client) {
                "claude"      { $ResolvedTarget = Join-Path $HOME ".claude\skills" }
                "antigravity" { $ResolvedTarget = Join-Path $HOME ".gemini\config\skills" }
                "gemini"      { $ResolvedTarget = Join-Path $HOME ".gemini\config\skills" }
                "codex"       { $ResolvedTarget = Join-Path $HOME ".codex\skills" }
                "copilot"     { $ResolvedTarget = Join-Path $HOME ".copilot\skills" }
                "agents"      { $ResolvedTarget = Join-Path $HOME ".agents\skills" }
                default       { $ResolvedTarget = Join-Path $HOME ".agents\skills" }
            }
        }
        "plugin" {
            switch ($Client) {
                "claude"      { $ResolvedTarget = Join-Path $HOME ".claude\plugins" }
                "antigravity" { $ResolvedTarget = Join-Path $HOME ".gemini\config\plugins" }
                "gemini"      { $ResolvedTarget = Join-Path $HOME ".gemini\config\plugins" }
                "codex"       { $ResolvedTarget = Join-Path $HOME ".codex\plugins" }
                "copilot"     { $ResolvedTarget = Join-Path $HOME ".copilot\plugins" }
                "agents"      { $ResolvedTarget = Join-Path $HOME ".agents\plugins" }
                default       { $ResolvedTarget = Join-Path $HOME ".agents\plugins" }
            }
        }
    }
}

if (-not [System.IO.Path]::IsPathRooted($ResolvedTarget)) {
    $ResolvedTarget = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $ResolvedTarget))
}

$SelectedSkills = Resolve-ProfileSpec -Spec $Profile
foreach ($sk in $SelectedSkills) {
    $srcCheck = Join-Path $SkillsRoot $sk
    if (-not (Test-Path -LiteralPath $srcCheck)) {
        Write-Error "Skill directory missing in repository: $srcCheck"
        exit 1
    }
}

$Stats = Get-TokenStats -Skills $SelectedSkills
Write-Host ("Profile: {0} | Mode: {1} | Target: {2}" -f $Profile, $Mode, $ResolvedTarget)
Write-Host ("Selected: {0} skills ({1} implicit, {2} explicit) | Estimated fixed cost: ~{3} tok/turn" -f `
    $Stats.Total, $Stats.Implicit, $Stats.Explicit, $Stats.Tokens)
if ($DryRun) {
    Write-Host "[DRY-RUN] No filesystem changes will be written."
}

$SkillsDest = $ResolvedTarget
if ($Mode -eq "plugin") {
    if ($PluginName -notmatch "^[a-zA-Z0-9][a-zA-Z0-9._-]*$") {
        Write-Error "Invalid -PluginName '$PluginName'. Use only alphanumeric characters, '.', '_' or '-'."
        exit 1
    }
    if (-not (Test-Path -LiteralPath $RulesCorePath)) {
        Write-Error "Layer 0 rules file not found: $RulesCorePath"
        exit 1
    }
    $PluginRoot = Join-Path $ResolvedTarget $PluginName
    $PluginJsonPath = Join-Path $PluginRoot "plugin.json"
    $PluginRulesDir = Join-Path $PluginRoot "rules"
    $PluginAgentsPath = Join-Path $PluginRulesDir "AGENTS.md"
    $SkillsDest = Join-Path $PluginRoot "skills"

    $ManifestObj = [ordered]@{
        name        = $PluginName
        displayName = "SK Engineering Toolbox"
        description = ("{0} (profile: {1})" -f $Config.pluginDefaults.description, $Profile)
        author      = $Config.pluginDefaults.author
        homepage    = $Config.pluginDefaults.homepage
        repository  = $Config.pluginDefaults.repository
    }
    $ManifestJson = (($ManifestObj | ConvertTo-Json -Depth 4) -replace "\r\n", "`n") + "`n"

    if ($DryRun) {
        Write-Host "[WRITE] $PluginJsonPath"
        Write-Host "[COPY]  $RulesCorePath -> $PluginAgentsPath"
    }
    else {
        New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null
        New-Item -ItemType Directory -Force -Path $PluginRulesDir | Out-Null
        $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($PluginJsonPath, $ManifestJson, $Utf8NoBom)
        $RulesText = ([System.IO.File]::ReadAllText($RulesCorePath, [System.Text.Encoding]::UTF8) -replace "\r\n", "`n")
        [System.IO.File]::WriteAllText($PluginAgentsPath, $RulesText, $Utf8NoBom)
        Write-Host "[OK]    plugin.json and rules/AGENTS.md written in $PluginRoot"
    }
}
elseif (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null
}

function Normalize-TargetPath {
    param([string]$RawPath)
    if ([string]::IsNullOrWhiteSpace($RawPath)) { return "" }
    $clean = $RawPath -replace '^(\\\\\?\\|\\\?\?\\)', ''
    try { return [System.IO.Path]::GetFullPath($clean).TrimEnd('\', '/') }
    catch { return $clean.TrimEnd('\', '/') }
}

$CreatedCount = 0
$UpdatedCount = 0
$UnchangedCount = 0
$SkippedCount = 0
$PrunedCount = 0

foreach ($sk in $SelectedSkills) {
    $src = [System.IO.Path]::GetFullPath((Join-Path $SkillsRoot $sk))
    $dst = Join-Path $SkillsDest $sk
    $existing = Get-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue

    if ($null -ne $existing) {
        $isReparse = ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
        if ($isReparse) {
            $curTarget = ""
            if ($existing.PSObject.Properties.Match("Target").Count -gt 0 -and $existing.Target) {
                $tVal = if ($existing.Target -is [System.Array]) { $existing.Target[0] } else { $existing.Target }
                $curTarget = Normalize-TargetPath -RawPath ([string]$tVal)
            }
            $expectedTarget = Normalize-TargetPath -RawPath $src
            if ($curTarget -and ($curTarget.Equals($expectedTarget, [System.StringComparison]::OrdinalIgnoreCase))) {
                $UnchangedCount++
                Write-Host "[OK]     $sk"
            }
            else {
                $UpdatedCount++
                Write-Host "[UPDATE] $sk -> $src"
                if (-not $DryRun) {
                    [System.IO.Directory]::Delete($dst)
                    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
                }
            }
        }
        elseif ($Force) {
            $UpdatedCount++
            Write-Host "[REPLACE] $sk -> $src"
            if (-not $DryRun) {
                Remove-Item -LiteralPath $dst -Recurse -Force
                New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
            }
        }
        else {
            $SkippedCount++
            Write-Warning "[SKIP] $sk already exists as a real entry (use -Force to replace)"
        }
    }
    else {
        $CreatedCount++
        Write-Host "[LINK]   $sk -> $src"
        if (-not $DryRun) {
            New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
        }
    }
}

if ($Prune -and (Test-Path -LiteralPath $SkillsDest)) {
    $SelectedSet = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($sk in $SelectedSkills) { [void]$SelectedSet.Add($sk) }

    Get-ChildItem -LiteralPath $SkillsDest -Force | Where-Object { $_.Name -like "sk-*" } | ForEach-Object {
        if (-not $SelectedSet.Contains($_.Name)) {
            $isReparse = ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
            if ($isReparse) {
                $PrunedCount++
                Write-Host "[PRUNE]  $($_.Name)"
                if (-not $DryRun) {
                    [System.IO.Directory]::Delete($_.FullName)
                }
            }
            elseif ($Force) {
                $PrunedCount++
                Write-Host "[PRUNE-FORCE] $($_.Name)"
                if (-not $DryRun) {
                    Remove-Item -LiteralPath $_.FullName -Recurse -Force
                }
            }
            else {
                $SkippedCount++
                Write-Warning "[SKIP-PRUNE] $($_.Name) is a real directory (use -Force to remove)"
            }
        }
    }
}

Write-Host ""
Write-Host ("Summary: created={0}, updated={1}, ok={2}, pruned={3}, skipped={4} | Fixed cost: ~{5} tok/turn" -f `
    $CreatedCount, $UpdatedCount, $UnchangedCount, $PrunedCount, $SkippedCount, $Stats.Tokens)

# Install the skill-security-scan skill + install-guard hook into ~/.claude (or $env:CLAUDE_CONFIG_DIR).
$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$claudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Error "node is required (Claude Code hooks run on node)."
}

New-Item -ItemType Directory -Force -Path (Join-Path $claudeDir 'skills\skill-security-scan') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $claudeDir 'hooks')                       | Out-Null

Copy-Item (Join-Path $repo 'skills\skill-security-scan\SKILL.md') (Join-Path $claudeDir 'skills\skill-security-scan\SKILL.md') -Force
Copy-Item (Join-Path $repo 'hooks\skill-install-guard.js')        (Join-Path $claudeDir 'hooks\skill-install-guard.js')        -Force

node (Join-Path $repo 'install\merge-settings.js') add

Write-Host ""
Write-Host "skill-security-scan installed into $claudeDir"
Write-Host "Restart Claude Code so the install-guard hook is picked up."
Write-Host "After that, any 'install this skill/plugin' prompt auto-runs a security scan first."
Write-Host "Or scan on demand any time: /skill-security-scan <path-or-url>"

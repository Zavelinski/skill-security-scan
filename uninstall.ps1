# Remove the skill-security-scan skill + install-guard hook from ~/.claude (or $env:CLAUDE_CONFIG_DIR).
$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$claudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }

try { node (Join-Path $repo 'install\merge-settings.js') remove } catch {}

Remove-Item -Recurse -Force (Join-Path $claudeDir 'skills\skill-security-scan')   -ErrorAction SilentlyContinue
Remove-Item -Force          (Join-Path $claudeDir 'hooks\skill-install-guard.js') -ErrorAction SilentlyContinue

Write-Host "skill-security-scan uninstalled from $claudeDir."

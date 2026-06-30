#!/usr/bin/env bash
# Remove the skill-security-scan skill + install-guard hook from ~/.claude (or $CLAUDE_CONFIG_DIR).
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

node "$repo/install/merge-settings.js" remove || true

rm -rf "$claude_dir/skills/skill-security-scan"
rm -f  "$claude_dir/hooks/skill-install-guard.js"

echo "skill-security-scan uninstalled from $claude_dir."

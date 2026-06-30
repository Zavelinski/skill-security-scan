#!/usr/bin/env bash
# Install the skill-security-scan skill + install-guard hook into ~/.claude (or $CLAUDE_CONFIG_DIR).
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

command -v node >/dev/null 2>&1 || { echo "error: node is required (Claude Code hooks run on node)." >&2; exit 1; }

mkdir -p "$claude_dir/skills/skill-security-scan" "$claude_dir/hooks"

cp "$repo/skills/skill-security-scan/SKILL.md" "$claude_dir/skills/skill-security-scan/SKILL.md"
cp "$repo/hooks/skill-install-guard.js"        "$claude_dir/hooks/skill-install-guard.js"

node "$repo/install/merge-settings.js" add

echo ""
echo "skill-security-scan installed into $claude_dir"
echo "Restart Claude Code so the install-guard hook is picked up."
echo "After that, any 'install this skill/plugin' prompt auto-runs a security scan first."
echo "Or scan on demand any time: /skill-security-scan <path-or-url>"

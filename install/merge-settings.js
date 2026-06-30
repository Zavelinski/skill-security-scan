#!/usr/bin/env node
// merge-settings.js — idempotently add/remove the skill-security-scan install-guard
// UserPromptSubmit hook in ~/.claude/settings.json. Shared by install.sh and
// install.ps1 so the JSON merge logic exists once, not twice, and so we never depend
// on PowerShell's ConvertTo-Json (which can silently unwrap single-element arrays).
// Node's JSON round-trip is faithful. Usage: node merge-settings.js [add|remove]
//   Honors $CLAUDE_CONFIG_DIR (defaults to ~/.claude). Never clobbers existing hooks.

const fs = require('fs');
const path = require('path');
const os = require('os');

const action = (process.argv[2] || 'add').toLowerCase();
const claudeDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
const settingsPath = path.join(claudeDir, 'settings.json');
const hookPath = path.join(claudeDir, 'hooks', 'skill-install-guard.js');
const MARKER = 'skill-install-guard.js';
// Use the exact node binary that ran this installer, so the hook command does not
// depend on `node` being on PATH inside the hook subprocess (matters on Windows).
const command = '"' + process.execPath + '" "' + hookPath + '"';

function load() {
  try { return JSON.parse(fs.readFileSync(settingsPath, 'utf8')); }
  catch (e) { return null; }
}
function save(obj) {
  fs.writeFileSync(settingsPath, JSON.stringify(obj, null, 2) + '\n');
}

if (action === 'remove') {
  const s = load();
  if (!s || !s.hooks || !Array.isArray(s.hooks.UserPromptSubmit)) {
    console.log('no skill-security-scan install-guard hook to remove');
    return;
  }
  for (const group of s.hooks.UserPromptSubmit) {
    if (Array.isArray(group.hooks)) {
      group.hooks = group.hooks.filter(h => !(h && typeof h.command === 'string' && h.command.includes(MARKER)));
    }
  }
  s.hooks.UserPromptSubmit = s.hooks.UserPromptSubmit.filter(g => !Array.isArray(g.hooks) || g.hooks.length > 0);
  save(s);
  console.log('skill-security-scan install-guard hook removed from ' + settingsPath);
  return;
}

// action === 'add'
const s = load() || {};
s.hooks = s.hooks || {};
s.hooks.UserPromptSubmit = Array.isArray(s.hooks.UserPromptSubmit) ? s.hooks.UserPromptSubmit : [];
const ups = s.hooks.UserPromptSubmit;

const present = ups.some(group =>
  Array.isArray(group.hooks) &&
  group.hooks.some(h => h && typeof h.command === 'string' && h.command.includes(MARKER)));

if (present) {
  console.log('skill-security-scan install-guard hook already present in ' + settingsPath + ' (no change)');
} else {
  ups.push({ hooks: [{ type: 'command', command: command, timeout: 5 }] });
  save(s);
  console.log('skill-security-scan install-guard hook added to ' + settingsPath);
}

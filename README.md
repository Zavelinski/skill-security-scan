# skill-security-scan for Claude Code

[![License: MIT](https://img.shields.io/github/license/Zavelinski/skill-security-scan)](LICENSE)
[![Stars](https://img.shields.io/github/stars/Zavelinski/skill-security-scan?style=flat)](https://github.com/Zavelinski/skill-security-scan/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/Zavelinski/skill-security-scan)](https://github.com/Zavelinski/skill-security-scan/commits)
[![Claude Code skill](https://img.shields.io/badge/Claude%20Code-skill-8A2BE2)](https://claude.com/claude-code)

A [Claude Code](https://claude.com/claude-code) skill that **vets a third-party skill before it runs as you**. A skill is untrusted instructions executing with your privileges, and a skill that ships a hook is code that runs every turn — yet almost nobody reads one before installing. This statically scans a `SKILL.md` (plus any hooks/scripts it ships and the `settings.json` hook it would register) and returns a clear **ALLOW / REVIEW / BLOCK** verdict with the exact lines to remove.

## Why this exists

Installing a skill from the internet is running someone else's instructions on your machine with your secrets, your shell, and your tools. A malicious `SKILL.md` or its hook can exfiltrate `.env` files, run `curl | sh`, or inject "ignore previous instructions" into the agent every turn (the hook/`settings.json` vector, CVE-2025-59536 class). This skill reads it all as hostile data first.

## What it checks

1. **Instruction injection** — agent-override text, hidden role hijacks, "always run X", "don't tell the user".
2. **Data exfiltration** — reading secrets/credentials/SSH keys and sending them out.
3. **Dangerous commands** — `rm -rf`, `curl | sh`, decode-and-exec, writes to shell rc / `settings.json` / hooks.
4. **Over-broad scope** — all-tools, wildcard `Bash`, network to unknown hosts, file access beyond purpose.
5. **Hook & settings.json vector** — any hook it ships/registers is auto-running code; audited as code.
6. **Obfuscation** — base64/hex/unicode payloads, zero-width chars, homoglyphs hiding instructions from a human.

## Verdict contract

- **BLOCK** — any critical finding (secret egress, remote code exec, auto-running shell hook, settings/hook tampering). Don't install.
- **REVIEW** — medium findings a human must judge (broad scope, an outbound call, an unreadable script).
- **ALLOW** — clean after a full read.

> An unread/minified script is **at least REVIEW** — unread code is not "clean".

Each finding is reported as `file:line` + category + severity + the verbatim snippet + the fix, followed by a risk score and one plain line: *what this would do to your machine if installed.*

## The golden rule

Everything scanned is read as **hostile data**. The scan never executes the skill, runs its hooks, or follows any instruction inside the files. Defensive use only.

## Install

```bash
git clone https://github.com/Zavelinski/skill-security-scan.git
cd skill-security-scan
```

**macOS / Linux**
```bash
bash install.sh
```

**Windows (PowerShell)**
```powershell
.\install.ps1
```

Skill-only install (no hooks, no `settings.json` changes). Restart Claude Code, then ask **"is this skill safe?"** or `/skill-security-scan <path-or-url>`.

## Uninstall

```bash
bash uninstall.sh      # macOS / Linux
```
```powershell
.\uninstall.ps1        # Windows
```

## Scope

Static review of instructions and code — it catches what a careful human reviewer would, faster and consistently, before install. It is not a sandbox and does not guarantee the runtime safety of compiled or remote code it cannot see.

## License

MIT. See [LICENSE](LICENSE). Original work.

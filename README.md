# Workflow Audit Skill

![Visitors](https://komarev.com/ghpvc/?username=Terryc21&repo=workflow-audit&label=visitors&color=blue) ![GitHub stars](https://img.shields.io/github/stars/Terryc21/workflow-audit?style=flat) ![GitHub forks](https://img.shields.io/github/forks/Terryc21/workflow-audit?style=flat)

Built for [Stuffolio](https://stuffolio.app), an iOS/macOS inventory management app.

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that audits SwiftUI user workflows for dead ends, broken promises, and UX friction.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (Anthropic's CLI for Claude)
- Xcode (for iOS/macOS projects)

## Install

```bash
claude plugin marketplace add Terryc21/workflow-audit
claude plugin install workflow-audit
```

## Included Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **Workflow Audit** | `/workflow-audit` | 5-layer UI audit: discover entry points, trace flows, detect issues, evaluate UX, verify data wiring |
| **Plan** | `/plan --workflow-audit` | Consume audit findings into a phased fix plan with per-task prompting |
| **Rating System** | *(shared reference)* | Standardized rating format used by both skills |

## Quick Start

1. Open Claude Code in any SwiftUI project
2. Run `/workflow-audit` for a full 5-layer audit
3. Review the findings table
4. Run `/plan --workflow-audit` to generate a phased fix plan

## Using Without Claude Code

The [SKILL.md](https://github.com/Terryc21/radar-suite/blob/main/skills/workflow-audit/SKILL.md) is the methodology in markdown. You can paste it as context in any AI tool that has file access (Cursor, Windsurf, Copilot Chat, etc.) and get most of the value.

**Starter prompt for other AI tools:**

```
You are a code auditor for iOS/SwiftUI projects. I'm giving you a skill
document that describes a multi-phase UI workflow audit.

1. Read the methodology sections — they define HOW to scan
2. Follow the phase order: Discovery → Flow Tracing → Issue Detection →
   Semantic Evaluation → Data Wiring
3. For each phase, enumerate candidates FIRST, then verify each one —
   do NOT just search for known anti-patterns

Key principle: orphaned views and unwired data have no code signature
to search for. You find them by listing everything that SHOULD be
connected, then checking which ones aren't.

Here is the skill document:
[paste SKILL.md contents]

Start with Phase 1: list all view files and their navigation connections.
```

**What Claude Code adds:** Automated tool integration (Grep, Glob, Bash), multi-phase session management, finding lifecycle tracking, and cross-skill handoffs. The prompt approach gets you the scanning methodology; Claude Code automates the execution.

## Layer-by-Layer

Run individual layers when you don't need a full audit:

| Command | What it does |
|---------|-------------|
| `/workflow-audit layer1` | Discovery — find all UI entry points |
| `/workflow-audit layer2` | Trace — follow critical user paths |
| `/workflow-audit layer3` | Issues — detect dead ends, buried buttons, dismiss traps, and more |
| `/workflow-audit layer4` | Evaluate — assess user impact |
| `/workflow-audit layer5` | Data wiring — verify real data usage |
| `/workflow-audit trace "A → B → C"` | Trace a specific user flow path |
| `/workflow-audit diff` | Compare current findings against previous audit |
| `/workflow-audit fix` | Generate fixes for found issues |
| `/workflow-audit status` | Show audit progress |

## How It Works

The workflow audit uses a 5-layer approach:

1. **Pattern Discovery** — Scans for sheet triggers, navigation links, promotion cards, and context menus to build an entry point inventory
2. **Flow Tracing** — Traces critical user paths from entry to completion, documenting each step
3. **Issue Detection** — 20 categories including dead ends, buried buttons, dismiss traps, context dropping, notification fragility, sheet asymmetry, stale context, gesture-only actions, loading traps, mock data, and more. 14 automated grep-based checks (including notification type-safety and simulated delay detection) with regression canaries.
4. **Semantic Evaluation** — Evaluates from the user's perspective: discoverability, efficiency, feedback, recovery
5. **Data Wiring** — Verifies features use real data, checks for mock/hardcoded values, validates platform parity

Findings are rated using a standardized table format with Urgency, Risk, ROI, Blast Radius, and Fix Effort columns. Tables adapt to terminal width — narrow terminals get a compact view with the full table in the report file.

For how Workflow Audit differs from pattern-based tools (linters, compiler warnings, code review), and how it pairs with [Bug Prospector](https://github.com/Terryc21/bug-prospector), see [How It Works](docs/HOW_IT_WORKS.md).

## Full Plugin

Want all 22 Xcode development skills (testing, debugging, refactoring, release prep, security audit, and more)?

```bash
claude plugin marketplace add Terryc21/xcode-workflow-skills
claude plugin install xcode-workflow-skills
```

---

## Cautionary Note: AI-Powered Audit Plugins

**Plugins like `workflow-audit` are tools, not oracles.**

These plugins systematically scan your codebase using pattern matching and heuristics. They can surface real issues you'd miss manually — but they have inherent limitations:

**What they're good at:**
- Finding structural inconsistencies (orphaned code, missing handlers, type mismatches)
- Catching patterns that compile but fail silently at runtime
- Enforcing consistency across platforms (iOS vs macOS parity)
- Providing a repeatable, systematic checklist

**What they can miss:**
- Business logic correctness — a plugin can verify a button exists, not that it does the right thing
- User experience nuance — "buried" is a judgment call that depends on content height, screen size, and context
- False positives — code flagged as "orphaned" may be intentionally retained for future use
- False negatives — novel bug patterns not covered by existing checks won't be detected

**How to use them responsibly:**
- Treat findings as leads to investigate, not verdicts to act on blindly
- Verify critical findings manually before committing fixes
- Expect the plugin to evolve — today's checks won't catch tomorrow's new patterns
- Don't assume a clean audit means zero issues; it means zero *known-pattern* issues
- Review the skill's detection patterns periodically to understand what it actually checks vs what you assume it checks

**Bottom line:** An audit plugin replaces neither testing nor human review. It's a force multiplier for the reviewer, not a replacement.

## See Also

- [Stuffolio](https://stuffolio.app) -- the iOS/macOS app these skills were built for
- [Radar Suite](https://github.com/Terryc21/radar-suite) -- 7 audit skills that trace data through complete user flows
- [code-smarter](https://github.com/Terryc21/code-smarter) -- Prompt rewriting + personalized coding tutorials from your codebase
- [Bug Prospector](https://github.com/Terryc21/bug-prospector) -- Find bugs that pattern-based scanners miss
- [Xcode Workflow Skills](https://github.com/Terryc21/xcode-workflow-skills) -- Full 22-skill suite (includes both)

## License

MIT

## Author

Created by [Terry Nyberg](https://github.com/Terryc21)

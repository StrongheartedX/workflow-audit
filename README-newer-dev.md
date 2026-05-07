# Workflow Audit

**A Claude Code skill that finds dead ends and broken flows in your SwiftUI app by tracing what a real user would actually do.**

Built while shipping [Stuffolio](https://stuffolio.app), an iOS/macOS app I work on every day. Free, open source, no paid tier, no referral links.

<a href="https://buymeacoffee.com/stuffolio"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="120"></a>

If this audit catches a real problem for you, a [coffee](https://buymeacoffee.com/stuffolio) is appreciated. Issue reports about what worked or didn't are even more useful.

---

## What is this, and why might I want it?

If you're newer to Claude Code and unsure what an "audit skill" does, here's the short version.

A **skill** is a markdown file Claude Code knows how to run. When you type `/workflow-audit`, Claude follows the instructions in that skill, looks at your code, and writes you a report. You don't have to memorize anything. The skill tells Claude what to do; you read the report.

What this particular skill does: it pretends to be a user trying to do something in your app, then walks through your SwiftUI code to see if anything would block them. The kinds of problems it finds:

- Buttons that don't navigate anywhere
- Sheets you can open but can't close
- Features that exist in your code but aren't reachable from any menu
- Empty states with no way out
- Buttons that look like they do something but actually call a stub
- Features that only show up on iOS but not on macOS (or the other way around)

These are problems a code linter usually misses, because the bug is in the *connection* between files, not in any single file. Each file is fine on its own. The handoff is broken.

---

## Install

Two commands in Claude Code:

```
/plugin marketplace add Terryc21/workflow-audit
```

```
/plugin install workflow-audit@workflow-audit
```

Run them one at a time and wait for the first to confirm before running the second.

That's it. The skill is now available everywhere you use Claude Code.

---

## Your first run (start here)

If you've never run an audit, **don't start with the full 5-layer scan**. Audits read a lot of files and can use a noticeable chunk of your weekly Claude Code allocation.

Try a single layer first:

```
/workflow-audit layer1
```

This just looks for entry points: every place a user might tap to start a flow. Sheets, navigation links, dashboard buttons, context menus. The output is a list of every door into your app.

Read it. You'll learn things just from the inventory itself. If a feature you built isn't on the list, it means there's no visible way for a user to reach it.

When you're ready for more, run:

```
/workflow-audit layer3
```

Layer 3 looks for actual workflow bugs (dead ends, dismiss traps, buried buttons, fragile notifications, mock data leaking into production). The output is a rated table of findings, each citing a specific file:line in your project so you can verify them yourself.

The full 5-layer audit is `/workflow-audit` with no arguments. It runs all five phases in order and produces the most thorough report. Save it for before a release or after a major refactor.

---

## What each layer does

You can run these individually or let the full audit do them in order.

| Command | What it looks for |
|---|---|
| `/workflow-audit layer1` | **Discovery.** Every entry point in your app. Sheets, NavigationLinks, toolbar buttons, dashboard cards, context menus. Builds an inventory you can sanity-check. |
| `/workflow-audit layer2` | **Flow tracing.** Picks key user journeys and walks each one start to finish, documenting every step. |
| `/workflow-audit layer3` | **Issue detection.** 32 categories of workflow bugs: dead ends, dismiss traps, buried CTAs, sheet asymmetry, gesture-only actions, mock data, platform parity gaps, and more. |
| `/workflow-audit layer4` | **Semantic evaluation.** Looks at your flows from the user's point of view: is the discoverability okay? Is feedback timely? Can the user recover from a mistake? |
| `/workflow-audit layer5` | **Data wiring.** Checks that features actually use real data, not mock or hardcoded values. Flags features that look complete but have a stub at the bottom. |

There's also `/workflow-audit fix` (turns findings into a phased fix plan) and `/workflow-audit status` (shows progress when an audit was interrupted).

---

## What the output looks like

Every audit produces a markdown report saved to `.agents/research/` in your project. Each finding has:

- A short description of the problem
- The exact file and line where it lives
- A rating table (urgency, risk, ROI, blast radius, fix effort)
- A suggested fix when one is obvious

A real example using my own Stuffolio findings: [example audit report](skills/workflow-audit/examples/2026-04-15-workflow-audit-stuffolio.md).

The report doesn't change your code. You decide which findings to fix, defer, or ignore. The skill is there to surface candidates, not to commit changes.

---

## Why this is different from a linter

A linter looks at one file at a time and matches what it sees against a list of known patterns. It catches real bugs, but only the kinds with a code signature.

Workflow Audit goes the other direction. It lists everything that *should* be connected (every screen, every action, every flow) and then checks which ones aren't. That inverse approach catches bugs that have no code signature, like an orphaned view or an action handler that's never wired up.

A useful analogy: a linter is the building inspector confirming every wire is up to code. Workflow Audit is the home inspector who turns on the lights to see which ones don't come on.

---

## Honest about limits

This skill is a tool, not an oracle. A few things to keep in mind before you act on a finding:

- **It surfaces candidates, not verdicts.** "Buried button" is a judgment call about screen size and user attention. The skill flags candidates; you decide.
- **False positives happen.** Code flagged as "orphaned" might be intentionally retained for a feature that's not yet wired up.
- **False negatives happen.** A novel bug pattern the skill hasn't seen yet won't be detected. A clean audit means zero *known-pattern* problems, not zero problems.
- **Business logic is not in scope.** The skill can verify a button exists. It can't verify the button does the right thing when tapped.

The right way to use any audit skill: treat findings as leads to investigate, not items to fix blindly. Verify critical findings before committing.

---

## Using this without Claude Code

If you don't use Claude Code but use Cursor, Windsurf, Copilot Chat, or another AI tool with file access, you can still get most of the value. Paste the skill's methodology file ([SKILL.md](skills/workflow-audit/SKILL.md)) into your AI's context along with this prompt:

```
You are a code auditor for iOS/SwiftUI projects. I'm giving you a skill
document that describes a multi-phase UI workflow audit.

1. Read the methodology sections — they define HOW to scan
2. Follow the phase order: Discovery, Flow Tracing, Issue Detection,
   Semantic Evaluation, Data Wiring
3. For each phase, enumerate candidates FIRST, then verify each one.
   Do NOT just search for known anti-patterns.

Key principle: orphaned views and unwired data have no code signature
to search for. You find them by listing everything that SHOULD be
connected, then checking which ones aren't.

Here is the skill document:
[paste SKILL.md contents]

Start with Phase 1: list all view files and their navigation connections.
```

What Claude Code adds on top of the manual prompt: tool integration (Grep, Glob, Bash), session management across multiple phases, finding-lifecycle tracking, and handoffs to other audit skills. The prompt approach gets you the methodology; Claude Code automates the execution.

---

## Updates

The skill changes regularly. To get the latest version:

```
/plugin update workflow-audit
```

Recent release notes are in [CHANGELOG.md](CHANGELOG.md). Star the repo on GitHub to get notified of new releases.

---

## Other Claude Code skills I've built

- [code-smarter](https://github.com/Terryc21/code-smarter) — turns a file from your project into an annotated tutorial with vocabulary, quizzes, and gap analysis. Works for any language.
- [prompter](https://github.com/Terryc21/prompter) — rewrites your Claude Code prompt for clarity and fixes typos before acting.
- [bug-echo](https://github.com/Terryc21/bug-echo) — after you fix a bug, scans the codebase for similar patterns elsewhere.
- [radar-suite](https://github.com/Terryc21/radar-suite) — 6 audit skills for iOS/macOS Swift codebases. Workflow Audit complements these by tracing flows; the radars trace data, models, and visual quality.

All free, all Apache 2.0, all built while shipping Stuffolio.

---

## Requirements

- A SwiftUI project (iOS, iPadOS, or macOS). UIKit projects won't get useful findings.
- Claude Code, or any AI tool that can read files and follow markdown instructions.
- Xcode is helpful for opening flagged files but not required for the audit.

---

## Deeper documentation

Want more than the basics? See [README-detailed.md](README-detailed.md) for the previous long-form README, which covers the full methodology, version history, and how Workflow Audit pairs with [Bug Prospector](https://github.com/Terryc21/bug-prospector). The methodology itself lives in [docs/HOW_IT_WORKS.md](docs/HOW_IT_WORKS.md).

---

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

## Author

Terry Nyberg, [Coffee & Code LLC](https://stuffolio.app/).

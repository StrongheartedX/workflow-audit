# workflow-audit

![Version](https://img.shields.io/github/v/tag/Terryc21/workflow-audit?label=version) ![Last commit](https://img.shields.io/github/last-commit/Terryc21/workflow-audit) ![Stars](https://img.shields.io/github/stars/Terryc21/workflow-audit?style=flat) ![Issues](https://img.shields.io/github/issues/Terryc21/workflow-audit) ![License](https://img.shields.io/github/license/Terryc21/workflow-audit) ![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet)

**A 5-layer audit of SwiftUI user flows. Enumerates entry points, traces critical paths, detects 32 categories of workflow bug, evaluates UX impact, and verifies data wiring.**

**This checks behavior, not code style.** Most code checkers read your app one file at a time and compare it against a list of rules — is this line written correctly? workflow-audit asks a different question: *can a person actually get from here to there and finish what they came to do?*

So it walks your app the way a user would. It starts at every door into a feature — a button, a menu item, a card on the dashboard — and follows each one forward: this button opens that screen, that screen has these three actions, this action leads somewhere else. Then it asks at each step what a real person would ask. Can I get to this screen at all? Now that I'm here, is the button I need visible without scrolling? I finished the task — did anything tell me it worked? I changed my mind — can I get back out?

That's why it finds a kind of bug a file-by-file checker structurally cannot. Consider a screen you built that no button anywhere opens. Every line of that screen is correct. It compiles, it would look fine in review, and no rule is broken — the only thing wrong is that the path to it was never connected, and the shipped app quietly doesn't include the feature. The same goes for a value your app carefully calculates and a screen that carefully displays it, when the two were never wired to each other: both files pass, and the user sees a blank space.

A rule-checker can't catch either one, because nothing is written incorrectly. The problem lives in the space between the files — in the walk, not the lines.

That makes it complementary to a linter rather than competitive: they answer different questions. Linters check whether each file is written correctly, cheaply and on every save. workflow-audit checks whether the paths through your app actually work, at higher cost and before a release. **A thorough audit uses both.**

Built while shipping [Stuffolio](https://stuffolio.app) ([App Store](https://apps.apple.com/app/stuffolio/id6757168677)), an iOS/macOS app, through real App Store submission cycles. workflow-audit itself is free, open source, Apache 2.0.

*~6 min read · scan the TL;DR if you only have 30 seconds*

## Newer to Claude Code?

A **skill** is a markdown file Claude Code knows how to run. When you type `/workflow-audit`, Claude follows the instructions in this skill, walks your SwiftUI codebase across five layers, and writes you a markdown report with file:line citations. You don't have to memorize anything — the skill tells Claude what to do, you read the report.

## TL;DR

- **What:** 5-layer audit of SwiftUI user flows (Discovery → Flow Tracing → Issue Detection → Semantic Evaluation → Data Wiring). 32 issue categories.
- **Why:** Catches a class of bug that has no code signature to search for — orphan features (the view exists but no entry point reaches it) and unwired data (declared, populated, displayed, but the populator and displayer don't share a path).
- **Install:** Two `/plugin` commands in Claude Code; then `/workflow-audit` is available in any project.
- **Try first:** `/workflow-audit layer1` runs the cheapest layer (entry-point inventory) and gives you a real report in ~10 minutes.
- **Example output:** [a real 5-layer audit report on Stuffolio's codebase](skills/workflow-audit/examples/2026-04-15-workflow-audit-stuffolio.md).
- **Portable:** methodology works in Cursor, Windsurf, or any AI tool that reads files — see "Using without Claude Code" below.
- **Maturity:** Used through real App Store submission cycles on a 600-file SwiftUI codebase; CHANGELOG tracks every release.

## What workflow-audit is for vs what linters are for

**Pattern-based linters** (SwiftLint, custom rule sets) check individual files against a catalog — force unwraps, missing `@MainActor`, deprecated APIs. Fast, run on every save, catch single-file violations cheaply.

**workflow-audit** walks the paths instead, across five layers. The two bug classes it exists to catch have names in the report:

- **Orphan features** — a screen that's finished and correct, but nothing anywhere opens it. From the user's side, the feature simply isn't in the app.
- **Unwired data** — the app works out a number and a screen displays a number, but the two were never connected. The user sees a placeholder or a stale value, presented as confidently as a real one.

Both ship silently. Neither breaks a rule, so nothing flags them, and neither one crashes — the app just quietly does less than you built.

| What linters do better | What workflow-audit does better |
|---|---|
| Run on every save (cheap, fast) | Run before release (deeper, slower) |
| Catch style and pattern violations | Catch connection and data-wiring bugs |
| Single-file context | Multi-file enumeration + verification |
| Hundreds of well-understood rules | Domain-specific workflow categories |
| Mature ecosystem | Newer approach, narrower scope |

If your project already uses SwiftLint or another pattern-based audit, keep it. workflow-audit layers on top.

## The five layers

Each layer can be invoked individually or chained as a full pipeline.

| Layer | Command | What it does |
|---|---|---|
| 1. Discovery | `/workflow-audit layer1` | Builds an inventory of every UI entry point. Sheet triggers (`isPresented:`, `item:`), `NavigationLink` destinations, toolbar buttons, dashboard cards, context menus, deep-link handlers. Output is a list you can sanity-check against your mental model of the app. If something you built isn't on the list, the layer just told you the user can't reach it. |
| 2. Flow tracing | `/workflow-audit layer2` | Traces critical user journeys end to end. For each entry point in layer 1, walks the destination view, identifies its actions, follows each action's handler to the next view or modal, repeats. Documents each step with file:line citations. |
| 3. Issue detection | `/workflow-audit layer3` | 32 categories: dead ends, dismiss traps, buried CTAs, sheet asymmetry (open path exists but close path doesn't), context dropping (modal presents with stale `@Binding`), notification fragility (string-based name without symbol fallback), gesture-only actions (no keyboard equivalent on macOS), loading traps (Progress view with no timeout), mock data leaking into production, platform parity gaps, and more. 14 of the 32 are automated grep checks with regression canaries; the rest are enumerate-then-verify. |
| 4. Semantic evaluation | `/workflow-audit layer4` | Evaluates each traced flow from a user's perspective. Discoverability (can a new user find this without prior knowledge), efficiency (number of taps to complete the action), feedback (does the user know what happened), recovery (can they undo a wrong path). |
| 5. Data wiring | `/workflow-audit layer5` | Verifies features use real data. Flags features that look complete in the UI but read from a stub, hardcoded constant, or mock provider. Catches the case where a feature shipped half-done and the placeholder data was never replaced. |

Plus utility commands:

- `/workflow-audit fix` — turns findings into a phased fix plan
- `/workflow-audit status` — shows progress when an audit was interrupted
- `/workflow-audit trace "A → B → C"` — traces a specific flow path you're investigating
- `/workflow-audit diff` — compares current findings against a previous audit (useful as a regression gate)

## Install

Two commands in Claude Code, run one at a time:

```
/plugin marketplace add Terryc21/workflow-audit
```

```
/plugin install workflow-audit@workflow-audit
```

> **Why two commands?** Claude Code's slash-command dispatcher treats the second `/plugin` as text inside the first command. Run them one at a time.

After installing, try:

```
/workflow-audit layer1
```

This runs the cheapest layer (entry-point inventory) on your whole project. Finishes in ~10 minutes and produces a real report you can read — a low-commitment way to evaluate whether workflow-audit is worth a fuller run.

**Example report:** [a real 5-layer audit on Stuffolio's codebase](skills/workflow-audit/examples/2026-04-15-workflow-audit-stuffolio.md), with all 32 categories applied and real findings + fix plans.

## Using without Claude Code

The methodology is an extracted skill document; you can paste it into Cursor, Windsurf, Copilot Chat, or any other AI tool with file access. Get most of the value with a manual prompt:

```
You are a code auditor for SwiftUI projects (iOS, iPadOS, or macOS). I'm
giving you a skill document that describes a multi-layer UI workflow audit.

1. Read the methodology sections — they define HOW to scan
2. Follow the layer order: Discovery, Flow Tracing, Issue Detection,
   Semantic Evaluation, Data Wiring
3. For each layer, enumerate candidates FIRST, then verify each one.
   Do NOT just search for known anti-patterns.

Key principle: orphaned views and unwired data have no code signature
to search for. You find them by listing everything that SHOULD be
connected, then checking which ones aren't.

Here is the skill document:
[paste contents of skills/workflow-audit/SKILL.md]

Start with Layer 1: list all view files and their navigation connections.
```

What Claude Code adds on top of the manual prompt: tool integration (Grep, Glob, Bash) for the enumeration step, multi-layer session management with checkpoint/resume, finding-lifecycle tracking across runs, and cross-skill handoffs to ui-path-radar and the rest of radar-suite. The prompt approach gets you the methodology; Claude Code automates the execution.

## How to scope a run

A full 5-layer audit on a 200-600 file SwiftUI app is a meaningful token investment — typically 1-3 hours of Claude Code session. The pipeline is structured so you don't need to commit to that on every run.

**Targeted layer.** When you've just finished a refactor or shipped a new flow, run the layer that matches:

| Just changed | Run |
|---|---|
| Added a new feature with multiple screens | layer2 + layer4 |
| Refactored navigation | layer1 + layer3 |
| Touched a model that several features read | layer5 |
| Added platform-specific code | layer3 (parity gaps live there) |
| Pre-release sweep | full audit |

**Specific path.** When you have a hypothesis about a particular flow:

```
/workflow-audit trace "Dashboard → Stuff Scout → Save"
```

Audits only that path. Faster than the full discovery layer; useful when a tester reports an issue and you want to pin which layer it lives in.

**Diff mode.** After running a full audit and shipping fixes, `/workflow-audit diff` compares against the previous report. Findings that were Fixed don't reappear; new findings get marked as such. Useful as a release gate.

**Fresh vs prior history.** The default mode is fresh — each invocation scans the codebase from scratch and produces a standalone report at `.agents/research/`. `/workflow-audit diff` switches to history mode: the skill loads the most recent prior report, re-runs the layers, and only surfaces *deltas* (new findings, regressed-Fixed findings, newly-Open rows). Fresh is what you want when something fundamental changed (new architecture, new platform target) or the prior report is stale; history is what you want when you've been actively fixing rows between runs and don't want to re-read findings you've already triaged.

## Output format

Every audit writes a markdown report to `.agents/research/YYYY-MM-DD-workflow-audit-<slug>.md`. Standard format across the radar/audit ecosystem:

- File and line citations for every finding — a finding is not emitted unless it cites a location the audit actually read, so the report can't assert a problem nobody verified
- 8-column rating table: #, finding, urgency, risk-of-fix, risk-of-no-fix, ROI, blast radius, fix effort (status column added on re-displays)
- Suggested fix when one is mechanical

The report doesn't change your code. You decide which findings to fix, defer, or skip.

### Reading the reports

The 8-column rating table needs a wide terminal (~150 chars) to render as a horizontal table. In a narrower window the cells stack vertically and the report becomes harder to scan. For best readability:

- **GitHub or GitLab**: open the report file in the web UI; tables render natively.
- **Markdown viewer apps**: [Bear](https://bear.app/) (Mac/iOS, free tier; import .md as a note), [MacDown](https://macdown.uranusjr.com/) (Mac, free), [Marked 2](https://marked2app.com/) (Mac, paid) or [iA Writer](https://ia.net/writer) (Mac/iOS/Windows/Android, paid), [Obsidian](https://obsidian.md/) or [Typora](https://typora.io/) (cross-platform).
- **VS Code**: built-in Markdown Preview (cmd-shift-V on Mac).

If tables look broken in your terminal (rendered as vertical blocks instead of horizontal rows), widen the window or use one of the apps above. The data is fine; only the rendering needs more space.

## Honest limits

workflow-audit is a static analysis tool. It has real limits:

- **Logic correctness.** workflow-audit verifies a button exists, that it's reachable, that its handler runs, that the handler reads real data. It cannot verify the handler does the right thing. Wrong-but-reachable is invisible to the audit.
- **Runtime-only issues.** Concurrency races, memory pressure, OS-specific bugs, animation timing. Static analysis has structural limits.
- **Novel bug categories.** A clean audit means zero matches for the 32 detected categories. New workflow-bug shapes that haven't been added to a layer's checklist won't be caught until the next release.
- **Subjective UX.** "Is this layout good" is a judgment call. The semantic evaluation layer flags candidates (buried buttons, low feedback density) but doesn't make verdicts.

Treat findings as leads to investigate, not items to fix blindly. The `BURIED` classification flags candidates; you decide whether the screen-position is actually a problem.

**Where to look for the bugs workflow-audit won't find:** pattern-based linters (SwiftLint, etc.) catch the single-file violations; runtime profiling (Instruments, debug builds with sanitizers) catches the threading and memory issues; targeted unit tests catch business-logic correctness. workflow-audit covers the connection-and-wiring gap between those tools.

### Pairs with ui-path-radar

[ui-path-radar](https://github.com/Terryc21/radar-suite) (part of [radar-suite](https://github.com/Terryc21/radar-suite)) covers similar territory at a different layer. The two are complementary:

- **ui-path-radar** enumerates routing cases and verifies each connects to a destination. Asks "is there a path from somewhere to here." Catches orphans and broken back links. Lower token cost.
- **workflow-audit** traces what a user actually trying to *do* something would experience step by step. Asks "does this flow let a user complete their goal." Catches dead ends, dismiss traps, semantic friction. Higher token cost but deeper analysis.

If you're auditing a SwiftUI app, running both is the standard pattern. ui-path-radar finds the structural problems first; workflow-audit catches what slips through. They share file:line citation conventions and finding lifecycle so the two reports can be read side by side.

## Requirements

- A SwiftUI project (iOS, iPadOS, or macOS). UIKit projects won't get useful findings — the methodology assumes declarative views and the SwiftUI navigation primitives.
- Claude Code, or any AI tool that can read files and follow markdown instructions.

## Maintenance

```
/plugin update workflow-audit
```

workflow-audit is updated regularly; check the [CHANGELOG](CHANGELOG.md) before a release-blocking audit. Recent updates added cross-skill handoff with radar-suite, adopted radar-suite-core for infrastructure parity (session persistence, wave-based fixes, suppression), and grew issue categories from 20 to 32.

## Deeper documentation

Methodology spec: [docs/HOW_IT_WORKS.md](docs/HOW_IT_WORKS.md).

## Sibling skills

- [**bug-echo**](https://github.com/Terryc21/bug-echo) — sibling-bug scan after a fix
- [**bug-prospector**](https://github.com/Terryc21/bug-prospector) — forward-looking bug hunt before a release
- [**unforget**](https://github.com/Terryc21/unforget) — one-file deferred-work ledger
- [**radar-suite**](https://github.com/Terryc21/radar-suite) — 6-skill suite tracing user behavior paths through the app (iOS + macOS); includes ui-path-radar, the structural counterpart to this skill
- [**prompter**](https://github.com/Terryc21/prompter) — prompt rewriting before execution
- [**skill-reviewer**](https://github.com/Terryc21/skill-reviewer) — candid reviews of other Claude Code skills
- [**tutorial-creator**](https://github.com/Terryc21/tutorial-creator) — annotated tutorials from your codebase

## Author

Terry Nyberg, [Coffee & Code LLC](https://stuffolio.app/). If workflow-audit catches a real bug for you, [a coffee](https://buymeacoffee.com/stuffolio) is appreciated. Issue reports about what worked or didn't are more useful.

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=flat&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/stuffolio)

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

# workflow-audit

**A 5-layer audit of SwiftUI user flows. Enumerates entry points, traces critical paths, detects 32 categories of workflow bug, evaluates UX impact, and verifies data wiring. The inverse of a linter: instead of searching for known anti-patterns, it lists everything that should be connected and flags what isn't.**

Built while shipping [Stuffolio](https://stuffolio.app), an iOS/macOS app I work on every day. Free, open source, no paid tier, no referral links.

<a href="https://buymeacoffee.com/stuffolio"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="120"></a>

If this audit catches a real problem for you, a [coffee](https://buymeacoffee.com/stuffolio) is appreciated. Issue reports about what worked or didn't are even more useful.

---

## Why enumerate-then-verify

Pattern-based audits search for known-bad code shapes: `try?` swallowing errors, missing `@MainActor`, force unwraps, deprecated APIs. The pattern is the unit; if your bug doesn't match a pattern, the audit can't see it.

Two large bug classes have no code signature to match:

- **Orphan features.** A view exists, compiles, runs, but no entry point reaches it. Nothing in the app's navigation enum, no menu item, no `NavigationLink`, no programmatic push. The view file is fine in isolation. The bug is the absence of a connection somewhere else.
- **Unwired data.** A field is declared in the model, populated by some flow, displayed by another. But the populator and the displayer don't share a path — the data is computed and dropped, or read but never updated. Each file is fine. The handoff is broken.

You don't find these with grep. You find them by enumerating everything that *should* connect (every routing case, every model property, every notification observer) and then verifying which ones do. workflow-audit runs that enumeration across five layers.

---

## The five layers

Each layer can be invoked individually or chained as a full pipeline.

| Layer | Command | What it does |
|---|---|---|
| 1. Discovery | `/workflow-audit layer1` | Builds an inventory of every UI entry point. Sheet triggers (`isPresented:`, `item:`), `NavigationLink` destinations, toolbar buttons, dashboard cards, context menus, deep-link handlers. Output is a list you can sanity-check against your mental model of the app. If something you built isn't on the list, the layer just told you the user can't reach it. |
| 2. Flow tracing | `/workflow-audit layer2` | Traces critical user journeys end to end. For each entry point in layer 1, walks the destination view, identifies its actions, follows each action's handler to the next view or modal, repeats. Documents each step with file:line citations. |
| 3. Issue detection | `/workflow-audit layer3` | 32 categories: dead ends, dismiss traps, buried CTAs, sheet asymmetry (open path exists but close path doesn't), context dropping (modal presents with stale `@Binding`), notification fragility (string-based name without symbol fallback), gesture-only actions (no keyboard equivalent on macOS), loading traps (Progress view with no timeout), mock data leaking into production, platform parity gaps (feature on iOS but not macOS, or vice versa), and more. 14 of the 32 are automated grep checks with regression canaries; the rest are enumerate-then-verify. |
| 4. Semantic evaluation | `/workflow-audit layer4` | Evaluates each traced flow from a user's perspective. Discoverability (can a new user find this without prior knowledge), efficiency (number of taps to complete the action), feedback (does the user know what happened), recovery (can they undo a wrong path). |
| 5. Data wiring | `/workflow-audit layer5` | Verifies features use real data. Flags features that look complete in the UI but read from a stub, hardcoded constant, or mock provider. Catches the case where a feature shipped half-done and the placeholder data was never replaced. |

Plus utility commands:

- `/workflow-audit fix` — turns findings into a phased fix plan
- `/workflow-audit status` — shows progress when an audit was interrupted
- `/workflow-audit trace "A → B → C"` — traces a specific flow path you're investigating
- `/workflow-audit diff` — compares current findings against a previous audit (useful as a regression gate)

---

## Install

Two commands in Claude Code, run one at a time:

```
/plugin marketplace add Terryc21/workflow-audit
```

```
/plugin install workflow-audit@workflow-audit
```

---

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

**Diff mode.** After running a full audit and shipping fixes, the next run with `--diff` compares against the previous report. Findings that were Fixed don't reappear; new findings get marked as such. Useful as a release gate.

---

## Output format

Every audit writes a markdown report to `.agents/research/YYYY-MM-DD-workflow-audit-<slug>.md`. Standard format across the radar/audit ecosystem:

- File and line citations for every finding (the schema gate rejects unattributed claims)
- 9-column rating table: severity, urgency, risk-of-fix, risk-of-no-fix, ROI, blast radius, fix effort, status, axis classification
- 3-axis classification: Axis 1 (release-blocking), Axis 2 (quality), Axis 3 (hygiene)
- Suggested fix when one is mechanical
- Tables adapt to terminal width — narrow terminals get a compact view; the full table always lands in the report file

Real example using my own Stuffolio findings: [example audit report](skills/workflow-audit/examples/2026-04-15-workflow-audit-stuffolio.md). Walks through all five layers with real findings, real fix plans, and the issue rating table format.

The report doesn't change your code. You decide which findings to fix, defer, or skip.

---

## Pairs naturally with ui-path-radar

[ui-path-radar](https://github.com/Terryc21/radar-suite) (part of [radar-suite](https://github.com/Terryc21/radar-suite)) covers similar territory at a different layer. The two are complementary:

- **ui-path-radar** enumerates routing cases and verifies each connects to a destination. Asks "is there a path from somewhere to here." Catches orphans and broken back links. Lower token cost.
- **workflow-audit** traces what a user actually trying to *do* something would experience step by step. Asks "does this flow let a user complete their goal." Catches dead ends, dismiss traps, semantic friction. Higher token cost but deeper analysis.

If you're auditing a SwiftUI app, running both is the standard pattern. ui-path-radar finds the structural problems first; workflow-audit catches what slips through. They share file:line citation conventions and finding lifecycle so the two reports can be read side by side.

---

## What it can't catch

Behavioral audits have real limits:

- **Logic correctness.** workflow-audit verifies a button exists, that it's reachable, that its handler runs, that the handler reads real data. It cannot verify the handler does the right thing. Wrong-but-reachable is invisible to the audit.
- **Runtime-only issues.** Concurrency races, memory pressure, OS-specific bugs, animation timing. Static analysis has structural limits.
- **Novel bug categories.** A clean audit means zero matches for the 32 detected categories. New workflow-bug shapes that haven't been added to a layer's checklist won't be caught until the next release.
- **Subjective UX.** "Is this layout good" is a judgment call. The semantic evaluation layer flags candidates (buried buttons, low feedback density) but doesn't make verdicts.

Treat findings as leads to investigate, not items to fix blindly. The 'BURIED' classification flags candidates; you decide whether the screen-position is actually a problem.

---

## Using without Claude Code

The methodology is an extracted skill document; you can paste it into Cursor, Windsurf, Copilot Chat, or any other AI tool with file access. Get most of the value with a manual prompt:

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
[paste contents of skills/workflow-audit/SKILL.md]

Start with Phase 1: list all view files and their navigation connections.
```

What Claude Code adds on top of the manual prompt: tool integration (Grep, Glob, Bash) for the enumeration step, multi-phase session management with checkpoint/resume, finding-lifecycle tracking across runs, and cross-skill handoffs to ui-path-radar and the rest of radar-suite. The prompt approach gets you the methodology; Claude Code automates the execution.

---

## Updates

```
/plugin update workflow-audit
```

Or check [CHANGELOG.md](CHANGELOG.md). Recent releases (v2.5 → v3.0) added cross-skill handoff with radar-suite, adopted radar-suite-core for infrastructure parity (session persistence, wave-based fixes, suppression), and bumped issue categories from 20 to 32.

---

## Other Claude Code skills I've built

- [tutorial-creator](https://github.com/Terryc21/tutorial-creator) — turns a file from your project into an annotated tutorial with vocabulary tracking, pre/post tests, and prerequisite gap analysis. Works for any language.
- [prompter](https://github.com/Terryc21/prompter) — rewrites your Claude Code prompt for clarity (resolves ambiguous references, tightens vague verbs, restructures stacked questions) before acting.
- [bug-echo](https://github.com/Terryc21/bug-echo) — after you fix a bug, infers the anti-pattern from your diff, validates against the pre-fix file, and scans for sibling instances.
- [radar-suite](https://github.com/Terryc21/radar-suite) — six audit skills for iOS/macOS Swift. Includes ui-path-radar (the structural-layer counterpart to this skill) plus data-model, time-bomb, roundtrip, ui-enhancer, and a capstone aggregator.

All free, all Apache 2.0, all built while shipping Stuffolio.

---

## Requirements

- A SwiftUI project (iOS, iPadOS, or macOS). UIKit projects won't get useful findings — the methodology assumes declarative views and the SwiftUI navigation primitives.
- Claude Code, or any AI tool that can read files and follow markdown instructions.

---

## Deeper documentation

Two longer docs:

- [README-newer-dev.md](README-newer-dev.md) — gentler walk-through aimed at readers new to Claude Code skills and audit tooling.
- [README-detailed.md](README-detailed.md) — the original pre-rewrite README with version history, the cautionary note about AI audit limits, and additional context on the v2.x → v3.0 migration.

Methodology spec: [docs/HOW_IT_WORKS.md](docs/HOW_IT_WORKS.md).

---

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

## Author

Terry Nyberg, [Coffee & Code LLC](https://stuffolio.app/).

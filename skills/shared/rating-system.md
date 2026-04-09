# Rating System — Shared Reference

> **Imported by:** `workflow-audit/SKILL.md`, `plan/SKILL.md`
> **Source of truth** for rating format, column definitions, and indicator scales.

---

## Table Format (Hard Rule)

> ALL findings MUST be presented in a single markdown table. Each finding is ONE ROW. Ratings are COLUMNS read left-to-right. Never expand findings into individual sections with bullet-pointed ratings.

**Also wrong — separate headed sections per category:**

```markdown
## Data Wiring Issues
- 0 mock data in production features
- Cross-feature flows: PriceWatch → RepairKeepReplace — connected

## Orphaned Views
- InformationHelpView — never instantiated
- ToolsHelpView — never instantiated
```

This is the same problem as the vertical list: it breaks findings into scrollable blocks instead of keeping them in one scannable table. Data wiring findings, orphaned views, missing confirmations — ALL go in the same table. Use the Finding column for context (e.g., "Data wiring: diyNotes defined but never shown in UI").

**Correct — scannable table (one row per finding):**

```markdown
| # | Finding | Urgency | Risk: Fix | Risk: No Fix | ROI | Blast Radius | Fix Effort |
|---|---------|---------|-----------|--------------|-----|--------------|------------|
| 1 | Missing confirmation dialog | 🟡 High | ⚪ Low | 🟡 High | 🟠 Excellent | ⚪ 1 file | Trivial |
| 2 | Silent delete operation | 🟢 Medium | ⚪ Low | 🟢 Medium | 🟠 Excellent | ⚪ 1 file | Trivial |
```

**Wrong — vertical list (one block per finding):**

```markdown
### Finding 1: Missing confirmation dialog
- **Urgency:** 🟡 High
- **Risk: Fix:** ⚪ Low
- ...
```

The table format lets you compare all findings at a glance. The vertical list forces scrolling through N separate blocks. These are NOT the same thing.

---

## Display Requirements

### Terminal Width Detection

Before rendering any rating table, check terminal width:

```bash
tput cols
```

- **160+ columns:** Render the **full 8-column table** inline.
- **Under 160 columns:** Render the **compact 4-column table** inline. Write the **full 8-column table** to the report file only. Display this notice after the compact table:

> **Compact view** — your terminal is [N] columns wide (160+ needed for full table). The complete Issue Rating Table with all 8 columns has been written to the report file. Open that file or widen your terminal to 160+ columns to view it as a single table.

### Compact Table Format

When terminal is under 160 columns, use this inline:

```markdown
| # | Finding | Urgency | Fix Effort |
|---|---------|---------|------------|
| 1 | Description | 🔴 Critical | Trivial |
| 2 | Description | 🟡 High | Small |
```

The compact table keeps the two most actionable columns (Urgency + Fix Effort). Full ratings are in the report file.

### Report File

The report file (`.agents/research/YYYY-MM-DD-*.md`) **always** contains the full 8-column table regardless of terminal width.

---

## Column Definitions

| Column | Meaning |
|--------|---------|
| **Urgency** | How time-sensitive — must it be fixed before release? |
| **Risk: Fix** | What could break when making the change |
| **Risk: No Fix** | Cost of leaving it — crash, data loss, user-visible bug |
| **ROI** | Return on effort (inverted — 🟠 = excellent, 🔴 = poor) |
| **Blast Radius** | Number of files the fix touches (e.g., "⚪ 1 file", "🟢 3 files", "🟡 12 files"). Count by grepping for callers/references before rating. |
| **Fix Effort** | Trivial / Small / Medium / Large |

---

## Indicator Scale

| Indicator | General meaning | ROI meaning |
|-----------|----------------|-------------|
| 🔴 | Critical / high concern | Poor return — reconsider |
| 🟡 | High / notable | Marginal return |
| 🟢 | Medium / moderate | Good return |
| ⚪ | Low / negligible | — |
| 🟠 | Pass / positive (test results, status) | Excellent return |

---

## Urgency Tiers

| Tier | Meaning | Examples |
|------|---------|----------|
| 🔴 CRITICAL | Pre-launch blocker OR data loss / crash risk | Dead end, wrong destination, mock data in production |
| 🟡 HIGH | User-visible or stability risk; fix before release | Broken promise, missing activation, unwired data, platform gap |
| 🟢 MEDIUM | Real issue; acceptable to schedule | Two-step flow, missing feedback |
| ⚪ LOW | Nice-to-have; minimal impact | Inconsistency, orphaned code |

---

## Sorting Rules

**Default sort:** Urgency descending, then ROI descending. This is `--sort urgency`.

### Sort Modes

| Flag | Primary Sort | Secondary Sort | Best For |
|------|-------------|----------------|----------|
| `--sort urgency` (default) | Urgency ↓ | ROI ↓ | Pre-release triage -- what's most broken |
| `--sort effort` | Fix Effort ↑ | Risk:Fix ↑ | Limited time -- easiest safe wins first |
| `--sort impact` | Risk:No Fix ↓ | Urgency ↓ | Stakeholder conversations -- most user-visible first |
| `--sort implement` | Dependency order | Urgency ↓ | Sprint planning -- what to build first |

### Sort Mode Details

**`--sort urgency`** — The default. Puts 🔴 CRITICAL at the top, ⚪ LOW at the bottom. Within the same urgency, higher ROI comes first. Use when deciding what must be fixed before shipping.

**`--sort effort`** — Trivial fixes first, Large last. Within the same effort tier, lower Risk:Fix comes first (safest changes bubble up). Use when you have a limited window and want to knock out the most fixes possible.

**`--sort impact`** — Highest Risk:No Fix first -- the findings that hurt users most if left unfixed. Within the same risk tier, higher Urgency comes first. Use when explaining to stakeholders why something needs to be fixed, or when deciding what to defer vs ship.

**`--sort implement`** — Dependency-aware ordering. Findings that unblock other findings come first. Within independent findings, fall back to Urgency sort. This requires the skill to reason about relationships between findings (e.g., "adding Codable to Item enables both @SceneStorage and better export"). If no dependency relationships exist, falls back to `--sort urgency`. Use when planning a sprint or sequencing a fix batch.

### Mid-Session Toggle

Sort can be changed at any time without re-running the audit:

```
--sort effort       (re-display current findings sorted by effort)
--sort urgency      (back to default)
```

The sort mode is noted in the end-of-audit suggestion so users know it's available.

---

## When to Apply

- Any fix, plan step, or architectural decision
- Any audit finding (including output from Axiom audit skills)
- Any time a prompt explicitly asks for a **"Rating"**

## User Impact Explanations (Optional)

When enabled, each finding in the Issue Rating Table gets a brief companion explanation below the table. This helps non-technical stakeholders, new team members, or the developer themselves understand what each finding means in practice.

### How to Enable

Add as a setup question alongside experience level and audit mode:

**"Include user impact explanations?"**
- **No (default)** -- Table only. Findings speak for themselves.
- **Yes** -- After the table, append a numbered explanation for each finding.

Can also be toggled mid-session: `--explain` on any audit command enables it, `--no-explain` disables it.

### Explanation Format

Each explanation has exactly 3 lines -- no more, no less:

```markdown
### #1 -- [Finding title from table]
**What's wrong:** [One sentence describing the bug or gap in the code.]
**Fix:** [One sentence describing the concrete change.]
**User experience:** [One sentence: what the user sees before the fix, and what changes after.]
```

### Rules

- **One sentence per line.** Not two. Not a paragraph. One.
- **"User experience" means the person using the app**, not the developer. Describe what they see, tap, or don't see -- not what the code does.
- **Skip for hygiene/polish findings** (⚪ LOW urgency) unless they have user-visible symptoms. For code-only findings, replace "User experience" with "Developer experience" (e.g., "Test failures show generic crash instead of which assertion failed").
- **Order matches the table.** Finding #1 in the table = Explanation #1.
- **Place after the table, before the next-step suggestion.** The table remains the primary output; explanations are supplementary.

### Example

```markdown
| # | Finding | Urgency | Risk: Fix | Risk: No Fix | ROI | Blast Radius | Fix Effort |
|---|---------|---------|-----------|--------------|-----|--------------|------------|
| 1 | Dismiss trap on Scout results sheet | 🟡 HIGH | ⚪ Low | 🟡 High | 🟠 Excellent | ⚪ 1 file | Trivial |
| 2 | N+1 faults in notification scheduling | 🟢 MEDIUM | ⚪ Low | 🟢 Medium | 🟢 Good | ⚪ 1 file | Small |

### #1 -- Dismiss trap on Scout results sheet
**What's wrong:** `.interactiveDismissDisabled` blocks swipe-to-dismiss when results are showing.
**Fix:** Remove `viewModel.showingResult` from the disable condition.
**User experience:** After Stuff Scout analysis, swiping down to close does nothing -- user must find the X button. After fix, swipe dismisses normally.

### #2 -- N+1 faults in notification scheduling
**What's wrong:** Notification loop accesses `.currentLoan` per item, triggering a separate database read each time.
**Fix:** Add `\.currentLoan` to the prefetch list in the fetch descriptor.
**User experience:** Brief hang when opening the app with 500+ items. After fix, no perceptible delay.
```

---

## Opt-Out

- **Persistent off:** If the project's CLAUDE.md has `## Issue Rating Criteria [OFF]`, skip all rating tables
- **Per-prompt:** If the user's message includes `--no-rating`, omit the rating table for that response only

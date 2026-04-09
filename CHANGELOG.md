# Changelog

All notable changes to workflow-audit are documented here.

---

## 2026-04-09 — v3.0.0

### Cross-Skill Handoff Protocol

- Writes `.workflow-audit/persona-handoff.yaml` after Layer 4 with personas, D/E/F/R evaluation matrix, and checks_performed
- Reads ui-path-radar handoff (if exists) to import companion findings and note category overlap
- Companion findings tagged `[via ui-path-radar]` in Issue Rating Table
- Handoff is "if exists" -- zero behavior change when ui-path-radar is not installed
- Updated Layer 4 execution to include persona handoff generation

---

## 2026-04-09 — v2.6.0

### Adopted radar-suite-core.md for Infrastructure Parity

- Added `radar-suite-core.md` as local copy (no radar-suite dependency required)
- workflow-audit now inherits: session persistence, checkpoint/resume, wave-based fixes, work receipts, fix-forward bias, known-intentional suppression, pattern reintroduction detection, contradiction detection, context exhaustion guard
- All `.radar-suite/` paths adapted to `.workflow-audit/` in workflow-audit context
- Opt-Out section preserved from rating-system.md
- Deleted `skills/shared/rating-system.md` (superseded by core)
- Updated `skills/plan/SKILL.md` reference to point to `radar-suite-core.md`
- Added Shared Patterns section to SKILL.md referencing all core features

---

## 2026-04-09 — v2.5.0

### 12 New Issue Categories + Table Formatting

**New categories (aligned with ui-path-radar coverage):**
- 🔴 CRITICAL: Destructive Without Confirmation, Silent State Reset
- 🟡 HIGH: Empty State Missing, Error Recovery Missing, Keyboard Obscures Input, Permission Denied Dead End, Modal Stacking, Navigation Container Mismatch
- 🟢 MEDIUM: Phantom Touch Target, Race Condition UX, Invisible Selection
- ⚪ LOW: Double-Nested Navigation

Total categories: 20 → 32. Full detection patterns in `agents/layer3-issue-detection.md` (Categories 21-32).

**Table formatting improvements:**
- Column-aligned Issue Categories table with compact headers
- Shortened 8-column Issue Rating Table headers (Risk:Fix, Risk:NoFix, Blast, Effort)
- Terminal width cue: tells user to widen window if table renders as vertical blocks
- Multi-row finding text supported for long descriptions

---

## 2026-04-09 — v2.4.0

### Experience-Level Session Setup

- Added Session Setup section with experience-level question (Beginner/Intermediate/Experienced/Senior)
- Experience-adapted skill introductions for all 4 levels
- Auto-apply rules: Beginner enables `--explain` and `--sort impact`; Senior defaults to `--sort effort`
- Output rules table covering 7 dimensions (intro, explain, progress banner, finding text, sort, citations, summaries)

---

## 2026-04-09 — v2.3.0

### User Impact Explanations & Sort Modes

**`--explain` / `--no-explain`**
- New toggle: appends a 3-line explanation after each finding in the Issue Rating Table
- Format: What's wrong (one sentence), Fix (one sentence), User experience before/after (one sentence)
- Code-only findings use "Developer experience" instead of "User experience"
- Default: off. Toggle mid-session with `--explain`
- Defined in `skills/shared/rating-system.md` "User Impact Explanations" section

**`--sort` modes**
- `--sort urgency` (default) -- most broken first (Urgency descending, ROI descending)
- `--sort effort` -- easiest safe wins first (Fix Effort ascending, Risk:Fix ascending)
- `--sort impact` -- most user-visible first (Risk:No Fix descending, Urgency descending)
- `--sort implement` -- dependency-aware ordering for sprint planning
- Can be changed mid-session without re-running the audit
- Defined in `skills/shared/rating-system.md` "Sort Modes" section

**End-of-audit suggestion updated**
- Now shows available sort modes and explain toggle

---

## 2026-04-07 — v2.2.0

### Handoff YAML & Rating System

- Handoff brief generation (`.workflow-audit/handoff.yaml`) for consumption by planning skill
- Shared rating system extracted to `skills/shared/rating-system.md`
- Terminal width detection with compact 4-column fallback
- Group hints for batch fix operations

---

## Pre-changelog history

- v2.0 — 5-layer audit architecture (discovery, flow tracing, issue detection, semantic evaluation, data wiring)
- v1.0 — Initial release with entry point discovery and dead-end detection

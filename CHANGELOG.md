# Changelog

All notable changes to workflow-audit are documented here.

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

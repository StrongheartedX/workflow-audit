# Contributing to workflow-audit

Thanks for your interest. Bug reports, ideas, and questions are all welcome.

## Reporting a bug

Open an issue using the **Bug report** template. Include:
- What you ran (skill version, the command you used)
- What you expected to happen
- What actually happened (error messages, screenshots, or output excerpts)
- Project context (Swift version, Xcode version, approximate codebase size)

## Suggesting a feature or audit category

Open an issue using the **Feature request** template. If you can link it to a real bug the audit missed or a real workflow that broke, include that: concrete cases beat abstract ideas.

## Asking a question

Start a thread in [Discussions](https://github.com/Terryc21/workflow-audit/discussions). Keeps the issue tracker focused on actionable work.

## Contributing code

workflow-audit is primarily a SKILL.md file plus supporting docs. Most contributions are edits to the skill's audit rules, new detection patterns, or documentation.

1. Fork the repo
2. Create a branch off `main`
3. Make your changes
4. Open a PR describing the change and linking to any issue it addresses

For substantive changes (new audit categories, structural rewrites), open an issue first to discuss scope before writing code.

## Before tagging a release

The plugin's version is written in four places. Check they agree:

```bash
./scripts/check-versions.sh          # the four manifests
./scripts/check-versions.sh --tag    # also compare the newest git tag
```

Exits non-zero on a mismatch, so it drops into a hook or a CI step as-is.

`skills/plan/SKILL.md` is deliberately excluded — the plan skill versions on its own cadence
(1.3.0 against the plugin's 3.0.3), and forcing those together would be wrong rather than
stricter.

*Why this exists: on 2026-08-27 a review found four version strings with nothing keeping them
honest. That same week the same drift produced two real defects — a README claiming a version
its own manifest disagreed with, and a shared file that silently stopped tracking upstream.*

---

## Feedback from AI coding sessions

If you found this skill via Claude Code or a similar tool, feedback from actual audit runs is especially valuable. Before-and-after examples, cases the skill missed, false positives: these are the highest-signal reports.

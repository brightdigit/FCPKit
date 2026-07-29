# Agent Notes

Running log of user corrections and standing always/never directives for this repo.
**This file is the source of truth for how to work here.**

## How to use this file

- **Read this file at the start of every session, before doing any work.**
- **Append one line per directive proactively** — without being asked — whenever the user
  corrects you or gives an "always"/"never" instruction. Record the literal meaning, not an
  interpretation.
- **Newest lines at the bottom.** One line per entry, prefixed with the date (YYYY-MM-DD).
- **When a directive supersedes an earlier one, update or remove the stale line** rather than
  leaving both. The log should always read as the current set of rules, not a history of every
  instruction ever given.

> Note: this supersedes the older strictly-append-only rule from `.claude/CORRECTIONS.md`
> (merged into this file 2026-07-29). Entries are still appended as they arise, but stale lines
> are now corrected in place instead of accumulating contradictions.

## Directives

- 2026-07-17: Append one concise line here whenever the user corrects me or gives an explicit "always"/"never" directive.
- 2026-07-17: Keep this log in the repo in an agent-visible folder (`.claude/`), not machine-only, so it is committed and shared.
- 2026-07-17: Save memories AND corrections in the repo (`.claude/memory/` and this file), never only in the local user memory directory.
- 2026-07-29: Write new tests in Swift Testing following https://gist.github.com/leogdion/0806c2f41aeb2c77db6a4a846cf13c0f — existing XCTest tests stay as they are; this overrides the older "write new tests in XCTest for now" guidance.
- 2026-07-29: Gate non-Apple platform support with `#if canImport(...)` (e.g. `FoundationXML`, `CoreMedia`) rather than excluding targets or platforms from CI.
- 2026-07-29: Never claim cross-platform support from reasoning or a macOS-only build — verify in the actual target environment (Docker container matching CI) before asserting it works.
- 2026-07-29: When copying BrightDigit package scaffolding, use the most recently maintained sibling repo as the template (currently SyndiKit).
- 2026-07-29: Prefer opening a PR over merging; leave work in a reviewable state that a new conversation can pick up.

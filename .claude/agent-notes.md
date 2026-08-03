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
- 2026-07-29: Gate Apple-only frameworks with `#if canImport(...)` (e.g. `CoreMedia`, `AVFoundation`) rather than excluding targets or platforms from CI.
- 2026-07-29: Never claim cross-platform support from reasoning or a macOS-only build — verify in the actual target environment (Docker container matching CI) before asserting it works.
- 2026-07-29: When copying BrightDigit package scaffolding, use the most recently maintained sibling repo as the template (currently SyndiKit).
- 2026-07-29: Prefer opening a PR over merging; leave work in a reviewable state that a new conversation can pick up.
- 2026-07-29: When verifying Linux/wasm builds in Docker, pass `--platform linux/amd64` to match CI — a Docker tag can ship different Swift builds per architecture, so an arm64 pass proves nothing about CI.
- 2026-07-29: Foundation and FoundationXML are available on all OSes.
- 2026-07-29: Do not rely on external host tools like ffprobe for MediaTools; prefer something that can be built into the library.

- 2026-07-30: Never `swiftlint:disable cyclomatic_complexity` for choice Codable or stacked if-let seed chains; use `XMLChoiceCodable` / `XMLChoiceField` / `OrderedChoiceContainer` / `AnchoredChoiceContainer` instead (large if/switch ladders are an anti-pattern; do not re-copy Codable loops or get/set helpers).
- 2026-07-31: Always check branch/merge state against the fetched remote (`git fetch` + `origin/*` refs), never local refs; and because PRs are squash-merged, verify "unmerged" claims by content (`git diff` / tree hash), not commit ranges.
- 2026-08-02: Demo/scaffolding documents (e.g. `RGBDocument`) belong only in `Sources/fcpxml-dsl`, not duplicated into the library; when a showcase type must ship in the library, the executable holds a thin command that invokes it rather than a second copy.
- 2026-08-02: Pre-1.0, do not contort a design to avoid changing DSL APIs — make types public and change signatures when that yields the simpler design.
- 2026-08-02: Do not add public API for a capability nothing needs yet (e.g. keep build-environment keys internal until an external need appears).
- 2026-08-02: When designing DSL ergonomics, ask what SwiftUI would do and prefer the option that demands least from the developer (alignment-style APIs over coordinate math), keeping absolute-value APIs as an escape hatch.

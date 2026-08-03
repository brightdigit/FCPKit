# Demo Issues — Parallel Worktree Plan

Status: proposal (not yet accepted)
Scope: executing [#35](https://github.com/brightdigit/FCPKit/issues/35)–[#41](https://github.com/brightdigit/FCPKit/issues/41)
across parallel git worktrees.

Companion to [demo-presentation-video.md](demo-presentation-video.md), which
specifies *what* to build. This document covers *how to run the work* — which
tracks can proceed simultaneously, and why the obvious partition is wrong.

## Decisions taken

| Decision | Choice | Rationale |
| --- | --- | --- |
| #35 vs #37 | **Fold #35 into #37** | Both rewrite the same 14 lines of `Title.build` |
| Base branch | **`v0.1.x`** | Matches PR #32's existing base; keeps code off `main` until the milestone closes |
| Worktree count | **3** | One per non-overlapping file set |

## The constraint that shapes everything

The naive plan — "#35, #36, #37 are independent, run all three in parallel" —
is what the spec's dependency graph implies, and it is **wrong at the file
level**.

`Sources/FCPKitDSL/Title.swift:64-76` is the collision:

```swift
internal func build(_ resources: inout ResourceStore) throws -> Built {
  let ref = try resources.effect(name: preset.name, uid: preset.uid)
  let style = FCPKit.TextStyle(ref: "ts1", content: text)      // ← #35 rewrites
  let definition = FCPKit.TextStyleDef(
    id: "ts1",                                                  // ← #35 rewrites
    textStyle: FCPKit.TextStyle(
      font: "Helvetica", fontSize: "63", fontFace: "Regular",   // ← #37 replaces
      fontColor: "1 1 1 1", alignment: "center"                 //   this whole block
    )
  )
```

The `ts1` literals #35 must replace sit **inside** the `TextStyle` block that
#37 replaces wholesale. This is not two edits near each other; it is two edits
to the same expression. Git would conflict, and the conflict would be in
rewritten code where neither side is obviously correct.

**#35 is therefore folded into #37.** One worktree owns `Title.swift` end to
end. The cost is that #35 stops being an independently reviewable bug-fix PR —
accepted deliberately, because a merge conflict in the exact code being
rewritten is worse than a slightly larger PR.

Verified overlap across the three issues:

| File | #35 | #36 | #37 |
| --- | :-: | :-: | :-: |
| `FCPKitDSL/Title.swift` | ✅ | — | ✅ |
| `FCPKitDSL/ResourceStore.swift` | ✅ | — | — |
| `FCPKitDSL/Anchor.swift` | — | ✅ | — |
| `FCPKitDSL/AssetClip*.swift` | — | ✅ | — |
| `FCPKitDSL/Generator*.swift` | — | ✅ | — |
| `FCPKitDSL/Color+DSL.swift` | — | ✅ | — |
| `FCPKitDSL/DSLNode.swift` | — | ✅ | — |
| `FCPKitDSL/Layout+Packing.swift` | — | ✅ | — |
| `FCPKitDSL/Title+Modifiers.swift` | — | — | ✅ |
| `FCPKit/Adjustments/AdjustTransform.swift` | — | — | ✅ |
| `FCPKitDSL/Defaults.swift` (#41) | — | — | — |

`Title.swift` is the only row with two marks. Everything else partitions
cleanly.

## Tracks

```
origin/v0.1.x
  ├── Track A  issue/36-story-item       #36            → PR → v0.1.x
  ├── Track B  issue/37-title-style-pos  #37 + #35      → PR → v0.1.x
  └── Track C  issue/41-match-analysis   #41            → PR → v0.1.x
         ↓ all three merged
      issue/38-presentation-document     #38            → PR → v0.1.x
         ↓
      issue/39-export-presentation       #39            → PR → v0.1.x
         ↓
      #40  (human — Share and Export, needs Final Cut)
```

### Track A — #36 `StoryItem`

Largest blast radius, zero overlap with the others. Makes `DSLNode` public,
adds `StoryItem`, moves `.anchor` off `AssetClip`.

Touches: `DSLNode`, `Anchor`, `AssetClip`, `AssetClip+Modifiers`, `Generator`,
`Generator+Modifiers`, `Color+DSL`, `Layout+Packing`, plus new `StoryItem.swift`
and `AnchoredItemBuilder.swift`.

Watch: the `.video` case missing from `anchoredExtent`
(`Layout+Packing.swift:162-180`) — anchored generators contribute no extent
without it.

### Track B — #37 + #35 title work

Owns `Title.swift`. Do #35's id allocator **first** as its own commit, then
build styling and positioning on top. Two commits, one PR, both issues closed.

Note `#37` also touches `Sources/FCPKit/` (adding `rotation`/`anchor`/`enabled`
to `AdjustTransform`) — the only track reaching outside `FCPKitDSL`.

### Track C — #41 version bug

One-line-ish fix in `Defaults.swift:63-67`, entirely disjoint. Good candidate
to run first or hand to whoever is free.

Relevant history: the multicam path already stopped emitting
`smart-collection` (see `docs/manual/typed-generation-gate.md` → "Generation
Policy Follow-up"). The DSL create path never inherited that change. Check
whether the fix should be "make it version-aware" or "drop it as multicam did".

## Serial tail

**#38 cannot start until all three tracks merge** — it consumes `StoryItem`
(Track A), title styling and `.position` (Track B), and would emit invalid 1.13
documents without Track C.

#38 → #39 → #40 are strictly serial and single-file-ish; parallelising them
buys nothing.

**#40 is human-only** and needs Final Cut Pro.

## Setup

```sh
cd /Users/leo/Documents/Projects/FCPKit
git fetch origin

git worktree add -b issue/36-story-item      wt-36 origin/v0.1.x
git worktree add -b issue/37-title-style-pos wt-37 origin/v0.1.x
git worktree add -b issue/41-match-analysis  wt-41 origin/v0.1.x
```

Housekeeping: `feature-rgb-document-generator-dsl` is currently **prunable**.
Clear it first with `git worktree prune`.

Each worktree needs its own SwiftPM build directory — they do not share
`.build`, so expect a full cold build per tree.

## Per-track gate

Every track runs before opening a PR:

```sh
swift test
swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData \
  --fail-if-total-exceeds 0
swift-format lint --recursive Sources Tests
swiftlint
```

Conventions from the spec apply per-issue: MIT header on new files, Swift
Testing for new tests, doc comments on public declarations, files under 225
lines, `CodingKeys` in DTD order.

## Merge order

Recommended: **C → A → B**.

- **C first** — smallest, and it unblocks 1.13 validation for everyone else.
- **A before B** — Track A makes `DSLNode` public and adds `StoryItem`;
  Track B's `.position` modifiers are cleaner rebased onto that than the
  reverse.
- Neither ordering is forced by file conflicts. This is about review ergonomics.

Rebase each track on `v0.1.x` after the prior merge and re-run the gate.

## Risks

- **Track A + Track B both change `build` signatures.** Track A makes
  `DSLNode.build` public; Track B's deferred position resolution may change its
  shape. They touch different declarations of the same protocol — no textual
  conflict expected, but rebase B on A and re-run tests rather than assuming.
- **The ordering invariant.** Track B's deferred resolution rebuilds
  `Spine.items`. The Step 0 ordering tests must be extended to cover
  post-resolution output; the existing tests would not catch a reordering
  introduced by the resolver. This is the single most likely place to ship a
  silent regression.
- **Cold builds.** Three worktrees, three `.build` directories.
- **PR #32 is still open** against `v0.1.x`. It is docs-only, so it does not
  conflict with any track, but merging it first means each worktree branches
  from a base containing the revised spec.

## What is already settled

Do not re-litigate during implementation:

- **Generator cross dissolves work.** Verified against Final Cut 2026-08-02;
  the T/2-overlap mitigation #38 held in reserve is **not needed**. Evidence:
  `docs/manual/typed-generation-gate.md` → "Generator Dissolve Gate".
- **`Transition.anchor` is a documented no-op**, pinned by a test — not a bug
  to "fix" into a throw.
- **The `adjust-transform` unit** is percent-of-frame-height from centre, Y-up,
  `height` as divisor on both axes.
- **Effect UIDs**: Motion-template effects derive their `uid` from the on-disk
  template path; only FxPlug built-ins need captured fixtures.

## Still unverified

Anchored titles over `<video>`-backed generator backgrounds on lane 1. Not
testable until Tracks A and B land, and the remaining unknown for #40.

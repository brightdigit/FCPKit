# ADR 0002: Create-First Authoring with Ordered, Typed FCPXML

- Status: Accepted
- Date: 2026-07-28

## Context

ADR 0001 established a supported-schema policy and best-effort editing: the typed
Codable model is authoritative for the tested vocabulary, and unsupported XML may
be dropped on encode. Schema-completeness reports zero structural loss on checked-in
fixtures, but that gate is **order-blind** — a multiset by ancestor path. The live
defect is `Spine`: parallel arrays re-encode `asset-clip, transition, asset-clip` as
`asset-clip, asset-clip, transition`, which Final Cut rejects.

Every model field is still `String?`, so times and requiredness are unchecked on both
edit and author paths (`AssetClipEditing.formatSeconds` can emit illegal decimals).
There is no authoring API beyond nested Codable initializers and hand-written resource
ids.

v0.1.0 must choose how far to go, and what “done” means. Evidence and rejected
alternatives:
[planning/v0.1.0-investigation-findings.md](../planning/v0.1.0-investigation-findings.md).
Sequenced implementation:
[planning/v0.1.0-first-working-version.md](../planning/v0.1.0-first-working-version.md).

## Decision

**Create-from-scratch is the acceptance bar for v0.1.0.** Typed authoring of new
FCPXML that Final Cut can import matters more than lossless editing of arbitrary
existing exports. ADR 0001’s best-effort editing policy stands and must not expand
0.1.0 scope.

v0.1.0 delivers the **full** plan (not ordering+DSL-only):

1. **Ordered content models.** Heterogeneous DTD sequences (`spine`, anchored
   children) become ordered choice arrays (`SpineItem`, `AnchoredItem`). Clean break —
   no `assetClips` compatibility shims. Prefer XMLCoder `items = ""` + choice encoding
   if the Step 0 spike succeeds; otherwise hand-written encode/decode. Sibling order is
   guarded by dedicated raw-tree tests; the completeness gate remains order-blind by
   design.
2. **Strong value types in the Codable model** (`FCPTime`, bools, DTD enums,
   `ResourceRef`), not only in a DSL layer. Canonical time form is preserved on
   round-trip; arithmetic must not emit illegal decimals.
3. **Unknown DTD-enum values pass through on decode by default**; an opt-in **strict**
   mode throws. The authoring DSL rejects invalid values. CDATA lookalikes
   (`colorSpace`, roles, `fieldOrder`) stay strings.
4. **`FCPKitDSL`** — SwiftUI-shaped `Document` protocol + result builders for create-path
   authoring. Soft-promotes library/event/project/primary-spine shells; media inline at use
   sites with spec-based dedupe; anchors via `.anchor(lane:content:)`; spine packing +
   transition overlap with modifier overrides. `export(version:) throws -> FCPXML`.
   See [planning §3](../planning/v0.1.0-first-working-version.md#3-resultbuilder-dsl-fcpkitdsl).
5. **`FCPKitScripting`** — additive, macOS-only, read-only ScriptingBridge inspector.
   Scripting timecode format is a separate enum (includes `unspecified`) with
   conversion to/from FCPXML `TCFormat` (`DF|NDF` only).
6. **BrightDigit package scaffolding** — CI, lint/format, and package hygiene so
   implementation PRs land against a reviewable pipeline
   ([#4](https://github.com/brightdigit/FCPKit/issues/4); added 2026-07-29).

Tracker: [planning/v0.1.0-issues.md](../planning/v0.1.0-issues.md). Parallel lanes:
[planning/v0.1.0-worktree-plan.md](../planning/v0.1.0-worktree-plan.md).

**Out of 0.1.0:** `locator` resources, `import-options`, sidecar unknown-XML
preservation, AppleScript-driven export, migrating the **existing** XCTest suite
to Swift Testing (defer to 0.1.1 as one no-behavior-change PR — note that
*newly authored* tests use Swift Testing as of 2026-07-29; see `AGENTS.md`), and
migrating `MulticamXMLBuilder` onto `FCPKitDSL`.

## Consequences

- Authoring tests (DSL → DTD validate → normalize → structural-equal FeaturePairs)
  become the strongest create-path signal; completeness-at-zero remains a regression
  net, not proof of safe round-trips.
- Call sites that used `spine.assetClips` move to pattern-matching over `items` in the
  same change that lands ordered `Spine`.
- Importers keep soft unknown-enum behavior unless they opt into strict decode;
  authors get fail-loud DSL checking.
- Future readers should not “fix” the completeness gate to be order-aware without
  revisiting this ADR — order belongs in explicit order tests.
- ADR 0001 still governs unsupported elements/attributes; this ADR adds create-first
  priority, ordering, typing, authoring/scripting boundaries, and package scaffolding
  for v0.1.0.

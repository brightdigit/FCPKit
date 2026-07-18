# FCPKit Roadmap Handoff

## Current State

Milestones 1 through 7 in `NEXT_STEPS.md` remain complete. The supported-schema
and best-effort editing decision is recorded, and the first loss diagnostics
API is implemented locally but not yet committed.

The structural schema-completeness report currently finds no measured loss in
the three checked-in FCPXML 1.13 fixtures:

| Files | Dropped elements | Dropped attributes | Dropped text | Total |
| ---: | ---: | ---: | ---: | ---: |
| 3 | 0 | 0 | 0 | 0 |

This is evidence for the checked-in fixtures only. It is not proof that the
model covers the complete FCPXML schema or content emitted by later Final Cut
versions.

The test suite has 40 passing tests. The required schema-completeness command
passes with zero loss for all three checked-in FCPXML 1.13 fixtures. The
worktree contains the intentional changes listed below.

## Completed Milestones

- Milestone 1: deterministic schema-completeness snapshots and a CI failure
  threshold.
- Milestone 2: complete Cross Dissolve transition payload decoding, mutation,
  and encoding.
- Milestone 3: recursive parameters, keyframe animation, fades, and observed
  heterogeneous child ordering.
- Milestone 4: mutable title text and text styling with stable style references.
- Milestone 5: nested timeline containers, timing, transforms, crop, conform,
  color-conform, and relationship-preserving mutation.
- Milestone 6: event-level multicam, sync clips, roles, and audio structures.
- Milestone 7: raw-pair comparison through `fcpxml-diff compare`, including
  Markdown, JSON, normalization, and path filtering.
- Milestone 8 foundation: accepted supported-schema/best-effort editing policy,
  reusable round-trip loss diagnostics, focused unsupported-content tests, and
  updated roadmap documentation.

Relevant commits, oldest first:

- `78a9ff7` Lock schema completeness baseline
- `9f25350` Model transition effect payloads
- `92d2996` Add shared parameter animation types
- `3c913e1` Complete title text styling model
- `795db6a` Complete nested timeline containers
- `e87285f` Complete library multicam audio model
- `98177ed` Add raw FCPXML pair comparison

Current uncommitted files:

- `Sources/FCPXMLDiff/RoundTripReport.swift` adds `FCPXMLRoundTripAnalyzer` and
  `FCPXMLRoundTripReport`. It can decode/re-encode input and report dropped
  elements, attributes, and text, or compare original and edited XML.
- `Tests/FCPKitTests/FCPXMLDiffTests.swift` adds two diagnostics tests.
- `docs/adr/0001-supported-schema-and-best-effort-editing.md` records the
  product decision.
- `NEXT_STEPS.md` and this document reflect the revised roadmap.

## Immediate Next Step: Typed Generation Vertical Slice

The product focus is new typed document creation and best-effort editing of
existing files within the supported model. Unknown-content preservation is out
of scope for this phase.

Editing existing files is best effort: supported content is typed and mutable,
unsupported content may be omitted, and callers can inspect a round-trip loss
report.

Continue Milestone 8 in this order:

1. Add public construction APIs for the core document graph: `FCPXML`,
   resources, formats, assets, media, library, event, project, sequence, spine,
   and clips.
2. Generate a minimal project solely through typed models.
3. Encode and parse it back, asserting resource IDs, references, timing, and
   hierarchy.
4. Add mutation tests against the generated document.
5. Reproduce the existing `MulticamXMLBuilder` output through typed
   construction, while leaving the raw builder unchanged.
6. Only after structural tests pass, import the generated file into Final Cut
   Pro and compare its re-export.

The immediate code gap is that most model types are Codable-only with `let`
properties and no public construction surface. Prefer ergonomic construction
APIs above the schema-faithful Codable types; do not use raw XML templates as a
shortcut.

## Later: Versioning and Validation

Milestone 9 follows the typed-generation slice when explicit multi-version
support is needed:

- Retain explicit behavior for the checked-in FCPXML 1.13 fixtures.
- Add original, uncleaned FCPXML 1.14 exports with recorded Final Cut versions.
- Recheck current primary Apple sources before changing any latest-version
  claim.
- Define decoder behavior for older, newer, and unsupported versions.
- Add validation against authoritative DTD or equivalent structural rules when
  available.
- Make validation failures identify actionable structural paths.

## Real Phase 2 Feature Pairs Still Needed

The comparison command is implemented, but real minimal Final Cut export pairs
must still be collected manually in this order:

1. Transitions and transition parameters.
2. Markers.
3. Roles and audio subroles.
4. Titles and `text-style` properties.
5. Retiming and speed ramps.

Store each pair under:

```text
Tests/FCPKitTests/FeaturePairs/<feature-name>/
├── before.fcpxml
├── after.fcpxml
└── metadata.json
```

The metadata records `finalCutVersion`, `fcpxmlVersion`, `baselineState`, and
`changedAction`. Each pair must consist of untouched exports differing by one
precisely recorded Final Cut action.

Compare a pair with:

```sh
swift run fcpxml-diff compare \
  Tests/FCPKitTests/FeaturePairs/<feature-name>/before.fcpxml \
  Tests/FCPKitTests/FeaturePairs/<feature-name>/after.fcpxml \
  --markdown /tmp/feature-diff.md \
  --json /tmp/feature-diff.json
```

Use `--path /fcpxml/...` when a narrow structural subtree is useful. Path
filtering must not alter normalization.

## Required Verification

Before committing any model milestone, run:

```sh
swift test
swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData \
  --markdown SCHEMA_COMPLETENESS_REPORT.md \
  --json SCHEMA_COMPLETENESS_REPORT.json \
  --fail-if-total-exceeds 0
```

Regenerate reports rather than editing them manually. A new real fixture may
legitimately introduce losses; model and test those losses before lowering the
accepted baseline again.

Verification completed for this handoff:

```text
swift test: 40 tests passed
schema-completeness: 3 files, 0 dropped elements, 0 dropped attributes,
0 dropped text, total 0
```

## Guardrails

- Read `AGENTS.md` and `NEXT_STEPS.md` before making changes.
- Preserve original real exports and their FCPXML versions.
- Treat decode success as insufficient; require read, mutate, encode, and
  structural round-trip evidence.
- Preserve lexical timing and parameter values unless the schema guarantees a
  safer typed representation.
- Keep resource identifiers, references, timing, ordering, and relationships
  stable.
- Keep `MulticamXMLBuilder` unchanged until typed generation is proven in Final
  Cut Pro.
- A zero report for the present fixture set must never be presented as complete
  schema coverage.

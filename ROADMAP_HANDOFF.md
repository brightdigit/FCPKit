# FCPKit Roadmap Handoff

## Current State

Milestones 1 through 7 in `NEXT_STEPS.md` are complete on the `prototype`
branch and pushed to `origin/prototype`.

The structural schema-completeness report currently finds no measured loss in
the three checked-in FCPXML 1.13 fixtures:

| Files | Dropped elements | Dropped attributes | Dropped text | Total |
| ---: | ---: | ---: | ---: | ---: |
| 3 | 0 | 0 | 0 | 0 |

This is evidence for the checked-in fixtures only. It is not proof that the
model covers the complete FCPXML schema or content emitted by later Final Cut
versions.

The test suite has 38 passing tests. The worktree was clean and synchronized
with `origin/prototype` at commit `98177ed` before this handoff was added.

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

Relevant commits, oldest first:

- `78a9ff7` Lock schema completeness baseline
- `9f25350` Model transition effect payloads
- `92d2996` Add shared parameter animation types
- `3c913e1` Complete title text styling model
- `795db6a` Complete nested timeline containers
- `e87285f` Complete library multicam audio model
- `98177ed` Add raw FCPXML pair comparison

## Immediate Next Step: Preserve Unknown Content

Milestone 8 is the highest-priority remaining safety work. FCPKit should not be
used to edit arbitrary user assets until unsupported XML can survive an
unrelated typed edit.

Proceed in this order:

1. Add synthetic fixtures containing:
   - An unknown attribute on a known element.
   - An unknown leaf element.
   - An unknown subtree placed between known siblings.
2. Measure exactly what XMLCoder discards and whether any supported extension
   point can retain unknown keyed content and child order.
3. Prototype a supplemental XML representation if XMLCoder cannot preserve the
   required content itself.
4. Decode the fixture, edit one unrelated typed field, encode it, and prove the
   unknown content remains present exactly once and in the correct position.
5. Write an architecture decision record covering:
   - Ownership of typed and opaque content.
   - Unknown attributes and namespaces.
   - Heterogeneous child ordering.
   - Conflict behavior after a known field is edited.
   - How malformed content differs from well-formed unsupported content.

Do not hide unknown-content differences in normalization to make these tests
pass. Preservation must occur in the model or encoding architecture.

Milestone 8 is accepted only when a known field can be edited without losing,
moving incorrectly, or duplicating each unknown test case.

## Then: Versioning and Validation

Milestone 9 should follow the unknown-content decision:

- Retain explicit behavior for the checked-in FCPXML 1.13 fixtures.
- Add original, uncleaned FCPXML 1.14 exports with recorded Final Cut versions.
- Recheck current primary Apple sources before changing any latest-version
  claim.
- Define decoder behavior for older, newer, and unsupported versions.
- Add validation against authoritative DTD or equivalent structural rules when
  available.
- Make validation failures identify actionable structural paths.

## Then: Typed Generation

Begin Milestone 10 only after the relevant model areas and unknown-content
strategy are reliable:

1. Add ergonomic construction APIs above the schema-faithful Codable layer.
2. Generate a minimal project solely through typed models.
3. Import it into Final Cut Pro and re-export it.
4. Structurally compare the generated and re-exported documents.
5. Reproduce one `MulticamXMLBuilder` result through typed construction.
6. Migrate the raw string builder incrementally, keeping regression fixtures.

Do not remove raw string generation until typed output imports successfully and
round-trips without unexplained structural differences.

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

# FCPKit Next Steps

This roadmap advances FCPKit toward its product goal: a Swift foundation for
apps that create, modify, and read Final Cut Pro assets. The immediate objective
is to make the FCPXML model measurable and progressively lossless before using
it as the authoritative generation layer.

## Current Baseline

Phase 1 is operational in Swift through the `FCPXMLDiff` library and
`fcpxml-diff` executable. The current structural round-trip report covers three
FCPXML 1.13 exports and finds:

| Files | Dropped elements | Dropped attributes | Dropped text | Total |
| ---: | ---: | ---: | ---: | ---: |
| 3 | 58 | 197 | 0 | 255 |

Milestones 1 through 3 are complete. The transition slice removed 28 losses.
Shared recursive parameters, animation, fades, and the parent links needed to
reach their real fixture instances removed another 476 losses: 128 elements,
344 attributes, and 4 text values. No parameter, keyframe, or fade paths remain
in the report.

The largest clusters are:

- Remaining title style attributes such as bold and kerning.
- Nested `ref-clip`, `asset-clip`, and `video` structures.
- Transform, crop, volume, color-conform, conform-rate, and time-map data.
- Library-level multicam, sync-clip, role, and audio-channel details.

The baseline artifacts are `SCHEMA_COMPLETENESS_REPORT.md` and
`SCHEMA_COMPLETENESS_REPORT.json`. Regenerate them after each model milestone;
do not edit them by hand.

## Milestone 1: Lock Down Phase 1

Before broad model work, make the report a dependable regression signal.

- Add fixture-level snapshot assertions for aggregate counts and representative
  structural paths.
- Add tests for repeated sibling matching, reordered attributes, mixed text,
  empty elements, and heterogeneous children.
- Confirm resource-reference normalization handles definitions and references
  consistently when resources are inserted, deleted, or reordered.
- Confirm opaque masking preserves the presence, element path, and attributes
  of `bookmark` and `data[key="effectConfig"]` while masking only payload text.
- Add a CLI option that returns a nonzero exit status when unexpected losses
  exceed an accepted baseline, so the report can be used in CI.
- Document whether a reported volatile attribute that disappears entirely is a
  real model loss. Volatile values are masked; attribute presence must still be
  compared.

Acceptance criteria:

- `swift test` passes.
- Repeated runs produce byte-stable Markdown and JSON reports.
- Synthetic tests suppress only expected volatile churn and continue to expose
  real element, attribute, and text changes.
- The checked-in baseline cannot increase unnoticed in CI.

## Milestone 2: Model a Transition End to End

Use the Cross Dissolve in `UntitledXML.fcpxml` as the first vertical slice. It
is a known, user-visible loss and exercises reusable effect structures.

- Extend `Transition` to represent nested `filter-video`, `filter-audio`,
  `param`, and `data` children.
- Preserve `data[key="effectConfig"]` content on decode and encode even though
  the differential display masks its opaque value.
- Reuse shared effect/parameter types only where their XML shape and child
  ordering genuinely match.
- Add focused assertions that read transition parameters from the real fixture.
- Add a decode, mutate, encode, decode test that changes a safe transition
  parameter without losing its siblings or opaque configuration.
- Regenerate the completeness report and record the exact reduction.

Acceptance criteria:

- The Cross Dissolve's complete nested subtree survives round-tripping.
- The transition-related dropped paths disappear from the report.
- Existing filter-video uses elsewhere in the fixtures do not regress.

## Milestone 3: Add Shared Parameter and Animation Types

The highest-frequency losses are repeated parameter structures. Address them as
a coherent family rather than adding feature-specific copies.

- Model `param` recursively where Final Cut emits nested parameters.
- Model `keyframeAnimation`, `keyframe`, `fadeIn`, and `fadeOut` with all
  observed attributes.
- Preserve child order when parameters, data, and animations are interleaved.
- Cover both title parameters and volume/effect parameters with real fixtures.
- Treat parameter values as lexical strings unless the schema guarantees a
  single numeric representation; Final Cut uses several compound formats.

Acceptance criteria:

- The large title/filter `param` clusters no longer appear as dropped.
- Keyframe and fade structures survive decode, mutation, and re-encode.
- A shared representation does not force unrelated parameter variants into an
  invalid shape.

## Milestone 4: Complete Titles and Text Styling

- Model `title`, `text`, `text-style-def`, and `text-style`, including styled
  text content and references.
- Preserve font, size, color, bold, kerning, and observed nested parameters.
- Add mutation tests for visible text and at least one style property.
- Add a minimal Final Cut export pair that changes only one title property when
  Phase 2 raw-pair comparison is available.

Acceptance criteria:

- The four currently dropped styled-text values survive round-tripping.
- Title text can be read and changed through a typed API.
- Re-encoded style definitions retain valid references and ordering.

## Milestone 5: Complete Timeline Containers

Work outward from shared leaf types to nested timeline containers.

- Support nested `ref-clip`, `asset-clip`, and `video` wherever the fixtures
  demonstrate they are legal.
- Complete transform, crop/trim-rect, volume, color-conform, conform-rate, and
  time-map representations.
- Preserve lane, offset, start, duration, format, role, and timecode semantics.
- Add relationship tests for resource references and nested timing rather than
  asserting only decoded counts.

Acceptance criteria:

- Nested clip/video losses are removed without flattening their hierarchy.
- Timing and lane values survive round-tripping exactly.
- Mutation tests demonstrate that changing one nested clip does not alter its
  siblings or resource references.

## Milestone 6: Complete Library, Multicam, Roles, and Audio

- Model library-level `mc-clip`, `mc-source`, and `sync-clip` content found in
  the real exports.
- Complete `audio-channel-source`, `adjust-loudness`, audio roles, subroles, and
  source-channel attributes.
- Add tests that traverse from library/event objects to referenced media and
  validate multicam angle relationships.
- Keep `MulticamXMLBuilder` unchanged during this milestone; use its generated
  XML only as additional behavioral evidence.

Acceptance criteria:

- `Both-Multicam.fcpxml` and `Interview.fcpxml` retain their modeled library and
  audio structures.
- Apps can inspect multicam angles and audio roles through typed APIs.
- The schema report shows no unexplained losses for these feature families.

## Milestone 7: Build Phase 2 Raw-Pair Diffing

Add a second CLI workflow on the existing normalize-and-diff core:

```sh
swift run fcpxml-diff compare before.fcpxml after.fcpxml
```

- Report additions, removals, and changed attribute/text values in both
  directions, not only round-trip losses.
- Provide Markdown and JSON output with the same structural path vocabulary as
  Phase 1.
- Add an optional narrow path filter for isolating a feature subtree without
  changing normalization behavior.
- Define a sample-pair directory convention and a small metadata file recording
  Final Cut version, FCPXML version, baseline state, and the one changed action.
- Add no-app synthetic tests for added, removed, and changed structures.

Collect minimal Final Cut pairs in this order:

1. Transitions and transition parameters.
2. Markers.
3. Roles and audio subroles.
4. Titles and `text-style` properties.
5. Retiming and speed ramps.

Acceptance criteria:

- The same normalized documents yield no diff.
- A single feature toggle produces a focused, deterministic report.
- Raw-pair output can directly inform a Codable model change and its tests.

## Milestone 8: Preserve Unknown Content

Full schema coverage will always lag Final Cut releases. Before FCPKit is used
to modify user assets, define an explicit forward-compatibility strategy.

- Investigate where XMLCoder can retain unknown attributes and ordered child
  elements and where a supplemental XML representation is required.
- Write an architecture decision record covering typed known content, opaque
  unknown content, ordering, namespaces, and mutation behavior.
- Prototype preservation on an unknown attribute, an unknown leaf, and an
  unknown subtree placed between known siblings.
- Ensure normal encoding does not duplicate preserved nodes after a known field
  is edited.

Acceptance criteria:

- Decode, edit an unrelated typed field, and encode without losing the unknown
  test content.
- The behavior is deterministic and documented for downstream app developers.
- Unsupported content is distinguishable from malformed content.

## Milestone 9: Versioning and Validation

- Add explicit coverage for both the checked-in FCPXML 1.13 fixtures and new
  FCPXML 1.14 samples.
- Record schema provenance and recheck current Apple primary sources whenever
  the supported/latest version claim changes.
- Add validation against an appropriate DTD or equivalent structural rules
  where current Apple schema material is available.
- Define decoder behavior for newer, older, and unsupported versions.

Acceptance criteria:

- Callers can determine the parsed version and understand compatibility
  failures.
- Generated documents declare a deliberate version.
- Validation failures identify actionable structural paths.

## Milestone 10: Generation and Builder Consolidation

Begin this only after the relevant model areas have strong round-trip coverage.

- Define ergonomic construction and mutation APIs above the schema-faithful
  Codable layer.
- Generate a minimal project solely through the model and import it into Final
  Cut Pro.
- Reproduce one `MulticamXMLBuilder` output through typed model construction and
  compare the normalized structures.
- Migrate builder functionality incrementally, retaining regression fixtures at
  each step.
- Remove raw string generation only when typed output is structurally complete
  and accepted by Final Cut Pro.

Acceptance criteria:

- A model-generated project imports successfully and re-exports without an
  unexplained structural delta.
- Resource IDs and references are assigned consistently by library code.
- The typed builder supports application-level creation and modification without
  requiring callers to assemble XML strings.

## Definition of Done for Model Features

A model feature is complete only when all of the following are true:

- It decodes from a real or intentionally synthetic fixture.
- Its meaningful values are exposed through a typed Swift API.
- It can be changed without disturbing unrelated content.
- It re-encodes with correct element names, attributes, ordering, and
  relationships.
- Its expected paths are absent from the schema-completeness loss report.
- It has regression tests, including failure or edge cases appropriate to its
  risk.
- Its behavior across supported FCPXML versions is known or explicitly limited.

## Immediate Work Queue

1. Commit the Phase 1 harness, its tests, `AGENTS.md`, and the generated baseline
   reports as one reviewable foundation change.
2. Add stable baseline/snapshot and CLI exit-status tests from Milestone 1.
3. Implement the transition vertical slice from Milestone 2.
4. Regenerate the reports and quantify the transition-related improvement.
5. Implement shared parameter/keyframe types, then titles.
6. Add the Phase 2 `compare` command and begin collecting minimal pairs.

Do not use a zero total-diff count as the only completion target. The real goal
is trustworthy read, modify, and write behavior with meaningful unknown content
preserved.

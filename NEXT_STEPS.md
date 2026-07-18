# FCPKit Next Steps

This is the living engineering roadmap for FCPKit. Completed implementation
detail belongs in Git history, focused tests, generated reports, and ADRs; this
document keeps only the evidence needed to understand the current baseline and
the work that remains.

FCPKit's goal is to become the Swift foundation for apps that create, modify,
and read Final Cut Pro assets. Work should continue to prioritize faithful
structure, type-safe inspection and mutation, reliable generation, explicit
schema compatibility, and stable identifiers, references, timing, ordering,
and relationships.

## Verified Baseline

As of July 17, 2026, the verified implementation baseline is commit `3fc669a`.
The Swift test suite passes 42 tests. The schema-completeness workflow reports
no measured structural loss in the three checked-in FCPXML 1.13 exports:

| Files | Dropped elements | Dropped attributes | Dropped text | Total |
| ---: | ---: | ---: | ---: | ---: |
| 3 | 0 | 0 | 0 | 0 |

The generated evidence is in `SCHEMA_COMPLETENESS_REPORT.md` and
`SCHEMA_COMPLETENESS_REPORT.json`. Regenerate these artifacts through the CLI;
never edit them by hand.

This zero-loss result is a regression signal for the tested fixture vocabulary,
not proof of complete FCPXML 1.13 coverage or compatibility with every Final
Cut Pro export. XMLCoder silently ignores unmodeled content, so parsing without
an error is not sufficient evidence of support.

[ADR 0001](docs/adr/0001-supported-schema-and-best-effort-editing.md)
establishes the current compatibility policy:

- The typed Codable model is authoritative for the explicitly tested
  vocabulary.
- Editing imported documents is best effort. Unsupported content may be
  omitted during encoding.
- Callers can use round-trip diagnostics to discover dropped elements,
  attributes, and text.
- Preserving arbitrary unknown XML, namespaces, or unknown child ordering in a
  sidecar representation is out of scope for this phase.

## Completed Foundation

Milestones 1 through 7 and the diagnostic foundation of Milestone 8 are
complete:

| Milestone | Outcome | Commit |
| --- | --- | --- |
| 1 | Deterministic schema-completeness snapshots, normalization tests, and CI loss threshold | `78a9ff7` |
| 2 | Transition payload decoding, mutation, and encoding | `9f25350` |
| 3 | Recursive parameters, animations, keyframes, and fades | `92d2996` |
| 4 | Mutable title text and styling with stable references | `3c913e1` |
| 5 | Nested timeline containers, timing, transforms, crop, and conform behavior | `795db6a` |
| 6 | Library multicam, sync clips, roles, and audio structures | `e87285f` |
| 7 | Raw-pair comparison with Markdown, JSON, normalization, and path filtering | `98177ed` |
| 8 foundation | Supported-schema policy and reusable round-trip loss diagnostics | `3fc669a` |

The next milestone must build on this evidence rather than reopening completed
schema-loss work without a new fixture or focused regression.

## Active Milestone: Typed Generation Vertical Slice

The automated portion is complete. Application code can now construct the core
project and multicam graph through public, schema-shaped initializers and
mutate supported nested values while stable document and resource identities
remain immutable.

Verified automated evidence:

- A public-client test (`import FCPKit`, without `@testable`) constructs and
  round-trips an FCPXML 1.13 format, asset/media representation, library, event,
  project, sequence, spine, and asset clip with stable timing and references.
- Nested value-semantic mutation renames the project without changing resource
  IDs, UIDs, timing, media paths, or references.
- A typed multicam graph has zero normalized symmetric findings against one
  unchanged `MulticamXMLBuilder` output, including media, crop, transforms,
  angles, sources, relationships, and smart collections.
- The full suite passes 42 tests and the three real FCPXML 1.13 fixtures remain
  at zero measured round-trip loss.

The Final Cut Pro gate remains pending. Follow the decision-complete
[manual artifact checklist](docs/manual/final-cut-artifacts.md) to generate the
typed input, import and re-export it, preserve the `.fcpxmld` bundle, and return
the structural diff and environment metadata. Do not migrate or remove
`MulticamXMLBuilder` until that gate passes.

Acceptance criteria:

- Application code can create the minimal project without assembling XML
  strings or relying on internal/memberwise initializers.
- The typed document encodes and parses back without structural loss.
- Resource IDs and all references resolve consistently.
- Timing and hierarchy survive both construction and mutation tests.
- The model-generated file imports successfully into Final Cut Pro and its
  re-export has no unexplained structural delta.
- `MulticamXMLBuilder` is not migrated or removed until typed parity and the
  manual import gate are complete.

## Parallel Evidence Work: Real Feature Pairs

The `fcpxml-diff compare` workflow is implemented, but real minimal Final Cut
exports still need to be collected manually. Collect them in this order:

1. Transitions and transition parameters.
2. Markers.
3. Roles and audio subroles.
4. Titles and `text-style` properties.
5. Retiming and speed ramps.

Store each untouched pair under:

```text
Tests/FCPKitTests/FeaturePairs/<feature-name>/
├── before.fcpxml
├── after.fcpxml
└── metadata.json
```

`metadata.json` records `finalCutVersion`, `fcpxmlVersion`, `baselineState`, and
`changedAction`. Each pair must differ by one precisely recorded Final Cut
action. Do not hand-clean volatile values, paths, or opaque payloads.

Compare a pair with:

```sh
swift run fcpxml-diff compare \
  Tests/FCPKitTests/FeaturePairs/<feature-name>/before.fcpxml \
  Tests/FCPKitTests/FeaturePairs/<feature-name>/after.fcpxml \
  --markdown /tmp/feature-diff.md \
  --json /tmp/feature-diff.json
```

Use `--path /fcpxml/...` only to focus the displayed subtree. Path filtering
must not change normalization behavior.

## Next Milestone: Versioning and Validation

Begin explicit multi-version work after the typed-generation vertical slice:

1. Add original, uncleaned FCPXML 1.14 exports with their Final Cut Pro version
   and provenance recorded.
2. Recheck current primary Apple sources before changing any supported or
   latest-version claim.
3. Define and test parser behavior for supported, older, newer, and malformed
   FCPXML versions. A version declaration alone must not imply complete schema
   coverage.
4. Add validation against an authoritative DTD or equivalent structural rules
   where current Apple material is available.
5. Report validation failures with actionable structural paths.

Acceptance criteria:

- Callers can inspect the parsed version and understand compatibility or
  validation failures.
- Generated documents declare a deliberate supported version.
- Both 1.13 and 1.14 behavior are backed by intact real fixtures.
- Version and validation errors identify the affected document path whenever
  possible.

## Later Milestone: Builder Consolidation

Only after typed generation passes structural and Final Cut import testing:

1. Move `MulticamXMLBuilder` behavior incrementally onto typed construction.
2. Retain a normalized regression fixture at each migration step.
3. Centralize resource-ID and reference assignment in library code.
4. Remove raw XML generation only when typed output has feature parity and is
   accepted by Final Cut Pro.

The completed API must support application-level creation and modification
without requiring callers to assemble XML strings.

## Documentation Accuracy

Public documentation must be reconciled with the supported-schema policy. In
particular, remove claims of complete FCPXML or complete version coverage,
update stale test counts, document best-effort editing and loss diagnostics,
and add typed-generation examples only after those APIs exist.

`ROADMAP_HANDOFF.md` is a historical handoff, not a second live roadmap. Future
status updates should be made here rather than maintaining competing current
state sections.

## Immediate Work Queue

1. Complete the manual Final Cut import and re-export acceptance check using
   [the artifact checklist](docs/manual/final-cut-artifacts.md).
2. Collect the first real transition feature pair when Final Cut is available.
3. Add FCPXML 1.14 fixture evidence and explicit version behavior.
4. Add authoritative validation with path-oriented diagnostics.
5. Migrate the raw multicam builder incrementally after all gates pass.
6. Reconcile README and API documentation with the supported-schema policy.

## Definition of Done for Model Features

A model feature is complete only when all of the following are true:

- It decodes from a real or intentionally synthetic fixture.
- Its meaningful values are exposed through a public typed Swift API.
- Application code can construct it when generation requires it.
- It can be changed without disturbing unrelated content.
- It re-encodes with correct element names, attributes, ordering, timing, and
  relationships.
- Its expected paths are absent from the schema-completeness loss report.
- It has focused regression tests, including appropriate failure or edge cases.
- Its behavior across supported FCPXML versions is known or explicitly limited.

## Required Verification

Before committing a model milestone, run:

```sh
swift test
swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData \
  --markdown SCHEMA_COMPLETENESS_REPORT.md \
  --json SCHEMA_COMPLETENESS_REPORT.json \
  --fail-if-total-exceeds 0
```

Generated reports are diagnostic evidence, not proof by themselves. A new real
fixture may legitimately reveal losses; model and test those losses rather than
lowering the accepted baseline or broadening normalization to hide them.

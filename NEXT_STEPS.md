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

As of July 28, 2026, the typed-generation vertical slice and Final Cut import
gate are complete. `MulticamXMLBuilder` constructs documents through the typed
Codable model (no raw XML templates, no generated smart collections). The
schema-completeness workflow reports no measured structural loss in the three
checked-in FCPXML 1.13 exports:

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

Gate evidence (accepted deltas, no private paths):
[docs/manual/typed-generation-gate.md](docs/manual/typed-generation-gate.md).

## Completed Foundation

| Milestone | Outcome |
| --- | --- |
| 1 | Deterministic schema-completeness snapshots, normalization tests, and CI loss threshold |
| 2 | Transition payload decoding, mutation, and encoding |
| 3 | Recursive parameters, animations, keyframes, and fades |
| 4 | Mutable title text and styling with stable references |
| 5 | Nested timeline containers, timing, transforms, crop, and conform behavior |
| 6 | Library multicam, sync clips, roles, and audio structures |
| 7 | Raw-pair comparison with Markdown, JSON, normalization, and path filtering |
| 8 | Supported-schema policy, loss diagnostics, typed generation, Final Cut import gate, typed `MulticamXMLBuilder` |

## Active Milestone: Versioning and Validation

Apple primary sources rechecked July 28, 2026:

- [Final Cut Pro release notes](https://support.apple.com/en-us/102825) document
  FCPXML 1.14 (Final Cut Pro 12.x).
- Apple's public developer FCPXML reference still centers older DTD material;
  current DTDs ship inside the Final Cut Pro app bundle
  (`Interchange.framework` resources). Do not change “latest version” product
  claims without a checked-in original 1.14 fixture and provenance.

Library groundwork in place:

- `FCPXMLVersion` / `FCPXMLVersionCompatibility` classify declared versions as
  supported (`1.13`), older, newer, or malformed.
- Default parse remains best-effort for older/newer documents.
- `parseRequiringWellFormedVersion` rejects malformed version strings only.
- Typed generation emits `FCPXMLVersion.supportedGenerationVersion` (`1.13`).

Still required to finish this milestone:

1. Add original, uncleaned FCPXML 1.14 exports with Final Cut version and
   provenance recorded (human export; see checklist below).
2. Add validation against an authoritative DTD or equivalent structural rules
   where current Apple material is available.
3. Report validation failures with actionable structural paths.

Acceptance criteria:

- Callers can inspect the parsed version and understand compatibility or
  validation failures.
- Generated documents declare a deliberate supported version.
- Both 1.13 and 1.14 behavior are backed by intact real fixtures.
- Version and validation errors identify the affected document path whenever
  possible.

## Parallel Evidence Work: Real Feature Pairs

The `fcpxml-diff compare` workflow is implemented. The first real pair is
checked in:

- Transitions: `Tests/FCPKitTests/FeaturePairs/transitions/` (FCPXML 1.14,
  Cross Dissolve defaults)

Still collect, in order:

1. Markers.
2. Roles and audio subroles.
3. Titles and `text-style` properties.
4. Retiming and speed ramps.

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

## Ready for Human

These steps require Final Cut Pro and cannot be completed unattended:

1. Export the next feature pair (markers)
   ([checklist pattern](docs/manual/final-cut-artifacts.md)).
2. Export one original FCPXML 1.14 document with provenance for `TestData`
   ([checklist](docs/manual/final-cut-artifacts.md#ready-for-human-original-fcpxml-114-export)).
   The transition pair is already 1.14 evidence for feature isolation, but a
   dedicated original fixture is still wanted for schema-completeness.
3. Optionally record `finalCutVersion` on any local gate metadata retained
   outside the repo.

## Documentation Accuracy

Public documentation must stay aligned with the supported-schema policy. Avoid
claims of complete FCPXML or complete version coverage. Prefer fixture evidence,
diagnostics, and explicit version compatibility APIs.

`ROADMAP_HANDOFF.md` is a historical handoff, not a second live roadmap. Future
status updates should be made here rather than maintaining competing current
state sections.

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

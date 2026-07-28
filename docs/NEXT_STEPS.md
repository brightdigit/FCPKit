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

As of July 28, 2026, typed generation, Final Cut import gate, FeaturePairs
isolation exports, AssetClip `timeMap`, ergonomic clip helpers
(`addMarker` / `assignMusicRole` / `setConstantSpeed`), common FCPXML 1.14
round-trip fields, DTD validation via `fcpxml-diff validate`, and a promoted
1.14 `TestData` fixture are in place. Schema-completeness reports no measured
structural loss across the checked-in fixtures (1.13 + 1.14):

| Files | Dropped elements | Dropped attributes | Dropped text | Total |
| ---: | ---: | ---: | ---: | ---: |
| 4 | 0 | 0 | 0 | 0 |

The generated evidence is in `docs/reports/SCHEMA_COMPLETENESS_REPORT.md` and
`docs/reports/SCHEMA_COMPLETENESS_REPORT.json`. Regenerate these artifacts
through the CLI; never edit them by hand.

Zero loss is a regression signal for the tested fixture vocabulary, not proof
of complete FCPXML 1.13/1.14 coverage. XMLCoder silently ignores unmodeled
content, so parsing without an error is not sufficient evidence of support.
DTD validation similarly proves DTD conformance, not full semantic coverage.

**The completeness gate is also order-blind, and a confirmed round-trip defect
hides behind it.** `Inventory` in `Sources/FCPXMLDiff/FCPXMLDiffEngine.swift`
keys a multiset by ancestor path with no sibling ordering, so a reordered spine
scores zero loss. `Spine` (`Sources/FCPKit/FCPXML.swift:297`) stores children as
14 parallel arrays, while the DTD declares
`<!ELEMENT spine (%clip_item; | transition)*>` — one ordered sequence. The
`transitions` FeaturePair is `asset-clip, transition, asset-clip` on disk and
re-encodes as `asset-clip, asset-clip, transition`, which Final Cut rejects.
Evidence and analysis:
[planning/v0.1.0-investigation-findings.md](planning/v0.1.0-investigation-findings.md).

[ADR 0001](adr/0001-supported-schema-and-best-effort-editing.md)
establishes the current compatibility policy:

- The typed Codable model is authoritative for the explicitly tested
  vocabulary.
- Editing imported documents is best effort. Unsupported content may be
  omitted during encoding.
- Callers can use round-trip diagnostics to discover dropped elements,
  attributes, and text.
- Preserving arbitrary unknown XML, namespaces, or unknown child ordering in a
  sidecar representation is out of scope for this phase.

Gate evidence:
[manual/typed-generation-gate.md](manual/typed-generation-gate.md).

## Proposed Next Milestone: v0.1.0

A design proposal for the first working version is under review — **not yet
accepted, no implementation started**:

- [planning/v0.1.0-first-working-version.md](planning/v0.1.0-first-working-version.md)
  — the proposal: ordered content models, strong value types (`FCPTime` and
  friends), a resultBuilder authoring DSL, and a read-only ScriptingBridge
  inspector, sequenced into nine steps.
- [planning/v0.1.0-investigation-findings.md](planning/v0.1.0-investigation-findings.md)
  — the supporting evidence: the spine ordering defect, verified XMLCoder
  ordering behavior, the read-only Final Cut sdef, 1.14 DTD reference notes,
  documentation inaccuracies, and the alternatives that were rejected.

Open questions are listed at the end of the findings document.

## Completed Foundation

| Milestone | Outcome |
| --- | --- |
| 1–7 | Schema completeness, transitions, params, titles, nested timelines, multicam/roles, raw-pair diff |
| 8 | Supported-schema policy, diagnostics, typed generation, Final Cut import gate, typed `MulticamXMLBuilder` |
| 9 (partial) | Version APIs, DTD validate CLI, 1.14 fixture + FeaturePairs round-trip vocabulary |
| Clip helpers | `AssetClip.addMarker` / `assignMusicRole` / `setConstantSpeed` match FeaturePairs signals; title-style and speed-ramp stay optional human recipes only |

## Versioning and Validation

- Generation baseline remains `FCPXMLVersion.supportedGenerationVersion` = `1.13`.
- `testedFixtureVersions` includes `1.13` and `1.14`.
- Declared `1.14` is still classified `.newer` relative to the generation
  baseline (fixture presence ≠ generation default).
- `fcpxml-diff validate <file> [--dtd path]` validates against Apple DTDs from
  the Final Cut app bundle when present (DTD copied to a spaceless temp path
  because `xmllint` cannot resolve spaced SYSTEM paths).

Remaining validation work: richer path mapping from `xmllint` diagnostics;
optional CI DTD cache without requiring Final Cut installed.

## Parallel Evidence Work: Real Feature Pairs

All planned isolation pairs are under `Tests/FCPKitTests/FeaturePairs/`:

| Pair | Changed action |
| --- | --- |
| `transitions` | Default Cross Dissolve between Left/Right |
| `markers` | Standard marker `Cue` at 5s |
| `roles` | Music via `audio-channel-source` (`music.music-1`) |
| `titles` | Default Basic Title + text-style |
| `retiming` | Constant 50% slow (`timeMap` on `asset-clip`) |

App-facing helpers for the three clip mutations above live on `AssetClip`
(`AssetClipEditing.swift`). Title-style and speed-ramp remain optional human
recipes only ([easy-export-recipes.md](manual/easy-export-recipes.md)).

Specs: [manual/final-cut-artifacts.md](manual/final-cut-artifacts.md).

## Ready for Human

These steps require Final Cut Pro and cannot be completed unattended.
AppleScript cannot automate exports.

**Child-simple recipes:** [manual/easy-export-recipes.md](manual/easy-export-recipes.md)

1. Optional follow-up pairs from that guide: title style only; speed ramp.
2. Import/re-export gate when generation APIs expand again.
3. Re-export after Final Cut upgrades that change FCPXML output.
4. Privacy review for any new exports that leave Shared/generic paths.


## Documentation Accuracy

Public documentation must stay aligned with the supported-schema policy. Avoid
claims of complete FCPXML or complete version coverage. Prefer fixture evidence,
diagnostics, and explicit version compatibility APIs.

`archive/ROADMAP_HANDOFF.md` is a historical handoff, not a second live roadmap.

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
  --markdown docs/reports/SCHEMA_COMPLETENESS_REPORT.md \
  --json docs/reports/SCHEMA_COMPLETENESS_REPORT.json \
  --fail-if-total-exceeds 0
```

Generated reports are diagnostic evidence, not proof by themselves. A new real
fixture may legitimately reveal losses; model and test those losses rather than
lowering the accepted baseline or broadening normalization to hide them.

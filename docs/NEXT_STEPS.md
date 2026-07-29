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

## Accepted Next Milestone: v0.1.0

[ADR 0002](adr/0002-create-first-ordered-typed-model.md) accepts the create-first,
ordered, typed working version. **Implementation has not started.** Create-from-scratch
authoring is the acceptance bar; editing existing exports stays best-effort
([ADR 0001](adr/0001-supported-schema-and-best-effort-editing.md)).

### Resume later (reading order)

1. [ADR 0002](adr/0002-create-first-ordered-typed-model.md) — accepted decisions
2. [planning/v0.1.0-first-working-version.md](planning/v0.1.0-first-working-version.md)
   — full plan; **§3 is the locked `FCPKitDSL` surface**
3. [planning/v0.1.0-investigation-findings.md](planning/v0.1.0-investigation-findings.md)
   — evidence, rejected alternatives, resolved questions, deferred DSL grill list (§10)
4. [planning/v0.1.0-issues.md](planning/v0.1.0-issues.md) — GitHub issues #4–#14
5. [planning/v0.1.0-worktree-plan.md](planning/v0.1.0-worktree-plan.md) — parallel lanes
6. This section — where to code next

**Worktrees:** This planning branch is `swift-package-plan`. Implementation evolves
`v0.1.x` (sibling worktree). Before Step 0 code: merge or cherry-pick these planning/ADR
commits onto `v0.1.x` (or continue implementing here only if that branch is intentionally
repurposed — default is **code on `v0.1.x` with docs present**). Then follow the
[worktree plan](planning/v0.1.0-worktree-plan.md): `v0.1-scaffold` for [#4](https://github.com/brightdigit/FCPKit/issues/4),
`v0.1.x` for the model chain starting at [#5](https://github.com/brightdigit/FCPKit/issues/5),
`v0.1-scripting` for [#12](https://github.com/brightdigit/FCPKit/issues/12) after Step 1.

**Frontier (ready now):**

- [#4](https://github.com/brightdigit/FCPKit/issues/4) — BrightDigit Swift package scaffolding
  (CI, lint/format, package hygiene)
- [#5](https://github.com/brightdigit/FCPKit/issues/5) — Step 0: XMLCoder ordering guardrails +
  Spine choice spike + `XCTExpectFailure` on
  `Tests/FCPKitTests/FeaturePairs/transitions/after.fcpxml`

DSL code is Step 6 / [#11](https://github.com/brightdigit/FCPKit/issues/11) (`FCPKitDSL` product).

**Still open (design, not blocking Steps 0–5):** markers / roles / retiming modifier shapes;
time literals (`10s`); `RefClip` / `<media>` authoring; exact transition-overlap algorithm
write-up; preset catalog membership; `URL` vs `filePath` spelling. Listed under findings §10.

- [planning/v0.1.0-first-working-version.md](planning/v0.1.0-first-working-version.md)
  — accepted plan: ordered content models, strong value types (`FCPTime` and
  friends), **`FCPKitDSL`** (`Document` + result builders), and a read-only
  ScriptingBridge inspector, sequenced into Steps 0–8. DSL surface grilled
  2026-07-28 (§3).
- [planning/v0.1.0-investigation-findings.md](planning/v0.1.0-investigation-findings.md)
  — supporting evidence and the resolved decision table.
- [planning/v0.1.0-issues.md](planning/v0.1.0-issues.md) — tracker map for #4–#14.
- [planning/v0.1.0-worktree-plan.md](planning/v0.1.0-worktree-plan.md) — parallel lanes.

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

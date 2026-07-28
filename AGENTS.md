# FCPKit Agent Guide

## Product Goal

FCPKit is intended to become the Swift foundation for apps that create, modify,
and read Final Cut Pro assets. It is not only an FCPXML decoder. The long-term
library must support faithful inspection, ergonomic mutation, and reliable
generation of assets that Final Cut Pro can consume.

Optimize changes for these capabilities:

- Preserve the meaning and structure of real Final Cut Pro data across a
  decode, edit, and encode cycle.
- Provide type-safe APIs suitable for application code, not merely tests or
  one-off conversion scripts.
- Generate valid FCPXML without relying indefinitely on raw XML templates.
- Handle schema versions explicitly and validate output where possible.
- Preserve unknown or opaque content when fully modeling it is impractical, so
  an app does not destroy data it did not edit.
- Keep resource references, identifiers, timing, ordering, and cross-element
  relationships stable and correct.

Parsing a file without throwing is not evidence of complete support. A feature
is supported only when its relevant structure and values survive round-tripping
and can be intentionally read, changed, and encoded.

## Current Architecture

- `Sources/FCPKit/FCPXML.swift`, `FCPXMLExtended.swift`, and
  `FCPXMLMissingElements.swift` contain the XMLCoder-backed Codable model.
- `Sources/FCPKit/FCPXMLParser.swift` is the public decode/encode entry point.
- `Sources/FCPKitMediaTools/MulticamXMLBuilder.swift` generates split-screen
  multicam documents through the typed Codable model (no raw XML templates).
  Final Cut import/re-export gate evidence lives in
  `docs/manual/typed-generation-gate.md`.
- `Sources/FCPXMLDiff/` and `Sources/FCPXMLDiffCLI/` provide the structural
  differential harness and the `fcpxml-diff` executable.
- `Tests/FCPKitTests/TestData/` contains real Final Cut Pro exports used as
  schema evidence and regression fixtures.

Typed generation is the source of truth for new multicam documents. Continue
using structural diffs, fixtures, and Final Cut gates before expanding
generation coverage; do not reintroduce raw XML templates for supported
vocabulary.

## Known Model Risk

XMLCoder silently ignores XML elements and attributes that the Codable structs
do not represent. Decode followed by encode is therefore lossy even when decode
succeeds. Treat that loss as a schema-completeness signal.

A concrete known example is `Transition` in
`FCPXMLMissingElements.swift`: it models only `ref`, `offset`, `duration`,
`alignment`, `name`, and `start`. Real transitions can include nested
`filter-video`, `param`, `data`, and `filter-audio` content. The Cross Dissolve
in `Tests/FCPKitTests/TestData/UntitledXML.fcpxml` includes a nested
`filter-video`/`param`/`effectConfig` payload that the current model drops.

Do not infer completeness from README claims. Use real fixtures, structural
round-trip diffs, focused access assertions, and tests.

## Differential Workflow

The normalize-and-diff core serves two workflows:

1. **Schema completeness:** Decode each checked-in FCPXML file with
   `FCPXMLParser`, re-encode it with XMLCoder, then structurally diff the result
   against the original. Rank dropped elements, attributes, and text by
   frequency. This is the missing-model work list.
2. **Feature isolation:** Compare a minimal pair of raw Final Cut Pro exports
   that differ by one manually toggled feature. Final Cut Pro's AppleScript
   dictionary is too limited to generate these samples reliably, so they are
   hand-authored and exported from the app.

Normalization must happen before either diff:

- Map `r1...rN` resource identifiers and references to symbolic values in first
  appearance order.
- Replace volatile `uid`, `sig`, and `modDate` values with placeholders.
- Mask opaque `<bookmark>` content and `<data key="effectConfig">` payloads.
- Compare parsed element/attribute trees, never formatted XML lines.

Run the schema-completeness report with:

```sh
swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData \
  --markdown SCHEMA_COMPLETENESS_REPORT.md \
  --json SCHEMA_COMPLETENESS_REPORT.json \
  --fail-if-total-exceeds 0
```

The failure threshold makes increases fail with exit status 1 while allowing
model improvements below the baseline. Volatile attribute values are masked,
but their presence is not: if `uid`, `sig`, or `modDate` disappears during
round-tripping, the report correctly records a dropped attribute.

Prioritize feature-isolation samples for transitions, markers, roles,
titles/`text-style`, and retiming. Store the FCPXML version and a precise
description of the single changed Final Cut setting with every pair.

## Schema Versions

The checked-in real exports are FCPXML 1.13. As verified in July 2026, Final Cut
Pro 12.0 exports FCPXML 1.14. Apple's Final Cut Pro release notes are currently
the evidence for 1.14, while its public developer DTD page still exposes older
documentation. Recheck current primary Apple sources before changing claims
about the latest version; do not rely on model memory.

Version differences must not be flattened accidentally. Prefer explicit,
tested compatibility behavior and retain the version attached to each fixture.

## Testing Expectations

Before changing the model, read the actual fixture subtree for the feature and
the surrounding Codable types. Add narrowly focused decode/access and
round-trip assertions alongside any new representation.

At minimum, run:

```sh
swift test
swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData
```

The no-app synthetic tests must continue proving that normalization suppresses
resource-ref, `uid`, `sig`, and `modDate` churn while still reporting genuine
structural changes. Changes to normalizing or matching logic need tests that
guard against masking meaningful content.

When adding a real export fixture:

- Keep the original export intact; do not hand-clean volatile or opaque data.
- Record the Final Cut Pro and FCPXML versions when known.
- Prefer minimal, single-feature samples over large projects for learning a
  representation.
- Use larger real projects to measure coverage and interaction regressions.
- Never include private media or credentials; FCPXML can contain file paths,
  user metadata, and opaque payloads.

## Engineering Direction

Favor the existing Swift, FCPKit, XMLCoder, and Swift Testing stack. The
differential tooling belongs in Swift because it must exercise the same model
and encoder used by downstream apps.

Keep model additions faithful to XML ordering and XMLCoder node-encoding rules.
Avoid convenience abstractions that prevent lossless representation. Where the
schema permits heterogeneous ordered children, preserve that order rather than
splitting content into unrelated arrays unless XMLCoder and round-trip tests
prove the encoding remains correct.

Generated reports are diagnostic artifacts, not proof by themselves. The
desired trajectory is fewer unexplained deltas plus stronger read/mutate/write
APIs. A zero-delta fixture set is useful only if normalization is narrow enough
that meaningful differences remain visible.

## Agent skills

### Issue tracker

Issues and PRDs live as GitHub issues in `brightdigit/FCPKit`, managed via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Agent memory & corrections

Persistent notes for agents live in the repo (committed and shared), not in any machine-local directory:

- **`.claude/CORRECTIONS.md`** — append-only log; the source of truth for user corrections and explicit always/never directives. Whenever the user corrects an agent or gives an "always"/"never" directive, append one concise dated line. Never rewrite, reorder, or delete prior entries.
- **`.claude/memory/MEMORY.md`** — index of persistent memories; read it, then the linked files under `.claude/memory/`.

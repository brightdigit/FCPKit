# Final Cut Pro Manual Artifact Checklist

Typed multicam generation has passed the Final Cut Pro import/re-export gate.
See [typed-generation-gate.md](typed-generation-gate.md) for the accepted
result and delta taxonomy. Remaining items below are human-only evidence work.

## Safe Test Media

Use newly created, non-private media containing only generic test imagery and
audio. Do not use client footage, faces, voices, location data, production file
names, credentials, private volume names, or home-directory paths.

Place the inputs at these generic paths, or record the substituted paths:

- `/Users/Shared/FCPKitMedia/Left.mov`: 1920×1080, 24 fps, Rec. 709, 10 seconds
  (`240/24s`), stereo PCM audio, 48 kHz.
- `/Users/Shared/FCPKitMedia/Right.mov`: 1280×720, 24 fps, Rec. 709, 9 seconds
  (`216/24s`), mono PCM audio, 48 kHz.

Color bars, numbered frames, geometric shapes, and synthesized tones are
appropriate. Before returning artifacts, inspect the XML for file URLs,
library locations, user metadata, notes, keywords, bookmarks, and opaque data.
Do not edit the returned export to remove private data; instead regenerate it
from safe media and a generic macOS account or shared path.

## Typed-Generation Import Gate (Complete)

Completed July 28, 2026. Typed multicam FCPXML `1.13` imported successfully and
re-exported as `1.13`. Core structure (Both/Left/Right/Multicam, transforms,
crop, angle IDs) survived. Accepted rewrite deltas are listed in
[typed-generation-gate.md](typed-generation-gate.md).

Generated documents no longer emit `smart-collection` elements. Local media and
`.fcpxmld` re-exports stay off-repo.

## Transition Feature Pair (Collected)

Collected July 28, 2026 under
[`Tests/FCPKitTests/FeaturePairs/transitions/`](../../Tests/FCPKitTests/FeaturePairs/transitions/).

- FCPXML `1.14` from Final Cut Pro Creator Studio 12.3 (build 450152)
- `before.fcpxml`: adjacent Left/Right hard cut
- `after.fcpxml`: default Cross Dissolve at that edit point
- `metadata.json`, `diff.md`, and `diff.json` included

Remaining feature pairs still needed: markers, roles, titles/`text-style`,
retiming.

## Ready for Human: Original FCPXML 1.14 Export

- Create a new generic library and project in the current Final Cut Pro using
  only the safe test media described above.
- Export directly as FCPXML `1.14`; do not convert an older document or edit the
  version attribute.
- If Final Cut returns an `.fcpxmld` bundle, preserve the whole bundle and use
  its root `Info.fcpxml` for analysis.
- Record Final Cut Pro version and build, macOS version and build, hardware,
  export date, selected FCPXML version, metadata view, and every warning.
- Preserve the original export untouched. Record provenance in an adjacent
  metadata file and complete a privacy review before adding it to `TestData`.
- Run schema completeness against the original artifact and return its
  Markdown and JSON reports without changing the accepted baseline.

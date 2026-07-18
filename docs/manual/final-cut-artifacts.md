# Final Cut Pro Manual Artifact Checklist

The automated typed-generation checks prove public construction, mutation,
round-tripping, and normalized parity with the current raw multicam builder.
They do not prove that Final Cut Pro accepts or preserves the generated file.
Complete this checklist on a Mac with Final Cut Pro before closing that gate.

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

## Typed-Generation Import Gate

Produce the exact typed document exercised by
`TypedGenerationTests.testTypedMulticamMatchesRawBuilderAfterNormalization`:

- FCPXML version: `1.13`.
- Event: `Typed Parity`.
- Media names: `Left`, `Right`, `Both`, and `Multicam Clip`.
- Resource IDs and references: `r1` through `r8` as constructed in the test.
- Left transform position: `-33.9193 0`.
- Right trim-left value: `21.2963`.
- Right transform position: `67.5926 0`.
- Library location: `file:///Users/Shared/Generated.fcpbundle/`.
- Preserve the generated angle IDs and all generated `uid`, `sig`, and
  `modDate` values in the submitted typed input.

Save the generated input as `typed-multicam-input.fcpxml` without hand-editing
it. Alongside it, create `typed-multicam-metadata.json` containing:

```json
{
  "artifact": "typed-multicam-input.fcpxml",
  "generatorCommit": "<full git commit>",
  "generatedAt": "<ISO-8601 timestamp with time zone>",
  "fcpxmlVersion": "1.13",
  "finalCutVersion": "<version and build>",
  "macOSVersion": "<version and build>",
  "hardware": "<Mac model and architecture>",
  "leftMedia": {
    "path": "/Users/Shared/FCPKitMedia/Left.mov",
    "dimensions": "1920x1080",
    "frameRate": 24,
    "duration": "240/24s",
    "audioChannels": 2,
    "audioSampleRate": 48000
  },
  "rightMedia": {
    "path": "/Users/Shared/FCPKitMedia/Right.mov",
    "dimensions": "1280x720",
    "frameRate": 24,
    "duration": "216/24s",
    "audioChannels": 1,
    "audioSampleRate": 48000
  }
}
```

### Import and Re-export

- In Final Cut Pro, choose **File → Import → XML** and select
  `typed-multicam-input.fcpxml`.
- Record whether the import succeeds. Capture every warning verbatim and take a
  screenshot of the result. If it fails, preserve the input and record the
  exact error; do not repair the XML by hand.
- Select the imported library or project, then choose **File → Export XML**.
  Apple's current workflow is documented in
  [Use XML to transfer projects in Final Cut Pro](https://support.apple.com/en-gb/guide/final-cut-pro/verdbd66ae/mac).
- Select FCPXML `1.13` when the export dialog offers it. If it is unavailable,
  record every offered version and the version selected.
- Record the export dialog's metadata view, destination, and all warnings.
- Preserve the untouched `.fcpxmld` re-export bundle. Do not rename or modify
  files inside it.
- For structural comparison, use the bundle's root `Info.fcpxml` payload while
  retaining the complete bundle. See Apple's
  [FCPXML Bundle Reference](https://developer.apple.com/documentation/professional-video-applications/fcpxml-bundle-reference).
- Compare the original typed input with the untouched root payload:

```sh
swift run fcpxml-diff compare \
  typed-multicam-input.fcpxml \
  typed-multicam-reexport.fcpxmld/Info.fcpxml \
  --markdown typed-multicam-diff.md \
  --json typed-multicam-diff.json
```

Return all of the following together:

- `typed-multicam-input.fcpxml`.
- The untouched `typed-multicam-reexport.fcpxmld` bundle.
- `typed-multicam-metadata.json`, completed with Final Cut Pro, macOS, build,
  hardware, media, and generation metadata.
- The import result, screenshots, metadata view, and exact warning or error
  text.
- `typed-multicam-diff.md` and `typed-multicam-diff.json`.

## Later Artifact: Transition Feature Pair

- Start from a new generic project using safe test media.
- Export `before.fcpxml` with no transition at the recorded edit point.
- Change exactly one Final Cut setting: add the chosen transition without
  changing its defaults or any other timeline state.
- Export `after.fcpxml` using the same FCPXML version.
- Preserve both exports untouched under
  `Tests/FCPKitTests/FeaturePairs/transitions/` only after privacy review.
- Add `metadata.json` with `finalCutVersion`, `finalCutBuild`, `macOSVersion`,
  `fcpxmlVersion`, `baselineState`, `changedAction`, export warnings, and media
  provenance.
- Run `fcpxml-diff compare` and return both Markdown and JSON output.

## Later Artifact: Original FCPXML 1.14 Export

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

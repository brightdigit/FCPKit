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

## Additional Feature Pairs (Collected)

Collected July 28, 2026 from a shared single-clip `before` baseline
(`Left` only). Each pair lives under
`Tests/FCPKitTests/FeaturePairs/<feature>/`.

| Feature | After signal |
| --- | --- |
| `markers` | `<marker start="5s" … value="Cue"/>` |
| `roles` | `<audio-channel-source … role="music.music-1"/>` (clip `audioRole` stays `dialogue`) |
| `titles` | connected Basic Title with `text` / `text-style-def` |
| `retiming` | `<timeMap>` 20s timeline ↔ 10s media (50% slow) |

## Feature Pair Specs (Reference)

Shared rules for every pair:

- Use a **project** timeline (not a compound clip).
- Prefer `Left.mov` alone unless the feature needs two clips.
- Change **one** Final Cut action between exports. Do not rename the project,
  move the playhead-only state, or tweak unrelated inspectors.
- Export FCPXML `1.14` when offered. Keep both exports untouched.
- Store under `Tests/FCPKitTests/FeaturePairs/<feature-name>/` with
  `before.fcpxml`, `after.fcpxml`, and `metadata.json` (`baselineState` and
  `changedAction` must match the rows below).

### Markers

| | |
| --- | --- |
| **before** | One `Left` clip on the project spine. No markers, keywords, to-dos, or chapter markers. |
| **after** | Add **one standard Marker** (Marker → Add Marker) near the midpoint. Name it `Cue`. Do not add a chapter marker, to-do, keyword, or rating. |

Expected XML signal: a `marker` (or equivalent marker element) on the clip or timeline; no chapter/keyword extras.

### Roles and audio subroles

| | |
| --- | --- |
| **before** | One `Left` clip with the default **Dialogue** audio role (whatever FCP assigns on import). Do not create custom roles yet. |
| **after** | Change **only** that clip’s audio role to **Music** (Modify → Assign Audio Roles → Music, or the Roles inspector). Do not also change video roles, lane, timing, or effects. |

Expected XML signal: often an `audio-channel-source` with `role="music…"` while clip `audioRole` may still say `dialogue`.

### Titles and `text-style`

| | |
| --- | --- |
| **before** | Empty project spine **or** a short gap only — no title. Prefer: project with no title clip. |
| **after** | Add one **Basic Title** (Titles → Basic Title) above/on the timeline with the default text. Do not customize font, size, color, or animation yet. |

If a second titles pair is collected later, isolate style: before = default Basic Title; after = change **one** inspector style (e.g. font size only).

Expected XML signal: `title`, `text`, `text-style` / `text-style-def`.

### Retiming and speed ramps

| | |
| --- | --- |
| **before** | One `Left` clip at **100%** / normal speed. No speed ramp, freeze, or reverse. |
| **after** | Set a **constant** retiming of **50%** slow motion (Retime → Slow → 50%, or enter 50% in the rate field). Do not add a speed ramp, optical-flow vs frame-blending toggle beyond the default FCP chooses, or blade the clip. |

Expected XML signal: retiming / `timeMap` / rate attributes on the clip (exact element names follow the export).

A later pair can isolate a **speed ramp** (before = 50% constant; after = ramp 50%→100%).

## Ready for Human

These steps still require Final Cut Pro. AppleScript cannot automate them.

**Simple click-by-click recipes** (read this first):
[easy-export-recipes.md](easy-export-recipes.md)

1. Optional follow-up isolation pairs from that guide:
   - Recipe A — title style only (font size → 72)
   - Recipe B — speed ramp (50% → 100%)
2. Import/re-export gate whenever typed generation surface expands again.
3. Re-export fixtures after Final Cut upgrades that change FCPXML behavior.
4. Privacy review when new exports leave Shared/generic media paths.


## FCPXML 1.14 TestData Fixture

Promoted from `FeaturePairs/markers/before.fcpxml` as
`Tests/FCPKitTests/TestData/FCPKit-Sample-1.14.fcpxml` with adjacent
`FCPKit-Sample-1.14.metadata.json`. This is schema-completeness evidence for
declared 1.14, not complete 1.14 coverage.



# Typed-Generation Final Cut Gate (Accepted)

Status: **Accepted** (July 28, 2026)

Typed multicam FCPXML generated through the public Codable model imported into
Final Cut Pro and re-exported as FCPXML `1.13`. The multicam graph survived.

Local media and re-export bundles were kept off-repo (paths, bookmarks, and
library locations are environment-specific). Do not commit
`/Users/Shared/FCPKitMedia` binaries or Desktop `.fcpxmld` bundles.

## Preserved Structure

- Event name `Typed Parity`
- Media: `Both`, `Left`, `Right`, `Multicam Clip`
- Left transform `-33.9193 0`
- Right transform `67.5926 0` and trim-left `21.2963`
- Three multicam angles with stable `angleID` values across import/re-export

## Accepted Re-export Deltas

These differences are Final Cut rewrite behavior, not unexplained model loss:

| Kind | Observation |
| --- | --- |
| Duration canonicalization | Lexical forms such as `240/24s` / `216/24s` become `10s` / `9s` |
| Format names | Long names such as `FFVideoFormat1920x1080p24` shorten to `FFVideoFormat1080p24` (dimensions unchanged) |
| Asset enrichment | Final Cut adds `metadata` and `media-rep/bookmark` |
| Media paths | `media-rep/@src` rewrites into the library Original Media location |
| Library attributes | `location` becomes the active library; `colorProcessing` may be added |
| Smart collections | Library-level smart collections in the generated input are omitted on re-export |

Normalized `@id` / `@ref` churn in `fcpxml-diff compare` after re-export is
largely cascade from resource reorder and duration rewrite, not broken
relationships.

## Generation Policy Follow-up

Generated multicam documents no longer emit `smart-collection` elements.
`SmartCollection` remains in the Codable model so real fixture exports that
include them still decode.

## DSL Create-Path Import Gate (Accepted)

Status: **Accepted** (July 31, 2026) — closes
[#14](https://github.com/brightdigit/FCPKit/issues/14)

DSL-generated FCPXML from the `FCPKitDSL` create path imported into Final Cut
Pro and was visually verified. Documents were generated at `v0.1.x`
commit `ff9169f` with:

```sh
swift run fcpxml-dsl export            # → transitions.fcpxml, titles.fcpxml
```

Test media regenerates with `Scripts/generate-test-media.sh`
(`/Users/Shared/FCPKitMediaLeft.mov` / `…Right.mov`).

### Verified

- `transitions.fcpxml` imported without rejection; the cross dissolve sits
  **between** the two clips on the timeline, not after both.
- `titles.fcpxml` imported without rejection; the title renders on its
  anchored lane above the clip.
- Both documents validate against the FCPXML DTD (`asset` emits `media-rep`
  rather than the pre-1.6 `src` attribute).

### Repeatable check

`swift run fcpxml-dsl verify-import <file>` sends the document to a running
Final Cut Pro via `open -b com.apple.FinalCutApp` and takes an AppleScript
project census (`name of every project of every event of every library`) to
confirm the project appeared. Timeline layout (dissolve placement, lanes)
still needs eyes on the timeline.

Export outputs stay off-repo (`/transitions.fcpxml`, `/titles.fcpxml` are
gitignored); regenerate them with the commands above.

## Generator Dissolve Gate (Accepted)

Status: **Accepted** (August 2, 2026)

Media-free generator clips separated by cross dissolves imported into Final Cut
Pro and rendered correctly. This retires the open structural risk recorded in
[planning/demo-presentation-video.md](../planning/demo-presentation-video.md):

> Do cross dissolves between two generators behave like dissolves between asset
> clips? Transition packing assumes T/2 overlap on both neighbors. Generators
> have no media handles beyond their declared duration, so Final Cut may object
> to the overlap.

**They do behave the same.** Final Cut accepted the T/2 overlap with no
objection — no red media, no missing-handle warning. The mitigation the spec
held in reserve (extending each generator by T/2 per side) is **not needed**.

### Generated with

```sh
swift run fcpxml-dsl export rgb rgb.fcpxml    # defaults to version 1.14
```

Red / green / blue `Color Solid` generators, 5s each, 1s cross dissolves.
No media files, no `Scripts/generate-test-media.sh` run.

### Verified

- Imported without rejection into Final Cut Pro Creator Studio.
- Both transitions render as dissolve bars **between** adjacent clips.
- Sequence reads `13:00` on the Final Cut timeline, matching the generated
  `<sequence duration="13s">` — Final Cut did not re-time the spine.
- Per-clip timing survives exactly as packed:

  | Clip | offset | duration | Trimmed |
  | --- | --- | --- | --- |
  | red | `0s` | `10800/2400s` (4.5s) | tail only |
  | dissolve | `4s` | `1s` | — |
  | green | `10800/2400s` | `4s` | both sides |
  | dissolve | `8s` | `1s` | — |
  | blue | `20400/2400s` | `10800/2400s` (4.5s) | head only |

  The middle clip is shortened by T/2 on both sides while the outer two are
  trimmed on one side each — `placeOverlapping` in `Layout+Packing.swift` agrees
  with Final Cut.
- Validates against Final Cut's own `FCPXMLv1_14.dtd` via `xmllint`.

### Not covered by this gate

Anchored titles over generator backgrounds. The RGB document contains no
titles, so lane-1 rendering over a `<video>`-backed generator remains
**unverified** — it needs
[#35](https://github.com/brightdigit/FCPKit/issues/35),
[#36](https://github.com/brightdigit/FCPKit/issues/36), and
[#37](https://github.com/brightdigit/FCPKit/issues/37) first, and is the
remaining unknown for
[#40](https://github.com/brightdigit/FCPKit/issues/40).

### Version caveat

This gate covers **1.14 only**. The same document exported at `--version 1.13`
is invalid: the DSL emits `<match-analysis-type>`, an element that does not
exist before 1.14. Tracked as
[#41](https://github.com/brightdigit/FCPKit/issues/41). Note the multicam
generation path already stopped emitting `smart-collection` (see "Generation
Policy Follow-up" above); the DSL create path did not inherit that change.

### Reproducing the DTD check

`xmllint --dtdvalid` fails with `xmlSAX2ResolveEntity` when the DTD is
referenced by its absolute path inside the Final Cut app bundle. Copy it to the
working directory and reference it by bare filename:

```sh
cp "/Applications/Final Cut Pro*.app/Contents/Frameworks/Interchange.framework/Resources/FCPXMLv1_14.dtd" .
xmllint --noout --dtdvalid FCPXMLv1_14.dtd rgb.fcpxml
```

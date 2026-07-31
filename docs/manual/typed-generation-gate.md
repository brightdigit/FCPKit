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

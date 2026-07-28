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

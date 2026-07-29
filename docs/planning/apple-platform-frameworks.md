# Apple Platform Frameworks Used by FCPKit

FCPKit’s **core** library depends on the cross-platform Foundation stack
(Foundation, and FoundationXML where the code imports it) plus third-party
XMLCoder. The **true Apple-platform** frameworks in this repo are **CoreMedia**
and **AVFoundation**, used only in `FCPKitMediaTools` (and tests/tools that
exercise it), gated with `#if canImport(...)` so non-Apple CI can still build
the package.

For non-Apple replacements of those MediaTools capabilities, see
[non-apple-media-alternatives.md](non-apple-media-alternatives.md).

## Inventory

### Cross-platform (available on all OSes)

Per user correction (2026-07-29): **Foundation and FoundationXML are available
on all OSes.** Do not classify them as Apple-only.

| Module | Where used (targets) | Required for FCPKit core? | Purpose |
| --- | --- | --- | --- |
| **Foundation** | All library/executable targets + tests | Yes | Data, URL, FileManager, Codable support types, Process (DTD validate), errors |
| **FoundationXML** | `FCPXMLDiff` (`XMLTree.swift`) | No (optional import for XMLParser) | Provides `XMLParser` / `XMLParserDelegate` when imported; see gate note below |

### Apple-platform frameworks (gated)

| Framework | Where used (targets) | Required for FCPKit core? | Purpose |
| --- | --- | --- | --- |
| **CoreMedia** | `FCPKitMediaTools`, gated MediaTools tests | No | `CMTime`, format-description helpers for media → FCPXML timing/codecs |
| **AVFoundation** | `FCPKitMediaTools` (`VideoMetadataExtractor`), `fcpxml-generator`, gated tests | No | Inspect real media files (`AVAsset` / tracks) |

### Testing / build (not product runtime frameworks)

| Module | Where used | Notes |
| --- | --- | --- |
| **XCTest** | `FCPKitTests` (all 10 test files) | Current unit-test harness (`XCTestCase`) |
| **Testing** (Swift Testing) | *Not imported anywhere yet* | Documented policy for *new* tests; migration of existing suite deferred |
| **PackageDescription** | `Package.swift` only | SPM manifest — build-time only |
| **XMLCoder** (third-party) | `FCPKit`, `FCPXMLDiff`, tests | Declared SPM dependency; Codable XML encode/decode |

`Package.swift` declares **no** `linkerSettings` / `linkedFramework(...)`.
Apple frameworks are brought in by `import` (auto-link on Darwin). The only
declared external dependency is XMLCoder.

Declared SPM platforms (`Package.swift` lines 8–12; README Requirements):
**macOS 13+, iOS 16+, tvOS 16+, watchOS 9+**. CI also builds Ubuntu (and
optionally wasm when enabled); Apple-only APIs are gated with
`canImport(CoreMedia)` / `canImport(AVFoundation)` and WASI-specific Process
limits with `#if !os(WASI)`.

---

## Cross-platform detail

### Foundation

**What we use it for**

- Ubiquitous `import Foundation` across `Sources/FCPKit`, `FCPKitMediaTools`,
  `FCPXMLDiff`, CLIs, and several tests.
- Core parse/encode I/O: `Data`, `URL`, `String` encoding in
  `Sources/FCPKit/FCPXMLParser.swift` (e.g. `Data(contentsOf:)`,
  `data.write(to:)`).
- Diff/report JSON: `JSONEncoder` in report renderers under `Sources/FCPXMLDiff/`.
- Filesystem: `FileManager` throughout CLIs and DTD validation.
- DTD validation subprocess: `Process`, `Pipe`, `FileHandle` in
  `Sources/FCPXMLDiff/DTDValidation.swift` (gated `#if !os(WASI)` because
  `Foundation.Process` is unavailable on WebAssembly — comment at lines 98–99,
  161–164). This is a **WASI/process-model** limit, not an “Foundation is
  Apple-only” claim.
- Event-driven XML for structural diffs: `XMLParser`, `XMLParserDelegate`,
  `NSObject` in `Sources/FCPXMLDiff/XMLTree.swift` (see FoundationXML for the
  companion import gate).
- Utilities: `DateFormatter`, `UUID`, `NSRegularExpression`, `LocalizedError`,
  `ObjCBool`, `CommandLine`, `exit`, etc.

**Why**

Foundation is the portable baseline for Swift packages: file/URL I/O, data,
and errors. Product intent is an FCPXML Codable layer that works without Apple
media frameworks (`AGENTS.md` architecture; README “typed Codable models”).

**Primary sources**

- [Foundation](https://developer.apple.com/documentation/foundation)
- [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser)
- [Process](https://developer.apple.com/documentation/foundation/process)
- [FileManager](https://developer.apple.com/documentation/foundation/filemanager)

### FoundationXML

**Availability:** Available on all OSes (user fact, 2026-07-29). Not an
Apple-only framework.

**What the code does**

```3:5:Sources/FCPXMLDiff/XMLTree.swift
// On Linux, XMLParser lives in FoundationXML rather than Foundation.
#if canImport(FoundationXML)
import FoundationXML
#endif
```

The file then uses `XMLParser`, `XMLParserDelegate`, and `NSObject` for the
structural tree used by schema-completeness / pair diffs. The repo does **not**
use `XMLDocument` / DOM APIs.

**How to read the `canImport` gate**

The gate is what the source currently does: import `FoundationXML` when the
module is importable. The in-file comment describes a historical module-layout
detail (XMLParser living in FoundationXML on some Swift Foundation builds).
**Do not infer from that gate that FoundationXML is Apple-only** — it is
cross-platform and available on all OSes. The Apple-only `canImport` examples
in this repo are CoreMedia and AVFoundation (see platform gating below).

**Primary sources**

- [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser)
  (API surface documented under Foundation)
- [swift-corelibs-foundation Swift 5 release notes — FoundationXML](https://github.com/apple/swift-corelibs-foundation/blob/main/Docs/ReleaseNotes_Swift5.md)
  (documents the Foundation / FoundationXML module split and
  `#if canImport(FoundationXML)` import style)

---

## Apple-platform detail

### CoreMedia

**What we use it for** (all under `#if canImport(CoreMedia)` unless noted)

| API / type | File | Role |
| --- | --- | --- |
| `CMTime` | `VideoMetadata.swift`, `FCPXMLUtilities.swift`, `MulticamXMLBuilder.swift` | Media duration; convert to FCPXML rational strings (`value`/`timescale`) |
| `CMFormatDescriptionGetMediaSubType` | `VideoMetadataExtractor.swift` | Codec FourCC → string |
| `CMAudioFormatDescriptionGetStreamBasicDescription` | `VideoMetadataExtractor.swift` | Channel count + sample rate from ASBD |
| `FourCharCode` | `VideoMetadataExtractor.swift` | Codec subtype encoding |

`MulticamXMLBuilder` and `VideoMetadata` are entirely inside the CoreMedia gate
because they take/store `VideoMetadata` / `CMTime`
(`MulticamXMLBuilder.swift` lines 4–9; `VideoMetadata.swift` lines 3–9).

**Why**

FCPXML durations are rational time strings (e.g. `7700200/2400s`). CoreMedia’s
`CMTime` is the natural Apple representation of media timeline time
(value + timescale). MediaTools bridges inspected media into those strings via
`FCPXMLUtilities.cmTimeToFCPXMLDuration`. **FCPKit core never imports CoreMedia**;
the Codable model stores timing as `String` attributes.

**Apple primary sources**

- [CMTime](https://developer.apple.com/documentation/coremedia/cmtime)
- [CMFormatDescriptionGetMediaSubType](https://developer.apple.com/documentation/coremedia/cmformatdescriptiongetmediasubtype(_:))
- [CMAudioFormatDescriptionGetStreamBasicDescription](https://developer.apple.com/documentation/coremedia/cmaudioformatdescriptiongetstreambasicdescription(_:))

### AVFoundation

**What we use it for** (under `#if canImport(AVFoundation)`)

In `Sources/FCPKitMediaTools/VideoMetadataExtractor.swift`:

- `AVAsset(url:)` — open a media file (Apple documents
  `convenience init(url:)` on `AVAsset` as **Deprecated**, still present in
  current docs)
- `asset.load(.duration)` — async duration as `CMTime`
- `asset.loadTracks(withMediaType: .video / .audio)`
- Track async loads: `.naturalSize`, `.nominalFrameRate`, `.formatDescriptions`

`VideoMetadata.swift` also `import AVFoundation` inside the CoreMedia gate, but
the struct’s stored properties are Foundation/CoreMedia/`CGSize` only — no
AVFoundation type appears in that file’s API surface.

`Sources/fcpxml-generator/FCPXMLGeneratorTool.swift` uses
`#if !canImport(AVFoundation)` to ship a stub `@main` that exits 1, so the
executable **target still builds** on platforms without AVFoundation
(comment: “cross-platform CI stays honest”).

Tests `TypedGenerationTests` / `MulticamXMLBuilderTests` import AVFoundation
only inside `#if canImport(CoreMedia)` (same Apple-platform gate as MediaTools).

**Why**

Typed multicam generation from **real files** needs duration, dimensions, frame
rate, and track presence. AVFoundation is Apple’s API for modeling file-based
timed media (`AVAsset` overview). This is intentionally **not** required for
decode/edit/encode of FCPXML text in `FCPKit`.

**Apple primary sources**

- [AVAsset](https://developer.apple.com/documentation/avfoundation/avasset)
- [Loading media data asynchronously](https://developer.apple.com/documentation/avfoundation/loading-media-data-asynchronously)
- [AVAsset.duration](https://developer.apple.com/documentation/avfoundation/avasset/duration)

### Types used without a direct framework import (Apple media path)

**`CGSize`** appears on `VideoMetadata.dimensions` and in
`FCPXMLUtilities.generateFormatName` without `import CoreGraphics`. Apple
documents [`CGSize`](https://developer.apple.com/documentation/coregraphics/cgsize)
under **CoreGraphics**. In this codebase it is reached transitively through
Foundation / CoreMedia / AVFoundation imports on Apple platforms. The package
does not treat CoreGraphics as a first-class dependency (no import, no gated
API surface of its own).

---

## Testing / build modules

### XCTest

All ten files under `Tests/FCPKitTests/` use `import XCTest` and
`XCTestCase` subclasses (verified by repo grep; matches `AGENTS.md`).

Historical harness. Policy now: **new** tests use Swift Testing; migrating
these ten files is deferred (`.claude/agent-notes.md`; `AGENTS.md`; ADR 0002).

- [XCTestCase](https://developer.apple.com/documentation/xctest/xctestcase)
- [XCTest](https://developer.apple.com/documentation/xctest)

### Testing (Swift Testing) — planned, not used yet

Zero matches for `import Testing`, `@Suite`, or `@Test` under `Sources/` /
`Tests/`. See [Swift Testing](https://developer.apple.com/documentation/testing).

### PackageDescription / platforms (manifest only)

```8:12:Package.swift
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
```

Constrains Apple deployment targets for clients; does not link media
frameworks. Targets list only SPM products (`FCPKit`, `XMLCoder`, etc.).

---

## Platform gating strategy

Standing directive (`.claude/agent-notes.md`, 2026-07-29), as corrected:

> Gate Apple-only frameworks with `#if canImport(...)` (e.g. `CoreMedia`,
> `AVFoundation`) rather than excluding targets or platforms from CI.

Also recorded: **Foundation and FoundationXML are available on all OSes.**

| Gate | What it is for | Effect when false / unavailable |
| --- | --- | --- |
| `canImport(CoreMedia)` | **Apple-only** | Entire `VideoMetadata`, `MulticamXMLBuilder`, and CMTime helpers omitted; Apple-only media tests compile away; UID/timestamp/format-name utilities in `FCPXMLUtilities` remain. |
| `canImport(AVFoundation)` | **Apple-only** | `VideoMetadataExtractor` omitted; `fcpxml-generator` becomes stub that prints error and `exit(1)`. |
| `canImport(FoundationXML)` | Cross-platform module import style (not Apple-only) | When the module is importable, `XMLTree.swift` imports it for `XMLParser`. Presence of this gate does **not** mean FoundationXML is Apple-only. |
| `!os(WASI)` / `os(WASI)` | WASI process / filesystem limits | DTD validate via `Process` disabled on WASI (throws `xmllintUnavailable`); CLI atomic file writes fall back to non-atomic `Data.write`. |

**What still builds without CoreMedia/AVFoundation**

- `FCPKit` (model + parser) — no media imports; Foundation only (+ XMLCoder).
- `FCPXMLDiff` + `fcpxml-diff` — Foundation / FoundationXML; schema completeness
  and compare. Validate needs `xmllint` (+ usually a Final Cut DTD path on
  macOS), not CoreMedia.
- `FCPKitMediaTools` as a target — compiles with a reduced API (error enum +
  non-CMTime utilities only).
- Ubuntu CI in `.github/workflows/FCPKit.yml` exercises this path; wasm legs
  are currently disabled via `ENABLE_WASM=false` for toolchain/XMLCoder
  reasons, with comments noting FCPKit’s own WASI gates for Process/atomic
  writes.

**Core vs MediaTools**

| Concern | Module | Apple-platform frameworks? |
| --- | --- | --- |
| Decode / mutate / encode FCPXML | `FCPKit` | No — Foundation (+ XMLCoder) |
| Structural round-trip / feature diffs | `FCPXMLDiff` | No — Foundation / FoundationXML |
| Inspect media files → typed multicam XML | `FCPKitMediaTools` | Yes — CoreMedia + AVFoundation, `#if canImport` |

## Gaps / not used

Notable Apple media / graphics frameworks with **no** `import` in this repo:

- **CoreVideo**, **VideoToolbox**, **CoreAudio**, **AudioToolbox**, **MediaToolbox**
- **CoreImage**, **Metal**, **AVKit**
- **AppKit** / **UIKit** / **SwiftUI** (ADR/planning mention “SwiftUI-*shaped*” DSL
  only — not an import)
- **CoreGraphics** as an explicit module (only transitive `CGSize` on the
  Apple media path)
- **FoundationNetworking** (no separate import; no URLSession-centric networking
  layer in Sources)
- **XMLDocument** (DOM) — unused; diffs use event-driven `XMLParser` only

Boundary: FCPKit is an **FCPXML / interchange** library. Apple media frameworks
exist only to feed generation helpers, not to play, edit pixels, or drive
Final Cut itself.

## Sources

### Repo (primary)

- `Package.swift` — platforms, products, dependencies, absence of linker settings
- `Sources/FCPKit/*.swift` — Foundation + XMLCoder only
- `Sources/FCPKitMediaTools/{VideoMetadata,VideoMetadataExtractor,FCPXMLUtilities,MulticamXMLBuilder}.swift` — CoreMedia / AVFoundation gates and APIs
- `Sources/FCPXMLDiff/XMLTree.swift` — FoundationXML `canImport` + XMLParser
- `Sources/FCPXMLDiff/DTDValidation.swift` — Process / WASI gate
- `Sources/FCPXMLDiffCLI/main.swift` — `os(WASI)` atomic write helper
- `Sources/fcpxml-generator/FCPXMLGeneratorTool.swift` — AVFoundation stub entry
- `Tests/FCPKitTests/*.swift` — XCTest; CoreMedia/AVFoundation gated tests
- `AGENTS.md`, `.claude/agent-notes.md`, `README.md`, `docs/adr/0002-create-first-ordered-typed-model.md`
- `.github/workflows/FCPKit.yml` — Ubuntu / wasm / Apple platform CI intent

### Apple / first-party docs

- https://developer.apple.com/documentation/foundation
- https://developer.apple.com/documentation/foundation/xmlparser
- https://developer.apple.com/documentation/foundation/process
- https://developer.apple.com/documentation/foundation/filemanager
- https://developer.apple.com/documentation/coremedia/cmtime
- https://developer.apple.com/documentation/coremedia/cmformatdescriptiongetmediasubtype(_:)
- https://developer.apple.com/documentation/coremedia/cmaudioformatdescriptiongetstreambasicdescription(_:)
- https://developer.apple.com/documentation/avfoundation/avasset
- https://developer.apple.com/documentation/avfoundation/loading-media-data-asynchronously
- https://developer.apple.com/documentation/avfoundation/avasset/duration
- https://developer.apple.com/documentation/coregraphics/cgsize
- https://developer.apple.com/documentation/xctest
- https://developer.apple.com/documentation/xctest/xctestcase
- https://developer.apple.com/documentation/testing
- https://github.com/apple/swift-corelibs-foundation/blob/main/Docs/ReleaseNotes_Swift5.md (FoundationXML module split)

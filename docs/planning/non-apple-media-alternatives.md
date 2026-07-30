# Non-Apple Media Alternatives for FCPKitMediaTools

> **Supersedes / updates (2026-07-29):** Host-tool probing (`ffprobe` /
> `mediainfo` via `Process`) is **rejected as the preferred MediaTools path**
> per `.claude/agent-notes.md` (“Do not rely on external host tools like
> ffprobe for MediaTools; prefer something that can be built into the
> library”). For the updated recommendation — rational time now; in-process
> FFmpeg (systemLibrary short-term, vendored/static with work) — see
> [`ffmpeg-in-library-viability.md`](ffmpeg-in-library-viability.md). This
> document remains a candidate inventory; treat § “Suggested direction” item 2
> (ffprobe CLI) as historical, not preferred.

FCPKit core does not need media frameworks. The Apple-only gap lives in
`FCPKitMediaTools`: rational timeline time (`CMTime`) and file probing
(`AVAsset`). Candidate inventory below still covers rational-time types,
CLI probes (contrast only), native library bindings, and pure-Swift parsers.
Linux/`linux/amd64` verification is still required before claiming support
(`.claude/agent-notes.md`).

## Capability gap (what Apple APIs provide today)

| Current API (MediaTools) | Required capability | Used by |
| --- | --- | --- |
| `CMTime` (`value` + `timescale`) | Exact rational media duration; compare max duration; emit FCPXML `"N/Ds"` | `VideoMetadata.duration`; `FCPXMLUtilities.cmTimeToFCPXMLDuration`; `MulticamXMLBuilder` |
| `AVAsset` + `load(.duration)` | Open file → duration as rational time | `VideoMetadataExtractor` |
| `loadTracks(withMediaType: .video/.audio)` | Detect video/audio track presence | `hasVideo` / `hasAudio` → multicam asset attrs |
| Track `naturalSize` | Pixel width × height | `dimensions` → format name / width / height |
| Track `nominalFrameRate` | Frame rate (Float today) | `frameRate` → format name / `frameDuration` |
| `CMFormatDescriptionGetMediaSubType` | Video/audio codec FourCC string | `videoCodec` / `audioCodec` (stored; not yet consumed by `MulticamXMLBuilder`) |
| `CMAudioFormatDescriptionGetStreamBasicDescription` | Channel count + sample rate | `audioChannels` / `audioSampleRate` → asset attrs (defaults 1 / 48000) |
| `CGSize` (transitive) | Width/height holder | `VideoMetadata.dimensions`; `generateFormatName` |

Sources:
`Sources/FCPKitMediaTools/{VideoMetadata,VideoMetadataExtractor,FCPXMLUtilities,MulticamXMLBuilder}.swift`;
prior inventory `docs/planning/apple-platform-frameworks.md`.

**Not required for core FCPKit:** playback, pixel decode, Final Cut host APIs,
or Apple-only “bookmark”/effect opaque payloads (those already live in FCPXML
text and the diff harness).

## Strategy options (overview)

1. **Pure Swift rational time + keep probing Apple-only**  
   Replace `CMTime` in the public MediaTools surface with a local
   `value`/`timescale` type (or adopt `SwiftTimecodeCore.Fraction`). Keep
   `VideoMetadataExtractor` behind `canImport(AVFoundation)`.  
   **Fit:** Unlocks Linux *compilation* of typed generation APIs when metadata
   is supplied by callers; does **not** enable file inspection on Linux.

2. **External probe CLI (`ffprobe` / `mediainfo`) via `Foundation.Process`**  
   Same pattern as `DTDValidation` → `/usr/bin/xmllint`
   (`Sources/FCPXMLDiff/DTDValidation.swift`). Parse JSON into MediaTools
   fields; convert `duration_ts` + `time_base` to rational time.  
   **Fit:** Best operational match for FCPKit today — optional host tool, no
   SPM native link, works wherever FFmpeg/MediaInfo CLI is installed. Same
   WASI/`Process` limits as xmllint.

3. **Native library bindings (FFmpeg / MediaInfoLib)**  
   SPM `systemLibrary` + pkg-config (e.g. SwiftFFmpeg) or C++ MediaInfoLib.  
   **Fit:** In-process probing without shelling out; heavier deploy (must ship
   or require system FFmpeg), license/version coupling, CI image complexity.

4. **Pure Swift container parsers**  
   ISOBMFF/MP4/MOV (and optionally MKV) parsers with no C deps.  
   **Fit:** Attractive for dependency purity; format coverage and duration
   exactness vary; editorial codecs/containers beyond the parser’s set need a
   fallback.

## Candidates

### Local trivial rational time (no package)

- **URL / license:** In-repo; MIT (package license).
- **Platforms / SPM:** Any platform with Foundation; no new dependency.
- **Maps to:** `CMTime` replacement for duration storage and
  `"\(value)/\(timescale)s"` encoding (today’s
  `FCPXMLUtilities.cmTimeToFCPXMLDuration`).
- **Gaps / risks:** Does not probe files. Must define comparison, invalid/zero
  sentinels (today uses `CMTime.flags.contains(.valid)`), and optionally
  bridge to `CMTime` on Apple for AVFoundation interop.
- **Primary sources:**
  `Sources/FCPKitMediaTools/FCPXMLUtilities.swift` (lines 40–48);
  Apple [CMTime](https://developer.apple.com/documentation/coremedia/cmtime).

### SwiftTimecode (`SwiftTimecodeCore.Fraction`)

- **URL:** https://github.com/orchetect/swift-timecode  
- **License:** MIT (GitHub API `license.spdx_id`; README badge).  
- **Last activity:** `pushed_at` 2026-07-10 (GitHub API, retrieved 2026-07-29).
- **Platforms / SPM:** `Package.swift` products `SwiftTimecode` /
  `SwiftTimecodeCore`; declared Apple platforms macOS 10.13+ / iOS 12+ / …
  AV/UI targets are `#if canImport(Darwin)` only. README: on Linux, `import
  SwiftTimecode` imports Core. **Linux CI:** `.github/workflows/build.yml` job
  `linux` runs `swift build` / `swift test` on `ubuntu-latest`. Topics include
  `linux`.
- **Maps to:** Rational time; **first-party FCPXML string**
  `Fraction.init?(fcpxmlString:)` / `fcpxmlStringValue`
  (`Sources/SwiftTimecodeCore/Fraction/Fraction.swift`). Optional SMPTE
  timecode beyond MediaTools’ current needs.
- **Gaps / risks:** `Fraction`↔`CMTime` helpers are `#if canImport(CoreMedia)`
  (`Fraction CMTime.swift`) — expected and fine. Does **not** inspect media
  files (AV helpers are Apple-only `SwiftTimecodeAV`). Pulling the whole
  timecode suite may be heavier than a 20-line local type if only duration
  strings are needed.
- **Primary sources:**
  https://github.com/orchetect/swift-timecode/blob/main/Package.swift;
  https://github.com/orchetect/swift-timecode/blob/main/README.md;
  https://github.com/orchetect/swift-timecode/blob/main/Sources/SwiftTimecodeCore/Fraction/Fraction.swift;
  https://github.com/orchetect/swift-timecode/blob/main/.github/workflows/build.yml;
  DocC `Rational-Numbers-and-CMTime.md`.

### OpenTimelineIO Swift bindings (`opentime` RationalTime)

- **URL:** https://github.com/OpenTimelineIO/OpenTimelineIO-Swift-Bindings  
- **License:** Apache-2.0.  
- **Last activity:** `pushed_at` 2026-03-10 (GitHub API).
- **Platforms / SPM:** Declares macOS 10.13 / iOS 12 / visionOS 1; embeds C++
  OTIO sources (`cxxLanguageStandard: .cxx17`). RationalTime is OTIO’s
  timeline time model — but OTIO uses **double** rate/value semantics;
  OpenTimelineIO-AVFoundation docs note conversion nuances vs `CMTime`
  Int64/Int32 (especially non-integer frame rates).
- **Maps to:** Partial rational-time story only; **not** a media file probe.
- **Gaps / risks:** Heavy C++ dependency for a thin need; Apple-focused
  companion packages lean on AVFoundation; not a probing substitute.
- **Primary sources:**
  https://github.com/OpenTimelineIO/OpenTimelineIO-Swift-Bindings/blob/main/Package.swift;
  https://github.com/CineBuild/OpenTimelineIO-AVFoundation (RationalTime↔CMTime
  notes).

### ffprobe CLI (Process fallback)

- **URL:** https://ffmpeg.org/ffprobe.html (tool); schema
  https://github.com/FFmpeg/FFmpeg/blob/master/doc/ffprobe.xsd  
- **License:** FFmpeg project licenses (LGPL/GPL depending on build); CLI is a
  **host dependency**, not an SPM link.
- **Last activity:** Upstream FFmpeg actively maintained (primary project).
- **Platforms / SPM:** Any OS with `ffprobe` on `PATH` and
  `Foundation.Process` (same WASI exclusion as xmllint). No SPM package
  required.
- **Maps to:** Duration, dimensions, fps, codec, audio channels/rate,
  track presence — via `-print_format json -show_format -show_streams`.
  Relevant **stream** attributes in `ffprobe.xsd`: `codec_type`,
  `codec_name`, `codec_tag_string`, `width`, `height`, `sample_rate`,
  `channels`, `r_frame_rate`, `avg_frame_rate`, `duration`, `duration_ts`,
  `time_base`. Prefer **`duration_ts` + `time_base`** for rational FCPXML
  strings; float `duration` alone is approximate. Prefer
  **`codec_tag_string`** (FourCC-like) to mirror today’s subtype strings;
  `codec_name` is a different vocabulary (e.g. `h264` vs `avc1`).
- **Gaps / risks:** External binary version drift; PATH discovery;
  ProRes/QuickTime edge cases may differ from AVFoundation; float-only
  duration if callers ignore `duration_ts`. Must not claim Linux support until
  verified in Docker `--platform linux/amd64`.
- **Primary sources:**
  https://ffmpeg.org/ffprobe.html (`-output_format` / `-print_format`,
  `-show_format`, `-show_streams`, json writer §4.5);
  https://raw.githubusercontent.com/FFmpeg/FFmpeg/master/doc/ffprobe.xsd;
  repo Process precedent: `Sources/FCPXMLDiff/DTDValidation.swift`.

### mediainfo CLI (Process fallback)

- **URL:** https://mediaarea.net/en/MediaInfo; CLI history
  https://github.com/MediaArea/MediaInfo/blob/master/History_CLI.txt  
- **License:** BSD-style (MediaArea site “License” section).  
- **Platforms:** Windows, macOS, many Linux distros (download matrix on
  mediaarea.net).
- **Maps to:** Container duration, video codec/frame rate/dimensions, audio
  codec/channels/sampling rate (supported-formats matrix and product
  feature list). CLI JSON via `--Output=JSON` (documented in project issues /
  History_CLI “+ JSON output”; structure object-vs-array quirk for 1 vs N
  files noted in MediaArea/MediaInfo#1103).
- **Gaps / risks:** No maintained modern Swift SPM binding found for
  MediaInfoLib (legacy `mackworth/MediaInfoKit` is macOS/Xcode-era, not SPM).
  Field names are MediaInfo’s Inform vocabulary, not FFmpeg’s; mapping must be
  tested. Duration often presented as string/milliseconds — rational
  reconstruction needs care.
- **Primary sources:**
  https://mediaarea.net/en/MediaInfo;
  https://mediaarea.net/en/MediaInfo/Support/Formats;
  https://mediaarea.net/en/MediaInfo/Support/SDK/Quick_Start;
  https://github.com/MediaArea/MediaInfo/issues/1103.

### SwiftFFmpeg (sunlubo) — FFmpeg API wrapper

- **URL:** https://github.com/sunlubo/SwiftFFmpeg  
- **License:** Apache-2.0 (repo LICENSE / GitHub API).  
- **Last activity:** `pushed_at` 2025-11-30; stars ~650 (GitHub API 2026-07-29).
- **Platforms / SPM:** `Package.swift` (swift-tools-version 5.10) declares
  **no** `platforms:` array; `systemLibrary` `CFFmpeg` with
  `pkgConfig: "libavformat"`. README requires **FFmpeg 7.1+** (Homebrew
  example). Module map links `avutil`/`avformat`/`avcodec`/… — usable on
  Linux **if** matching FFmpeg + pkg-config are present (not proven in this
  research run).
- **Maps to:** In-process open → `AVFormatContext` / streams / codec
  parameters (README usage sample: `AVFormatContext(url:)`,
  `findStreamInfo()`, `videoStream`, codec params). Can cover duration,
  dimensions, fps, codec IDs, audio channels/rate **in principle** via
  libavformat — same capability class as ffprobe’s library side.
- **Gaps / risks:** System FFmpeg version coupling; API “still in
  development” (README); binary size / LGPL of underlying FFmpeg; no
  first-party Windows story in README; must verify Linux CI image build
  before claiming support.
- **Primary sources:**
  https://github.com/sunlubo/SwiftFFmpeg/blob/master/Package.swift;
  https://github.com/sunlubo/SwiftFFmpeg/blob/master/README.md;
  https://github.com/sunlubo/SwiftFFmpeg/blob/master/Sources/CFFmpeg/module.modulemap;
  https://github.com/sunlubo/SwiftFFmpeg/blob/master/LICENSE.

### SwiftFFmpeg / SwiftFFMpeg (intrusive-memory) — fork

- **URL:** https://github.com/intrusive-memory/SwiftFFMpeg (API name;
  README still says `SwiftFFmpeg.git`).  
- **License:** LGPL-2.1 (GitHub API).  
- **Last activity:** `pushed_at` 2026-02-16.  
- **Platforms / SPM:** `Package.swift` sets `platforms: [.macOS("26")]` —
  **macOS-only** in the manifest; `pkgConfig: "libavformat"` + brew provider;
  XCFramework fetch plugin. README banner: **EXPERIMENTAL - NOT READY FOR
  PRODUCTION**.
- **Maps to:** Same FFmpeg capability class as sunlubo, but not a credible
  cross-platform dependency today.
- **Gaps / risks:** Explicit experimental status; macOS 26 platform floor;
  LGPL; naming/URL inconsistency.
- **Primary sources:**
  https://github.com/intrusive-memory/SwiftFFMpeg/blob/main/README.md;
  Package.swift via
  https://raw.githubusercontent.com/intrusive-memory/SwiftFFmpeg/main/Package.swift
  (content retrieved 2026-07-29).

### SwiftExif (pure Swift probe / metadata)

- **URL:** https://codeberg.org/taagedal/SwiftExif  
- **License:** GPL-3.0 (README “License” section).  
- **Last activity:** Codeberg `updated_at` 2026-07-01; README claims active
  MP4/MOV/MXF/MKV stream probing.
- **Platforms / SPM:** README Requirements: **Swift 6.0+, macOS 13+ / iOS
  16+**. Linux release binaries **“no longer part of the release pipeline”**
  (unsupported static-musl recipe only). SPM URL in README is a placeholder
  (`yourusername/SwiftExif.git`) — treat packaging as **verify before
  adopt**.
- **Maps to:** README `VideoMetadata` API: duration (`TimeInterval?`
  seconds), video width/height/codec/fps, audio codec/sample rate/channels —
  closely matches MediaTools field set for supported containers. Positions
  itself as ffprobe alternative for editorial pipelines.
- **Gaps / risks:** **GPL-3.0** vs FCPKit’s MIT packaging implications;
  duration as floating seconds (not rational) unless derived elsewhere;
  Linux not a supported release target; SPM install path unclear from README
  placeholder.
- **Primary sources:**
  https://codeberg.org/taagedal/SwiftExif (README Supported Formats /
  Requirements / Video metadata / License sections; fetched 2026-07-29).

### swift-cmaf-kit (CMAFKit) — pure Swift ISOBMFF

- **URL:** https://github.com/atelier-socle/swift-cmaf-kit  
- **License:** Apache-2.0.  
- **Last activity:** `pushed_at` 2026-05-25; README status **0.1.2**.  
- **Platforms / SPM:** `Package.swift` Apple platforms macOS 14 / iOS 17 / …;
  README + CI claim **Linux** (`swift:6.2-jammy`, 3574 tests). Product
  `CMAFKit` has zero library deps. Requires **Swift 6.2**.
- **Maps to:** Fragmented MP4 / CMAF / ISO BMFF track config: dimensions,
  timescale, frame rate fraction, audio sample rate/channels, codecs —
  `cmafkit-cli probe`. Strong for **streaming CMAF** init/media segments.
- **Gaps / risks:** Oriented to CMAF/DASH/HLS fragmented media, not general
  Final Cut camera masters (MOV/ProRes/MXF as AVFoundation sees them). Young
  0.1.x API; Swift 6.2 floor may exceed FCPKit’s current toolchain. Useful
  building block for MP4-like files, not a full AVFoundation replacement.
- **Primary sources:**
  https://github.com/atelier-socle/swift-cmaf-kit/blob/main/Package.swift;
  https://github.com/atelier-socle/swift-cmaf-kit/blob/main/README.md.

### MediaInfoKit / GStreamer Swift / SwiftVLC

- **MediaInfoKit** (https://github.com/mackworth/MediaInfoKit): macOS
  Objective-C/Swift wrapper; **not SPM**; Xcode 7 / OS X 10.8 era README —
  **not recommended**.
- **GStreamerSwift** (https://github.com/byuarus/GStreamerSwift): iOS SDK /
  bridging-header sample, not a portable SPM probe library —
  **not recommended** for FCPKitMediaTools.
- **SwiftVLC** (https://github.com/harflabs/SwiftVLC): libVLC **playback**
  wrapper with Apple XCFramework (~1.2 GB); wrong problem domain for metadata
  probe — **not recommended**.

## Recommendation matrix

| Capability | Local rational / SwiftTimecode Fraction | ffprobe CLI | mediainfo CLI | SwiftFFmpeg (sunlubo) | SwiftExif | swift-cmaf-kit |
| --- | --- | --- | --- | --- | --- | --- |
| Rational duration → FCPXML `N/Ds` | **feasible** | **feasible** (via `duration_ts`+`time_base`) | partial (often non-rational display) | **feasible** (AVRational / stream TB) | partial (`TimeInterval`) | partial (timescale-oriented; CMAF scope) |
| File duration probe | no | **feasible** | **feasible** | **feasible** | **feasible** (supported formats) | partial (ISOBMFF/CMAF) |
| Dimensions | no | **feasible** | **feasible** | **feasible** | **feasible** | **feasible** (init/probe) |
| Frame rate | no | **feasible** (`r_frame_rate`/`avg_frame_rate`) | **feasible** | **feasible** | **feasible** | **feasible** |
| Video/audio codec | no | **feasible** (`codec_tag_string` / `codec_name`) | **feasible** | **feasible** | **feasible** | partial (codec set) |
| Audio channels / sample rate | no | **feasible** | **feasible** | **feasible** | **feasible** | **feasible** |
| Track presence | no | **feasible** | **feasible** | **feasible** | **feasible** | partial |
| Linux without Apple frameworks | **feasible** (time only) | **feasible*** | **feasible*** | **feasible*** | unsupported release | **feasible*** (claimed CI) |
| SPM-only, no host tools | **feasible** | no | no | no (needs FFmpeg libs) | unclear packaging | **feasible** (narrow formats) |

\*Feasible on paper from primary docs/CI claims; **not verified** in this
worktree’s Docker `linux/amd64` environment. Do not advertise support until
verified.

## Out of scope / not recommended

- Replacing Foundation / FoundationXML (available on all OSes; user fact).
- Adopting playback stacks (SwiftVLC, GStreamer samples) for probe-only needs.
- Claiming bit-identical metadata with AVFoundation across codecs without
  fixture comparison (ProRes, MXF, variable frame rate, display vs coded
  size, audio channel layout).
- Using float seconds alone for FCPXML generation when editorial exactness
  matters — prefer integer rational pairs (local `Fraction` / `duration_ts`).
- **intrusive-memory SwiftFFmpeg** for production or Linux (experimental +
  macOS-26 platform pin).
- **GPL-3.0 SwiftExif** without an explicit license decision for FCPKit
  distribution.
- Asserting cross-platform MediaTools support from macOS-only builds
  (`.claude/agent-notes.md`).

## Suggested direction (non-binding)

1. Introduce a **platform-neutral rational time** type on MediaTools (local
   or `SwiftTimecodeCore`) and gate AVFoundation probing as today.
2. Add an optional **`ffprobe` JSON extractor** behind the same
   `VideoMetadata` shape, mirroring `DTDValidation`’s Process pattern.
3. Keep Apple AVFoundation as the high-fidelity path on Darwin; treat
   ffprobe as best-effort / CI-friendly until fixture parity is measured.
4. Revisit pure-Swift parsers (CMAFKit / SwiftExif) only if SPM-only probing
   becomes a hard requirement and license/format scope fit.

## Sources

### Repo

- `docs/planning/apple-platform-frameworks.md`
- `Sources/FCPKitMediaTools/VideoMetadata.swift`
- `Sources/FCPKitMediaTools/VideoMetadataExtractor.swift`
- `Sources/FCPKitMediaTools/FCPXMLUtilities.swift`
- `Sources/FCPKitMediaTools/MulticamXMLBuilder.swift`
- `Sources/FCPXMLDiff/DTDValidation.swift`
- `.claude/agent-notes.md` (canImport gates; no unverified cross-platform claims)

### External primary

- https://developer.apple.com/documentation/coremedia/cmtime
- https://developer.apple.com/documentation/avfoundation/avasset
- https://ffmpeg.org/ffprobe.html
- https://github.com/FFmpeg/FFmpeg/blob/master/doc/ffprobe.xsd
- https://github.com/orchetect/swift-timecode (Package.swift, README, Fraction.swift, build.yml)
- https://github.com/sunlubo/SwiftFFmpeg (Package.swift, README, LICENSE, CFFmpeg/module.modulemap)
- https://github.com/intrusive-memory/SwiftFFMpeg (README, Package.swift, license)
- https://codeberg.org/taagedal/SwiftExif (README)
- https://github.com/atelier-socle/swift-cmaf-kit (Package.swift, README)
- https://github.com/OpenTimelineIO/OpenTimelineIO-Swift-Bindings (Package.swift)
- https://mediaarea.net/en/MediaInfo
- https://mediaarea.net/en/MediaInfo/Support/Formats
- https://mediaarea.net/en/MediaInfo/Support/SDK/Quick_Start
- https://github.com/MediaArea/MediaInfo/blob/master/History_CLI.txt
- https://github.com/MediaArea/MediaInfo/issues/1103
- https://github.com/mackworth/MediaInfoKit
- https://github.com/byuarus/GStreamerSwift
- https://github.com/harflabs/SwiftVLC

*Research date: 2026-07-29. Activity timestamps from GitHub/Codeberg APIs on that date.*

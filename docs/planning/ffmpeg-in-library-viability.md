# Building Media Probing Into FCPKit (No ffprobe)

Research date: 2026-07-29. Updates and partially supersedes the preferred-path advice in
[`non-apple-media-alternatives.md`](non-apple-media-alternatives.md) (that doc still
inventories candidates; this one answers the “built into the library” constraint).

## Constraint

`.claude/agent-notes.md` (2026-07-29):

> Do not rely on external host tools like ffprobe for MediaTools; prefer something that
> can be built into the library.

Also relevant: never claim Linux/wasm support without verifying in Docker
`--platform linux/amd64` (same notes file); gate Apple frameworks with
`#if canImport(...)`.

“Built into the library” is interpreted here as: **callers get probing through the
FCPKitMediaTools Swift API without spawning a host CLI** (`ffprobe`, `mediainfo`,
`xmllint`-style `Process`). That still allows an **in-process native library**
(linked FFmpeg / MediaInfoLib) or a **pure-Swift parser**. It does **not** require
zero native code on disk.

## Capability needs

From `Sources/FCPKitMediaTools/VideoMetadataExtractor.swift` and
`VideoMetadata.swift` (today `CMTime` / `CGSize` / AVFoundation-gated):

| Need | Today | Must survive round-trip into FCPXML-facing builders |
| --- | --- | --- |
| Duration as rational time | `CMTime` (`value` + `timescale`) | Exact `"N/Ds"` strings via `FCPXMLUtilities` |
| Video size | track `naturalSize` | format width/height |
| Frame rate | `nominalFrameRate` (Float) | format name / `frameDuration` |
| Video codec | FourCC from format description | stored on `VideoMetadata` |
| Audio channels / sample rate | ASBD | asset attrs (defaults 1 / 48000) |
| Audio codec | FourCC | stored on `VideoMetadata` |
| Track presence | video/audio track lists | multicam asset attrs |

Playback, full decode, and encoding are **out of scope**.

## Rejected: host-tool probing

Spawning `ffprobe` or `mediainfo` via `Foundation.Process` (as sketched in
`non-apple-media-alternatives.md`, patterned on `DTDValidation` → `xmllint`) is
**rejected as the preferred product path**. It contradicts the agent-notes
directive: the probe lives on the **host PATH**, not in the library image, and
shares WASI/`Process` limits with xmllint.

Those CLIs remain useful as **human/debug** tools and as a capability reference
(ffprobe JSON ≈ libavformat stream fields). They are not the MediaTools
integration strategy.

## Options that ship in-process

### Local/pure-Swift pieces

#### Rational time (required regardless of probe backend)

- **Local type:** A small `numerator`/`denominator` (or `value`/`timescale`)
  struct in-repo replaces `CMTime` on the public MediaTools surface. No SPM
  dependency. Maps directly to `"\(value)/\(timescale)s"`
  (`FCPXMLUtilities.cmTimeToFCPXMLDuration` today).
- **SwiftTimecode** (`SwiftTimecodeCore.Fraction`): MIT; `numerator` /
  `denominator`; first-party FCPXML string helpers; Linux CI in upstream
  (`swift build` / `swift test` on `ubuntu-latest`).
  Sources: https://github.com/orchetect/swift-timecode ;
  `Sources/SwiftTimecodeCore/Fraction/Fraction.swift`.

Neither probes files. Both are **viable now** for the timing half of the gap.

#### Pure-Swift container parsers

| Package | License | What it covers | Linux / SPM evidence | Fit for MediaTools |
| --- | --- | --- | --- | --- |
| **swift-cmaf-kit** (`CMAFKit`) | Apache-2.0 | ISOBMFF / CMAF / fragmented MP4 track config; CLI `probe` | `Package.swift` product has **zero** library deps; README/CI claim Linux (`swift:6.2-jammy`) | Strong for streaming CMAF; **not** a general Final Cut master probe (MOV/ProRes/MXF) |
| **SwiftExif** | **GPL-3.0** | MP4/MOV/MXF/MKV (+ audio containers) stream metadata; `VideoMetadata` API close to our fields | README: macOS 13+ / iOS 16+; Linux release **unsupported**; SPM URL in README is a placeholder (`yourusername/SwiftExif.git`) | Field fit is good; **GPL-3.0** and packaging/Linux status block adoption without an explicit license decision |

Sources: https://github.com/atelier-socle/swift-cmaf-kit/blob/main/Package.swift ;
https://codeberg.org/taagedal/SwiftExif (Requirements, License, Video metadata).

**Probe-only subset (pure Swift):** feasible only for a **declared format
subset**. Editorial cameras and Final Cut imports routinely exceed ISOBMFF/CMAF
scope. Treat as a future opt-in path, not a full AVFoundation replacement.

### Linked MediaInfo / other libs

**MediaInfoLib** is a **linked library** (C++ / DLL), not only a CLI:

- SDK quick start: `MediaInfo::Open` / `Get` / `Inform` —
  https://mediaarea.net/en/MediaInfo/Support/SDK/Quick_Start
- License: BSD-style (MediaArea) —
  https://mediaarea.net/en/MediaInfo/License ;
  GitHub `MediaArea/MediaInfoLib` LICENSE is BSD 2-Clause
- **SPM reality:** no maintained modern Swift SPM binding found in prior
  inventory; legacy `mackworth/MediaInfoKit` is Xcode-era, not SPM
  (`non-apple-media-alternatives.md`). Integrating means a custom
  `systemLibrary` or vendored C++ build — same class of work as FFmpeg, with
  less community Swift precedent and Inform-vocabulary → rational-time mapping
  work.

**GStreamer / libVLC wrappers** remain wrong problem domain (playback stacks),
as previously documented.

### FFmpeg C libraries (deep dive)

FFmpeg ships **libraries for developers** separately from the `ffprobe` CLI:
libavutil, libavcodec, libavformat, libavfilter, libavdevice, libswscale,
libswresample —
https://ffmpeg.org/about.html .

#### APIs for probe-only

Minimum demux / inspect flow (official lavf demuxing docs):

1. `avformat_open_input` — allocate/open, autodetect format, read header into
   `AVFormatContext`
2. `avformat_find_stream_info` — recommended when headers are incomplete;
   “tries to read and decode a few frames to find missing information”
3. Walk `AVFormatContext.streams` / `nb_streams`
4. `avformat_close_input`

Sources: https://ffmpeg.org/doxygen/trunk/group__lavf__decoding.html ;
header commentary in `libavformat/avformat.h` (same wording).

| MediaTools field | FFmpeg surface | Citation |
| --- | --- | --- |
| Duration (container) | `AVFormatContext.duration` — “in `AV_TIME_BASE` fractional seconds”; `AV_TIME_BASE` is `1000000` | doxygen `AVFormatContext`; `libavutil/avutil.h` |
| Duration (per stream, preferred for rational) | `AVStream.duration` in `AVStream.time_base` units; `AVStream.time_base` is `AVRational` | https://ffmpeg.org/doxygen/trunk/structAVStream.html |
| Rational math | `AVRational` `{num, den}`; `av_rescale_q` etc. | https://ffmpeg.org/doxygen/trunk/structAVRational.html ; lavu math group |
| Width / height | `AVCodecParameters.width` / `.height` | https://ffmpeg.org/doxygen/trunk/structAVCodecParameters.html |
| Frame rate | `AVStream.avg_frame_rate`, `AVStream.r_frame_rate` (`AVRational`); codec-level `AVCodecParameters.framerate` is last resort | `AVStream` / `AVCodecParameters` doxygen |
| Codec id / FourCC-like tag | `codec_id`, `codec_tag` (“corresponds to the AVI FOURCC”) | `AVCodecParameters` |
| Media type (video/audio) | `codec_type` (`AVMediaType`) | `AVCodecParameters` |
| Audio sample rate | `sample_rate` | `AVCodecParameters` |
| Audio channels | `ch_layout` (`AVChannelLayout`) | `AVCodecParameters` |
| Stream list | `AVFormatContext.streams` filled on demux open / find_stream_info | `AVFormatContext` doxygen |

**Library roles:**

- **libavformat** — demuxers/muxers; open file, streams, container duration
  (https://ffmpeg.org/about.html).
- **libavutil** — `AVRational`, time-base constants, rescale helpers.
- **libavcodec** — `AVCodecParameters` lives here; you typically **link**
  libavcodec even when you never call a full decode loop. Probe path does
  **not** require opening an `AVCodecContext` for every use case; parameters
  are filled by libavformat on the stream’s `codecpar`
  (`AVStream.codecpar` doxygen: filled on stream creation or in
  `avformat_find_stream_info`).

Honest caveat: “probe-only” is not “zero decode.” Official docs state
`avformat_find_stream_info` may decode a few frames. You still avoid a
full-file decode and avoid the `ffprobe` **executable**.

#### SPM integration models (system vs vendored vs static)

Distinguish three product meanings:

| Phrase | Meaning |
| --- | --- |
| Ships inside our `.swiftmodule` API | Callers import `FCPKitMediaTools` and call `extractMetadata` — true for all in-process options |
| Ships with no host `ffprobe` binary | No `Process` to PATH tools — true for linked libs + pure Swift |
| Zero external native deps at all | Only pure Swift / Apple frameworks — **not** true for FFmpeg or MediaInfoLib |

**1. SPM `systemLibrary` + pkg-config (SwiftFFmpeg / sunlubo pattern)**

sunlubo/SwiftFFmpeg:

```swift
.systemLibrary(
  name: "CFFmpeg",
  pkgConfig: "libavformat"
)
```

Module map links `avutil`, `avformat`, `avcodec`, `avfilter`, `swscale`,
`swresample`
(https://github.com/sunlubo/SwiftFFmpeg/blob/master/Sources/CFFmpeg/module.modulemap).
README: install FFmpeg **7.1+** first (`brew install ffmpeg`); wrapper still
“in development”
(https://github.com/sunlubo/SwiftFFmpeg/blob/master/README.md).

Apple PackageDescription: `systemLibrary` is for libraries **expected to exist
on the system**; SPM does not install them. pkg-config supplies cflags/libs
when present (Swift Forums guidance on system libraries / pkg-config).

**Verdict:** In-process, no `ffprobe` CLI — but **not** “built into the
library” in the redistribution sense. Build **and** runtime still need
system-installed FFmpeg (Homebrew / apt `libavformat-dev` etc.). This is an
**external native dependency**, just linked rather than exec’d.

**2. Vendoring / building FFmpeg from source or as a binary target**

- **SPM `binaryTarget`:** Apple docs historically: binary dependencies /
  XCFrameworks are **Apple-platform oriented**
  (https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages ;
  `binaryTarget(name:url:checksum:)` discussion: “Binary targets are only
  available on Apple platforms”).
- **SE-0482** (Implemented in **Swift 6.2**): extends artifact bundles with
  `staticLibrary` for **non-Apple** platforms (Linux/Windows), with headers +
  module map; default audit assumes deps limited to the C standard library
  (https://github.com/swiftlang/swift-evolution/blob/main/proposals/0482-swiftpm-static-library-binary-target-non-apple-platforms.md).
  FFmpeg builds often pull zlib and other libs depending on `./configure` —
  shipping a “safe” audited artifact may require a carefully self-contained
  static configure, which is **non-trivial**.
- **Real Swift examples:**
  - sunlubo: system FFmpeg only (no vendored binary).
  - intrusive-memory/SwiftFFMpeg: still `systemLibrary` + brew provider;
    experimental **FetchFFmpegXCFrameworks** command plugin; platforms pinned
    to **macOS 26**; README experimental — not a production Linux story
    (https://raw.githubusercontent.com/intrusive-memory/SwiftFFMpeg/main/Package.swift).

Compiling full FFmpeg **as ordinary SPM C targets** is impractical: FFmpeg’s
own `./configure` + generated config headers are the supported build system
(https://ffmpeg.org/ffmpeg-codecs.html configure discussion;
`configure --help` options below). Expect an **external build script** that
produces `.a` / XCFramework / artifactbundle, then a `binaryTarget` or manual
linker settings — not `swift build` compiling FFmpeg sources as first-class
SPM C files.

**Verdict:** **Viable with substantial work** if the goal is “no host
ffprobe **and** no required brew/apt FFmpeg at consumer build time.” Not
viable as a weekend Package.swift tweak.

**3. Static linking a prebuilt FFmpeg into the product**

- Size: **no official probe-only megabyte figure** in FFmpeg docs. Size is
  entirely a function of `./configure` feature set; must be **measured** per
  triple after a trimmed build.
- License: FFmpeg is **LGPL 2.1+**; optional parts under **GPL** if
  `--enable-gpl` (https://ffmpeg.org/legal.html). Compliance checklist’s
  *easiest* path uses **dynamic** linking; static is allowed if you still meet
  LGPL (FFmpeg developers: skip checklist item 2, provide object files +
  FFmpeg source for relinking —
  https://ffmpeg.org/pipermail/ffmpeg-devel/2012-May/124914.html ;
  https://ffmpeg.org/pipermail/libav-user/2016-April/009055.html).
- For an **MIT library** like FCPKit: dynamic LGPL FFmpeg is the lower-friction
  compliance story; static is heavier (relink materials for every consumer
  binary). **Do not** `--enable-gpl` / libx264 if you want LGPL-only FFmpeg
  (legal checklist items 1 and 18).

**4. Dynamic linking to system `dylib` / `.so`**

- Matches legal checklist item 2; matches SwiftFFmpeg’s link lines.
- **CI:** Ubuntu image must install matching `-dev` packages (or a pinned
  FFmpeg); macOS needs Homebrew FFmpeg + pkg-config; version skew (README
  wants 7.1+) becomes a matrix problem.
- **Docker `linux/amd64`:** still mandatory before claiming Linux support
  (agent-notes).
- Windows: FFmpeg builds on Windows (about.html), but FCPKit Windows CI is
  expensive/tiered; no first-party SwiftFFmpeg Windows story in README.
- **WASI:** FFmpeg’s documented portability list is Linux, macOS, Windows,
  BSDs, Solaris — **not** WASI (https://ffmpeg.org/about.html). FCPKit already
  gates `Process` off WASI; native FFmpeg-on-WASI is **not viable** without a
  separate port that FFmpeg does not document. Keep MediaTools probe
  `#if !os(WASI)` (or equivalent) unavailable.

#### License & redistribution

From https://ffmpeg.org/legal.html (not legal advice):

- Prefer builds **without** `--enable-gpl` / `--enable-nonfree`.
- Prefer **dynamic** linking for simplest LGPL compliance.
- Distribute corresponding FFmpeg **source**, document configure line,
  attribution in about/docs/download pages.
- GPL components (e.g. libx264) make **all of FFmpeg** GPL for that build —
  avoid for a MIT-licensed library product unless the project consciously
  accepts GPL coupling.

Static link: still LGPL-compatible **if** users can relink (object files +
sources), per FFmpeg developer guidance cited above.

#### Wrapper vs thin C interop

| Approach | Pros | Cons |
| --- | --- | --- |
| **sunlubo/SwiftFFmpeg** | Existing Swift API (`AVFormatContext`, streams, codec params); Apache-2.0 wrapper | systemLibrary only; API unstable per README; last push 2025-11-30; pulls avfilter/swscale/swresample into module map even for probe |
| **intrusive-memory fork** | Exploring XCFramework fetch | Experimental; macOS 26 floor; LGPL on wrapper; not cross-platform |
| **Thin in-repo C interop** | Few calls: open → find_stream_info → read `codecpar` / duration / time_base → close; own module map limited to avutil/avformat/avcodec; no stale wrapper surface | Must maintain shim headers + unsafe Swift; still need FFmpeg libs via system or vendored binary |

**Feasibility:** Thin C interop is **credible** for probe-only and may be
preferable to depending on an unstable full wrapper. The hard part is
**shipping/finding the C libraries**, not the Swift call sites.

#### Size / configure / CI cost

Documented `./configure` knobs (from FFmpeg `configure` help text / codecs
docs):

- `--disable-programs` — no ffmpeg/ffprobe/ffplay binaries
- `--disable-encoders` / `--disable-muxers` / `--disable-filters`
- `--disable-network`
- `--disable-everything` then selectively `--enable-demuxer=…` /
  `--enable-decoder=…` (extreme trim; easy to break format coverage)
- `--enable-shared` / static defaults discussed in configure help

Codecs doc: disable all encoders with `--disable-encoders`, list with
`--list-encoders` —
https://ffmpeg.org/ffmpeg-codecs.html .

For MediaTools, a **practical** trim is: disable programs, encoders, muxers,
filters, devices, network; keep demuxers (+ whatever parsers/decoders
`find_stream_info` needs for target formats). Exact size: **measure** after
configure; do not cite a fake MB number.

**CI cost for FCPKit:**

| Model | Image needs |
| --- | --- |
| systemLibrary | `ffmpeg` / `libavformat-dev` (+ pkg-config) on Ubuntu; brew on macOS; pin major version |
| vendored static / artifactbundle | Build or download per triple in CI; cache artifacts; LGPL source tarball publishing |
| Apple AVFoundation path | unchanged (`canImport`) |
| WASI | probe disabled |

Windows remains optional/expensive in `.github/workflows/FCPKit.yml`; do not
promise it until a Windows FFmpeg + SPM path is proven.

## Viability verdict

| Goal | Verdict |
| --- | --- |
| Rational time in MediaTools API (no CoreMedia) | **Viable now** (local type or SwiftTimecode) |
| No host `ffprobe` / `mediainfo` Process | **Viable** via in-process FFmpeg, MediaInfoLib, or pure-Swift subset |
| Probe via SPM `systemLibrary` FFmpeg | **Viable with work** — in-process, but **still an external system native dep**; does **not** fully satisfy “built into the library” redistribution |
| Probe with FFmpeg **vendored inside** the package (binaryTarget / artifactbundle / static) | **Viable with substantial work** — closest match to “built in”; LGPL + multi-triple builds + SE-0482 constraints |
| Zero external native deps + broad format coverage | **Not viable today** — pure Swift parsers are subset/GPL/packaging-limited |
| WASI probing via FFmpeg | **Not viable** (no FFmpeg WASI port in project docs) |
| Prefer ffprobe CLI for product MediaTools | **Rejected** by product direction |

## Recommended path for FCPKit

1. **Now:** Introduce a platform-neutral rational duration type on MediaTools;
   keep Darwin probing on AVFoundation behind `canImport`.
2. **Next (matches “built into library” intent):** Prefer an **in-process**
   probe behind the same `VideoMetadata` shape:
   - **Short term / CI-friendly:** optional `systemLibrary` FFmpeg (thin C
     interop or carefully pinned SwiftFFmpeg) — documents system FFmpeg as a
     **build dependency**, not a PATH CLI.
   - **Medium term / redistribution:** trimmed LGPL FFmpeg static or shared
     libs shipped via XCFramework (Apple) + SE-0482 artifact bundles (Linux),
     built by an explicit script with published configure line and source
     tarball — only after license review.
3. **Do not** implement Process→ffprobe as the default MediaTools backend.
4. Revisit **swift-cmaf-kit** only for an explicit ISOBMFF/CMAF-only mode;
   treat **SwiftExif** as blocked on GPL-3.0 + Linux/SPM readiness.
5. Verify every non-Apple claim in Docker `--platform linux/amd64` before
   README/support text.

## Sources

### Repo

- `.claude/agent-notes.md`
- `Sources/FCPKitMediaTools/VideoMetadataExtractor.swift`
- `Sources/FCPKitMediaTools/VideoMetadata.swift`
- `Sources/FCPKitMediaTools/FCPXMLUtilities.swift`
- `docs/planning/non-apple-media-alternatives.md`
- `docs/planning/apple-platform-frameworks.md`
- `.github/workflows/FCPKit.yml`

### FFmpeg (primary)

- https://ffmpeg.org/about.html
- https://ffmpeg.org/legal.html
- https://ffmpeg.org/documentation.html
- https://ffmpeg.org/doxygen/trunk/group__lavf__decoding.html
- https://ffmpeg.org/doxygen/trunk/structAVFormatContext.html
- https://ffmpeg.org/doxygen/trunk/structAVStream.html
- https://ffmpeg.org/doxygen/trunk/structAVCodecParameters.html
- https://ffmpeg.org/doxygen/trunk/structAVRational.html
- https://ffmpeg.org/ffmpeg-codecs.html
- FFmpeg `configure` help (`--disable-programs`, `--disable-encoders`, …)
- `libavutil/avutil.h` (`AV_TIME_BASE`)
- https://ffmpeg.org/pipermail/ffmpeg-devel/2012-May/124914.html
- https://ffmpeg.org/pipermail/libav-user/2016-April/009055.html

### Swift / SPM

- https://developer.apple.com/documentation/packagedescription/target/binarytarget(name:url:checksum:)
- https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages
- https://github.com/swiftlang/swift-evolution/blob/main/proposals/0482-swiftpm-static-library-binary-target-non-apple-platforms.md
- https://github.com/sunlubo/SwiftFFmpeg (Package.swift, README, module.modulemap, LICENSE)
- https://github.com/intrusive-memory/SwiftFFMpeg (Package.swift)
- https://github.com/orchetect/swift-timecode
- https://github.com/atelier-socle/swift-cmaf-kit
- https://codeberg.org/taagedal/SwiftExif

### MediaInfo

- https://mediaarea.net/en/MediaInfo/Support/SDK/Quick_Start
- https://mediaarea.net/en/MediaInfo/License
- https://github.com/MediaArea/MediaInfoLib

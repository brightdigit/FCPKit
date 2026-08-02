# Demo Presentation Video — Implementation Spec

Status: proposal (not yet accepted)
Target: a ~30-45s movie embedded in `README.md`, showcasing FCPKit by using FCPKit.

## Goal

Produce a short "slide deck" movie for the README: solid color backgrounds with
styled headings, separated by cross dissolves, authored entirely in `FCPKitDSL`,
imported into Final Cut Pro, and exported to `.mp4`.

The deck is **media-free** — no `.mov` files, no `ffmpeg` prerequisite, no
`Scripts/generate-test-media.sh` run. Anyone who clones the repo can regenerate the
`.fcpxml` with one command. This makes FCPKit demonstrate itself.

Three library gaps block this today. One of them is a latent correctness bug that a
multi-slide deck would trigger immediately. This document decomposes the work into
six independently reviewable issues.

## Why the Final Cut export step is manual

FCPKit writes `.fcpxml` and can push it into a running Final Cut Pro
(`Sources/fcpxml-dsl/FCPXMLDSLCommand+VerifyImport.swift` shells out to
`/usr/bin/open -b com.apple.FinalCutApp`). It cannot render or export a movie, and
neither can any automation layer we could add.

This was re-verified during planning by dumping the live scripting dictionary:

```console
$ sdef "$(mdfind 'kMDItemCFBundleIdentifier == com.apple.FinalCutApp' | head -1)" > fcp.sdef
$ grep -o '<command name="[^"]*"' fcp.sdef
<command name="get"
```

(Resolve the app by bundle identifier rather than hardcoding a path. Final Cut is not
always installed as `/Applications/Final Cut Pro.app` — on the machine where this was
verified it is `/Applications/Final Cut Pro Creator Studio.app`, and `sdef` on the
conventional path fails with error -43. The bundle identifier `com.apple.FinalCutApp`
is stable across both, which is why `FCPApplication.bundleIdentifier` and the
`open -b` call in `verify-import` keep working.)

The entire dictionary is ~8 KB and declares exactly **one command**, `get`. There is
no `export`, `share`, `render`, or `open` verb. Every property on every class
(`library`, `event`, `project`, `sequence`, `item`) is `access="r"`, and both suites
are gated behind:

```xml
<access-group identifier="com.apple.FinalCut.library.inspection" access="r"/>
```

Apple designed this interface for library *inspection* only. A `render` command
driven through ScriptingBridge is therefore not possible — there is no verb to call.
This corroborates `docs/NEXT_STEPS.md:151-156` ("AppleScript cannot automate
exports") and the doc comment on `FCPLibraryInspector`.

Two alternatives were weighed and declined:

- **Rendering the deck ourselves via AVFoundation.** Fully automatable, but it would
  produce FCPKit's interpretation of the timeline rather than Final Cut's — different
  dissolve curves and text metrics. A README video rendered that way would not be
  evidence that the `.fcpxml` is valid Final Cut content.
- **UI-scripting the Share sheet via System Events.** The only route to genuine
  unattended FCP output, but brittle across Final Cut releases and dependent on
  Accessibility permission. Not appropriate to ship in a CLI.

**Decision: the export stays a manual Share → Master File step**, performed once and
recorded as evidence. Re-verify with the `sdef` command above against a newer Final
Cut release before revisiting.

## Dependency graph

```
Issue 1 (text-style-def ids)  ─┐
Issue 2 (Anchorable)           ├─→ Issue 4 (PresentationDocument) ─→ Issue 5 (CLI) ─→ Issue 6 (record + README)
Issue 3 (Title styling)       ─┘
```

Issues 1, 2, and 3 are mutually independent and can be worked in parallel.

## Conventions for every issue below

- MIT header block on every new file (see `Scripts/header.sh`, or copy from any
  existing source file).
- Swift Testing (`import Testing`, `@Test`) for new tests, per `.claude/agent-notes.md`.
  Include "Tests" in either the parent enum or the child struct, never both.
- Doc comments on every public declaration (`AllPublicDeclarationsHaveDocumentation`
  is enabled).
- Keep files under 225 lines (SwiftLint `file_length` warning); prefer
  `Type+Modifiers.swift` splits, following the `AssetClip` / `AssetClip+Modifiers`
  precedent.
- Run `swift test` and
  `swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData` before each
  PR. Prefer opening a PR over merging.

---

## Issue 1 — Fix duplicate `text-style-def` ids

**Labels:** `bug`, `ready-for-agent`

### Problem

`Sources/FCPKitDSL/Title.swift:64-76` hardcodes the id `"ts1"` in both the
`TextStyle(ref:)` and the `TextStyleDef(id:)` it emits — for *every* title:

```swift
let style = FCPKit.TextStyle(ref: "ts1", content: text)
let definition = FCPKit.TextStyleDef(id: "ts1", textStyle: ...)
```

Final Cut's own DTD (`FCPXMLv1_14.dtd:581`, shipped inside
`Final Cut Pro.app/Contents/Frameworks/Interchange.framework`) declares:

```
<!ATTLIST text-style-def id ID #REQUIRED>
```

XML requires values of type `ID` to be unique within a document. **Any document
containing two titles therefore emits invalid XML today.** This is latent only
because no shipped document has more than one title; the presentation deck has seven.

### Reproduced

This four-line document is enough:

```swift
Project(name: "Two Titles") {
  Sequence {
    Title("First", duration: FCPTime(numerator: 5))
    Title("Second", duration: FCPTime(numerator: 5))
  }
}
```

Exporting it emits `text-style-def id="ts1"` twice, and validating the output against
Final Cut's 1.14 DTD fails:

```console
$ xmllint --noout --valid twotitles.xml
twotitles.xml:29: element text-style-def: validity error : ID ts1 already defined
                                <text-style-def id="ts1">
```

Real Final Cut output shows the correct behavior: in
`Tests/FCPKitTests/TestData/UntitledXML.fcpxml`, two titles produce ids
`ts1, ts2, ts3, ts4` — numbered **globally across separate titles**, not restarted
per title. Match that.

### Files

- Modify `Sources/FCPKitDSL/ResourceStore.swift` — add a text-style id allocator
- Modify `Sources/FCPKitDSL/Title.swift` — consume it in `build`

### API

Internal only; no public surface change. `ResourceStore` already has a `nextNumber`
counter for resource ids (`ResourceStore.swift:41`) — model this on it:

```swift
private var nextTextStyleNumber = 1

internal mutating func textStyleID() -> String {
  defer { nextTextStyleNumber += 1 }
  return "ts\(nextTextStyleNumber)"
}
```

`Title.build` already receives `inout ResourceStore`, so no signature change is
needed — take one `let styleID = resources.textStyleID()` and use it in both places.

### Tests

New `Tests/FCPKitDSLTests/TextStyleIDTests.swift`:

- A document with three titles yields `textStyleDef` ids `["ts1", "ts2", "ts3"]`, all
  distinct.
- Each title's `text[0].textStyle[0].ref` equals that same title's
  `textStyleDef[0].id` — the styles must stay correctly paired, not merely unique.
- The multi-title document passes `assertDTDValidates`. **This is the assertion that
  fails on `main` today** and is the regression guard.

### Acceptance criteria

- A two-title document DTD-validates.
- Single-title documents still emit exactly `ts1`, because the counter starts at 1 —
  so `FeaturePairAcceptanceTests.titlesFeaturePairMatchesAfterNormalize` passes
  **unchanged**, with no fixture edits. This structural diff against a real Final Cut
  export is the backward-compatibility proof.

---

## Issue 2 — `Anchorable`: lift `.anchor` off `AssetClip`

**Labels:** `enhancement`, `ready-for-agent`

### Problem

`.anchor(lane:offset:content:)` is declared only on `AssetClip`
(`Sources/FCPKitDSL/AssetClip+Modifiers.swift`), so nothing can be anchored onto a
generator or a color. A media-free slide deck needs exactly that: text over a color
background. Anchoring belongs on any story item that can accept it.

The internal machinery is already general. `Sources/FCPKitDSL/Anchor.swift` handles
title, assetClip, generator, and video, and already throws `BuildError.invalidLane`
for lane 0. Only the *storage* (`AssetClip.anchors`) and the *public modifier* are
`AssetClip`-specific. This is a lift, not a rewrite.

### Design constraint (verified with the compiler)

`DSLNode` is an **internal** protocol, so it cannot appear in a public protocol
requirement:

```
error: method cannot be declared public because its parameter uses an internal type
```

The naive `public protocol Anchorable { func replacing(anchors: [any DSLNode]) -> Self }`
does not compile. A public but structurally opaque wrapper is required to carry the
internal existential through a public signature. Justify this in the PR description —
it looks odd without the compiler error as context.

### Files

- Create `Sources/FCPKitDSL/Anchorable.swift` — protocol, wrapper, shared modifier
- Create `Sources/FCPKitDSL/AnchoredItemBuilder.swift` — hoist the anchored-item
  mapping currently private to `AssetClip`
- Create `Sources/FCPKitDSL/Generator+Modifiers.swift` — `Generator` conformance
  (keeps `Generator.swift`, already 144 lines, under the length warning)
- Modify `Sources/FCPKitDSL/AssetClip.swift` — conform
- Modify `Sources/FCPKitDSL/AssetClip+Modifiers.swift` — **remove** `.anchor`, keep
  `.audioRole`
- Modify `Sources/FCPKitDSL/Generator.swift` — add `anchors` storage, thread through
  `replacing`, populate `Video.anchoredItems` in `build`
- Modify `Sources/FCPKitDSL/Color+DSL.swift` — conformance with promotion
- Modify `Sources/FCPKitDSL/Layout+Packing.swift` — add the missing `.video` case to
  `anchoredExtent`

### API

```swift
/// Opaque anchored content produced by ``Anchorable/anchor(lane:offset:content:)``.
public struct AnchoredContent {
  internal let node: any DSLNode
  internal init(_ node: any DSLNode) { self.node = node }
}

/// A story item that accepts anchored content on connected lanes.
public protocol Anchorable: DocumentContent {
  /// The type produced by anchoring; usually `Self`.
  associatedtype Anchored: DocumentContent
  /// The anchors already attached to this item.
  var anchoredContents: [AnchoredContent] { get }
  /// Returns a copy carrying the given anchors.
  func replacingAnchoredContents(_ contents: [AnchoredContent]) -> Anchored
}

extension Anchorable {
  /// Anchors content on a connected lane. `lane` must be nonzero.
  public func anchor(
    lane: Int,
    offset: FCPTime = .zero,
    @DocumentBuilder content: () -> DocumentGroup
  ) -> Anchored
}
```

The internal `Anchor` struct is **unchanged**.

Conformances:

| Type | `Anchored` | Notes |
|---|---|---|
| `AssetClip` | `AssetClip` | Behavior identical to today |
| `Generator` | `Generator` | New `anchors` storage |
| `Color` | `Generator` | **Promotes** — see below |

**Why `Color` promotes.** `Color` is `FCPKit.Color`, a model type in a different
module; it cannot gain stored properties. The `associatedtype Anchored` exists
precisely to allow this. It is also semantically honest: `Color.build` already
desugars to `Generator(.custom).color(self)`, so `.anchor` just performs that
desugaring one step earlier. Chaining still works, since `Generator` is itself
`Anchorable`.

```swift
extension Color: Anchorable {
  public var anchoredContents: [AnchoredContent] { [] }
  public func replacingAnchoredContents(_ contents: [AnchoredContent]) -> Generator {
    Generator(.custom, duration: duration ?? .zero)
      .color(self)
      .replacingAnchoredContents(contents)
  }
}
```

**Document this caveat:** `.duration(_:)` should precede `.anchor(_:)`. `.anchor`
cannot throw (it sits in builder position), so promotion uses `duration ?? .zero`;
a zero duration surfaces later as `BuildError.missingDuration` at `export()`.

**Anchors into the model.** `Generator.build` emits `FCPKit.Video` (not
`<generator>`, which is absent from the DTD's `%anchor_item;` list). `FCPKit.Video`
already has a settable `anchoredItems`, so:

```swift
let items = try anchors.map { try anchoredItem($0, resources: &resources) }
videoElement.anchoredItems = items.isEmpty ? nil : items
```

**Packing needs no new wiring.** `Layout+Packing.swift:64` already passes
`anchoredExtent(video.anchoredItems, …)` for the `.video` branch, which is where
generators land. However `anchoredExtent` itself (`Layout+Packing.swift:162-180`)
handles only `.title` and `.assetClip` — add a `.video` case so anchored
generators/colors contribute extent.

### Tests

Extend `Tests/FCPKitDSLTests/GeneratorDSLTests.swift` and add
`Tests/FCPKitDSLTests/AnchorableTests.swift`:

- `Generator.anchor(lane: 1) { Title }` → spine item `.video` with one anchored
  `.title` at `lane == "1"`.
- `Color.red.duration(...).anchor(lane: 1) { Title }` → same shape, and the color
  param survives (`param[0].value == "1 0 0 1"`).
- Lane 0 throws `BuildError.invalidLane` on both new conformers.
- Sequence duration accounts for an anchored title longer than its background
  (exercises the new `anchoredExtent` case).
- A nested `Spine { }` inside `Generator.anchor` still passes through.
- **Regression:** the existing `exportsGeneratorWithAnchoredTitle` and all
  `AssetClip.anchor` call sites (`TitlesCutDocument`, `FeaturePairDocuments`) compile
  and pass untouched.

### Acceptance criteria

- `AssetClip+Modifiers.swift` no longer declares `.anchor`; no call site changes.
- Full existing suite green with zero fixture changes.
- `swift-format lint` and `swiftlint` clean; `Generator.swift` stays under 225 lines.

---

## Issue 3 — Title styling modifiers

**Labels:** `enhancement`, `ready-for-agent`

### Problem

`Sources/FCPKitDSL/Title.swift:64-76` hardcodes Helvetica 63pt Regular white centered
for every title. A slide deck needs to distinguish a heading from body text.

### Files

- Create `Sources/FCPKitDSL/TitleStyle.swift` — public style value type
- Create `Sources/FCPKitDSL/Title+Modifiers.swift` — the public modifiers
- Modify `Sources/FCPKitDSL/Title.swift` — add a `style` payload, thread through the
  inits and `duration(_:)`, consume in `build`

### API

```swift
/// Text styling applied to a ``Title``.
public struct TitleStyle: Equatable, Sendable {
  /// Final Cut Pro's Basic Title default styling.
  public static let `default` = TitleStyle()

  /// Paragraph alignment.
  public enum Alignment: String, Equatable, Sendable {
    case left, center, right, justified
  }

  public var font: String = "Helvetica"
  public var fontSize: String = "63"
  public var fontFace: String = "Regular"
  public var fontColor: Color = .white
  public var alignment: Alignment = .center
  public var bold: Bool = false
}

extension Title {
  /// Sets the font family, such as `Helvetica`.
  public func font(_ name: String) -> Title
  /// Sets the font size in points.
  public func fontSize(_ points: Double) -> Title
  /// Sets the text color.
  public func fontColor(_ color: Color) -> Title
  /// Sets the paragraph alignment.
  public func alignment(_ alignment: TitleStyle.Alignment) -> Title
  /// Sets the font face or weight within the family, such as `Bold`.
  public func fontFace(_ face: String) -> Title
  /// Renders the text bold.
  public func bold(_ isBold: Bool = true) -> Title
  /// Sets the title clip display name, independent of its text.
  public func name(_ name: String) -> Title
}
```

### Matching real Final Cut output

`Tests/FCPKitTests/FeaturePairs/titles/after.fcpxml:37` shows exactly what FCP emits:

```xml
<text-style font="Helvetica" fontSize="63" fontFace="Regular" fontColor="1 1 1 1" alignment="center"/>
```

Attribute order is `font, fontSize, fontFace, fontColor, alignment`, and `bold` is
never set. `FCPKit.TextStyle`'s `CodingKeys` place `bold` between `fontColor` and
`alignment`, so **emit `bold` only when true** to keep the default path
byte-identical to the fixture.

`fontSize` takes `Double` but must serialize as `63`, not `63.0` — reuse the
integer-collapse approach from `Sources/FCPKit/Values/Color.swift`.

Keep `name` defaulting to `preset.name` ("Basic Title") and `start: "3600s"`; the
fixture confirms both are what real Final Cut writes.

### Tests

New `Tests/FCPKitDSLTests/TitleStyleTests.swift`:

- An unstyled `Title` emits today's exact attributes — **fixture parity guard**.
- `.font("Avenir Next").fontSize(96).fontColor(.red).alignment(.left)` →
  `font == "Avenir Next"`, `fontSize == "96"`, `fontColor == "1 0 0 1"`,
  `alignment == "left"`.
- `.bold()` emits `bold == "1"`; the default emits `bold == nil`.
- `.fontSize(63.5)` → `"63.5"`; `.fontSize(63)` → `"63"`.
- A styled multi-title document DTD-validates.

### Acceptance criteria

- `titlesFeaturePairMatchesAfterNormalize` passes unchanged — a structural diff
  against a real Final Cut export is the strongest available parity proof.
- Every new public declaration carries a doc comment.

### Open question for Final Cut verification

`.bold()` (the `bold` attribute) and `.fontFace("Bold")` are two different mechanisms
and it is unverified which one Final Cut actually honors for a given family. The
presentation deck should prefer `.fontFace(...)` with a face known-good for its
family, since that is what Final Cut itself writes. `alignment: "justified"` is
included for completeness but is likewise unverified.

---

## Issue 4 — `PresentationDocument`

**Labels:** `enhancement`, `ready-for-agent`
**Depends on:** Issues 1, 2, 3

### Files

- Create `Sources/FCPKitDSL/PresentationSlide.swift`
- Create `Sources/FCPKitDSL/PresentationDocument.swift`

Both public and shipped in the library, so users browsing `FCPKitDSL` can read the
showcase and tests can import it. **Do not** duplicate into `Sources/fcpxml-dsl/` —
the CLI already imports `FCPKitDSL`. (`RGBDocument` is currently duplicated across
both; that is pre-existing debt, intentionally left alone here.)

### API

```swift
/// A slide in a ``PresentationDocument``: a heading over a solid color background.
public struct PresentationSlide: Sendable {
  public var heading: String
  public var subheading: String?
  public var background: Color
  public var duration: FCPTime
  public init(
    heading: String,
    subheading: String? = nil,
    background: Color,
    duration: FCPTime = .seconds(6)
  )
}

/// A media-free slide deck showcasing FCPKitDSL, built from color generators
/// and anchored titles.
public struct PresentationDocument: Document {
  public let projectName: String
  public let slides: [PresentationSlide]
  public let transitionDuration: FCPTime

  /// The default FCPKit feature deck.
  public static let featureShowcase: [PresentationSlide]

  public init(
    projectName: String = "FCPKit Presentation",
    slides: [PresentationSlide] = PresentationDocument.featureShowcase,
    transitionDuration: FCPTime = FCPTime(numerator: 1)
  )

  public var body: some DocumentContent { ... }
}
```

The body loops `slides`, interleaving `Transition(.crossDissolve)` between them and
anchoring a styled `Title` on lane 1 of each `Color` background. This exercises
Issue 2's `Color` → `Generator` promotion, Issue 3's title modifiers, and the result
builder's `buildArray` / `buildOptional` — a genuine showcase rather than a contrived
one. If `if index > 0` inside the `for` proves awkward through the builder, fall back
to a helper returning `DocumentGroup`.

### Dissolve-safe title timing

Anchored items are **not** automatically included in a primary-storyline transition,
so a title spanning a dissolve would hard-cut while its background dissolves. We
design around this rather than discovering it at import.

`placeOverlapping` (`Layout+Packing.swift:130-142`) sets a clip's
`start = overlap.previous` (= T/2) and shrinks its `duration` by both overlaps.
Anchored `offset` is relative to the parent's *trimmed* `start`, so a title at
`offset: .zero` already begins exactly where the incoming dissolve ends. Only the
tail needs trimming:

```
titleDuration = slideDuration - (incomingT / 2) - (outgoingT / 2)
```

with `incomingT` / `outgoingT` zero for the first and last slide. The title then sits
entirely inside the non-overlapping region and hard-cuts nowhere visible. Assert this
formula in tests.

### Deck content

Seven slides at 6s with 1s dissolves lands ~36s, inside the 30-45s target. Assert on
the packer's computed sequence duration rather than hand arithmetic.

| # | Heading | Background |
|---|---|---|
| 1 | FCPKit | near-black `Color(white: 0.08)` |
| 2 | Typed FCPXML model | deep blue |
| 3 | Ordered spine, preserved | teal |
| 4 | SwiftUI-shaped DSL | purple |
| 5 | Resource interning | orange |
| 6 | DTD-validated output | green |
| 7 | brightdigit/FCPKit | near-black |

Use Helvetica so the video reproduces on any machine.

### Tests

New `Tests/FCPKitDSLTests/PresentationDocumentTests.swift`:

- Spine children alternate `["video", "transition", "video", "transition", ...]`
  (copy the `assertSpineChildNames` helper pattern from `FeaturePairAcceptanceTests`).
- Each `video` has exactly one anchored `title` at `lane == "1"`.
- Every `text-style-def` id in the document is unique — ties Issue 1 to the showcase.
- Each title's duration matches the dissolve-safe formula above.
- Sequence duration falls in the 30-45s range.
- Effect interning: exactly one `Custom` generator effect and one `Basic Title`
  effect despite seven slides, proving `ResourceStore` dedup.
- `assertDTDValidates(generatedData)` — the end-to-end gate.

### Acceptance criteria

- `FCPKIT_REQUIRE_DTD=1 swift test` passes.
- Both new files stay under the 225-line warning.

---

## Issue 5 — `export presentation` CLI subcommand

**Labels:** `enhancement`, `ready-for-agent`
**Depends on:** Issue 4

### Files

- Modify `Sources/fcpxml-dsl/FCPXMLDSLCommand.swift`
- Modify `Sources/fcpxml-dsl/FCPXMLDSLCommand+Export.swift`
- Modify `.gitignore`

### Work

Add a `"presentation"` case to the `export` switch (`FCPXMLDSLCommand.swift:78-87`)
and an `exportPresentationCommand`, mirroring `exportRGBCommand`
(`FCPXMLDSLCommand.swift:133-144`) exactly: optional positional output defaulting to
`presentation.fcpxml`, plus `--project` and `--version`.

Add `case "presentation": return "FCPKit Presentation"` to `defaultProjectName`
(`FCPXMLDSLCommand.swift:165-176`), and update `printUsage()` — the USAGE block and
the EXAMPLES block both list the export kinds.

The existing `export` implementations sit inside `#if canImport(AVFoundation)`.
`presentation` needs no media probing and could live outside that gate, but keep it
inside for consistency with its siblings and to avoid restructuring the conditional.

`.gitignore:142-144` lists `/transitions.fcpxml` and `/titles.fcpxml` under
"fcpxml-dsl export outputs" but is missing `/rgb.fcpxml` (an oversight from
`e2a64c3`). Add both `/rgb.fcpxml` and `/presentation.fcpxml`.

### Acceptance criteria

- `swift run fcpxml-dsl export presentation presentation.fcpxml` writes a valid file.
- `swift run fcpxml-dsl --help` lists the new kind in USAGE and EXAMPLES.
- Neither `rgb.fcpxml` nor `presentation.fcpxml` shows up in `git status` after an
  export run.

---

## Issue 6 — Record the demo and embed it in the README

**Labels:** `documentation`, `ready-for-human`
**Depends on:** Issue 5

Human-only; requires Final Cut Pro.

### Procedure

1. `swift run fcpxml-dsl export presentation presentation.fcpxml`
2. `swift run fcpxml-dsl verify-import presentation.fcpxml`
3. Confirm visually in Final Cut that the slides and dissolves render as intended.
4. Share → Master File, H.264, 1080p24.
5. Drag the resulting `.mp4` into a GitHub issue or PR comment. GitHub returns a
   permanent `https://github.com/user-attachments/assets/<uuid>` URL.
6. Paste that URL **bare, on its own line** into `README.md`.

### Why that hosting mechanism

GitHub's markdown renderer will not play a repo-hosted video.
`![](docs/assets/demo.mp4)` renders as a broken image or a plain link. A bare
user-attachments URL on its own line renders a real inline player, and it keeps a
multi-MB binary out of a package repository that SwiftPM clones on every resolve.

### README changes

Place the video near the top of `### Authoring with FCPKitDSL` (README.md:122-155),
with a copy-pasteable `PresentationDocument` snippet beneath it.

While there: README.md:151 says the CLI "exports two smoke-test cuts". That is stale —
`e2a64c3` added `rgb` for a third, and Issue 5 adds a fourth. Update the count.

### Evidence doc

Create `docs/manual/presentation-demo.md` recording the procedure as performed, with
Final Cut and FCPXML versions, matching the fixture-provenance convention in
`AGENTS.md` and the precedent of `docs/manual/typed-generation-gate.md`.

That doc must also record **why step 4 is manual**, citing the evidence from
"Why the Final Cut export step is manual" above: one `get` command, every property
`access="r"`, everything behind the `com.apple.FinalCut.library.inspection`
read-only access group. Include the bundle-identifier-based `sdef` invocation from
that section so a future reader can re-verify against a newer Final Cut release
rather than taking the claim on trust.

### Verify during import — genuinely unknown until Final Cut sees the file

- **Does Final Cut render an anchored title over a `<video>`-backed generator on
  lane 1?** The DTD permits it and lane semantics say yes, but this combination has
  not been round-tripped through Final Cut in this repo.
- **Do cross dissolves between two generators behave like dissolves between asset
  clips?** Transition packing assumes T/2 overlap on both neighbors. Generators have
  no media handles beyond their declared duration, so Final Cut may object to the
  overlap. If it does, the mitigation is extending each generator's duration by T/2
  on each side.

Record the outcome of both in `docs/manual/presentation-demo.md` either way — a
negative result is evidence worth keeping.

### Acceptance criteria

- The README shows an inline-playing video and a copy-pasteable snippet.
- No new files at the repo root (per the `AGENTS.md` docs-layout rule).
- `docs/manual/presentation-demo.md` records versions, the sdef rationale, and the
  two verification outcomes.

# Demo Presentation Video — Implementation Spec

Status: proposal (not yet accepted). Decomposed into GitHub issues
[#35](https://github.com/brightdigit/FCPKit/issues/35)-[#40](https://github.com/brightdigit/FCPKit/issues/40),
plus non-blocking [#33](https://github.com/brightdigit/FCPKit/issues/33) and
[#34](https://github.com/brightdigit/FCPKit/issues/34). Blocking relationships are
tracked as native GitHub issue dependencies.
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
six independently reviewable issues, plus two optional issues (7 and 8) that widen
what the deck can show without blocking it.

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
Issue 1 #35 (text-style-def ids) ─┐
Issue 2 #36 (StoryItem)           ├─→ Issue 4 #38 (PresentationDocument) ─→ Issue 5 #39 (CLI) ─→ Issue 6 #40 (share + export)
Issue 3 #37 (Title style/pos)   ─┘

Issue 7 (clip modifiers, #33) ─── independent; enriches the Issue 4 deck
Issue 8 (effect vocab,   #34) ─── independent; enriches the Issue 4 deck
```

Issues 1, 2, and 3 are mutually independent and can be worked in parallel.

Issues 7 and 8 are **not blockers** for the demo. They expand what the deck can show
(goofier transitions, blend modes, opacity, masking) and are tracked as separate
GitHub issues so the demo can ship on cross dissolves and be revisited.

Execution plan across parallel worktrees:
[demo-parallel-worktree-plan.md](demo-parallel-worktree-plan.md). Note that
#35 and #37 both rewrite `Title.build` and **cannot** be worked in parallel
despite being independent in the graph above.

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

**Filed as [#35](https://github.com/brightdigit/FCPKit/issues/35)**

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

## Issue 2 — `StoryItem`: lift `.anchor` off `AssetClip`

**Filed as [#36](https://github.com/brightdigit/FCPKit/issues/36)**

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

### `DSLNode` becomes public

An earlier draft of this issue routed around `DSLNode` being `internal` with a
structurally opaque public wrapper, because a public protocol requirement cannot
mention an internal type:

```
error: method cannot be declared public because its parameter uses an internal type
```

**That constraint is lifted: `DSLNode` becomes `public`** (decision recorded
2026-08-02 — pre-1.0, DSL API churn is acceptable). The wrapper is deleted from this
design. `public protocol StoryItem` can name `any DSLNode` directly.

Note `DSLNode.build`'s signature is expected to change again in Issue 3 (deferred
transform resolution). Making it public does not freeze it; it is documented as
evolving until 1.0.

### One protocol or two

`StoryItem` — "I can sit in a spine" — is the protocol, not `Anchorable`.
`.anchor(lane:offset:content:)` hangs off `StoryItem` directly.

This admits `Transition().anchor(lane: 1) { … }`, which compiles and is a **no-op**:
`Anchor.swift` maps only title/assetClip/generator/video into
`%anchor_item;`, so a transition's anchors are silently not emitted. That is the
accepted trade (decision 2026-08-02) — one protocol matching the DTD's `%clip_item;`
entity beats two protocols splitting hairs over which story items host lanes.

**Pin it with a test** (`transitionAnchorsAreIgnored`) so the no-op is documented
behavior rather than an accident a later change "fixes" into a throw.

### Files

- Create `Sources/FCPKitDSL/StoryItem.swift` — protocol + shared `.anchor` modifier
- Create `Sources/FCPKitDSL/AnchoredItemBuilder.swift` — hoist the anchored-item
  mapping currently private to `AssetClip`
- Create `Sources/FCPKitDSL/Generator+Modifiers.swift` — `Generator` conformance
  (keeps `Generator.swift`, already 144 lines, under the length warning)
- Modify `Sources/FCPKitDSL/DSLNode.swift` — make the protocol `public`
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
/// A story item: content that can sit in a spine, per the DTD's `%clip_item;` entity.
public protocol StoryItem: DocumentContent {
  /// The type produced by anchoring; usually `Self`.
  associatedtype Anchored: DocumentContent
  /// The anchors already attached to this item.
  var anchors: [any DSLNode] { get }
  /// Returns a copy carrying the given anchors.
  func replacingAnchors(_ anchors: [any DSLNode]) -> Anchored
}

extension StoryItem {
  /// Anchors content on a connected lane. `lane` must be nonzero.
  ///
  /// Anchoring onto a ``Transition`` has no effect: the FCPXML DTD does not admit
  /// anchored items on transitions, so they are not emitted.
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
| `Title` | `Title` | Anchors emitted; also a spine item in its own right |
| `Gap` | `Gap` | Anchors emitted |
| `Transition` | `Transition` | Anchors accepted, **not** emitted (see above) |

**Why `Color` promotes.** `Color` is `FCPKit.Color`, a model type in a different
module; it cannot gain stored properties. The `associatedtype Anchored` exists
precisely to allow this. It is also semantically honest: `Color.build` already
desugars to `Generator(.custom).color(self)`, so `.anchor` just performs that
desugaring one step earlier. Chaining still works, since `Generator` is itself
a `StoryItem`.

```swift
extension Color: StoryItem {
  public var anchors: [any DSLNode] { [] }
  public func replacingAnchors(_ anchors: [any DSLNode]) -> Generator {
    Generator(.custom, duration: duration ?? .zero)
      .color(self)
      .replacingAnchors(anchors)
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
`Tests/FCPKitDSLTests/StoryItemTests.swift`:

- `Generator.anchor(lane: 1) { Title }` → spine item `.video` with one anchored
  `.title` at `lane == "1"`.
- `Color.red.duration(...).anchor(lane: 1) { Title }` → same shape, and the color
  param survives (`param[0].value == "1 0 0 1"`).
- Lane 0 throws `BuildError.invalidLane` on both new conformers.
- `transitionAnchorsAreIgnored` — `Transition(.crossDissolve).anchor(lane: 1) { Title }`
  builds successfully and emits a `<transition>` with **no** anchored children.
  Pins the documented no-op.
- Sequence duration accounts for an anchored title longer than its background
  (exercises the new `anchoredExtent` case).
- A nested `Spine { }` inside `Generator.anchor` still passes through.
- **Regression:** the existing `exportsGeneratorWithAnchoredTitle` and all
  `AssetClip.anchor` call sites (`TitlesCutDocument`, `FeaturePairDocuments`) compile
  and pass untouched.

### Acceptance criteria

- `AssetClip+Modifiers.swift` no longer declares `.anchor`; no call site changes.
- `DSLNode` is `public` with doc comments on every requirement.
- Full existing suite green with zero fixture changes.
- `swift-format lint` and `swiftlint` clean; `Generator.swift` stays under 225 lines.

---

## Issue 3 — Title styling and positioning modifiers

**Filed as [#37](https://github.com/brightdigit/FCPKit/issues/37)**

**Labels:** `enhancement`, `ready-for-agent`

### Problem

`Sources/FCPKitDSL/Title.swift:64-76` hardcodes Helvetica 63pt Regular white centered
for every title. A slide deck needs to distinguish a heading from body text, and needs
to place text somewhere other than dead center — independent of whatever the title
preset does internally.

### Files

- Create `Sources/FCPKitDSL/TitleStyle.swift` — public style value type
- Create `Sources/FCPKitDSL/Title+Modifiers.swift` — the public modifiers
- Create `Sources/FCPKitDSL/FramePosition.swift` — position value type + alignment
- Create `Sources/FCPKitDSL/BuildEnvironment.swift` — internal environment + keys
- Modify `Sources/FCPKitDSL/Title.swift` — add `style` and `position` payloads, thread
  through the inits and `duration(_:)`, consume in `build`
- Modify `Sources/FCPKit/Adjustments/AdjustTransform.swift` — add the DTD's missing
  `rotation` and `anchor` attributes (see below)

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

### Positioning within the frame

Text must be placeable independent of the title preset's own layout. This is a
sibling `<adjust-transform>` on the clip, which composes over whatever the preset
does internally.

**The public surface is alignment-first**, in the SwiftUI spirit — developers should
not do coordinate math:

```swift
Title("FCPKit")                            // centered; emits no adjust-transform
Title("FCPKit").position(.topLeading)      // alignment — the common case
Title("FCPKit").position(.bottom, inset: 40)
Title("FCPKit").position(x: 960, y: 200)   // absolute pixels — escape hatch
```

```swift
/// A position within the video frame.
public struct FramePosition: Equatable, Sendable {
  /// The nine standard frame alignments.
  public enum Alignment: Equatable, Sendable {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing
  }
}

extension Title {
  /// Positions the title at a frame alignment, optionally inset in points.
  public func position(_ alignment: FramePosition.Alignment, inset: Double = 0) -> Title
  /// Positions the title at absolute pixel coordinates, origin top-left.
  ///
  /// Requires an enclosing ``Sequence`` with a format; otherwise ``BuildError``
  /// `missingFrameSize` is thrown at `export()`.
  public func position(x: Double, y: Double) -> Title
}
```

**No `adjust-transform` is emitted unless a position modifier is applied**, so
existing output is byte-identical.

### The coordinate unit (verified against fixtures and the DTD)

`FCPXMLv1_9.dtd:266-271` declares:

```
<!ATTLIST adjust-transform position CDATA "0 0">
<!ATTLIST adjust-transform scale    CDATA "1 1">
<!ATTLIST adjust-transform rotation CDATA "0">
<!ATTLIST adjust-transform anchor   CDATA "0 0">
```

`position` is **percent of frame height on both axes**, measured from frame center,
Y-up. Confirmed from `Tests/FCPKitTests/TestData`: on a 1920×1080 sequence,
`position="-17.8241 7.77778"` has a Y of `84/1080 × 100`. The multicam split-screen
values (`67.5926`, `-33.9193`) are consistent with the same unit.

Conversion from absolute pixels (origin top-left):

```
xPercent = (absX - width / 2)  / height * 100
yPercent = (height / 2 - absY) / height * 100
```

The divisor is `height` on **both** axes — that is what makes the 16:9 fixture values
land correctly. Assert this formula directly in tests using the fixture numbers above.

Alignment cases need **no frame size at all**: they map to fixed percentages
(`.leading` is `-50 × aspect`… but expressed in height-percent it depends only on the
aspect ratio, and `.top`/`.bottom` are exactly `±50` minus inset). Only
`.position(x:y:)` requires the actual pixel dimensions.

### Deferred resolution (`Built` carries unresolved transforms)

`build` is a single eager bottom-up pass: `Title.build` finishes *before* the
enclosing `Sequence.build` runs, so a title cannot read the sequence format at the
moment it builds. Rather than mutating shared state on the way down, **resolution is
deferred** (decision 2026-08-02):

- `Title.build` emits its `FCPKit.Title` with the position still *symbolic*.
- The ancestor that knows the format resolves symbolic positions into
  `adjust-transform position="…"` on the way out.

```swift
/// Ambient values supplied by ancestors during a build.
internal struct BuildEnvironment {
  internal var frameSize: (width: Double, height: Double)?
}
```

The environment and its keys are **internal**. Only `.position(…)` is public; there is
no public `@Environment`-style injection API, and third-party `DSLNode` conformers
cannot participate. That keeps the resolver total over values it created. Revisit if
an external need appears.

**Ordering invariant.** `Built` feeds the ordered `Spine.items` array, whose DTD order
guarantee came from v0.1.0 Step 3. The resolution pass must rebuild items **in place**,
preserving index order exactly. Extend the Step 0 ordering tests to run against
post-resolution output, not just build output — the existing tests would not catch a
reordering introduced by the resolver.

**Missing format is an error, not a silent default.** `.position(x:y:)` with no
enclosing format throws `BuildError.missingFrameSize` at `export()`. Alignment cases
never throw.

### `AdjustTransform` is missing two DTD attributes

`Sources/FCPKit/Adjustments/AdjustTransform.swift` models only `position` and `scale`.
The DTD also declares `rotation` and `anchor`, which are **silently dropped today** —
a schema-completeness hole. Add both (as `String?`, matching the existing style, in
DTD `CodingKeys` order: `position, scale, rotation, anchor`) while this type is being
touched. `enabled` is also declared; add it for completeness.

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

New `Tests/FCPKitDSLTests/FramePositionTests.swift`:

- A `Title` with no position modifier emits **no** `adjust-transform` — regression
  guard for existing output.
- `.position(x: 1920/2, y: 1080/2)` on a 1080p sequence → `position == "0 0"`.
- The fixture formula: on 1920×1080, absolute `(0, 84)` → Y component `7.77778`.
  Assert against the real value from `TestData`.
- `.position(.top)` and `.position(.bottom)` produce symmetric Y values.
- `.position(.center)` → `"0 0"`.
- `.position(x:y:)` with no enclosing format throws `BuildError.missingFrameSize`;
  `.position(.topLeading)` in the same document does **not** throw.
- **Ordering:** a spine of `[clip, transition, clip]` where a clip carries a deferred
  position still emits in that order after resolution.
- `AdjustTransform` round-trips `rotation` and `anchor` (new attributes).

### Acceptance criteria

- `titlesFeaturePairMatchesAfterNormalize` passes unchanged — a structural diff
  against a real Final Cut export is the strongest available parity proof.
- Schema-completeness total does not increase; `rotation`/`anchor` may decrease it.
- Step 0 ordering tests extended to cover post-resolution output.
- Every new public declaration carries a doc comment.

### Open question for Final Cut verification

`.bold()` (the `bold` attribute) and `.fontFace("Bold")` are two different mechanisms
and it is unverified which one Final Cut actually honors for a given family. The
presentation deck should prefer `.fontFace(...)` with a face known-good for its
family, since that is what Final Cut itself writes. `alignment: "justified"` is
included for completeness but is likewise unverified.

---

## Issue 4 — `PresentationDocument`

**Filed as [#38](https://github.com/brightdigit/FCPKit/issues/38)**

**Labels:** `enhancement`, `ready-for-agent`
**Depends on:** Issues 1, 2, 3

### Files

- Create `Sources/FCPKitDSL/PresentationSlide.swift`
- Create `Sources/FCPKitDSL/PresentationDocument.swift`
- **Delete** `Sources/FCPKitDSL/RGBDocument.swift`
- Modify `Tests/FCPKitDSLTests/FCPTimeIntervalTests.swift` — see below

### Placement: library type, thin CLI command

`PresentationDocument` and `PresentationSlide` are **public and shipped in the
library**, so users browsing `FCPKitDSL` can read the showcase and tests can import
it. The executable holds only a thin command that invokes the library type — **not**
a duplicated copy (decision 2026-08-02).

`RGBDocument` is the counter-example to clean up in the same pass. It is currently
duplicated across `Sources/FCPKitDSL/RGBDocument.swift` and
`Sources/fcpxml-dsl/RGBDocument.swift`. **Demo scaffolding belongs only in the CLI**,
so delete the library copy and keep the executable's.

That deletion breaks `Tests/FCPKitDSLTests/FCPTimeIntervalTests.swift`, which imports
the library copy. That test is really about `FCPTimeInterval`, not about
`RGBDocument` — **give it a small local fixture document** rather than moving it to a
CLI test target.

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

| # | Heading | Background | Showcases |
|---|---|---|---|
| 1 | FCPKit | near-black `Color(white: 0.08)` | title positioning |
| 2 | Typed FCPXML model | deep blue | — |
| 3 | Ordered spine, preserved | teal | — |
| 4 | SwiftUI-shaped DSL | purple | alignment-positioned subheading |
| 5 | Resource interning | orange | — |
| 6 | DTD-validated output | green | — |
| 7 | brightdigit/FCPKit | near-black | — |

Use Helvetica so the video reproduces on any machine.

**Show more than cross dissolves.** A deck with seven identical dissolves undersells
the library. Once Issues 7 and 8 land, vary the transitions and apply at least a few
clip modifiers (opacity, blend mode, scale) across the deck so the video demonstrates
range rather than repetition.

Two constraints on that variety:

- The 30-45s target is a **soft** guide, not a hard gate. If showing more capability
  costs a few seconds, take the seconds — but assert on the packer's computed
  duration so the number is never guessed.
- Every effect used must have a UID that is either derivable from the Motion template
  catalog or captured from a real Final Cut export (see Issue 8). Do not invent UIDs.

Until Issues 7 and 8 land, the deck ships with cross dissolves and is revisited
afterward; this issue is not blocked on them.

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

**Filed as [#39](https://github.com/brightdigit/FCPKit/issues/39)**

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

**Keep this command thin.** It parses arguments and invokes
`FCPKitDSL.PresentationDocument`; the deck itself lives in the library (Issue 4). Do
not re-create a copy of the document here — that is exactly the `RGBDocument`
duplication Issue 4 cleans up.

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

## Issue 6 — Share and export the demo, then embed it in the README

**Filed as [#40](https://github.com/brightdigit/FCPKit/issues/40)**

**Labels:** `documentation`, `ready-for-human`
**Depends on:** Issue 5

Human-only; requires Final Cut Pro. This is the **Share and Export** step: generate
the `.fcpxml`, import it, confirm it renders, then use Final Cut's Share → Master File
to produce the `.mp4`. It is manual because Final Cut exposes no scripting verb for
export (see "Why the Final Cut export step is manual" above).

### Procedure

1. `swift run fcpxml-dsl export presentation presentation.fcpxml`
2. `swift run fcpxml-dsl verify-import presentation.fcpxml`
3. Confirm visually in Final Cut that the slides and dissolves render as intended —
   in particular that anchored titles appear over their generator backgrounds.
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
- ~~**Do cross dissolves between two generators behave like dissolves between asset
  clips?**~~ **ANSWERED 2026-08-02: yes.** The `rgb` document (three color solids,
  1s dissolves) imported into Final Cut and rendered correctly — Final Cut accepted
  the T/2 overlap with no objection, and the sequence read `13:00` matching the
  generated `duration="13s"`. The reserved mitigation (extending each generator by
  T/2 per side) is **not needed**. Evidence:
  [manual/typed-generation-gate.md](../manual/typed-generation-gate.md)
  "Generator Dissolve Gate".

Record the outcome of both in `docs/manual/presentation-demo.md` either way — a
negative result is evidence worth keeping.

### Acceptance criteria

- The README shows an inline-playing video and a copy-pasteable snippet.
- No new files at the repo root (per the `AGENTS.md` docs-layout rule).
- `docs/manual/presentation-demo.md` records versions, the sdef rationale, and the
  two verification outcomes.

---

## Issue 7 — Expressive clip modifiers

**Filed as [#33](https://github.com/brightdigit/FCPKit/issues/33)**
**Labels:** `enhancement`, `ready-for-agent`
**Depends on:** nothing (independent of Issues 1-6)

### Problem

`FCPKitDSL` can set duration, color, and anchors, but nothing about how a clip
*looks*. Opacity, blend mode, rotation, scale, and cropping are all in the DTD and
partly in the model, with no DSL surface reaching them. A demo deck without them
undersells what the library can express.

### Scope

`FCPXMLv1_9.dtd` declares these adjustments; the model covers them unevenly:

| DTD element | Attributes | Model status |
|---|---|---|
| `adjust-transform` | `position`, `scale`, `rotation`, `anchor`, `enabled` | `position`/`scale` only |
| `adjust-blend` | `amount`, `mode` | not modeled |
| `adjust-crop` | `mode` + `trim-rect`/`crop-rect` children | partially |

Issue 3 adds `rotation`/`anchor`/`enabled` to `AdjustTransform` as a side effect of
positioning; if Issue 3 has not landed, do it here instead. The two issues must not
both add them — whichever lands second should find them present.

### API

```swift
extension StoryItem {
  /// Sets clip opacity, from 0 (transparent) to 1 (opaque).
  public func opacity(_ value: Double) -> Self
  /// Sets the blend mode, such as `.screen` or `.multiply`.
  public func blendMode(_ mode: BlendMode) -> Self
  /// Rotates the clip in degrees.
  public func rotation(_ degrees: Double) -> Self
  /// Scales the clip; 1.0 is unscaled.
  public func scale(x: Double, y: Double) -> Self
  /// Crops the clip to a trim rectangle.
  public func crop(left: Double, right: Double, top: Double, bottom: Double) -> Self
}
```

`BlendMode` is a public enum over the DTD's `adjust-blend mode` vocabulary. Capture
the exact spelling FCP writes from a real export before finalizing the raw values —
do not guess the strings.

### Constraints

- Emit **nothing** when a modifier is not applied, so existing fixtures stay
  byte-identical. Same rule as Issue 3's positioning.
- These hang off `StoryItem` (Issue 2), so they apply uniformly to clips, generators,
  colors, and titles. If Issue 2 has not landed, scope to `AssetClip` and `Generator`
  and generalize later.
- Keep `CodingKeys` in DTD order per `AGENTS.md`; extend the Step 0 ordering tests.

### Tests

- Each modifier round-trips through decode → encode unchanged.
- An unmodified clip emits no adjustment elements — regression guard.
- Schema-completeness total does not increase.
- A document using every modifier DTD-validates.

### Acceptance criteria

- `swift test` green; schema-completeness at or below baseline.
- `BlendMode` raw values verified against a real Final Cut export, not invented.

---

## Issue 8 — Transition and effect vocabulary

**Filed as [#34](https://github.com/brightdigit/FCPKit/issues/34)**
**Labels:** `enhancement`, `ready-for-agent`
**Depends on:** nothing (independent of Issues 1-6)

### Problem

`TransitionPreset` offers Cross Dissolve and nothing else. Final Cut ships **88
built-in transitions** and over a thousand effects, titles, and generators. The demo
deck is limited to one transition purely by DSL vocabulary.

### The UID problem is smaller than it looks

Effects fall into two classes, and only one needs manual capture:

**1. Motion templates — UID is a path, derivable without any export.** FCP ships the
catalog inside the app bundle:

```
Final Cut Pro.app/Contents/PlugIns/MediaProviders/MotionEffect.fxp/Contents/Resources/
  Templates.localized/{Transitions,Effects,Titles,Generators}.localized/
```

Counts on FCP Creator Studio as of 2026-08-02: **169 `.motr`** (transitions),
**592 `.moti`** (titles), **258 `.moef`** (effects), **116 `.motn`** (generators).
The `Templates.localized/Transitions.localized` tree alone holds 88.

Their `uid` is the template path, exactly as seen in our own fixtures:

```
Gaussian           → …/Effects.localized/Blur.localized/Gaussian.localized/Gaussian.moef
Lower Third Basic  → …/Titles.localized/Social.localized/Lower Third Basic.localized/…moti
```

**2. FxPlug built-ins — opaque GUIDs, must be captured from a real export.** Only
these need a fixture. Known from `Tests/FCPKitTests/TestData`:

| Name | UID |
|---|---|
| Cross Dissolve | `FxPlug:4731E73A-8DAC-4113-9A30-AE85B1761265` |
| Drop Shadow | `FxPlug:9C13F991-BC99-4DC8-B150-381D7CCE183B` |
| Green Screen Keyer | `FxPlug:41122549-B8A6-470E-94DA-211294D20B62` |
| Color Correction | `FFColorCorrectionHDREffect` |
| Audio Crossfade | `FFAudioTransition` |

### Work

- Expand `TransitionPreset` with the Motion-template transitions, deriving each `uid`
  from its catalog path.
- Add an `EffectPreset` equivalent for `.moef` effects and `.moti` titles.
- Keep the five known FxPlug/FF UIDs above as explicit constants.
- **Do not invent UIDs.** Any effect whose UID is neither path-derivable nor in the
  table above is out of scope until someone captures a fixture for it.

### Caveat to document

These paths live inside the Final Cut Pro app bundle and **can move between
releases**. The generated presets are a snapshot to validate on import, not a stable
contract. Record the FCP version the catalog was read from, and re-verify after a
Final Cut upgrade. Localized path components (`.localized` directories) are another
fragility: confirm whether FCP accepts the base-language path on a non-English system
before claiming portability.

### Tests

- A document using a template-derived transition DTD-validates.
- Effect interning still dedups when several slides share a transition.
- The five FxPlug constants match the fixture values exactly.

### Acceptance criteria

- `swift test` green.
- A generated preset list is checked in with the FCP version it came from.
- At least one non-Cross-Dissolve transition round-trips through Final Cut import
  (this one gate needs a human with FCP).

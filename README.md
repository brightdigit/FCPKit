# FCPKit

A Swift package for reading, mutating, and generating Final Cut Pro FCPXML
through typed Codable models (XMLCoder).

## Features

- **Typed FCPXML model**: Schema-shaped Swift types for the explicitly tested
  vocabulary (currently evidenced against checked-in FCPXML 1.13 fixtures)
- **Best-effort editing**: Supported content round-trips; unsupported XML may be
  omitted on encode (see [ADR 0001](docs/adr/0001-supported-schema-and-best-effort-editing.md))
- **Loss diagnostics**: `fcpxml-diff` reports dropped elements, attributes, and
  text after decode/re-encode
- **Typed generation**: Public initializers and `MulticamXMLBuilder` construct
  documents without raw XML templates
- **Version inspection**: Callers can classify declared versions as supported,
  older, newer, or malformed without treating a version string as full coverage

## Installation

Add FCPKit to your Swift package dependencies in `Package.swift`:

```swift
dependencies: [
    .package(url: "path/to/FCPKit", from: "1.0.0")
]
```

## Usage

### Basic Parsing

```swift
import FCPKit

let parser = FCPXMLParser()

// Parse from file
let fcpxml = try parser.parse(fileURL: URL(fileURLWithPath: "project.fcpxml"))

// Inspect declared version compatibility (does not imply full schema coverage)
print(fcpxml.versionCompatibility) // .supported, .older, .newer, ...

// Parse from string
let xmlString = "<?xml version=\"1.0\"?>..."
let fromString = try parser.parse(xmlString: xmlString)

// Parse from data
let data = try Data(contentsOf: url)
let fromData = try parser.parse(data: data)
```

### Accessing Data

```swift
print("FCPXML Version: \(fcpxml.version)")

if let resources = fcpxml.resources {
    print("Assets: \(resources.assets?.count ?? 0)")
    print("Formats: \(resources.formats?.count ?? 0)")
    print("Media: \(resources.media?.count ?? 0)")
}

if let library = fcpxml.library {
    print("Library location: \(library.location ?? "Unknown")")
    print("Events: \(library.events?.count ?? 0)")
}
```

### Typed Construction

```swift
import FCPKit

let document = FCPXML(
    version: FCPXMLVersion.supportedGenerationVersion.rawValue,
    resources: Resources(
        formats: [
            Format(
                id: "r1",
                name: "FFVideoFormat1920x1080p24",
                frameDuration: "1/24s",
                width: "1920",
                height: "1080",
                colorSpace: "1-1-1 (Rec. 709)"
            )
        ]
    ),
    library: Library(
        location: "file:///Users/Shared/Generated.fcpbundle/",
        events: [
            Event(name: "Typed Event", uid: "EVENT-UID")
        ]
    )
)

let parser = FCPXMLParser()
try parser.write(document, to: URL(fileURLWithPath: "output.fcpxml"))
```

Mutate an existing spine `asset-clip` with the FeaturePairs-shaped helpers:

```swift
var clip: AssetClip = /* from document */
clip.addMarker(name: "Cue", at: "5s")
clip.assignMusicRole()
try clip.setConstantSpeed(percent: 50, mediaDuration: "10s")
// Update parent sequence.duration when timeline length must change.
```

Multicam split-screen documents can also be built from two `VideoMetadata`
values via `FCPKitMediaTools.MulticamXMLBuilder` (typed encode; no smart
collections).

### Scripting inspector (macOS)

`FCPKitScripting` is a read-only ScriptingBridge inspector for the running Final
Cut Pro application (libraries → events → projects/sequences). It shares
`FCPTime` with the Codable model and does not automate export.

```swift
import FCPKitScripting

if FCPApplication.isFinalCutRunning() {
    let inspector = FCPLibraryInspector()
    let libraries = try inspector.libraries()
    for library in libraries {
        print(library.name, library.events.count)
    }
}
```

macOS apps that call into `FCPKitScripting` must declare
`NSAppleEventsUsageDescription` in `Info.plist` (explaining why the app needs to
control Final Cut Pro) and enable the
`com.apple.security.automation.apple-events` entitlement in the app target's
entitlements file. Without both, ScriptingBridge calls fail at runtime with a
sandbox/TCC error.

### Encoding Back to XML

```swift
let xmlString = try parser.encodeToString(fcpxml)
let data = try parser.encode(fcpxml)
try parser.write(fcpxml, to: URL(fileURLWithPath: "output.fcpxml"))
```

## Supported Vocabulary

FCPKit models the elements exercised by the checked-in fixtures and generation
tests, including resources, library/event/project/sequence, multicam,
transforms, crop, titles, transitions, parameters, and related timeline
structures. Decode success alone is not complete support; prefer
schema-completeness and focused round-trip tests.

`smart-collection` remains decodable when present in real exports. Generators
do not emit smart collections.

## Error Handling

```swift
do {
    let fcpxml = try parser.parse(fileURL: url)
    // Process FCPXML
} catch FCPXMLError.invalidXMLString {
    print("Invalid XML string provided")
} catch FCPXMLError.encodingFailed {
    print("Failed to encode FCPXML")
} catch FCPXMLError.unsupportedVersion(let version) {
    print("Malformed version declaration: \(version)")
} catch FCPXMLError.fileNotFound {
    print("FCPXML file not found")
} catch {
    print("Parsing error: \(error)")
}
```

## Requirements

- Swift 6.1+
- macOS 13+, iOS 16+, tvOS 16+, watchOS 9+
- XMLCoder 0.17.0+

## Testing

Run:

```bash
swift test
swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData \
  --fail-if-total-exceeds 0
```

Checked-in real exports live under `Tests/FCPKitTests/TestData/` (FCPXML 1.13).
A zero-loss report is a regression signal for those fixtures, not proof of
complete schema coverage. Roadmap and remaining human evidence work are in
[`docs/NEXT_STEPS.md`](docs/NEXT_STEPS.md).

## License

This package is provided as-is for educational and development purposes.

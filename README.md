# FCPKit

A Swift Package that uses XMLCoder to create Codable types based on the Final Cut Pro XML specification.

## Features

- **Complete FCPXML Support**: Handles FCPXML versions 1.10+ with comprehensive element coverage
- **XMLCoder Integration**: Uses XMLCoder for robust XML parsing and encoding
- **Swift 6.1 Compatible**: Built with modern Swift language features
- **Real-world Tested**: Validated against actual FCPXML files from Final Cut Pro
- **Type Safe**: Full Swift type safety with Codable structs for all FCPXML elements

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

// Parse from string
let xmlString = "<?xml version=\"1.0\"?>..."
let fcpxml = try parser.parse(xmlString: xmlString)

// Parse from data
let data = Data(contentsOf: url)
let fcpxml = try parser.parse(data: data)
```

### Accessing Data

```swift
// Access basic project info
print("FCPXML Version: \(fcpxml.version)")

// Access resources
if let resources = fcpxml.resources {
    print("Assets: \(resources.assets?.count ?? 0)")
    print("Formats: \(resources.formats?.count ?? 0)")
    print("Media: \(resources.media?.count ?? 0)")
}

// Access library structure
if let library = fcpxml.library {
    print("Library location: \(library.location ?? "Unknown")")
    print("Events: \(library.events?.count ?? 0)")
    print("Smart Collections: \(library.smartCollections?.count ?? 0)")
}
```

### Encoding Back to XML

```swift
// Encode to XML string
let xmlString = try parser.encodeToString(fcpxml)

// Encode to Data
let data = try parser.encode(fcpxml)

// Write to file
try parser.write(fcpxml, to: URL(fileURLWithPath: "output.fcpxml"))
```

## Supported FCPXML Elements

FCPKit supports all major FCPXML elements including:

### Core Elements
- `fcpxml` - Root element with version
- `resources` - Asset definitions and formats
- `library` - Project organization
- `event` - Event containers
- `project` - Project definitions
- `sequence` - Timeline sequences

### Media Elements
- `asset` - Media asset references
- `media` - Complex media definitions
- `format` - Video/audio format specifications
- `media-rep` - Media representations

### Timeline Elements
- `spine` - Main timeline spine
- `clip` - Basic clips
- `mc-clip` - Multicam clips
- `ref-clip` - Reference clips
- `asset-clip` - Asset-based clips
- `sync-clip` - Synchronized clips
- `gap` - Timeline gaps

### Advanced Elements
- `multicam` - Multicam definitions
- `mc-angle` - Multicam angles
- `mc-source` - Multicam sources
- `video` - Video layers
- `filter-video` - Video filters
- `smart-collection` - Smart collections
- `conform-rate` - Frame rate conforming
- `time-map` - Time mapping
- `adjust-transform` - Transform adjustments
- `adjust-crop` - Crop adjustments
- `audio-channel-source` - Audio routing

## Error Handling

FCPKit provides comprehensive error handling:

```swift
do {
    let fcpxml = try parser.parse(fileURL: url)
    // Process FCPXML
} catch FCPXMLError.invalidXMLString {
    print("Invalid XML string provided")
} catch FCPXMLError.encodingFailed {
    print("Failed to encode FCPXML")
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

The package includes comprehensive tests covering:

### **Basic Tests** (5 tests)
- Basic FCPXML parsing and encoding
- Round-trip encoding/decoding
- Error handling scenarios
- Invalid XML handling

### **Real-world FCPXML Tests** (3 tests)
- **Interview.fcpxml**: Complex multicam project with smart collections
- **UntitledXML.fcpxml**: Advanced editing with sync clips, transforms, and filters
- Element coverage validation across both files

### **Schema Completeness Tests** (5 tests)
- Title and text elements
- Audio processing elements  
- Transition effects
- Generator elements
- Marker and metadata support

### **Test Data**
The package includes real FCPXML files as test examples:
- `Tests/FCPKitTests/TestData/Interview.fcpxml` - Multicam interview project
- `Tests/FCPKitTests/TestData/UntitledXML.fcpxml` - Complex editing project

**Total: 13 passing tests** validating comprehensive FCPXML support

Run tests with:
```bash
swift test
```

### **Validation Results**
✅ Successfully parses FCPXML v1.13 files  
✅ Handles 5+ media elements and 5+ smart collections  
✅ Supports multicam, sync clips, transforms, filters  
✅ Covers titles, audio, transitions, generators, markers

## License

This package is provided as-is for educational and development purposes.
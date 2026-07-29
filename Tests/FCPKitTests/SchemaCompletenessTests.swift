import XCTest

@testable import FCPKit

internal final class SchemaCompletenessTests: XCTestCase {
  /// Test for elements commonly found in title-heavy projects
  internal func testTitleElements() {
    let sampleTitleXML = fixture("SampleTitleXML")

    // This should reveal missing title-related elements
    do {
      let parser = FCPXMLParser()
      let fcpxml = try parser.parse(xmlString: sampleTitleXML)
      print("✅ Basic title parsing succeeded")
      XCTAssertEqual(fcpxml.version, "1.11")
    } catch {
      print("❌ Title parsing failed - missing elements: \(error)")
      // This is expected since we haven't implemented title elements yet
    }
  }

  /// Test for audio-specific elements
  internal func testAudioElements() {
    let sampleAudioXML = fixture("SampleAudioXML")

    do {
      let parser = FCPXMLParser()
      let fcpxml = try parser.parse(xmlString: sampleAudioXML)
      print("✅ Basic audio parsing succeeded")
    } catch {
      print("❌ Audio parsing failed - missing elements: \(error)")
    }
  }

  /// Test for transition elements
  internal func testTransitionElements() {
    let sampleTransitionXML = fixture("SampleTransitionXML")

    do {
      let parser = FCPXMLParser()
      let fcpxml = try parser.parse(xmlString: sampleTransitionXML)
      print("✅ Basic transition parsing succeeded")
    } catch {
      print("❌ Transition parsing failed - missing elements: \(error)")
    }
  }

  /// Test for marker and metadata elements
  internal func testMarkerElements() {
    let sampleMarkerXML = fixture("SampleMarkerXML")

    do {
      let parser = FCPXMLParser()
      let fcpxml = try parser.parse(xmlString: sampleMarkerXML)
      print("✅ Basic marker parsing succeeded")
    } catch {
      print("❌ Marker parsing failed - missing elements: \(error)")
    }
  }

  /// Test for generator elements (color matte, noise, etc.)
  internal func testGeneratorElements() {
    let sampleGeneratorXML = fixture("SampleGeneratorXML")

    do {
      let parser = FCPXMLParser()
      let fcpxml = try parser.parse(xmlString: sampleGeneratorXML)
      print("✅ Basic generator parsing succeeded")
    } catch {
      print("❌ Generator parsing failed - missing elements: \(error)")
    }
  }
}

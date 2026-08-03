import XCTest

@testable import FCPKit

internal final class FCPKitTests: XCTestCase {
  internal let sampleFCPXML = fixture("SampleFCPXML")

  internal func testParseBasicFCPXML() throws {
    let parser = FCPXMLParser()
    let fcpxml = try parser.parse(xmlString: sampleFCPXML)

    XCTAssertEqual(fcpxml.version, "1.10")
    XCTAssertNotNil(fcpxml.resources)
    XCTAssertNotNil(fcpxml.library)

    let resources = try XCTUnwrap(fcpxml.resources)
    XCTAssertEqual(resources.formats?.count, 1)
    XCTAssertEqual(resources.assets?.count, 1)

    let format = try XCTUnwrap(resources.formats?.first)
    XCTAssertEqual(format.id, "r1")
    XCTAssertEqual(format.name, "FFVideoFormat1080p2997")
    XCTAssertEqual(format.width, "1920")
    XCTAssertEqual(format.height, "1080")

    let asset = try XCTUnwrap(resources.assets?.first)
    XCTAssertEqual(asset.id, "r2")
    XCTAssertEqual(asset.name, "sample_video")
    XCTAssertEqual(asset.uid, "1234567890")
    XCTAssertEqual(asset.hasVideo, "1")
    XCTAssertEqual(asset.hasAudio, "1")
    XCTAssertEqual(asset.audioChannels, "2")

    let library = try XCTUnwrap(fcpxml.library)
    XCTAssertEqual(library.events?.count, 1)

    let event = try XCTUnwrap(library.events?.first)
    XCTAssertEqual(event.name, "Test Event")
    XCTAssertEqual(event.uid, "event123")
    XCTAssertEqual(event.projects?.count, 1)

    let project = try XCTUnwrap(event.projects?.first)
    XCTAssertEqual(project.name, "Test Project")
    XCTAssertEqual(project.uid, "project456")
    XCTAssertNotNil(project.sequence)

    let sequence = try XCTUnwrap(project.sequence)
    XCTAssertEqual(sequence.format, "r1")
    XCTAssertEqual(sequence.duration, "7200s")
    XCTAssertEqual(sequence.tcStart, "0s")
    XCTAssertNotNil(sequence.spine)

    let spine = try XCTUnwrap(sequence.spine)
    XCTAssertEqual(spine.clips?.count, 1)

    let clip = try XCTUnwrap(spine.clips?.first)
    XCTAssertEqual(clip.name, "sample_video")
    XCTAssertEqual(clip.ref, "r2")
    XCTAssertEqual(clip.offset, "0s")
    XCTAssertEqual(clip.duration, "7200s")
  }

  internal func testEncodeToXML() throws {
    let parser = FCPXMLParser()
    let fcpxml = try parser.parse(xmlString: sampleFCPXML)
    let xmlString = try parser.encodeToString(fcpxml)

    XCTAssertTrue(xmlString.contains("<fcpxml version=\"1.10\">"))
    XCTAssertFalse(xmlString.contains("<version>"))
    XCTAssertTrue(xmlString.contains("<format id=\"r1\""))
    XCTAssertTrue(xmlString.contains("<event name=\"Test Event\""))
    XCTAssertTrue(xmlString.contains("resources"))
    XCTAssertTrue(xmlString.contains("library"))
  }

  internal func testRoundTripEncoding() throws {
    let parser = FCPXMLParser()
    let originalFCPXML = try parser.parse(xmlString: sampleFCPXML)
    let encodedXML = try parser.encodeToString(originalFCPXML)
    let decodedFCPXML = try parser.parse(xmlString: encodedXML)

    XCTAssertEqual(originalFCPXML.version, decodedFCPXML.version)
    XCTAssertEqual(
      originalFCPXML.resources?.formats?.count, decodedFCPXML.resources?.formats?.count
    )
    XCTAssertEqual(originalFCPXML.resources?.assets?.count, decodedFCPXML.resources?.assets?.count)
    XCTAssertEqual(originalFCPXML.library?.events?.count, decodedFCPXML.library?.events?.count)
  }

  internal func testDataElementTextContentRoundTrips() throws {
    let xml = fixture("DataElementTextContentRoundTripsXml")
    let parser = FCPXMLParser()
    let model = try parser.parse(xmlString: xml)

    let value = model.library?.events?.first?.projects?.first?.sequence?
      .spine?.assetClips?.first?.filterVideo?.first?.data?.first?.value
    XCTAssertEqual(value, "PAYLOAD")
    let encoded = try parser.encodeToString(model)
    let reparsed = try parser.parse(xmlString: encoded)
    let reparsedValue = reparsed.library?.events?.first?.projects?.first?.sequence?
      .spine?.assetClips?.first?.filterVideo?.first?.data?.first?.value
    XCTAssertEqual(reparsedValue, "PAYLOAD")
  }

  internal func testInvalidXMLHandling() {
    let parser = FCPXMLParser()
    let invalidXML = "invalid xml content"

    XCTAssertThrowsError(try parser.parse(xmlString: invalidXML))
  }

  internal func testEmptyXMLHandling() {
    let parser = FCPXMLParser()
    let emptyXML = ""

    XCTAssertThrowsError(try parser.parse(xmlString: emptyXML))
  }
}

import XCTest
@testable import FCPKit

final class FCPKitTests: XCTestCase {
    
    let sampleFCPXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE fcpxml>
    <fcpxml version="1.10">
        <resources>
            <format id="r1" name="FFVideoFormat1080p2997" frameDuration="1001/30000s" width="1920" height="1080" colorSpace="1-1-1 (Rec. 709)"/>
            <asset id="r2" name="sample_video" uid="1234567890" src="file:///Users/test/sample_video.mov" start="3600s" duration="7200s" hasVideo="1" hasAudio="1" audioChannels="2" audioRate="48000"/>
        </resources>
        <library>
            <event name="Test Event" uid="event123">
                <project name="Test Project" uid="project456">
                    <sequence format="r1" duration="7200s" tcStart="0s" tcFormat="NDF">
                        <spine>
                            <clip name="sample_video" ref="r2" offset="0s" duration="7200s" start="3600s" tcFormat="NDF"/>
                        </spine>
                    </sequence>
                </project>
            </event>
        </library>
    </fcpxml>
    """
    
    func testParseBasicFCPXML() throws {
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
    
    func testEncodeToXML() throws {
        let parser = FCPXMLParser()
        let fcpxml = try parser.parse(xmlString: sampleFCPXML)
        let xmlString = try parser.encodeToString(fcpxml)
        
        XCTAssertTrue(xmlString.contains("fcpxml"))
        XCTAssertTrue(xmlString.contains("version"))
        XCTAssertTrue(xmlString.contains("resources"))
        XCTAssertTrue(xmlString.contains("library"))
    }
    
    func testRoundTripEncoding() throws {
        let parser = FCPXMLParser()
        let originalFCPXML = try parser.parse(xmlString: sampleFCPXML)
        let encodedXML = try parser.encodeToString(originalFCPXML)
        let decodedFCPXML = try parser.parse(xmlString: encodedXML)
        
        XCTAssertEqual(originalFCPXML.version, decodedFCPXML.version)
        XCTAssertEqual(originalFCPXML.resources?.formats?.count, decodedFCPXML.resources?.formats?.count)
        XCTAssertEqual(originalFCPXML.resources?.assets?.count, decodedFCPXML.resources?.assets?.count)
        XCTAssertEqual(originalFCPXML.library?.events?.count, decodedFCPXML.library?.events?.count)
    }
    
    func testInvalidXMLHandling() {
        let parser = FCPXMLParser()
        let invalidXML = "invalid xml content"
        
        XCTAssertThrowsError(try parser.parse(xmlString: invalidXML))
    }
    
    func testEmptyXMLHandling() {
        let parser = FCPXMLParser()
        let emptyXML = ""
        
        XCTAssertThrowsError(try parser.parse(xmlString: emptyXML))
    }
}
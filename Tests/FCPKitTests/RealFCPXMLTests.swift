import XCTest
@testable import FCPKit

final class RealFCPXMLTests: XCTestCase {
    
    func testParseInterviewFCPXMLFile() throws {
        let bundle = Bundle.module
        guard let fileURL = bundle.url(forResource: "Interview", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("Interview FCPXML test file not found")
        }
        
        let parser = FCPXMLParser()
        let fcpxml = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(fcpxml.version, "1.13")
        XCTAssertNotNil(fcpxml.resources)
        XCTAssertNotNil(fcpxml.library)
        
        let resources = try XCTUnwrap(fcpxml.resources)
        XCTAssertNotNil(resources.formats)
        XCTAssertNotNil(resources.assets)
        XCTAssertNotNil(resources.media)
        
        let library = try XCTUnwrap(fcpxml.library)
        XCTAssertNotNil(library.events)
        XCTAssertNotNil(library.smartCollections)
        XCTAssertNotNil(library.location)
        
        // Test that we have parsed media elements with sequences
        let mediaElements = try XCTUnwrap(resources.media)
        XCTAssertFalse(mediaElements.isEmpty)
        
        let firstMedia = try XCTUnwrap(mediaElements.first)
        XCTAssertEqual(firstMedia.name, "Interview")
        XCTAssertNotNil(firstMedia.sequence)
        
        // Test that we have parsed smart collections
        let smartCollections = try XCTUnwrap(library.smartCollections)
        XCTAssertFalse(smartCollections.isEmpty)
        XCTAssertTrue(smartCollections.contains { $0.name == "Projects" })
        
        print("✅ Successfully parsed Interview FCPXML file with version \(fcpxml.version)")
        print("✅ Found \(resources.media?.count ?? 0) media elements")
        print("✅ Found \(smartCollections.count) smart collections")
    }
    
    func testParseUntitledXMLFCPXMLFile() throws {
        let bundle = Bundle.module
        guard let fileURL = bundle.url(forResource: "UntitledXML", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("UntitledXML FCPXML test file not found")
        }
        
        let parser = FCPXMLParser()
        let fcpxml = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(fcpxml.version, "1.13")
        XCTAssertNotNil(fcpxml.resources)
        
        let resources = try XCTUnwrap(fcpxml.resources)
        XCTAssertNotNil(resources.formats)
        XCTAssertNotNil(resources.media)
        
        // Test that we have parsed media elements
        let mediaElements = try XCTUnwrap(resources.media)
        XCTAssertFalse(mediaElements.isEmpty)
        
        print("✅ Successfully parsed UntitledXML FCPXML file with version \(fcpxml.version)")
        print("✅ Found \(resources.media?.count ?? 0) media elements")
        print("✅ Found \(resources.formats?.count ?? 0) format definitions")
    }
    
    func testFCPXMLElementCoverage() throws {
        let bundle = Bundle.module
        
        // Test Interview FCPXML elements
        guard let interviewURL = bundle.url(forResource: "Interview", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("Interview FCPXML test file not found")
        }
        
        let interviewData = try Data(contentsOf: interviewURL)
        let interviewString = String(data: interviewData, encoding: .utf8)!
        
        XCTAssertTrue(interviewString.contains("mc-clip"))
        XCTAssertTrue(interviewString.contains("mc-source"))
        XCTAssertTrue(interviewString.contains("multicam"))
        XCTAssertTrue(interviewString.contains("ref-clip"))
        XCTAssertTrue(interviewString.contains("asset-clip"))
        XCTAssertTrue(interviewString.contains("media-rep"))
        XCTAssertTrue(interviewString.contains("smart-collection"))
        
        // Test UntitledXML FCPXML elements
        guard let untitledURL = bundle.url(forResource: "UntitledXML", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("UntitledXML FCPXML test file not found")
        }
        
        let untitledData = try Data(contentsOf: untitledURL)
        let untitledString = String(data: untitledData, encoding: .utf8)!
        
        XCTAssertTrue(untitledString.contains("sync-clip"))
        XCTAssertTrue(untitledString.contains("adjust-transform"))
        XCTAssertTrue(untitledString.contains("adjust-crop"))
        XCTAssertTrue(untitledString.contains("filter-video"))
        XCTAssertTrue(untitledString.contains("conform-rate"))
        XCTAssertTrue(untitledString.contains("timeMap"))
        
        print("✅ FCPXML files contain comprehensive element coverage")
        print("✅ Interview file: multicam, smart collections, media references")
        print("✅ UntitledXML file: sync clips, transforms, filters, time mapping")
    }
}
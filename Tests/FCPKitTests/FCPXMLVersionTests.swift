import FCPKit
import XCTest

final class FCPXMLVersionTests: XCTestCase {
    func testCompatibilityClassifiesSupportedOlderNewerAndMalformed() {
        let parser = FCPXMLParser()

        XCTAssertEqual(parser.compatibility(ofVersion: "1.13"), .supported)
        XCTAssertEqual(parser.compatibility(ofVersion: "1.12"), .older)
        XCTAssertEqual(parser.compatibility(ofVersion: "1.10"), .older)
        XCTAssertEqual(parser.compatibility(ofVersion: "1.14"), .newer)
        XCTAssertEqual(parser.compatibility(ofVersion: "2.0"), .newer)
        XCTAssertEqual(parser.compatibility(ofVersion: "latest"), .malformed)
        XCTAssertEqual(parser.compatibility(ofVersion: ""), .malformed)
        XCTAssertEqual(parser.compatibility(ofVersion: "1.13-beta"), .malformed)
    }

    func testParseWithCompatibilityReportsDocumentVersion() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.13">
            <resources/>
        </fcpxml>
        """
        let data = try XCTUnwrap(xml.data(using: .utf8))
        let parser = FCPXMLParser()
        let result = try parser.parseWithCompatibility(data: data)
        XCTAssertEqual(result.document.version, "1.13")
        XCTAssertEqual(result.compatibility, .supported)
        XCTAssertEqual(result.document.versionCompatibility, .supported)
    }

    func testParseRequiringWellFormedVersionRejectsMalformed() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="not-a-version">
            <resources/>
        </fcpxml>
        """
        let data = try XCTUnwrap(xml.data(using: .utf8))
        let parser = FCPXMLParser()

        XCTAssertThrowsError(try parser.parseRequiringWellFormedVersion(data: data)) { error in
            guard case FCPXMLError.unsupportedVersion(let version) = error else {
                return XCTFail("Expected unsupportedVersion, got \(error)")
            }
            XCTAssertEqual(version, "not-a-version")
        }

        // Newer versions remain best-effort under the well-formed policy.
        let newer = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.14">
            <resources/>
        </fcpxml>
        """
        let newerData = try XCTUnwrap(newer.data(using: .utf8))
        let newerDocument = try parser.parseRequiringWellFormedVersion(data: newerData)
        XCTAssertEqual(newerDocument.versionCompatibility, .newer)
    }

    func testGenerationBaselineMatchesSupportedVersion() {
        XCTAssertEqual(FCPXMLVersion.supportedGenerationVersion.rawValue, "1.13")
        XCTAssertTrue(FCPXMLVersion.testedFixtureVersions.contains(.supportedGenerationVersion))
        XCTAssertTrue(FCPXMLVersion.testedFixtureVersions.contains(FCPXMLVersion("1.14")))
        // 1.14 is fixture-tested but still newer than the generation baseline.
        XCTAssertEqual(FCPXMLVersion("1.14").compatibility(), .newer)
    }
}

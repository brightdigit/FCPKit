import FCPXMLDiff
import Foundation
import XCTest

final class DTDValidationTests: XCTestCase {
    func testDTDLocatorFindsBundled114WhenFinalCutInstalled() throws {
        let locator = FCPXMLDTDLocator()
        guard let dtd = locator.dtdURL(forVersion: "1.14") else {
            throw XCTSkip("Final Cut Pro DTD not installed on this machine")
        }
        XCTAssertTrue(dtd.lastPathComponent.contains("1_14"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dtd.path))
    }

    func testValidateFeaturePairAgainstLocalDTD() throws {
        let locator = FCPXMLDTDLocator()
        guard let dtd = locator.dtdURL(forVersion: "1.14") else {
            throw XCTSkip("Final Cut Pro DTD not installed on this machine")
        }
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("FeaturePairs/markers/after.fcpxml")
        let data = try Data(contentsOf: url)
        let report = try FCPXMLDTDValidator(locator: locator).validate(
            data: data,
            sourcePath: url.path,
            dtdURL: dtd
        )
        XCTAssertEqual(report.fcpxmlVersion, "1.14")
        XCTAssertEqual(report.dtdPath, dtd.path)
        // Real FCP exports should validate against the bundled DTD when available.
        XCTAssertTrue(report.isValid, "Unexpected DTD issues: \(report.issues)")
    }

    func testValidateThrowsWhenDTDMissing() throws {
        let emptyLocator = FCPXMLDTDLocator(searchRoots: [
            URL(fileURLWithPath: "/tmp/fcpxml-missing-dtds", isDirectory: true),
        ])
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <fcpxml version="1.14"><resources/></fcpxml>
        """
        let data = try XCTUnwrap(xml.data(using: .utf8))
        XCTAssertThrowsError(
            try FCPXMLDTDValidator(locator: emptyLocator).validate(data: data)
        ) { error in
            guard case FCPXMLValidationError.dtdNotFound(let version) = error else {
                return XCTFail("Expected dtdNotFound, got \(error)")
            }
            XCTAssertEqual(version, "1.14")
        }
    }
}

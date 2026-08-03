import FCPXMLDiff
import XCTest
import XMLCoder

@testable import FCPKit

extension FCPXMLDiffTests {
  internal func testCompleteSyntheticModelHasNoRoundTripLoss() throws {
    let xml = fixture("CompleteSyntheticModelHasNoRoundTripLossXml")
    let originalData = try XCTUnwrap(xml.data(using: .utf8))
    let modelParser = FCPXMLParser()
    let model = try modelParser.parse(data: originalData)
    let encodedData = try modelParser.encode(model)

    let differences = engine.compare(
      try parser.parse(originalData),
      try parser.parse(encodedData),
      mode: .completeness
    )

    XCTAssertEqual(differences, [])
  }

  internal func testRealTransitionPayloadRoundTripsWithoutStructuralLoss() throws {
    let url = try XCTUnwrap(
      Bundle.module.url(
        forResource: "UntitledXML",
        withExtension: "fcpxml",
        subdirectory: "TestData"
      )
    )

    let report = try SchemaCompletenessAnalyzer().analyze(fileURLs: [url])
    let findings = try XCTUnwrap(report.files.first).findings

    XCTAssertFalse(findings.contains { $0.path.contains("/transition/") })
  }

  internal func testObservedHeterogeneousParameterChildOrderSurvivesRoundTrip() throws {
    let url = try XCTUnwrap(
      Bundle.module.url(
        forResource: "UntitledXML",
        withExtension: "fcpxml",
        subdirectory: "TestData"
      )
    )
    let modelParser = FCPXMLParser()
    let model = try modelParser.parse(fileURL: url)
    let encodedTree = try parser.parse(modelParser.encode(model))
    let animatedVolume = try XCTUnwrap(
      descendants(of: encodedTree).first {
        $0.name == "param"
          && $0.attributes["name"] == "amount"
          && $0.children.count == 3
      }
    )

    XCTAssertEqual(
      animatedVolume.children.map(\.name),
      [
        "fadeIn", "fadeOut", "keyframeAnimation",
      ]
    )
    XCTAssertEqual(
      animatedVolume.children.last?.children.map(\.name),
      [
        "keyframe", "keyframe", "keyframe",
      ]
    )
  }
}

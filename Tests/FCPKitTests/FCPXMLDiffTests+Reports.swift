import FCPXMLDiff
import XCTest
import XMLCoder

@testable import FCPKit

extension FCPXMLDiffTests {
  internal func testReportRenderingIsDeterministic() throws {
    let report = SchemaCompletenessReport(
      formatVersion: 1,
      normalization: ["rule"],
      totals: SchemaCompletenessSummary(findings: [
        FCPXMLDifference(kind: .droppedElement, path: "/fcpxml/missing", count: 2)
      ]),
      aggregateFindings: [
        FCPXMLDifference(kind: .droppedElement, path: "/fcpxml/missing", count: 2)
      ],
      files: []
    )
    let renderer = SchemaCompletenessReportRenderer()

    XCTAssertEqual(renderer.markdown(report), renderer.markdown(report))
    XCTAssertEqual(try renderer.jsonData(report), try renderer.jsonData(report))
  }

  internal func testCheckedInFixtureBaselineAndRepresentativePaths() throws {
    let urls = try ["Both-Multicam", "Interview", "UntitledXML"].map {
      try XCTUnwrap(
        Bundle.module.url(forResource: $0, withExtension: "fcpxml", subdirectory: "TestData")
      )
    }
    let report = try SchemaCompletenessAnalyzer().analyze(fileURLs: urls)

    XCTAssertEqual(report.totals.droppedElements, 0)
    XCTAssertEqual(report.totals.droppedAttributes, 0)
    XCTAssertEqual(report.totals.droppedText, 0)
    XCTAssertEqual(report.totals.total, 0)
    XCTAssertEqual(
      Dictionary(uniqueKeysWithValues: report.files.map { ($0.path, $0.summary.total) }),
      ["Both-Multicam.fcpxml": 0, "Interview.fcpxml": 0, "UntitledXML.fcpxml": 0]
    )
    XCTAssertTrue(
      report.aggregateFindings.allSatisfy {
        $0.path.hasPrefix("/fcpxml/library/event/")
      }
    )
    XCTAssertFalse(
      report.aggregateFindings.contains {
        $0.path.contains("/param")
          || $0.path.contains("/keyframe")
          || $0.path.contains("/fadeIn")
          || $0.path.contains("/fadeOut")
      }
    )
    XCTAssertFalse(report.aggregateFindings.contains { $0.path.contains("/title/") })
    XCTAssertEqual(report.aggregateFindings, [])

    let renderer = SchemaCompletenessReportRenderer()
    XCTAssertEqual(renderer.markdown(report), renderer.markdown(report))
    XCTAssertEqual(try renderer.jsonData(report), try renderer.jsonData(report))
  }

  internal func testCompletenessAcceptanceRejectsOnlyTotalsAboveBaseline() {
    let acceptance = SchemaCompletenessAcceptance(maximumTotalLoss: 10)
    let accepted = report(with: 10)
    let rejected = report(with: 11)

    XCTAssertTrue(acceptance.accepts(accepted))
    XCTAssertFalse(acceptance.accepts(rejected))
  }

  internal func testRawPairReportsAddedRemovedAndChangedStructures() throws {
    let before = Data(fixture("RawPairReportsAddedRemovedAndChangedStructuresBefore").utf8)
    let after = Data(fixture("RawPairReportsAddedRemovedAndChangedStructuresAfter").utf8)

    let report = try RawPairAnalyzer().analyze(beforeData: before, afterData: after)

    XCTAssertTrue(
      report.findings.contains { $0.kind == .changedAttribute && $0.path.hasSuffix("/event/@name") }
    )
    XCTAssertTrue(
      report.findings.contains {
        $0.kind == .changedAttribute && $0.path.hasSuffix("/marker/@value")
      }
    )
    XCTAssertTrue(
      report.findings.contains { $0.kind == .droppedElement && $0.path.hasSuffix("/note") }
    )
    XCTAssertTrue(
      report.findings.contains { $0.kind == .addedElement && $0.path.hasSuffix("/keyword") }
    )
  }

  internal func testRawPairNormalizationIdentityFilteringAndRenderingAreDeterministic() throws {
    let before = Data(
      fixture("RawPairNormalizationIdentityFilteringAndRenderingAreDeterministicBefore").utf8
    )
    let after = Data(
      fixture("RawPairNormalizationIdentityFilteringAndRenderingAreDeterministicAfter").utf8
    )
    let analyzer = RawPairAnalyzer()
    let report = try analyzer.analyze(
      beforeData: before,
      afterData: after,
      pathFilter: "/fcpxml/library/marker"
    )

    XCTAssertEqual(
      report.findings,
      [
        FCPXMLDifference(kind: .changedAttribute, path: "/fcpxml/library/marker/@value", count: 1)
      ]
    )
    let renderer = RawPairReportRenderer()
    XCTAssertEqual(renderer.markdown(report), renderer.markdown(report))
    XCTAssertEqual(try renderer.jsonData(report), try renderer.jsonData(report))

    let identical = try analyzer.analyze(beforeData: before, afterData: before)
    XCTAssertEqual(identical.findings, [])
  }
}

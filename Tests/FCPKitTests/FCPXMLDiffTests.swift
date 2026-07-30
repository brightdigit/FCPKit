import FCPXMLDiff
import XCTest
import XMLCoder


internal final class FCPXMLDiffTests: XCTestCase {
  internal let parser = XMLTreeParser()
  internal let engine = FCPXMLDiffEngine()

  internal func testNormalizerSuppressesChurnAndSurfacesStructuralDelta() throws {
    let left = try tree(fixture("NormalizerSuppressesChurnAndSurfacesStructuralDeltaLeft"))
    let right = try tree(fixture("NormalizerSuppressesChurnAndSurfacesStructuralDeltaRight"))

    let differences = engine.compare(left, right, mode: .symmetric)

    XCTAssertFalse(differences.isEmpty)
    XCTAssertTrue(differences.allSatisfy { $0.path.contains("/marker") })
    XCTAssertTrue(
      differences.contains {
        $0.kind == .addedElement
          && $0.path.hasSuffix("/asset-clip/marker")
      }
    )
  }

  internal func testInsertedResourceDoesNotChangeLaterReferences() throws {
    let left = try tree(fixture("InsertedResourceDoesNotChangeLaterReferencesLeft"))
    let right = try tree(fixture("InsertedResourceDoesNotChangeLaterReferencesRight"))

    let differences = engine.compare(left, right, mode: .symmetric)

    XCTAssertTrue(differences.allSatisfy { $0.path.contains("/resources/effect") })
    XCTAssertFalse(differences.contains { $0.kind == .changedAttribute })
  }

  internal func testDeletedAndReorderedResourcesDoNotChangeSurvivingReferences() throws {
    let left = try tree(fixture("DeletedAndReorderedResourcesDoNotChangeSurvivingReferencesLeft"))
    let right = try tree(fixture("DeletedAndReorderedResourcesDoNotChangeSurvivingReferencesRight"))

    let differences = engine.compare(left, right, mode: .symmetric)

    XCTAssertTrue(differences.allSatisfy { $0.path.contains("/resources/effect") })
    XCTAssertFalse(differences.contains { $0.kind == .changedAttribute })
  }

  internal func testRepeatedSiblingsAreMatchedAsMultisets() throws {
    let left = try tree("<root><param value=\"a\"/><param value=\"b\"/><param value=\"b\"/></root>")
    let right = try tree(
      "<root><param value=\"b\"/><param value=\"c\"/><param value=\"b\"/></root>"
    )

    XCTAssertEqual(
      engine.compare(left, right, mode: .symmetric),
      [
        FCPXMLDifference(kind: .changedAttribute, path: "/root/param/@value", count: 1)
      ]
    )
  }

  internal func testAttributeOrderEmptyElementsAndHeterogeneousChildrenAreStable() throws {
    let left = try tree("<root b=\"2\" a=\"1\"><empty/><a/><b/><a/></root>")
    let right = try tree("<root a=\"1\" b=\"2\"><empty></empty><a/><b/><a/></root>")

    XCTAssertEqual(engine.compare(left, right, mode: .symmetric), [])
  }

  internal func testMixedTextChangesRemainVisible() throws {
    let left = try tree("<root>before<em>middle</em>after</root>")
    let right = try tree("<root>before<em>middle</em>changed</root>")

    XCTAssertEqual(
      engine.compare(left, right, mode: .symmetric),
      [
        FCPXMLDifference(kind: .changedText, path: "/root/#text", count: 1)
      ]
    )
  }

  internal func testOpaqueMaskingKeepsElementPathsAndAttributesSignificant() throws {
    let left = try tree(fixture("OpaqueMaskingKeepsElementPathsAndAttributesSignificantLeft"))
    let payloadOnly = try tree(
      fixture("OpaqueMaskingKeepsElementPathsAndAttributesSignificantPayloadOnly")
    )
    let changedAttribute = try tree(
      fixture("OpaqueMaskingKeepsElementPathsAndAttributesSignificantChangedAttribute")
    )

    XCTAssertEqual(engine.compare(left, payloadOnly, mode: .symmetric), [])
    XCTAssertEqual(
      Set(engine.compare(left, changedAttribute, mode: .symmetric).map(\.path)),
      ["/root/bookmark/@kind", "/root/data/@version"]
    )

    let missing = try tree("<root/>")
    let missingDifferences = engine.compare(left, missing, mode: .completeness)
    XCTAssertTrue(missingDifferences.contains { $0.path == "/root/bookmark" })
    XCTAssertTrue(missingDifferences.contains { $0.path == "/root/data/@key" })
  }

  internal func testRemovedVolatileAttributeIsStillReportedAsModelLoss() throws {
    let original = try tree("<root uid=\"volatile-value\"/>")
    let encoded = try tree("<root/>")

    XCTAssertEqual(
      engine.compare(original, encoded, mode: .completeness),
      [
        FCPXMLDifference(kind: .droppedAttribute, path: "/root/@uid", count: 1)
      ]
    )
  }

  internal func tree(_ xml: String) throws -> XMLTreeNode {
    try parser.parse(XCTUnwrap(xml.data(using: .utf8)))
  }

  internal func descendants(of node: XMLTreeNode) -> [XMLTreeNode] {
    node.children + node.children.flatMap(descendants)
  }

  internal func report(with droppedElementCount: Int) -> SchemaCompletenessReport {
    let findings = [
      FCPXMLDifference(kind: .droppedElement, path: "/root/missing", count: droppedElementCount)
    ]
    return SchemaCompletenessReport(
      formatVersion: 1,
      normalization: [],
      totals: SchemaCompletenessSummary(findings: findings),
      aggregateFindings: findings,
      files: []
    )
  }

  internal func assertEncoding(
    _ actual: XMLEncoder.NodeEncoding,
    is expected: XMLEncoder.NodeEncoding,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertEqual(label(actual), label(expected), file: file, line: line)
  }

  internal func label(_ encoding: XMLEncoder.NodeEncoding) -> String {
    switch encoding {
    case .attribute: return "attribute"
    case .element: return "element"
    case .both: return "both"
    }
  }
}

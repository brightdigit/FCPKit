import FCPXMLDiff
import XCTest
import XMLCoder

@testable import FCPKit

internal final class FCPXMLDiffTests: XCTestCase {
  internal let parser = XMLTreeParser()
  internal let engine = FCPXMLDiffEngine()

  internal func testNormalizerSuppressesChurnAndSurfacesStructuralDelta() throws {
    let left = try tree(
      """
      <fcpxml version="1.13">
          <resources>
              <asset id="r1" name="Clip" uid="OLD-ASSET">
                  <media-rep kind="original-media" sig="OLD-SIG" src="file:///clip.mov">
                      <bookmark>OLD-BOOKMARK</bookmark>
                  </media-rep>
              </asset>
              <effect id="r2" name="Effect" uid="OLD-EFFECT"/>
          </resources>
          <library>
              <event name="Event" uid="OLD-EVENT">
                  <project name="Project" uid="OLD-PROJECT" modDate="OLD-DATE">
                      <sequence format="r1" duration="10s">
                          <spine>
                              <asset-clip ref="r1" duration="10s">
                                  <filter-video ref="r2">
                                      <data key="effectConfig">OLD-CONFIG</data>
                                  </filter-video>
                              </asset-clip>
                          </spine>
                      </sequence>
                  </project>
              </event>
          </library>
      </fcpxml>
      """)
    let right = try tree(
      """
      <fcpxml version="1.13">
          <resources>
              <asset id="r7" name="Clip" uid="NEW-ASSET">
                  <media-rep kind="original-media" sig="NEW-SIG" src="file:///clip.mov">
                      <bookmark>NEW-BOOKMARK</bookmark>
                  </media-rep>
              </asset>
              <effect id="r8" name="Effect" uid="NEW-EFFECT"/>
          </resources>
          <library>
              <event name="Event" uid="NEW-EVENT">
                  <project name="Project" uid="NEW-PROJECT" modDate="NEW-DATE">
                      <sequence format="r7" duration="10s">
                          <spine>
                              <asset-clip ref="r7" duration="10s">
                                  <filter-video ref="r8">
                                      <data key="effectConfig">NEW-CONFIG</data>
                                  </filter-video>
                                  <marker start="1s" value="Feature marker"/>
                              </asset-clip>
                          </spine>
                      </sequence>
                  </project>
              </event>
          </library>
      </fcpxml>
      """)

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
    let left = try tree(
      """
      <fcpxml version="1.13">
          <resources>
              <format id="r1" name="Format"/>
              <asset id="r2" name="Clip" format="r1"/>
          </resources>
          <library><event><asset-clip ref="r2" format="r1"/></event></library>
      </fcpxml>
      """)
    let right = try tree(
      """
      <fcpxml version="1.13">
          <resources>
              <effect id="r1" name="New Effect"/>
              <format id="r2" name="Format"/>
              <asset id="r3" name="Clip" format="r2"/>
          </resources>
          <library><event><asset-clip ref="r3" format="r2"/></event></library>
      </fcpxml>
      """)

    let differences = engine.compare(left, right, mode: .symmetric)

    XCTAssertTrue(differences.allSatisfy { $0.path.contains("/resources/effect") })
    XCTAssertFalse(differences.contains { $0.kind == .changedAttribute })
  }

  internal func testDeletedAndReorderedResourcesDoNotChangeSurvivingReferences() throws {
    let left = try tree(
      """
      <fcpxml><resources>
          <format id="r1" name="Format"/>
          <effect id="r2" name="Removed"/>
          <asset id="r3" name="Clip" format="r1"/>
      </resources><library><asset-clip ref="r3" format="r1"/></library></fcpxml>
      """)
    let right = try tree(
      """
      <fcpxml><resources>
          <asset id="r1" name="Clip" format="r3"/>
          <format id="r3" name="Format"/>
      </resources><library><asset-clip ref="r1" format="r3"/></library></fcpxml>
      """)

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
    let left = try tree(
      """
      <root><bookmark kind="security">OLD</bookmark><data key="effectConfig" version="1">OLD</data></root>
      """)
    let payloadOnly = try tree(
      """
      <root><bookmark kind="security">NEW</bookmark><data key="effectConfig" version="1">NEW</data></root>
      """)
    let changedAttribute = try tree(
      """
      <root><bookmark kind="different">NEW</bookmark><data key="effectConfig" version="2">NEW</data></root>
      """)

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

  internal func testCompleteSyntheticModelHasNoRoundTripLoss() throws {
    let xml = """
      <fcpxml version="1.13">
          <resources>
              <format id="r1" name="Format" frameDuration="1/24s" width="1920" height="1080"/>
              <asset id="r2" name="Clip" uid="ASSET" duration="10s" format="r1" hasVideo="1"/>
          </resources>
          <library>
              <event name="Event" uid="EVENT">
                  <project name="Project" uid="PROJECT" modDate="DATE">
                      <sequence format="r1" duration="10s" tcStart="0s" tcFormat="NDF">
                          <spine><asset-clip ref="r2" name="Clip" duration="10s"/></spine>
                      </sequence>
                  </project>
              </event>
          </library>
      </fcpxml>
      """
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

internal struct TestCodingKey: CodingKey {
  let stringValue: String
  let intValue: Int? = nil

  init(_ stringValue: String) {
    self.stringValue = stringValue
  }

  init?(stringValue: String) {
    self.init(stringValue)
  }

  init?(intValue: Int) {
    nil
  }
}

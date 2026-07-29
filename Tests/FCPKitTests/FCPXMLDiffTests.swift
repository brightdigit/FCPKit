import FCPXMLDiff
import XCTest
import XMLCoder

@testable import FCPKit

internal final class FCPXMLDiffTests: XCTestCase {
  private let parser = XMLTreeParser()
  private let engine = FCPXMLDiffEngine()

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
    let before = Data(
      """
      <fcpxml version="1.13"><library><event name="Before"><marker value="old"/><note>gone</note></event></library></fcpxml>
      """.utf8)
    let after = Data(
      """
      <fcpxml version="1.13"><library><event name="After"><marker value="new"/><keyword value="added"/></event></library></fcpxml>
      """.utf8)

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
      "<fcpxml version=\"1.13\" uid=\"old\"><resources><format id=\"r1\"/></resources><library format=\"r1\"><marker value=\"old\"/></library></fcpxml>"
        .utf8
    )
    let after = Data(
      "<fcpxml version=\"1.13\" uid=\"new\"><resources><format id=\"r9\"/></resources><library format=\"r9\"><marker value=\"new\"/></library></fcpxml>"
        .utf8
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

  internal func testRoundTripAnalyzerReportsUnsupportedContentWithoutRejectingInput() throws {
    let xml = Data(
      """
      <fcpxml version="1.13">
          <resources><format id="r1"/></resources>
          <library><event><project><sequence format="r1" duration="2s"><spine>
              <gap duration="1s" unsupported-attribute="kept-nowhere"/>
              <unsupported><nested>payload</nested></unsupported>
              <gap duration="1s"/>
          </spine></sequence></project></event></library>
      </fcpxml>
      """.utf8)

    let report = try FCPXMLRoundTripAnalyzer().analyze(data: xml)

    XCTAssertTrue(report.hasLoss)
    XCTAssertEqual(report.summary.droppedAttributes, 1)
    XCTAssertEqual(report.summary.droppedElements, 2)
    XCTAssertTrue(
      report.findings.contains {
        $0.kind == .droppedAttribute
          && $0.path.hasSuffix("/gap/@unsupported-attribute")
      }
    )
    XCTAssertTrue(
      report.findings.contains {
        $0.kind == .droppedElement
          && $0.path.hasSuffix("/unsupported")
      }
    )
    XCTAssertTrue(
      report.findings.contains {
        $0.kind == .droppedElement
          && $0.path.hasSuffix("/unsupported/nested")
      }
    )
  }

  internal func testRoundTripAnalyzerCanCheckAnEditedEncodedDocument() throws {
    let original = Data(
      """
      <fcpxml version="1.13"><resources><format id="r1"/></resources>
      <library><event><project><sequence format="r1" duration="1s"><spine>
      <gap duration="1s"/>
      </spine></sequence></project></event></library></fcpxml>
      """.utf8)
    let edited = Data(
      """
      <fcpxml version="1.13"><resources><format id="r1"/></resources>
      <library><event><project><sequence format="r1" duration="2s"><spine>
      <gap duration="1s"/>
      </spine></sequence></project></event></library></fcpxml>
      """.utf8)

    let report = try FCPXMLRoundTripAnalyzer().analyze(
      originalData: original,
      encodedData: edited,
      sourcePath: "edited.fcpxml"
    )

    XCTAssertFalse(report.hasLoss)
    XCTAssertEqual(report.sourcePath, "edited.fcpxml")
    XCTAssertEqual(report.fcpxmlVersion, "1.13")
  }

  internal func testEveryModelTypeDeclaresNodeEncoding() {
    let attributeOnlyTypes: [any DynamicNodeEncoding.Type] = [
      Format.self, Effect.self, Clip.self, Gap.self, Keyword.self,
      MCSource.self, ParamElement.self, ConformRate.self, Timept.self,
      AdjustTransform.self, TrimRect.self, MatchClip.self, MatchMedia.self,
      MatchRatings.self, AdjustVolume.self, AdjustLoudness.self,
      AdjustBlend.self, Transition.self, Marker.self, Rating.self,
      ChapterMarker.self, ConnectedClip.self, Keyframe.self,
      CompoundClip.self, AudioRole.self, VideoRole.self, CaptionRole.self,
      Fade.self,
      AdjustColorConform.self,
      MatchAnalysisType.self,
    ]
    for type in attributeOnlyTypes {
      assertEncoding(type.nodeEncoding(for: TestCodingKey("value")), is: .attribute)
    }

    let elementKeys: [(any DynamicNodeEncoding.Type, String)] = [
      (FCPXML.self, "resources"),
      (Resources.self, "asset"),
      (Asset.self, "media-rep"),
      (Asset.self, "metadata"),
      (AssetClip.self, "timeMap"),
      (Library.self, "event"),
      (Event.self, "project"),
      (Project.self, "sequence"),
      (Sequence.self, "spine"),
      (Spine.self, "transition"),
      (AssetClip.self, "marker"),
      (AssetClip.self, "title"),
      (MCClip.self, "mc-source"),
      (Video.self, "filter-video"),
      (Video.self, "param"),
      (FilterVideo.self, "data"),
      (ParamElement.self, "param"),
      (ParamElement.self, "data"),
      (ParamElement.self, "fadeIn"),
      (ParamElement.self, "fadeOut"),
      (ParamElement.self, "keyframeAnimation"),
      (Media.self, "sequence"),
      (Multicam.self, "mc-angle"),
      (MCAngle.self, "ref-clip"),
      (RefClip.self, "timeMap"),
      (RefClip.self, "video"),
      (TimeMap.self, "timept"),
      (AdjustCrop.self, "trim-rect"),
      (SyncClip.self, "asset-clip"),
      (MediaRep.self, "bookmark"),
      (SmartCollection.self, "match-clip"),
      (SmartCollection.self, "match-analysis-type"),
      (AssetMetadata.self, "md"),
      (MetadataEntry.self, "array"),
      (MetadataArray.self, "string"),
      (AudioChannelSource.self, "adjust-loudness"),
      (AdjustVolume.self, "param"),
      (Title.self, "text"),
      (Title.self, "param"),
      (TextElement.self, "text-style"),
      (TextStyleDef.self, "text-style"),
      (TextStyle.self, "param"),
      (KeyframeAnimation.self, "keyframe"),
      (FilterAudio.self, "param"),
      (Transition.self, "filter-video"),
      (Transition.self, "filter-audio"),
      (Generator.self, "param"),
      (Storyline.self, "title"),
      (RetimeClip.self, "timeMap"),
      (ColorCorrection.self, "param"),
      (Motion.self, "param"),
      (Caption.self, "text"),
    ]
    for (type, key) in elementKeys {
      assertEncoding(type.nodeEncoding(for: TestCodingKey(key)), is: .element)
    }

    assertEncoding(DataElement.nodeEncoding(for: TestCodingKey("key")), is: .attribute)
    assertEncoding(DataElement.nodeEncoding(for: TestCodingKey("")), is: .element)
    assertEncoding(TextStyle.nodeEncoding(for: TestCodingKey("font")), is: .attribute)
    assertEncoding(TextStyle.nodeEncoding(for: TestCodingKey("")), is: .element)
    assertEncoding(MetadataString.nodeEncoding(for: TestCodingKey("")), is: .element)

    let mixedTypes: [any DynamicNodeEncoding.Type] = [
      FCPXML.self, Asset.self, Library.self, Event.self, Project.self,
      Sequence.self, AssetClip.self, MCClip.self, Video.self,
      FilterVideo.self, Media.self, Multicam.self, MCAngle.self,
      RefClip.self, TimeMap.self, AdjustCrop.self, SyncClip.self, ParamElement.self,
      MediaRep.self, SmartCollection.self, AudioChannelSource.self,
      AdjustVolume.self, Title.self, TextStyle.self, TextStyleDef.self,
      FilterAudio.self, Transition.self, Generator.self,
      Storyline.self, RetimeClip.self, ColorCorrection.self, Motion.self,
      Caption.self, AssetMetadata.self, MetadataEntry.self,
    ]
    for type in mixedTypes {
      assertEncoding(type.nodeEncoding(for: TestCodingKey("name")), is: .attribute)
    }
  }

  private func tree(_ xml: String) throws -> XMLTreeNode {
    try parser.parse(XCTUnwrap(xml.data(using: .utf8)))
  }

  private func descendants(of node: XMLTreeNode) -> [XMLTreeNode] {
    node.children + node.children.flatMap(descendants)
  }

  private func report(with droppedElementCount: Int) -> SchemaCompletenessReport {
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

  private func assertEncoding(
    _ actual: XMLEncoder.NodeEncoding,
    is expected: XMLEncoder.NodeEncoding,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertEqual(label(actual), label(expected), file: file, line: line)
  }

  private func label(_ encoding: XMLEncoder.NodeEncoding) -> String {
    switch encoding {
    case .attribute: return "attribute"
    case .element: return "element"
    case .both: return "both"
    }
  }
}

private struct TestCodingKey: CodingKey {
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

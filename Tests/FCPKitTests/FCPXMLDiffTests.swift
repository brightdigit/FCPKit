import FCPXMLDiff
@testable import FCPKit
import XMLCoder
import XCTest

final class FCPXMLDiffTests: XCTestCase {
    private let parser = XMLTreeParser()
    private let engine = FCPXMLDiffEngine()

    func testNormalizerSuppressesChurnAndSurfacesStructuralDelta() throws {
        let left = try tree("""
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
        let right = try tree("""
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
        XCTAssertTrue(differences.contains {
            $0.kind == .addedElement
                && $0.path.hasSuffix("/asset-clip/marker")
        })
    }

    func testInsertedResourceDoesNotChangeLaterReferences() throws {
        let left = try tree("""
        <fcpxml version="1.13">
            <resources>
                <format id="r1" name="Format"/>
                <asset id="r2" name="Clip" format="r1"/>
            </resources>
            <library><event><asset-clip ref="r2" format="r1"/></event></library>
        </fcpxml>
        """)
        let right = try tree("""
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

    func testCompleteSyntheticModelHasNoRoundTripLoss() throws {
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

    func testRealTransitionPayloadIsReportedAsDropped() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(
                forResource: "UntitledXML",
                withExtension: "fcpxml",
                subdirectory: "TestData"
            )
        )

        let report = try SchemaCompletenessAnalyzer().analyze(fileURLs: [url])
        let findings = try XCTUnwrap(report.files.first).findings

        XCTAssertTrue(findings.contains {
            $0.kind == .droppedElement
                && $0.path.hasSuffix("/transition/filter-video")
        })
        XCTAssertTrue(findings.contains {
            $0.kind == .droppedElement
                && $0.path.hasSuffix("/transition/filter-video/param")
                && $0.count == 5
        })
        XCTAssertTrue(findings.contains {
            $0.kind == .droppedElement
                && $0.path.hasSuffix("/transition/filter-audio")
        })
    }

    func testReportRenderingIsDeterministic() throws {
        let report = SchemaCompletenessReport(
            formatVersion: 1,
            normalization: ["rule"],
            totals: SchemaCompletenessSummary(findings: [
                FCPXMLDifference(kind: .droppedElement, path: "/fcpxml/missing", count: 2),
            ]),
            aggregateFindings: [
                FCPXMLDifference(kind: .droppedElement, path: "/fcpxml/missing", count: 2),
            ],
            files: []
        )
        let renderer = SchemaCompletenessReportRenderer()

        XCTAssertEqual(renderer.markdown(report), renderer.markdown(report))
        XCTAssertEqual(try renderer.jsonData(report), try renderer.jsonData(report))
    }

    func testEveryModelTypeDeclaresNodeEncoding() {
        let attributeOnlyTypes: [any DynamicNodeEncoding.Type] = [
            Format.self, Effect.self, Clip.self, Gap.self, Keyword.self,
            MCSource.self, ParamElement.self, ConformRate.self, Timept.self,
            AdjustTransform.self, TrimRect.self, MatchClip.self, MatchMedia.self,
            MatchRatings.self, AdjustVolume.self, AdjustLoudness.self,
            AdjustBlend.self, Transition.self, Marker.self, Rating.self,
            ChapterMarker.self, ConnectedClip.self, Keyframe.self,
            CompoundClip.self, AudioRole.self, VideoRole.self, CaptionRole.self,
        ]
        for type in attributeOnlyTypes {
            assertEncoding(type.nodeEncoding(for: TestCodingKey("value")), is: .attribute)
        }

        let elementKeys: [(any DynamicNodeEncoding.Type, String)] = [
            (FCPXML.self, "resources"),
            (Resources.self, "asset"),
            (Asset.self, "media-rep"),
            (Library.self, "event"),
            (Event.self, "project"),
            (Project.self, "sequence"),
            (Sequence.self, "spine"),
            (Spine.self, "transition"),
            (AssetClip.self, "marker"),
            (MCClip.self, "mc-source"),
            (Video.self, "filter-video"),
            (FilterVideo.self, "data"),
            (Media.self, "sequence"),
            (Multicam.self, "mc-angle"),
            (MCAngle.self, "ref-clip"),
            (RefClip.self, "timeMap"),
            (TimeMap.self, "timept"),
            (AdjustCrop.self, "trim-rect"),
            (SyncClip.self, "asset-clip"),
            (MediaRep.self, "bookmark"),
            (SmartCollection.self, "match-clip"),
            (AudioChannelSource.self, "adjust-loudness"),
            (Title.self, "text"),
            (TextElement.self, "text-style"),
            (TextStyleDef.self, "text-style"),
            (FilterAudio.self, "param"),
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

        let mixedTypes: [any DynamicNodeEncoding.Type] = [
            FCPXML.self, Asset.self, Library.self, Event.self, Project.self,
            Sequence.self, AssetClip.self, MCClip.self, Video.self,
            FilterVideo.self, Media.self, Multicam.self, MCAngle.self,
            RefClip.self, TimeMap.self, AdjustCrop.self, SyncClip.self,
            MediaRep.self, SmartCollection.self, AudioChannelSource.self,
            Title.self, TextStyleDef.self, FilterAudio.self, Generator.self,
            Storyline.self, RetimeClip.self, ColorCorrection.self, Motion.self,
            Caption.self,
        ]
        for type in mixedTypes {
            assertEncoding(type.nodeEncoding(for: TestCodingKey("name")), is: .attribute)
        }
    }

    private func tree(_ xml: String) throws -> XMLTreeNode {
        try parser.parse(XCTUnwrap(xml.data(using: .utf8)))
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
        return nil
    }
}

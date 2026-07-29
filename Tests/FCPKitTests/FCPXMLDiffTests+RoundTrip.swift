import FCPXMLDiff
import XCTest
import XMLCoder

@testable import FCPKit

extension FCPXMLDiffTests {
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
}

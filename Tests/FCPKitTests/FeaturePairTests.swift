import FCPKit
import FCPXMLDiff
import Foundation
import XCTest

final class FeaturePairTests: XCTestCase {
  private func featurePairURL(_ feature: String, file name: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .appendingPathComponent("FeaturePairs", isDirectory: true)
      .appendingPathComponent(feature, isDirectory: true)
      .appendingPathComponent(name)
  }

  private func loadAfter(_ feature: String) throws -> (FCPXML, Data) {
    let url = featurePairURL(feature, file: "after.fcpxml")
    let data = try Data(contentsOf: url)
    let document = try FCPXMLParser().parse(data: data)
    return (document, data)
  }

  private func assertNoRoundTripLoss(
    _ data: Data, file: StaticString = #filePath, line: UInt = #line
  ) throws {
    let report = try FCPXMLRoundTripAnalyzer().analyze(data: data)
    XCTAssertFalse(report.hasLoss, "Unexpected round-trip loss: \(report)", file: file, line: line)
  }

  func testMarkersFeaturePairRoundTripsAndMutates() throws {
    var (document, data) = try loadAfter("markers")
    try assertNoRoundTripLoss(data)

    let marker = try XCTUnwrap(
      document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.markers?
        .first)
    XCTAssertEqual(marker.start, "5s")
    XCTAssertEqual(marker.value, "Cue")

    document.library?.events?[0].projects?[0].sequence?.spine?.assetClips?[0].markers?[0].value =
      "Cue Renamed"
    let encoded = try FCPXMLParser().encode(document)
    let decoded = try FCPXMLParser().parse(data: encoded)
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.markers?
        .first?.value,
      "Cue Renamed"
    )
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.markers?
        .first?.start,
      "5s"
    )
    try assertNoRoundTripLoss(encoded)
  }

  func testRolesFeaturePairRoundTripsAndMutates() throws {
    var (document, data) = try loadAfter("roles")
    try assertNoRoundTripLoss(data)

    let clip = try XCTUnwrap(
      document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first)
    XCTAssertEqual(clip.audioRole, "dialogue")
    let source = try XCTUnwrap(clip.audioChannelSource?.first)
    XCTAssertEqual(source.srcCh, "1, 2")
    XCTAssertEqual(source.role, "music.music-1")

    document.library?.events?[0].projects?[0].sequence?.spine?.assetClips?[0].audioChannelSource?[0]
      .role = "music.music-2"
    let encoded = try FCPXMLParser().encode(document)
    let decoded = try FCPXMLParser().parse(data: encoded)
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?
        .audioChannelSource?.first?.role,
      "music.music-2"
    )
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?
        .audioRole,
      "dialogue"
    )
    try assertNoRoundTripLoss(encoded)
  }

  func testTitlesFeaturePairRoundTripsAndMutates() throws {
    var (document, data) = try loadAfter("titles")
    try assertNoRoundTripLoss(data)

    let title = try XCTUnwrap(
      document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.titles?
        .first)
    XCTAssertEqual(title.name, "Basic Title")
    let styledText = try XCTUnwrap(title.text?.first?.textStyle?.first)
    XCTAssertEqual(styledText.content, "Title")
    let styleDef = try XCTUnwrap(title.textStyleDef?.first?.textStyle)
    XCTAssertEqual(styleDef.font, "Helvetica")
    XCTAssertEqual(styleDef.fontSize, "63")

    document.library?.events?[0].projects?[0].sequence?.spine?.assetClips?[0].titles?[0]
      .textStyleDef?[0].textStyle?.fontSize = "72"
    let encoded = try FCPXMLParser().encode(document)
    let decoded = try FCPXMLParser().parse(data: encoded)
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.titles?
        .first?.textStyleDef?.first?.textStyle?.fontSize,
      "72"
    )
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.titles?
        .first?.name,
      "Basic Title"
    )
    try assertNoRoundTripLoss(encoded)
  }

  func testRetimingFeaturePairRoundTripsAndMutates() throws {
    var (document, data) = try loadAfter("retiming")
    try assertNoRoundTripLoss(data)

    let clip = try XCTUnwrap(
      document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first)
    XCTAssertEqual(clip.duration, "20s")
    let timeMap = try XCTUnwrap(clip.timeMap)
    XCTAssertEqual(timeMap.timepts?.count, 2)
    XCTAssertEqual(timeMap.timepts?[0].time, "0s")
    XCTAssertEqual(timeMap.timepts?[0].value, "0s")
    XCTAssertEqual(timeMap.timepts?[1].time, "20s")
    XCTAssertEqual(timeMap.timepts?[1].value, "10s")

    document.library?.events?[0].projects?[0].sequence?.spine?.assetClips?[0].timeMap?.timepts?[1]
      .interp = "linear"
    let encoded = try FCPXMLParser().encode(document)
    let decoded = try FCPXMLParser().parse(data: encoded)
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.timeMap?
        .timepts?[1].interp,
      "linear"
    )
    XCTAssertEqual(
      decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.timeMap?
        .timepts?[1].value,
      "10s"
    )
    try assertNoRoundTripLoss(encoded)
  }

  func testCommon114AttributesSurviveMarkersAfter() throws {
    let (document, data) = try loadAfter("markers")
    try assertNoRoundTripLoss(data)
    XCTAssertEqual(document.version, "1.14")
    XCTAssertEqual(document.library?.colorProcessing, "wide-hdr")
    XCTAssertEqual(
      document.library?.events?.first?.projects?.first?.sequence?.renderFormat,
      "FFRenderFormatProRes422HQ"
    )
    XCTAssertNotNil(document.resources?.assets?.first?.metadata)
    XCTAssertTrue(
      document.library?.smartCollections?.contains {
        $0.matchAnalysisType?.contains { $0.rule == "isMissing" && $0.value == "any" } == true
      } == true
    )
  }
}

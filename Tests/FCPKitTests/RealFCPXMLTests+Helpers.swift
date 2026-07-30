import XCTest

@testable import FCPKit

extension RealFCPXMLTests {
  /// Parses the bundled UntitledXML fixture used by the mutation tests.
  internal func loadUntitledDocument() throws -> FCPXML {
    let fileURL = try XCTUnwrap(
      Bundle.module.url(
        forResource: "UntitledXML",
        withExtension: "fcpxml",
        subdirectory: "TestData"
      )
    )
    return try FCPXMLParser().parse(fileURL: fileURL)
  }

  /// Unwraps the spine of the media at `index`, applies `mutate`, and writes it back.
  internal func withSpine(
    in document: inout FCPXML,
    mediaAt index: Int,
    _ mutate: (inout Spine) -> Void
  ) throws {
    var spine = try XCTUnwrap(document.resources?.media?[index].sequence?.spine)
    mutate(&spine)
    document.resources?.media?[index].sequence?.spine = spine
  }

  /// Unwraps the asset clip at `clipIndex` in the media at `mediaIndex`,
  /// applies `mutate`, and writes it back.
  internal func withAssetClip(
    in document: inout FCPXML,
    mediaAt mediaIndex: Int,
    at clipIndex: Int,
    _ mutate: (inout AssetClip) -> Void
  ) throws {
    var clip = try XCTUnwrap(
      document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?[clipIndex]
    )
    mutate(&clip)
    document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?[clipIndex] = clip
  }

  /// Asserts the library event, ref clips, multicam clip, and assets of the
  /// Both-Multicam fixture.
  internal func assertBothMulticamLibrary(_ library: Library, resources: Resources) throws {
    let events = try XCTUnwrap(library.events)
    XCTAssertFalse(events.isEmpty)

    let firstEvent = try XCTUnwrap(events.first)
    XCTAssertEqual(firstEvent.name, "EAS-202")

    // Check ref-clips in event
    let refClips = try XCTUnwrap(firstEvent.refClips)
    XCTAssertEqual(refClips.count, 3)  // Both, Leo, Rachel

    let eventMulticam = try XCTUnwrap(firstEvent.mcClips?.first)
    XCTAssertEqual(eventMulticam.name, "Multicam Clip")
    XCTAssertEqual(eventMulticam.mcSources?.first?.angleID, "lecA7YF4SLCbdYmLe/clVg")
    XCTAssertEqual(eventMulticam.mcSources?.first?.srcEnable, "all")

    // Test assets
    let assets = try XCTUnwrap(resources.assets)
    XCTAssertEqual(assets.count, 2)  // Leo and Rachel video assets

    // Verify both assets have media representations
    for asset in assets {
      XCTAssertNotNil(asset.mediaRep)
      XCTAssertEqual(asset.hasVideo, "1")
      XCTAssertEqual(asset.hasAudio, "1")
    }
  }
}

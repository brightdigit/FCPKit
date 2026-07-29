import FCPKit
import FCPKitMediaTools
import FCPXMLDiff
import XCTest

// Exercises MulticamXMLBuilder / VideoMetadata, which are gated on CoreMedia,
// so these tests only exist on Apple platforms.
#if canImport(CoreMedia)
  import AVFoundation
  import CoreMedia

  internal final class TypedGenerationTests: XCTestCase {
    internal func testPublicAPIConstructsRoundTripsAndMutatesMinimalProject() throws {
      var document = FCPXML(
        version: "1.13",
        resources: Resources(
          assets: [
            Asset(
              id: "r2",
              name: "Interview",
              uid: "ASSET-UID",
              start: "0s",
              duration: "240/24s",
              format: "r1",
              hasVideo: "1",
              hasAudio: "1",
              audioChannels: "2",
              audioRate: "48000",
              mediaRep: [
                MediaRep(
                  kind: "original-media",
                  sig: "ASSET-SIGNATURE",
                  src: "file:///Users/Shared/FCPKitMedia/interview.mov"
                )
              ]
            )
          ],
          formats: [
            Format(
              id: "r1",
              name: "FFVideoFormat1920x1080p24",
              frameDuration: "1/24s",
              width: "1920",
              height: "1080",
              colorSpace: "1-1-1 (Rec. 709)"
            )
          ]
        ),
        library: Library(
          location: "file:///Users/Shared/FCPKitTypedGeneration.fcpbundle/",
          events: [
            Event(
              name: "Typed Event",
              uid: "EVENT-UID",
              projects: [
                Project(
                  name: "Typed Project",
                  uid: "PROJECT-UID",
                  modDate: "2026-07-17 12:00:00 -0400",
                  sequence: Sequence(
                    format: "r1",
                    duration: "240/24s",
                    tcStart: "0s",
                    tcFormat: "NDF",
                    audioLayout: "stereo",
                    audioRate: "48k",
                    spine: Spine(
                      assetClips: [
                        AssetClip(
                          ref: "r2",
                          name: "Interview",
                          duration: "240/24s",
                          start: "0s",
                          format: "r1",
                          tcFormat: "NDF",
                          offset: "0s"
                        )
                      ]
                    )
                  )
                )
              ]
            )
          ]
        )
      )

      let parser = FCPXMLParser()
      let originalData = try parser.encode(document)
      let decoded = try parser.parse(data: originalData)

      XCTAssertEqual(decoded.version, "1.13")
      XCTAssertEqual(decoded.resources?.formats?.first?.id, "r1")
      XCTAssertEqual(decoded.resources?.assets?.first?.id, "r2")
      XCTAssertEqual(
        decoded.resources?.assets?.first?.mediaRep?.first?.src,
        "file:///Users/Shared/FCPKitMedia/interview.mov"
      )
      XCTAssertEqual(decoded.library?.events?.first?.uid, "EVENT-UID")
      XCTAssertEqual(decoded.library?.events?.first?.projects?.first?.sequence?.format, "r1")
      XCTAssertEqual(decoded.library?.events?.first?.projects?.first?.sequence?.duration, "240/24s")
      XCTAssertEqual(
        decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.ref,
        "r2"
      )
      XCTAssertEqual(
        decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.offset,
        "0s"
      )
      XCTAssertFalse(try FCPXMLRoundTripAnalyzer().analyze(data: originalData).hasLoss)

      document.library?.events?[0].projects?[0].name = "Renamed Typed Project"
      let mutatedData = try parser.encode(document)
      let mutated = try parser.parse(data: mutatedData)

      XCTAssertEqual(mutated.library?.events?.first?.projects?.first?.name, "Renamed Typed Project")
      XCTAssertEqual(mutated.version, decoded.version)
      XCTAssertEqual(mutated.resources?.formats?.first?.id, decoded.resources?.formats?.first?.id)
      XCTAssertEqual(mutated.resources?.assets?.first?.id, decoded.resources?.assets?.first?.id)
      XCTAssertEqual(mutated.resources?.assets?.first?.uid, decoded.resources?.assets?.first?.uid)
      XCTAssertEqual(mutated.library?.events?.first?.uid, decoded.library?.events?.first?.uid)
      XCTAssertEqual(
        mutated.library?.events?.first?.projects?.first?.uid,
        decoded.library?.events?.first?.projects?.first?.uid
      )
      XCTAssertEqual(mutated.library?.events?.first?.projects?.first?.sequence?.format, "r1")
      XCTAssertEqual(mutated.library?.events?.first?.projects?.first?.sequence?.duration, "240/24s")
      XCTAssertEqual(
        mutated.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.ref,
        "r2"
      )
      XCTAssertEqual(
        mutated.resources?.assets?.first?.mediaRep?.first?.src,
        decoded.resources?.assets?.first?.mediaRep?.first?.src
      )
    }

    internal func testTypedMulticamBuilderRoundTripsAndPreservesStructure() throws {
      let left = VideoMetadata(
        url: URL(fileURLWithPath: "/Users/Shared/FCPKitMedia/Left.mov"),
        duration: CMTime(value: 240, timescale: 24),
        dimensions: CGSize(width: 1_920, height: 1_080),
        frameRate: 24,
        hasVideo: true,
        hasAudio: true,
        audioChannels: 2,
        audioSampleRate: 48_000
      )
      let right = VideoMetadata(
        url: URL(fileURLWithPath: "/Users/Shared/FCPKitMedia/Right.mov"),
        duration: CMTime(value: 216, timescale: 24),
        dimensions: CGSize(width: 1_280, height: 720),
        frameRate: 24,
        hasVideo: true,
        hasAudio: true,
        audioChannels: 1,
        audioSampleRate: 48_000
      )

      let document = MulticamXMLBuilder().generateMulticamDocument(
        leftSideVideo: left,
        rightSideVideo: right,
        projectName: "Typed Parity"
      )
      let parser = FCPXMLParser()
      let encoded = try parser.encode(document)
      let decoded = try parser.parse(data: encoded)

      XCTAssertEqual(decoded.version, FCPXMLVersion.supportedGenerationVersion.rawValue)
      XCTAssertEqual(decoded.versionCompatibility, .supported)
      XCTAssertNil(decoded.library?.smartCollections)
      XCTAssertEqual(decoded.library?.events?.first?.name, "Typed Parity")

      let both = try XCTUnwrap(decoded.resources?.media?.first(where: { $0.id == "r1" }))
      let leftClip = try XCTUnwrap(both.sequence?.spine?.refClips?.first)
      XCTAssertEqual(leftClip.ref, "r3")
      XCTAssertEqual(leftClip.adjustTransform?.position, "-33.9193 0")
      let rightClip = try XCTUnwrap(leftClip.refClips?.first)
      XCTAssertEqual(rightClip.ref, "r5")
      XCTAssertEqual(rightClip.adjustTransform?.position, "67.5926 0")
      XCTAssertEqual(rightClip.adjustCrop?.mode, "trim")
      XCTAssertEqual(rightClip.adjustCrop?.trimRect?.left, "21.2963")

      XCTAssertEqual(
        decoded.resources?.media?.first(where: { $0.id == "r3" })?.sequence?.spine?.assetClips?
          .first?.ref, "r4"
      )
      XCTAssertEqual(
        decoded.resources?.media?.first(where: { $0.id == "r5" })?.sequence?.spine?.assetClips?
          .first?.ref, "r7"
      )
      XCTAssertEqual(
        decoded.resources?.assets?.first(where: { $0.id == "r4" })?.mediaRep?.first?.src,
        left.url.absoluteString
      )
      XCTAssertEqual(
        decoded.resources?.assets?.first(where: { $0.id == "r7" })?.mediaRep?.first?.src,
        right.url.absoluteString
      )

      let angles = try XCTUnwrap(
        decoded.resources?.media?.first(where: { $0.id == "r8" })?.multicam?.mcAngles
      )
      XCTAssertEqual(angles.count, 3)
      XCTAssertEqual(angles.map(\.name), ["Both", "Left", "Right"])
      let angleIDs = try angles.map { try XCTUnwrap($0.angleID) }
      XCTAssertEqual(Set(angleIDs).count, 3)
      XCTAssertEqual(
        decoded.library?.events?.first?.mcClips?.first?.mcSources?.first?.angleID,
        angleIDs[0]
      )

      XCTAssertFalse(try FCPXMLRoundTripAnalyzer().analyze(data: encoded).hasLoss)
      XCTAssertFalse(
        try parser.encodeToString(document).contains("smart-collection"),
        "Generated multicam XML should omit smart-collection elements"
      )
    }
  }
#endif

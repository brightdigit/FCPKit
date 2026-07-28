import AVFoundation
import CoreMedia
import FCPKit
import XCTest
@testable import FCPKitMediaTools

final class MulticamXMLBuilderTests: XCTestCase {

    func testDefaultValuesMatchExpectedStructure() throws {
        let leftVideo = VideoMetadata(
            url: URL(fileURLWithPath: "/test/Leo.mp4"),
            duration: CMTime(value: 7700000, timescale: 2400),
            dimensions: CGSize(width: 3840, height: 2160),
            frameRate: 24.0,
            hasVideo: true,
            hasAudio: true,
            audioChannels: 1,
            audioSampleRate: 48000
        )

        let rightVideo = VideoMetadata(
            url: URL(fileURLWithPath: "/test/Rachel.mp4"),
            duration: CMTime(value: 7700200, timescale: 2400),
            dimensions: CGSize(width: 1920, height: 1080),
            frameRate: 24.0,
            hasVideo: true,
            hasAudio: true,
            audioChannels: 1,
            audioSampleRate: 48000
        )

        let document = MulticamXMLBuilder().generateMulticamDocument(
            leftSideVideo: leftVideo,
            rightSideVideo: rightVideo,
            projectName: "Test Project"
        )

        let both = try XCTUnwrap(document.resources?.media?.first(where: { $0.id == "r1" }))
        let leftClip = try XCTUnwrap(both.sequence?.spine?.refClips?.first)
        XCTAssertEqual(leftClip.name, "Leo")
        XCTAssertEqual(leftClip.adjustTransform?.position, "-33.9193 0")
        let rightClip = try XCTUnwrap(leftClip.refClips?.first)
        XCTAssertEqual(rightClip.name, "Rachel")
        XCTAssertEqual(rightClip.adjustTransform?.position, "67.5926 0")
        XCTAssertEqual(rightClip.adjustCrop?.trimRect?.left, "21.2963")
        XCTAssertNil(document.library?.smartCollections)
        XCTAssertEqual(document.version, "1.13")
    }

    func testCustomValuesAreAppliedCorrectly() throws {
        let leftVideo = VideoMetadata(
            url: URL(fileURLWithPath: "/test/LeftVideo.mp4"),
            duration: CMTime(value: 1000000, timescale: 2400),
            dimensions: CGSize(width: 1920, height: 1080),
            frameRate: 24.0,
            hasVideo: true,
            hasAudio: true,
            audioChannels: 2,
            audioSampleRate: 48000
        )

        let rightVideo = VideoMetadata(
            url: URL(fileURLWithPath: "/test/RightVideo.mp4"),
            duration: CMTime(value: 1000000, timescale: 2400),
            dimensions: CGSize(width: 1920, height: 1080),
            frameRate: 24.0,
            hasVideo: true,
            hasAudio: true,
            audioChannels: 2,
            audioSampleRate: 48000
        )

        let document = MulticamXMLBuilder().generateMulticamDocument(
            leftSideVideo: leftVideo,
            rightSideVideo: rightVideo,
            projectName: "Custom Test",
            leftSideVideoOffset: -50.0,
            rightSideVideoLeftTrim: 30.0,
            rightSideVideoOffset: 100.0
        )

        let both = try XCTUnwrap(document.resources?.media?.first(where: { $0.id == "r1" }))
        let leftClip = try XCTUnwrap(both.sequence?.spine?.refClips?.first)
        XCTAssertEqual(leftClip.name, "LeftVideo")
        XCTAssertEqual(leftClip.adjustTransform?.position, "-50.0 0")
        let rightClip = try XCTUnwrap(leftClip.refClips?.first)
        XCTAssertEqual(rightClip.name, "RightVideo")
        XCTAssertEqual(rightClip.adjustTransform?.position, "100.0 0")
        XCTAssertEqual(rightClip.adjustCrop?.trimRect?.left, "30.0")

        let xml = MulticamXMLBuilder().generateMulticamFCPXML(
            leftSideVideo: leftVideo,
            rightSideVideo: rightVideo,
            projectName: "Custom Test",
            leftSideVideoOffset: -50.0,
            rightSideVideoLeftTrim: 30.0,
            rightSideVideoOffset: 100.0
        )
        XCTAssertFalse(xml.contains("smart-collection"))
        let parsed = try FCPXMLParser().parse(xmlString: xml)
        XCTAssertEqual(parsed.library?.events?.first?.name, "Custom Test")
        XCTAssertEqual(parsed.resources?.media?.count, 4)
    }
}

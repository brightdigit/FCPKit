import FCPKit
import FCPXMLDiff
import Foundation
import XCTest

final class AssetClipEditingTests: XCTestCase {
    private func featurePairURL(_ feature: String, file name: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("FeaturePairs", isDirectory: true)
            .appendingPathComponent(feature, isDirectory: true)
            .appendingPathComponent(name)
    }

    private func loadDocument(_ feature: String, file name: String) throws -> FCPXML {
        let data = try Data(contentsOf: featurePairURL(feature, file: name))
        return try FCPXMLParser().parse(data: data)
    }

    private func spineClip(_ document: inout FCPXML) throws -> AssetClip {
        try XCTUnwrap(document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first)
    }

    private func setSpineClip(_ document: inout FCPXML, _ clip: AssetClip) throws {
        document.library?.events?[0].projects?[0].sequence?.spine?.assetClips?[0] = clip
    }

    func testAddMarkerMatchesFeaturePairAfter() throws {
        var document = try loadDocument("markers", file: "before.fcpxml")
        var clip = try spineClip(&document)
        clip.addMarker(name: "Cue", at: "5s")
        try setSpineClip(&document, clip)

        let expected = try loadDocument("markers", file: "after.fcpxml")
        let expectedMarker = try XCTUnwrap(
            expected.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.markers?.first
        )
        let actualMarker = try XCTUnwrap(
            document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.markers?.first
        )
        XCTAssertEqual(actualMarker.start, expectedMarker.start)
        XCTAssertEqual(actualMarker.duration, expectedMarker.duration)
        XCTAssertEqual(actualMarker.value, expectedMarker.value)

        let encoded = try FCPXMLParser().encode(document)
        XCTAssertFalse(try FCPXMLRoundTripAnalyzer().analyze(data: encoded).hasLoss)
    }

    func testAssignMusicRoleMatchesFeaturePairAfter() throws {
        var document = try loadDocument("roles", file: "before.fcpxml")
        var clip = try spineClip(&document)
        clip.assignMusicRole()
        try setSpineClip(&document, clip)

        let expected = try loadDocument("roles", file: "after.fcpxml")
        let expectedSource = try XCTUnwrap(
            expected.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.audioChannelSource?.first
        )
        let actualClip = try XCTUnwrap(
            document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first
        )
        let actualSource = try XCTUnwrap(actualClip.audioChannelSource?.first)
        XCTAssertEqual(actualClip.audioRole, expected.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.audioRole)
        XCTAssertEqual(actualSource.srcCh, expectedSource.srcCh)
        XCTAssertEqual(actualSource.role, expectedSource.role)

        let encoded = try FCPXMLParser().encode(document)
        XCTAssertFalse(try FCPXMLRoundTripAnalyzer().analyze(data: encoded).hasLoss)
    }

    func testSetConstantSpeedMatchesFeaturePairAfter() throws {
        var document = try loadDocument("retiming", file: "before.fcpxml")
        var clip = try spineClip(&document)
        try clip.setConstantSpeed(percent: 50, mediaDuration: "10s")
        try setSpineClip(&document, clip)
        document.library?.events?[0].projects?[0].sequence?.duration = clip.duration

        let expected = try loadDocument("retiming", file: "after.fcpxml")
        let expectedClip = try XCTUnwrap(
            expected.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first
        )
        let actualClip = try XCTUnwrap(
            document.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first
        )
        XCTAssertEqual(actualClip.duration, expectedClip.duration)
        XCTAssertEqual(actualClip.timeMap?.timepts?.count, 2)
        XCTAssertEqual(actualClip.timeMap?.timepts?[0].time, expectedClip.timeMap?.timepts?[0].time)
        XCTAssertEqual(actualClip.timeMap?.timepts?[0].value, expectedClip.timeMap?.timepts?[0].value)
        XCTAssertEqual(actualClip.timeMap?.timepts?[0].interp, expectedClip.timeMap?.timepts?[0].interp)
        XCTAssertEqual(actualClip.timeMap?.timepts?[1].time, expectedClip.timeMap?.timepts?[1].time)
        XCTAssertEqual(actualClip.timeMap?.timepts?[1].value, expectedClip.timeMap?.timepts?[1].value)
        XCTAssertEqual(actualClip.timeMap?.timepts?[1].interp, expectedClip.timeMap?.timepts?[1].interp)
        XCTAssertEqual(
            document.library?.events?.first?.projects?.first?.sequence?.duration,
            expected.library?.events?.first?.projects?.first?.sequence?.duration
        )

        let encoded = try FCPXMLParser().encode(document)
        XCTAssertFalse(try FCPXMLRoundTripAnalyzer().analyze(data: encoded).hasLoss)
    }

    func testSetConstantSpeedRejectsNonPositivePercent() {
        var clip = AssetClip(ref: "r2", duration: "10s")
        XCTAssertThrowsError(try clip.setConstantSpeed(percent: 0, mediaDuration: "10s")) { error in
            XCTAssertEqual(error as? AssetClipEditingError, .invalidSpeedPercent(0))
        }
    }
}

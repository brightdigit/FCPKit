import AVFoundation
import CoreMedia
import FCPKit
import FCPKitMediaTools
import FCPXMLDiff
import XCTest

final class TypedGenerationTests: XCTestCase {
    func testPublicAPIConstructsRoundTripsAndMutatesMinimalProject() throws {
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
                            ),
                        ]
                    ),
                ],
                formats: [
                    Format(
                        id: "r1",
                        name: "FFVideoFormat1920x1080p24",
                        frameDuration: "1/24s",
                        width: "1920",
                        height: "1080",
                        colorSpace: "1-1-1 (Rec. 709)"
                    ),
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
                                            ),
                                        ]
                                    )
                                )
                            ),
                        ]
                    ),
                ]
            )
        )

        let parser = FCPXMLParser()
        let originalData = try parser.encode(document)
        let decoded = try parser.parse(data: originalData)

        XCTAssertEqual(decoded.version, "1.13")
        XCTAssertEqual(decoded.resources?.formats?.first?.id, "r1")
        XCTAssertEqual(decoded.resources?.assets?.first?.id, "r2")
        XCTAssertEqual(decoded.resources?.assets?.first?.mediaRep?.first?.src, "file:///Users/Shared/FCPKitMedia/interview.mov")
        XCTAssertEqual(decoded.library?.events?.first?.uid, "EVENT-UID")
        XCTAssertEqual(decoded.library?.events?.first?.projects?.first?.sequence?.format, "r1")
        XCTAssertEqual(decoded.library?.events?.first?.projects?.first?.sequence?.duration, "240/24s")
        XCTAssertEqual(decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.ref, "r2")
        XCTAssertEqual(decoded.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.offset, "0s")
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
        XCTAssertEqual(mutated.library?.events?.first?.projects?.first?.uid, decoded.library?.events?.first?.projects?.first?.uid)
        XCTAssertEqual(mutated.library?.events?.first?.projects?.first?.sequence?.format, "r1")
        XCTAssertEqual(mutated.library?.events?.first?.projects?.first?.sequence?.duration, "240/24s")
        XCTAssertEqual(mutated.library?.events?.first?.projects?.first?.sequence?.spine?.assetClips?.first?.ref, "r2")
        XCTAssertEqual(mutated.resources?.assets?.first?.mediaRep?.first?.src, decoded.resources?.assets?.first?.mediaRep?.first?.src)
    }

    func testTypedMulticamMatchesRawBuilderAfterNormalization() throws {
        let left = VideoMetadata(
            url: URL(fileURLWithPath: "/Users/Shared/FCPKitMedia/Left.mov"),
            duration: CMTime(value: 240, timescale: 24),
            dimensions: CGSize(width: 1920, height: 1080),
            frameRate: 24,
            hasVideo: true,
            hasAudio: true,
            audioChannels: 2,
            audioSampleRate: 48_000
        )
        let right = VideoMetadata(
            url: URL(fileURLWithPath: "/Users/Shared/FCPKitMedia/Right.mov"),
            duration: CMTime(value: 216, timescale: 24),
            dimensions: CGSize(width: 1280, height: 720),
            frameRate: 24,
            hasVideo: true,
            hasAudio: true,
            audioChannels: 1,
            audioSampleRate: 48_000
        )
        let rawXML = MulticamXMLBuilder().generateMulticamFCPXML(
            leftSideVideo: left,
            rightSideVideo: right,
            projectName: "Typed Parity"
        )
        let parser = FCPXMLParser()
        let rawDocument = try parser.parse(xmlString: rawXML)
        let angles = try XCTUnwrap(rawDocument.resources?.media?.first(where: { $0.id == "r8" })?.multicam?.mcAngles)
        let angleIDs = try angles.map { try XCTUnwrap($0.angleID) }
        XCTAssertEqual(angleIDs.count, 3)

        let leftDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(left.duration)
        let rightDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(right.duration)
        let maxDuration = leftDuration
        let leftName = "Left"
        let rightName = "Right"
        let timestamp = "2026-07-17 12:00:00 -0400"
        let typed = FCPXML(
            version: "1.13",
            resources: Resources(
                assets: [
                    Asset(
                        id: "r4", name: leftName, uid: "LEFT-ASSET-UID", start: "0s",
                        duration: leftDuration, format: "r2", hasVideo: "1", hasAudio: "1",
                        audioChannels: "2", audioRate: "48000", videoSources: "1", audioSources: "1",
                        mediaRep: [MediaRep(kind: "original-media", sig: "LEFT-SIG", src: left.url.absoluteString)]
                    ),
                    Asset(
                        id: "r7", name: rightName, uid: "RIGHT-ASSET-UID", start: "0s",
                        duration: rightDuration, format: "r6", hasVideo: "1", hasAudio: "1",
                        audioChannels: "1", audioRate: "48000", videoSources: "1", audioSources: "1",
                        mediaRep: [MediaRep(kind: "original-media", sig: "RIGHT-SIG", src: right.url.absoluteString)]
                    ),
                ],
                formats: [
                    Format(
                        id: "r2", name: "FFVideoFormat1920x1080p24", frameDuration: "100/2400s",
                        width: "1920", height: "1080", colorSpace: "1-1-1 (Rec. 709)"
                    ),
                    Format(
                        id: "r6", name: "FFVideoFormat1280x720p24", frameDuration: "100/2400s",
                        width: "1280", height: "720", colorSpace: "1-1-1 (Rec. 709)"
                    ),
                ],
                media: [
                    Media(
                        id: "r1", name: "Both", uid: "BOTH-UID", modDate: timestamp,
                        sequence: Sequence(
                            format: "r2", duration: maxDuration, tcStart: "0s", tcFormat: "NDF",
                            spine: Spine(refClips: [
                                RefClip(
                                    ref: "r3", offset: "0s", name: leftName, duration: leftDuration,
                                    useAudioSubroles: "1",
                                    adjustTransform: AdjustTransform(position: "-33.9193 0"),
                                    refClips: [
                                        RefClip(
                                            ref: "r5", offset: "0s", name: rightName, duration: rightDuration,
                                            lane: "1", useAudioSubroles: "1",
                                            adjustTransform: AdjustTransform(position: "67.5926 0"),
                                            adjustCrop: AdjustCrop(mode: "trim", trimRect: TrimRect(left: "21.2963"))
                                        ),
                                    ]
                                ),
                            ])
                        )
                    ),
                    Media(
                        id: "r3", name: leftName, uid: "LEFT-MEDIA-UID", modDate: timestamp,
                        sequence: Sequence(
                            format: "r2", duration: leftDuration, tcStart: "0s", tcFormat: "NDF",
                            spine: Spine(assetClips: [
                                AssetClip(ref: "r4", name: leftName, duration: leftDuration, tcFormat: "NDF", audioRole: "dialogue", offset: "0s"),
                            ])
                        )
                    ),
                    Media(
                        id: "r5", name: rightName, uid: "RIGHT-MEDIA-UID", modDate: timestamp,
                        sequence: Sequence(
                            format: "r6", duration: rightDuration, tcStart: "0s", tcFormat: "NDF",
                            spine: Spine(assetClips: [
                                AssetClip(ref: "r7", name: rightName, duration: rightDuration, tcFormat: "NDF", audioRole: "dialogue", offset: "0s"),
                            ])
                        )
                    ),
                    Media(
                        id: "r8", name: "Multicam Clip", uid: "MULTICAM-UID", modDate: timestamp,
                        multicam: Multicam(
                            format: "r2", tcStart: "0s", tcFormat: "NDF",
                            mcAngles: [
                                MCAngle(name: "Both", angleID: angleIDs[0], refClips: [RefClip(ref: "r1", offset: "0s", name: "Both", duration: maxDuration, useAudioSubroles: "1")]),
                                MCAngle(name: leftName, angleID: angleIDs[1], refClips: [RefClip(ref: "r3", offset: "0s", name: leftName, duration: leftDuration, useAudioSubroles: "1")]),
                                MCAngle(name: rightName, angleID: angleIDs[2], refClips: [RefClip(ref: "r5", offset: "0s", name: rightName, duration: rightDuration, useAudioSubroles: "1")]),
                            ]
                        )
                    ),
                ]
            ),
            library: Library(
                location: "file:///Users/Shared/Generated.fcpbundle/",
                events: [
                    Event(
                        name: "Typed Parity", uid: "EVENT-UID",
                        refClips: [
                            RefClip(ref: "r1", name: "Both", duration: maxDuration, modDate: timestamp, useAudioSubroles: "1"),
                            RefClip(ref: "r3", name: leftName, duration: leftDuration, modDate: timestamp, useAudioSubroles: "1"),
                            RefClip(ref: "r5", name: rightName, duration: rightDuration, modDate: timestamp, useAudioSubroles: "1"),
                        ],
                        mcClips: [
                            MCClip(ref: "r8", name: "Multicam Clip", duration: maxDuration, modDate: timestamp, mcSources: [MCSource(angleID: angleIDs[0], srcEnable: "all")]),
                        ]
                    ),
                ],
                smartCollections: [
                    SmartCollection(name: "Projects", match: "all", matchClip: [MatchClip(rule: "is", type: "project")]),
                    SmartCollection(name: "All Video", match: "any", matchMedia: [MatchMedia(rule: "is", type: "videoOnly"), MatchMedia(rule: "is", type: "videoWithAudio")]),
                    SmartCollection(name: "Audio Only", match: "all", matchMedia: [MatchMedia(rule: "is", type: "audioOnly")]),
                    SmartCollection(name: "Stills", match: "all", matchMedia: [MatchMedia(rule: "is", type: "stills")]),
                    SmartCollection(name: "Favorites", match: "all", matchRatings: [MatchRatings(value: "favorites")]),
                ]
            )
        )

        let typedData = try parser.encode(typed)
        let rawData = try XCTUnwrap(rawXML.data(using: .utf8))
        let report = try RawPairAnalyzer().analyze(beforeData: rawData, afterData: typedData)

        XCTAssertEqual(report.findings, [])
    }
}

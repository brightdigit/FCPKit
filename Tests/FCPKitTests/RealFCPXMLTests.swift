import XCTest
@testable import FCPKit

final class RealFCPXMLTests: XCTestCase {
    
    func testParseInterviewFCPXMLFile() throws {
        let bundle = Bundle.module
        guard let fileURL = bundle.url(forResource: "Interview", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("Interview FCPXML test file not found")
        }
        
        let parser = FCPXMLParser()
        let fcpxml = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(fcpxml.version, "1.13")
        XCTAssertNotNil(fcpxml.resources)
        XCTAssertNotNil(fcpxml.library)
        
        let resources = try XCTUnwrap(fcpxml.resources)
        XCTAssertNotNil(resources.formats)
        XCTAssertNotNil(resources.assets)
        XCTAssertNotNil(resources.media)
        
        let library = try XCTUnwrap(fcpxml.library)
        XCTAssertNotNil(library.events)
        XCTAssertNotNil(library.smartCollections)
        XCTAssertNotNil(library.location)
        
        // Test that we have parsed media elements with sequences
        let mediaElements = try XCTUnwrap(resources.media)
        XCTAssertFalse(mediaElements.isEmpty)
        
        let firstMedia = try XCTUnwrap(mediaElements.first)
        XCTAssertEqual(firstMedia.name, "Interview")
        XCTAssertNotNil(firstMedia.sequence)
        
        // Test that we have parsed smart collections
        let smartCollections = try XCTUnwrap(library.smartCollections)
        XCTAssertFalse(smartCollections.isEmpty)
        XCTAssertTrue(smartCollections.contains { $0.name == "Projects" })
        
        print("✅ Successfully parsed Interview FCPXML file with version \(fcpxml.version)")
        print("✅ Found \(resources.media?.count ?? 0) media elements")
        print("✅ Found \(smartCollections.count) smart collections")
    }
    
    func testParseUntitledXMLFCPXMLFile() throws {
        let bundle = Bundle.module
        guard let fileURL = bundle.url(forResource: "UntitledXML", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("UntitledXML FCPXML test file not found")
        }
        
        let parser = FCPXMLParser()
        let fcpxml = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(fcpxml.version, "1.13")
        XCTAssertNotNil(fcpxml.resources)
        
        let resources = try XCTUnwrap(fcpxml.resources)
        XCTAssertNotNil(resources.formats)
        XCTAssertNotNil(resources.media)
        
        // Test that we have parsed media elements
        let mediaElements = try XCTUnwrap(resources.media)
        XCTAssertFalse(mediaElements.isEmpty)
        
        print("✅ Successfully parsed UntitledXML FCPXML file with version \(fcpxml.version)")
        print("✅ Found \(resources.media?.count ?? 0) media elements")
        print("✅ Found \(resources.formats?.count ?? 0) format definitions")
    }

    func testCrossDissolveCanBeReadMutatedAndRoundTripped() throws {
        let fileURL = try XCTUnwrap(
            Bundle.module.url(
                forResource: "UntitledXML",
                withExtension: "fcpxml",
                subdirectory: "TestData"
            )
        )
        let parser = FCPXMLParser()
        var document = try parser.parse(fileURL: fileURL)
        let originalTransition = try crossDissolve(in: document)
        let videoFilter = try XCTUnwrap(originalTransition.filterVideo?.first)
        let audioFilter = try XCTUnwrap(originalTransition.filterAudio?.first)
        let originalData = try XCTUnwrap(videoFilter.data?.first)

        XCTAssertEqual(videoFilter.name, "Cross Dissolve")
        XCTAssertEqual(audioFilter.name, "Audio Crossfade")
        XCTAssertEqual(videoFilter.param?.map(\.name), [
            "Look", "Amount", "Ease", "Ease Amount", "disableDRT",
        ])
        XCTAssertEqual(videoFilter.param?.first(where: { $0.name == "Amount" })?.value, "50")
        XCTAssertEqual(originalData.key, "effectConfig")
        XCTAssertFalse(try XCTUnwrap(originalData.value).isEmpty)

        let mediaIndex = try XCTUnwrap(document.resources?.media?.firstIndex { $0.name == "Music Intro" })
        let amountIndex = try XCTUnwrap(
            document.resources?.media?[mediaIndex].sequence?.spine?.transitions?[0]
                .filterVideo?[0].param?.firstIndex { $0.name == "Amount" }
        )
        document.resources?.media?[mediaIndex].sequence?.spine?.transitions?[0]
            .filterVideo?[0].param?[amountIndex].value = "65"

        let encoded = try parser.encode(document)
        let reparsed = try parser.parse(data: encoded)
        let reparsedTransition = try crossDissolve(in: reparsed)
        let reparsedVideo = try XCTUnwrap(reparsedTransition.filterVideo?.first)

        XCTAssertEqual(reparsedVideo.param?.first(where: { $0.name == "Amount" })?.value, "65")
        XCTAssertEqual(reparsedVideo.param?.count, 5)
        XCTAssertEqual(reparsedVideo.data?.first?.value, originalData.value)
        XCTAssertEqual(reparsedTransition.filterAudio?.first?.name, "Audio Crossfade")
    }

    func testSharedParametersAnimationsAndFadesCanBeReadAndMutated() throws {
        let fileURL = try XCTUnwrap(
            Bundle.module.url(
                forResource: "UntitledXML",
                withExtension: "fcpxml",
                subdirectory: "TestData"
            )
        )
        let parser = FCPXMLParser()
        var document = try parser.parse(fileURL: fileURL)
        let assetClips = document.resources?.media?.flatMap {
            $0.sequence?.spine?.assetClips ?? []
        } ?? []
        let titles = assetClips.flatMap { $0.titles ?? [] }
        let title = try XCTUnwrap(titles.first { $0.name?.contains("SyntaxKit") == true })
        let customSpeed = try XCTUnwrap(title.param?.first { $0.name == "Custom Speed" })
        let tracking = try XCTUnwrap(
            title.textStyleDef?.first?.textStyle?.param?.first?.param?.first
        )

        XCTAssertEqual(customSpeed.value, nil)
        XCTAssertEqual(customSpeed.keyframeAnimation?.keyframes?.map(\.value), ["0", "1"])
        XCTAssertEqual(tracking.name, "motionTextTracking")
        XCTAssertEqual(tracking.value, "-1.7751")

        let mediaIndex = try XCTUnwrap(document.resources?.media?.firstIndex { media in
            media.sequence?.spine?.assetClips?.contains {
                $0.adjustVolume?.param?.contains { $0.keyframeAnimation != nil } == true
            } == true
        })
        let assetIndex = try XCTUnwrap(
            document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?.firstIndex {
                $0.adjustVolume?.param?.contains { $0.keyframeAnimation != nil } == true
            }
        )
        let volume = try XCTUnwrap(
            document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?[assetIndex]
                .adjustVolume?.param?.first
        )
        XCTAssertEqual(volume.fadeIn?.type, "easeIn")
        XCTAssertEqual(volume.fadeOut?.duration, "1947511/720000s")
        XCTAssertEqual(volume.keyframeAnimation?.keyframes?.count, 3)

        document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?[assetIndex]
            .adjustVolume?.param?[0].keyframeAnimation?.keyframes?[2].value = "-3dB"
        let reparsed = try parser.parse(data: parser.encode(document))
        let changedVolume = try XCTUnwrap(
            reparsed.resources?.media?[mediaIndex].sequence?.spine?.assetClips?[assetIndex]
                .adjustVolume?.param?.first
        )

        XCTAssertEqual(changedVolume.keyframeAnimation?.keyframes?[2].value, "-3dB")
        XCTAssertEqual(changedVolume.fadeIn?.type, "easeIn")
        XCTAssertEqual(changedVolume.fadeOut?.duration, "1947511/720000s")
        XCTAssertEqual(changedVolume.keyframeAnimation?.keyframes?.count, 3)
    }

    private func crossDissolve(in document: FCPXML) throws -> Transition {
        let media = try XCTUnwrap(document.resources?.media?.first { $0.name == "Music Intro" })
        return try XCTUnwrap(media.sequence?.spine?.transitions?.first)
    }
    
    func testFCPXMLElementCoverage() throws {
        let bundle = Bundle.module
        
        // Test Interview FCPXML elements
        guard let interviewURL = bundle.url(forResource: "Interview", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("Interview FCPXML test file not found")
        }
        
        let interviewData = try Data(contentsOf: interviewURL)
        let interviewString = String(data: interviewData, encoding: .utf8)!
        
        XCTAssertTrue(interviewString.contains("mc-clip"))
        XCTAssertTrue(interviewString.contains("mc-source"))
        XCTAssertTrue(interviewString.contains("multicam"))
        XCTAssertTrue(interviewString.contains("ref-clip"))
        XCTAssertTrue(interviewString.contains("asset-clip"))
        XCTAssertTrue(interviewString.contains("media-rep"))
        XCTAssertTrue(interviewString.contains("smart-collection"))
        
        // Test UntitledXML FCPXML elements
        guard let untitledURL = bundle.url(forResource: "UntitledXML", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("UntitledXML FCPXML test file not found")
        }
        
        let untitledData = try Data(contentsOf: untitledURL)
        let untitledString = String(data: untitledData, encoding: .utf8)!
        
        XCTAssertTrue(untitledString.contains("sync-clip"))
        XCTAssertTrue(untitledString.contains("adjust-transform"))
        XCTAssertTrue(untitledString.contains("adjust-crop"))
        XCTAssertTrue(untitledString.contains("filter-video"))
        XCTAssertTrue(untitledString.contains("conform-rate"))
        XCTAssertTrue(untitledString.contains("timeMap"))
        
        print("✅ FCPXML files contain comprehensive element coverage")
        print("✅ Interview file: multicam, smart collections, media references")
        print("✅ UntitledXML file: sync clips, transforms, filters, time mapping")
    }
    
    func testParseBothMulticamFCPXMLFile() throws {
        let bundle = Bundle.module
        guard let fileURL = bundle.url(forResource: "Both-Multicam", withExtension: "fcpxml", subdirectory: "TestData") else {
            throw XCTSkip("Both-Multicam FCPXML test file not found")
        }
        
        let parser = FCPXMLParser()
        let fcpxml = try parser.parse(fileURL: fileURL)
        
        // Basic assertions
        XCTAssertEqual(fcpxml.version, "1.13")
        XCTAssertNotNil(fcpxml.resources)
        XCTAssertNotNil(fcpxml.library)
        
        let resources = try XCTUnwrap(fcpxml.resources)
        let library = try XCTUnwrap(fcpxml.library)
        
        // Test media elements
        let mediaElements = try XCTUnwrap(resources.media)
        XCTAssertEqual(mediaElements.count, 4) // Both, Leo, Rachel, Multicam Clip
        
        // Find and test the "Both" media with nested sequences
        let bothMedia = mediaElements.first { $0.name == "Both" }
        XCTAssertNotNil(bothMedia)
        let bothSequence = try XCTUnwrap(bothMedia?.sequence)
        XCTAssertNotNil(bothSequence.spine)
        
        // Find and test the multicam media
        let multicamMedia = mediaElements.first { $0.name == "Multicam Clip" }
        XCTAssertNotNil(multicamMedia)
        XCTAssertNotNil(multicamMedia?.multicam)
        
        let multicam = try XCTUnwrap(multicamMedia?.multicam)
        XCTAssertEqual(multicam.tcFormat, "NDF")
        XCTAssertNotNil(multicam.mcAngles)
        
        let mcAngles = try XCTUnwrap(multicam.mcAngles)
        XCTAssertEqual(mcAngles.count, 3) // Both, Leo, Rachel angles
        
        // Verify angle names
        let angleNames = mcAngles.compactMap { $0.name }
        XCTAssertTrue(angleNames.contains("Both"))
        XCTAssertTrue(angleNames.contains("Leo"))
        XCTAssertTrue(angleNames.contains("Rachel"))
        
        // Test library event
        let events = try XCTUnwrap(library.events)
        XCTAssertFalse(events.isEmpty)
        
        let firstEvent = try XCTUnwrap(events.first)
        XCTAssertEqual(firstEvent.name, "EAS-202")
        
        // Check ref-clips in event
        let refClips = try XCTUnwrap(firstEvent.refClips)
        XCTAssertEqual(refClips.count, 3) // Both, Leo, Rachel
        
        // Note: mc-clip elements at the event level are not currently parsed by FCPKit
        // The mc-clip "Multicam Clip" in the FCPXML is being ignored
        // Only ref-clips are parsed at the event level
        
        // Test assets
        let assets = try XCTUnwrap(resources.assets)
        XCTAssertEqual(assets.count, 2) // Leo and Rachel video assets
        
        // Verify both assets have media representations
        for asset in assets {
            XCTAssertNotNil(asset.mediaRep)
            XCTAssertEqual(asset.hasVideo, "1")
            XCTAssertEqual(asset.hasAudio, "1")
        }
        
        print("✅ Successfully parsed Both-Multicam FCPXML file with version \(fcpxml.version)")
        print("✅ Found \(mediaElements.count) media elements including multicam")
        print("✅ Found \(mcAngles.count) multicam angles: \(angleNames.joined(separator: ", "))")
        print("⚠️  Note: mc-clip in event is not parsed (FCPKit limitation)")
    }
}

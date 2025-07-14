import XCTest
import CoreMedia
import AVFoundation
@testable import FCPKitMediaTools

final class MulticamXMLBuilderTests: XCTestCase {
    
    func testDefaultValuesMatchExpectedXML() throws {
        // Create test video metadata
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
        
        let builder = MulticamXMLBuilder()
        let xml = builder.generateMulticamFCPXML(
            leftSideVideo: leftVideo,
            rightSideVideo: rightVideo,
            projectName: "Test Project"
        )
        
        // Verify the hardcoded values appear in the output
        XCTAssertTrue(xml.contains("<adjust-transform position=\"-33.9193 0\"/>"), 
                     "Left side video offset should be -33.9193")
        XCTAssertTrue(xml.contains("<trim-rect left=\"21.2963\"/>"), 
                     "Right side video left trim should be 21.2963")
        XCTAssertTrue(xml.contains("<adjust-transform position=\"67.5926 0\"/>"), 
                     "Right side video offset should be 67.5926")
        
        // Verify video names are used correctly
        XCTAssertTrue(xml.contains("name=\"Leo\""))
        XCTAssertTrue(xml.contains("name=\"Rachel\""))
    }
    
    func testCustomValuesAreAppliedCorrectly() throws {
        // Create test video metadata
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
        
        let builder = MulticamXMLBuilder()
        let xml = builder.generateMulticamFCPXML(
            leftSideVideo: leftVideo,
            rightSideVideo: rightVideo,
            projectName: "Custom Test",
            leftSideVideoOffset: -50.0,
            rightSideVideoLeftTrim: 30.0,
            rightSideVideoOffset: 100.0
        )
        
        // Verify custom values appear in the output
        XCTAssertTrue(xml.contains("<adjust-transform position=\"-50.0 0\"/>"), 
                     "Custom left side video offset should be -50.0")
        XCTAssertTrue(xml.contains("<trim-rect left=\"30.0\"/>"), 
                     "Custom right side video left trim should be 30.0")
        XCTAssertTrue(xml.contains("<adjust-transform position=\"100.0 0\"/>"), 
                     "Custom right side video offset should be 100.0")
        
        // Verify video names are used correctly
        XCTAssertTrue(xml.contains("name=\"LeftVideo\""))
        XCTAssertTrue(xml.contains("name=\"RightVideo\""))
    }
}
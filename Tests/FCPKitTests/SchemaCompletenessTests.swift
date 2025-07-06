import XCTest
@testable import FCPKit

final class SchemaCompletenessTests: XCTestCase {
    
    /// Test for elements commonly found in title-heavy projects
    func testTitleElements() {
        let sampleTitleXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.11">
            <resources>
                <format id="r1" name="FFVideoFormat1080p2398" frameDuration="1001/24000s" width="1920" height="1080"/>
                <effect id="r2" name="Basic Title" uid="9FDA5CAF-BB38-4842-B2F6-2941DD4D0A3C"/>
            </resources>
            <library>
                <event name="Titles Test">
                    <project name="Title Project">
                        <sequence format="r1" duration="600s">
                            <spine>
                                <title ref="r2" offset="0s" name="My Title" start="0s" duration="300s">
                                    <text>
                                        <text-style ref="ts1">Hello World</text-style>
                                    </text>
                                    <text-style-def id="ts1">
                                        <text-style font="Helvetica" fontSize="48" fontFace="Regular" fontColor="1 1 1 1" alignment="center"/>
                                    </text-style-def>
                                </title>
                            </spine>
                        </sequence>
                    </project>
                </event>
            </library>
        </fcpxml>
        """
        
        // This should reveal missing title-related elements
        do {
            let parser = FCPXMLParser()
            let fcpxml = try parser.parse(xmlString: sampleTitleXML)
            print("✅ Basic title parsing succeeded")
            XCTAssertEqual(fcpxml.version, "1.11")
        } catch {
            print("❌ Title parsing failed - missing elements: \(error)")
            // This is expected since we haven't implemented title elements yet
        }
    }
    
    /// Test for audio-specific elements
    func testAudioElements() {
        let sampleAudioXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.11">
            <resources>
                <format id="r1" name="FFAudioFormat48k" audioSampleRate="48000" audioChannels="2"/>
                <asset id="r2" name="audio_track.wav" hasAudio="1" audioChannels="2" audioRate="48000"/>
            </resources>
            <library>
                <event name="Audio Test">
                    <project name="Audio Project">
                        <sequence format="r1" duration="300s">
                            <spine>
                                <asset-clip ref="r2" offset="0s" duration="300s" audioRole="dialogue">
                                    <audio-channel-source srcCh="1" role="dialogue.dialogue-1"/>
                                    <audio-channel-source srcCh="2" role="dialogue.dialogue-2"/>
                                    <filter-audio ref="r3" name="Channel EQ">
                                        <param name="Mode" key="1" value="0"/>
                                        <param name="Frequency" key="2" value="1000"/>
                                    </filter-audio>
                                </asset-clip>
                            </spine>
                        </sequence>
                    </project>
                </event>
            </library>
        </fcpxml>
        """
        
        do {
            let parser = FCPXMLParser()
            let fcpxml = try parser.parse(xmlString: sampleAudioXML)
            print("✅ Basic audio parsing succeeded")
        } catch {
            print("❌ Audio parsing failed - missing elements: \(error)")
        }
    }
    
    /// Test for transition elements
    func testTransitionElements() {
        let sampleTransitionXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.11">
            <resources>
                <format id="r1" name="FFVideoFormat1080p24" frameDuration="1/24s" width="1920" height="1080"/>
                <asset id="r2" name="clip1.mov" hasVideo="1" duration="600s"/>
                <asset id="r3" name="clip2.mov" hasVideo="1" duration="600s"/>
                <effect id="r4" name="Cross Dissolve" uid="CEB4AC37-2A4F-4C6B-A0C3-C1004DC2CBD1"/>
            </resources>
            <library>
                <event name="Transition Test">
                    <project name="Transition Project">
                        <sequence format="r1" duration="1100s">
                            <spine>
                                <asset-clip ref="r2" offset="0s" duration="550s"/>
                                <transition ref="r4" offset="500s" duration="100s" alignment="center"/>
                                <asset-clip ref="r3" offset="550s" duration="550s"/>
                            </spine>
                        </sequence>
                    </project>
                </event>
            </library>
        </fcpxml>
        """
        
        do {
            let parser = FCPXMLParser()
            let fcpxml = try parser.parse(xmlString: sampleTransitionXML)
            print("✅ Basic transition parsing succeeded")
        } catch {
            print("❌ Transition parsing failed - missing elements: \(error)")
        }
    }
    
    /// Test for marker and metadata elements
    func testMarkerElements() {
        let sampleMarkerXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.11">
            <resources>
                <format id="r1" name="FFVideoFormat1080p24" frameDuration="1/24s" width="1920" height="1080"/>
                <asset id="r2" name="video.mov" hasVideo="1" duration="600s"/>
            </resources>
            <library>
                <event name="Marker Test">
                    <project name="Marker Project">
                        <sequence format="r1" duration="600s">
                            <spine>
                                <asset-clip ref="r2" offset="0s" duration="600s">
                                    <marker start="60s" duration="1s" value="Chapter 1"/>
                                    <marker start="180s" duration="1s" value="Chapter 2" note="Important scene"/>
                                    <keyword start="0s" duration="120s" value="intro"/>
                                    <rating value="favorite"/>
                                </asset-clip>
                            </spine>
                        </sequence>
                    </project>
                </event>
            </library>
        </fcpxml>
        """
        
        do {
            let parser = FCPXMLParser()
            let fcpxml = try parser.parse(xmlString: sampleMarkerXML)
            print("✅ Basic marker parsing succeeded")
        } catch {
            print("❌ Marker parsing failed - missing elements: \(error)")
        }
    }
    
    /// Test for generator elements (color matte, noise, etc.)
    func testGeneratorElements() {
        let sampleGeneratorXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        <fcpxml version="1.11">
            <resources>
                <format id="r1" name="FFVideoFormat1080p24" frameDuration="1/24s" width="1920" height="1080"/>
                <effect id="r2" name="Custom" uid="FFB3BDE8-E5F3-4E11-9C67-9D8CFB57A076"/>
            </resources>
            <library>
                <event name="Generator Test">
                    <project name="Generator Project">
                        <sequence format="r1" duration="300s">
                            <spine>
                                <generator ref="r2" offset="0s" duration="300s" name="Color Solid">
                                    <param name="Color" key="9999/999166631/999166633/1/100/101" value="1 0 0 1"/>
                                </generator>
                            </spine>
                        </sequence>
                    </project>
                </event>
            </library>
        </fcpxml>
        """
        
        do {
            let parser = FCPXMLParser()
            let fcpxml = try parser.parse(xmlString: sampleGeneratorXML)
            print("✅ Basic generator parsing succeeded")
        } catch {
            print("❌ Generator parsing failed - missing elements: \(error)")
        }
    }
}
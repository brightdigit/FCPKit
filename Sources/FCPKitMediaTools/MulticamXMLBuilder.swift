import Foundation
import CoreMedia

/// Builds FCPXML content directly as XML strings for multicam projects
public class MulticamXMLBuilder {
    
    public init() {}
    
    /// Generates a complete multicam FCPXML document from two video files
    /// - Parameters:
    ///   - video1: Metadata for first video (Leo)
    ///   - video2: Metadata for second video (Rachel)
    ///   - projectName: Name for the project (default: "Multicam Project")
    /// - Returns: Complete FCPXML document as XML string
    public func generateMulticamFCPXML(
        video1: VideoMetadata,
        video2: VideoMetadata,
        projectName: String = "Multicam Project"
    ) -> String {
        
        let currentTime = FCPXMLUtilities.currentTimestamp()
        let maxDuration = video1.duration > video2.duration ? video1.duration : video2.duration
        
        // Generate unique IDs
        let bothUID = FCPXMLUtilities.generateUID()
        let video1UID = FCPXMLUtilities.generateUID()
        let video2UID = FCPXMLUtilities.generateUID()
        let multicamUID = FCPXMLUtilities.generateUID()
        let eventUID = FCPXMLUtilities.generateUID()
        
        let angle1ID = FCPXMLUtilities.generateUID()
        let angle2ID = FCPXMLUtilities.generateUID()
        let angle3ID = FCPXMLUtilities.generateUID()
        
        // Generate asset signatures
        let video1Sig = FCPXMLUtilities.generateAssetSignature(from: video1)
        let video2Sig = FCPXMLUtilities.generateAssetSignature(from: video2)
        
        let video1Name = video1.url.deletingPathExtension().lastPathComponent
        let video2Name = video2.url.deletingPathExtension().lastPathComponent
        
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        
        <fcpxml version="1.13">
            <resources>
                <media id="r1" name="Both" uid="\(bothUID)" modDate="\(currentTime)">
                    <sequence format="r2" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" tcStart="0s" tcFormat="NDF">
                        <spine>
                            <ref-clip ref="r3" offset="0s" name="\(video1Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video1.duration))" useAudioSubroles="1">
                                <adjust-transform position="-33.9193 0"/>
                                <ref-clip ref="r5" lane="1" offset="0s" name="\(video2Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video2.duration))" useAudioSubroles="1">
                                    <adjust-crop mode="trim">
                                        <trim-rect left="21.2963"/>
                                    </adjust-crop>
                                    <adjust-transform position="67.5926 0"/>
                                </ref-clip>
                            </ref-clip>
                        </spine>
                    </sequence>
                </media>
                <format id="r2" name="\(FCPXMLUtilities.generateFormatName(dimensions: video1.dimensions, frameRate: video1.frameRate))" frameDuration="\(FCPXMLUtilities.frameDurationFromFrameRate(video1.frameRate))" width="\(Int(video1.dimensions.width))" height="\(Int(video1.dimensions.height))" colorSpace="1-1-1 (Rec. 709)"/>
                <media id="r3" name="\(video1Name)" uid="\(video1UID)" modDate="\(currentTime)">
                    <sequence format="r2" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video1.duration))" tcStart="0s" tcFormat="NDF">
                        <spine>
                            <asset-clip ref="r4" offset="0s" name="\(video1Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video1.duration))" tcFormat="NDF" audioRole="dialogue"/>
                        </spine>
                    </sequence>
                </media>
                <asset id="r4" name="\(video1Name)" uid="\(video1Sig)" start="0s" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video1.duration))" hasVideo="1" format="r2" hasAudio="1" videoSources="1" audioSources="1" audioChannels="\(video1.audioChannels ?? 1)" audioRate="\(Int(video1.audioSampleRate ?? 48000))">
                    <media-rep kind="original-media" sig="\(video1Sig)" src="\(FCPXMLUtilities.formatFileURL(video1.url))"/>
                </asset>
                <media id="r5" name="\(video2Name)" uid="\(video2UID)" modDate="\(currentTime)">
                    <sequence format="r6" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video2.duration))" tcStart="0s" tcFormat="NDF">
                        <spine>
                            <asset-clip ref="r7" offset="0s" name="\(video2Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video2.duration))" tcFormat="NDF" audioRole="dialogue"/>
                        </spine>
                    </sequence>
                </media>
                <format id="r6" name="\(FCPXMLUtilities.generateFormatName(dimensions: video2.dimensions, frameRate: video2.frameRate))" frameDuration="\(FCPXMLUtilities.frameDurationFromFrameRate(video2.frameRate))" width="\(Int(video2.dimensions.width))" height="\(Int(video2.dimensions.height))" colorSpace="1-1-1 (Rec. 709)"/>
                <asset id="r7" name="\(video2Name)" uid="\(video2Sig)" start="0s" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video2.duration))" hasVideo="1" format="r6" hasAudio="1" videoSources="1" audioSources="1" audioChannels="\(video2.audioChannels ?? 1)" audioRate="\(Int(video2.audioSampleRate ?? 48000))">
                    <media-rep kind="original-media" sig="\(video2Sig)" src="\(FCPXMLUtilities.formatFileURL(video2.url))"/>
                </asset>
                <media id="r8" name="Multicam Clip" uid="\(multicamUID)" modDate="\(currentTime)">
                    <multicam format="r2" tcStart="0s" tcFormat="NDF">
                        <mc-angle name="Both" angleID="\(angle1ID)">
                            <ref-clip ref="r1" offset="0s" name="Both" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" useAudioSubroles="1"/>
                        </mc-angle>
                        <mc-angle name="\(video1Name)" angleID="\(angle2ID)">
                            <ref-clip ref="r3" offset="0s" name="\(video1Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video1.duration))" useAudioSubroles="1"/>
                        </mc-angle>
                        <mc-angle name="\(video2Name)" angleID="\(angle3ID)">
                            <ref-clip ref="r5" offset="0s" name="\(video2Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video2.duration))" useAudioSubroles="1"/>
                        </mc-angle>
                    </multicam>
                </media>
            </resources>
            <library location="file:///Users/Shared/Generated.fcpbundle/">
                <event name="\(projectName)" uid="\(eventUID)">
                    <ref-clip ref="r1" name="Both" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" useAudioSubroles="1" modDate="\(currentTime)"/>
                    <ref-clip ref="r3" name="\(video1Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video1.duration))" useAudioSubroles="1" modDate="\(currentTime)"/>
                    <mc-clip ref="r8" name="Multicam Clip" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" modDate="\(currentTime)">
                        <mc-source angleID="\(angle1ID)" srcEnable="all"/>
                    </mc-clip>
                    <ref-clip ref="r5" name="\(video2Name)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(video2.duration))" useAudioSubroles="1" modDate="\(currentTime)"/>
                </event>
                <smart-collection name="Projects" match="all">
                    <match-clip rule="is" type="project"/>
                </smart-collection>
                <smart-collection name="All Video" match="any">
                    <match-media rule="is" type="videoOnly"/>
                    <match-media rule="is" type="videoWithAudio"/>
                </smart-collection>
                <smart-collection name="Audio Only" match="all">
                    <match-media rule="is" type="audioOnly"/>
                </smart-collection>
                <smart-collection name="Stills" match="all">
                    <match-media rule="is" type="stills"/>
                </smart-collection>
                <smart-collection name="Favorites" match="all">
                    <match-ratings value="favorites"/>
                </smart-collection>
            </library>
        </fcpxml>
        """
        
        return xml
    }
}
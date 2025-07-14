import Foundation
import CoreMedia

/// Builds FCPXML content directly as XML strings for multicam projects
public class MulticamXMLBuilder {
    
    public init() {}
    
    /// Generates a complete multicam FCPXML document from two video files
    /// - Parameters:
    ///   - leftSideVideo: Metadata for left side video
    ///   - rightSideVideo: Metadata for right side video
    ///   - projectName: Name for the project (default: "Multicam Project")
    ///   - leftSideVideoOffset: Horizontal offset for left side video position (default: -33.9193)
    ///   - rightSideVideoLeftTrim: Left trim amount for right side video (default: 21.2963)
    ///   - rightSideVideoOffset: Horizontal offset for right side video position (default: 67.5926)
    /// - Returns: Complete FCPXML document as XML string
    public func generateMulticamFCPXML(
        leftSideVideo: VideoMetadata,
        rightSideVideo: VideoMetadata,
        projectName: String = "Multicam Project",
        leftSideVideoOffset: Double = -33.9193,
        rightSideVideoLeftTrim: Double = 21.2963,
        rightSideVideoOffset: Double = 67.5926
    ) -> String {
        
        let currentTime = FCPXMLUtilities.currentTimestamp()
        let maxDuration = leftSideVideo.duration > rightSideVideo.duration ? leftSideVideo.duration : rightSideVideo.duration
        
        // Generate unique IDs
        let bothUID = FCPXMLUtilities.generateUID()
        let leftSideVideoUID = FCPXMLUtilities.generateUID()
        let rightSideVideoUID = FCPXMLUtilities.generateUID()
        let multicamUID = FCPXMLUtilities.generateUID()
        let eventUID = FCPXMLUtilities.generateUID()
        
        let angle1ID = FCPXMLUtilities.generateUID()
        let angle2ID = FCPXMLUtilities.generateUID()
        let angle3ID = FCPXMLUtilities.generateUID()
        
        // Generate asset signatures
        let leftSideVideoSig = FCPXMLUtilities.generateAssetSignature(from: leftSideVideo)
        let rightSideVideoSig = FCPXMLUtilities.generateAssetSignature(from: rightSideVideo)
        
        let leftSideVideoName = leftSideVideo.url.deletingPathExtension().lastPathComponent
        let rightSideVideoName = rightSideVideo.url.deletingPathExtension().lastPathComponent
        
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fcpxml>
        
        <fcpxml version="1.13">
            <resources>
                <media id="r1" name="Both" uid="\(bothUID)" modDate="\(currentTime)">
                    <sequence format="r2" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" tcStart="0s" tcFormat="NDF">
                        <spine>
                            <ref-clip ref="r3" offset="0s" name="\(leftSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration))" useAudioSubroles="1">
                                <adjust-transform position="\(leftSideVideoOffset) 0"/>
                                <ref-clip ref="r5" lane="1" offset="0s" name="\(rightSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration))" useAudioSubroles="1">
                                    <adjust-crop mode="trim">
                                        <trim-rect left="\(rightSideVideoLeftTrim)"/>
                                    </adjust-crop>
                                    <adjust-transform position="\(rightSideVideoOffset) 0"/>
                                </ref-clip>
                            </ref-clip>
                        </spine>
                    </sequence>
                </media>
                <format id="r2" name="\(FCPXMLUtilities.generateFormatName(dimensions: leftSideVideo.dimensions, frameRate: leftSideVideo.frameRate))" frameDuration="\(FCPXMLUtilities.frameDurationFromFrameRate(leftSideVideo.frameRate))" width="\(Int(leftSideVideo.dimensions.width))" height="\(Int(leftSideVideo.dimensions.height))" colorSpace="1-1-1 (Rec. 709)"/>
                <media id="r3" name="\(leftSideVideoName)" uid="\(leftSideVideoUID)" modDate="\(currentTime)">
                    <sequence format="r2" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration))" tcStart="0s" tcFormat="NDF">
                        <spine>
                            <asset-clip ref="r4" offset="0s" name="\(leftSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration))" tcFormat="NDF" audioRole="dialogue"/>
                        </spine>
                    </sequence>
                </media>
                <asset id="r4" name="\(leftSideVideoName)" uid="\(leftSideVideoSig)" start="0s" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration))" hasVideo="1" format="r2" hasAudio="1" videoSources="1" audioSources="1" audioChannels="\(leftSideVideo.audioChannels ?? 1)" audioRate="\(Int(leftSideVideo.audioSampleRate ?? 48000))">
                    <media-rep kind="original-media" sig="\(leftSideVideoSig)" src="\(FCPXMLUtilities.formatFileURL(leftSideVideo.url))"/>
                </asset>
                <media id="r5" name="\(rightSideVideoName)" uid="\(rightSideVideoUID)" modDate="\(currentTime)">
                    <sequence format="r6" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration))" tcStart="0s" tcFormat="NDF">
                        <spine>
                            <asset-clip ref="r7" offset="0s" name="\(rightSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration))" tcFormat="NDF" audioRole="dialogue"/>
                        </spine>
                    </sequence>
                </media>
                <format id="r6" name="\(FCPXMLUtilities.generateFormatName(dimensions: rightSideVideo.dimensions, frameRate: rightSideVideo.frameRate))" frameDuration="\(FCPXMLUtilities.frameDurationFromFrameRate(rightSideVideo.frameRate))" width="\(Int(rightSideVideo.dimensions.width))" height="\(Int(rightSideVideo.dimensions.height))" colorSpace="1-1-1 (Rec. 709)"/>
                <asset id="r7" name="\(rightSideVideoName)" uid="\(rightSideVideoSig)" start="0s" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration))" hasVideo="1" format="r6" hasAudio="1" videoSources="1" audioSources="1" audioChannels="\(rightSideVideo.audioChannels ?? 1)" audioRate="\(Int(rightSideVideo.audioSampleRate ?? 48000))">
                    <media-rep kind="original-media" sig="\(rightSideVideoSig)" src="\(FCPXMLUtilities.formatFileURL(rightSideVideo.url))"/>
                </asset>
                <media id="r8" name="Multicam Clip" uid="\(multicamUID)" modDate="\(currentTime)">
                    <multicam format="r2" tcStart="0s" tcFormat="NDF">
                        <mc-angle name="Both" angleID="\(angle1ID)">
                            <ref-clip ref="r1" offset="0s" name="Both" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" useAudioSubroles="1"/>
                        </mc-angle>
                        <mc-angle name="\(leftSideVideoName)" angleID="\(angle2ID)">
                            <ref-clip ref="r3" offset="0s" name="\(leftSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration))" useAudioSubroles="1"/>
                        </mc-angle>
                        <mc-angle name="\(rightSideVideoName)" angleID="\(angle3ID)">
                            <ref-clip ref="r5" offset="0s" name="\(rightSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration))" useAudioSubroles="1"/>
                        </mc-angle>
                    </multicam>
                </media>
            </resources>
            <library location="file:///Users/Shared/Generated.fcpbundle/">
                <event name="\(projectName)" uid="\(eventUID)">
                    <ref-clip ref="r1" name="Both" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" useAudioSubroles="1" modDate="\(currentTime)"/>
                    <ref-clip ref="r3" name="\(leftSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration))" useAudioSubroles="1" modDate="\(currentTime)"/>
                    <mc-clip ref="r8" name="Multicam Clip" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDuration))" modDate="\(currentTime)">
                        <mc-source angleID="\(angle1ID)" srcEnable="all"/>
                    </mc-clip>
                    <ref-clip ref="r5" name="\(rightSideVideoName)" duration="\(FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration))" useAudioSubroles="1" modDate="\(currentTime)"/>
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
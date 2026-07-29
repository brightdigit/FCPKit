//
//  MulticamXMLBuilder.swift
//  FCPKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import FCPKit
import Foundation

#if canImport(CoreMedia)
  import CoreMedia

  /// Builds multicam FCPXML documents through the typed FCPKit model.
  ///
  /// Available only on platforms that provide CoreMedia, because it builds from `VideoMetadata`.
  public class MulticamXMLBuilder {
    /// Values derived once per document and shared by the sub-builders.
    private struct BuildContext {
      let currentTime: String
      let leftDuration: String
      let rightDuration: String
      let maxDuration: String
      let leftName: String
      let rightName: String
      let bothUID: String
      let leftMediaUID: String
      let rightMediaUID: String
      let multicamUID: String
      let eventUID: String
      let angleBothID: String
      let angleLeftID: String
      let angleRightID: String
      let leftSig: String
      let rightSig: String
      let leftFormatName: String
      let rightFormatName: String
    }

    /// Creates a builder.
    public init() {}

    /// Generates a complete multicam FCPXML document from two video files.
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
      let document = generateMulticamDocument(
        leftSideVideo: leftSideVideo,
        rightSideVideo: rightSideVideo,
        projectName: projectName,
        leftSideVideoOffset: leftSideVideoOffset,
        rightSideVideoLeftTrim: rightSideVideoLeftTrim,
        rightSideVideoOffset: rightSideVideoOffset
      )
      do {
        return try FCPXMLParser().encodeToString(document)
      } catch {
        preconditionFailure("Failed to encode multicam FCPXML: \(error)")
      }
    }

    /// Builds the typed multicam document used for encoding and tests.
    public func generateMulticamDocument(
      leftSideVideo: VideoMetadata,
      rightSideVideo: VideoMetadata,
      projectName: String = "Multicam Project",
      leftSideVideoOffset: Double = -33.9193,
      rightSideVideoLeftTrim: Double = 21.2963,
      rightSideVideoOffset: Double = 67.5926
    ) -> FCPXML {
      let currentTime = FCPXMLUtilities.currentTimestamp()
      let maxDurationTime =
        leftSideVideo.duration > rightSideVideo.duration
        ? leftSideVideo.duration
        : rightSideVideo.duration

      let leftDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration)
      let rightDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration)
      let maxDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDurationTime)

      let leftName = leftSideVideo.url.deletingPathExtension().lastPathComponent
      let rightName = rightSideVideo.url.deletingPathExtension().lastPathComponent

      let bothUID = FCPXMLUtilities.generateUID()
      let leftMediaUID = FCPXMLUtilities.generateUID()
      let rightMediaUID = FCPXMLUtilities.generateUID()
      let multicamUID = FCPXMLUtilities.generateUID()
      let eventUID = FCPXMLUtilities.generateUID()
      let angleBothID = FCPXMLUtilities.generateUID()
      let angleLeftID = FCPXMLUtilities.generateUID()
      let angleRightID = FCPXMLUtilities.generateUID()

      let leftSig = FCPXMLUtilities.generateAssetSignature(from: leftSideVideo)
      let rightSig = FCPXMLUtilities.generateAssetSignature(from: rightSideVideo)

      let leftFormatName = FCPXMLUtilities.generateFormatName(
        dimensions: leftSideVideo.dimensions,
        frameRate: leftSideVideo.frameRate
      )
      let rightFormatName = FCPXMLUtilities.generateFormatName(
        dimensions: rightSideVideo.dimensions,
        frameRate: rightSideVideo.frameRate
      )

      let context = BuildContext(
        currentTime: currentTime,
        leftDuration: leftDuration,
        rightDuration: rightDuration,
        maxDuration: maxDuration,
        leftName: leftName,
        rightName: rightName,
        bothUID: bothUID,
        leftMediaUID: leftMediaUID,
        rightMediaUID: rightMediaUID,
        multicamUID: multicamUID,
        eventUID: eventUID,
        angleBothID: angleBothID,
        angleLeftID: angleLeftID,
        angleRightID: angleRightID,
        leftSig: leftSig,
        rightSig: rightSig,
        leftFormatName: leftFormatName,
        rightFormatName: rightFormatName
      )

      return FCPXML(
        version: FCPXMLVersion.supportedGenerationVersion.rawValue,
        resources: Resources(
          assets: buildAssets(
            leftSideVideo: leftSideVideo,
            rightSideVideo: rightSideVideo,
            context: context
          ),
          formats: buildFormats(
            leftSideVideo: leftSideVideo,
            rightSideVideo: rightSideVideo,
            context: context
          ),
          media: buildMedia(
            leftSideVideoOffset: leftSideVideoOffset,
            rightSideVideoLeftTrim: rightSideVideoLeftTrim,
            rightSideVideoOffset: rightSideVideoOffset,
            context: context
          )
        ),
        library: buildLibrary(projectName: projectName, context: context)
      )
    }

    /// Builds the asset entries for the two source videos.
    private func buildAssets(
      leftSideVideo: VideoMetadata,
      rightSideVideo: VideoMetadata,
      context: BuildContext
    ) -> [Asset] {
      [
        Asset(
          id: "r4",
          name: context.leftName,
          uid: context.leftSig,
          start: "0s",
          duration: context.leftDuration,
          format: "r2",
          hasVideo: leftSideVideo.hasVideo ? "1" : "0",
          hasAudio: leftSideVideo.hasAudio ? "1" : "0",
          audioChannels: "\(leftSideVideo.audioChannels ?? 1)",
          audioRate: "\(Int(leftSideVideo.audioSampleRate ?? 48_000))",
          videoSources: "1",
          audioSources: "1",
          mediaRep: [
            MediaRep(
              kind: "original-media",
              sig: context.leftSig,
              src: FCPXMLUtilities.formatFileURL(leftSideVideo.url)
            )
          ]
        ),
        Asset(
          id: "r7",
          name: context.rightName,
          uid: context.rightSig,
          start: "0s",
          duration: context.rightDuration,
          format: "r6",
          hasVideo: rightSideVideo.hasVideo ? "1" : "0",
          hasAudio: rightSideVideo.hasAudio ? "1" : "0",
          audioChannels: "\(rightSideVideo.audioChannels ?? 1)",
          audioRate: "\(Int(rightSideVideo.audioSampleRate ?? 48_000))",
          videoSources: "1",
          audioSources: "1",
          mediaRep: [
            MediaRep(
              kind: "original-media",
              sig: context.rightSig,
              src: FCPXMLUtilities.formatFileURL(rightSideVideo.url)
            )
          ]
        ),
      ]
    }

    /// Builds the format entries for the two source videos.
    private func buildFormats(
      leftSideVideo: VideoMetadata,
      rightSideVideo: VideoMetadata,
      context: BuildContext
    ) -> [Format] {
      [
        Format(
          id: "r2",
          name: context.leftFormatName,
          frameDuration: FCPXMLUtilities.frameDurationFromFrameRate(leftSideVideo.frameRate),
          width: "\(Int(leftSideVideo.dimensions.width))",
          height: "\(Int(leftSideVideo.dimensions.height))",
          colorSpace: "1-1-1 (Rec. 709)"
        ),
        Format(
          id: "r6",
          name: context.rightFormatName,
          frameDuration: FCPXMLUtilities.frameDurationFromFrameRate(rightSideVideo.frameRate),
          width: "\(Int(rightSideVideo.dimensions.width))",
          height: "\(Int(rightSideVideo.dimensions.height))",
          colorSpace: "1-1-1 (Rec. 709)"
        ),
      ]
    }

    /// Builds the media entries: combined clip and multicam clip.
    private func buildMedia(
      leftSideVideoOffset: Double,
      rightSideVideoLeftTrim: Double,
      rightSideVideoOffset: Double,
      context: BuildContext
    ) -> [Media] {
      [
        buildCombinedMedia(
          leftSideVideoOffset: leftSideVideoOffset,
          rightSideVideoLeftTrim: rightSideVideoLeftTrim,
          rightSideVideoOffset: rightSideVideoOffset,
          context: context
        ),
        buildLeftMedia(context: context),
        buildRightMedia(context: context),
        buildMulticamMedia(context: context),
      ]
    }

    /// Combined side-by-side media clip.
    private func buildCombinedMedia(
      leftSideVideoOffset: Double,
      rightSideVideoLeftTrim: Double,
      rightSideVideoOffset: Double,
      context: BuildContext
    ) -> Media {
      Media(
        id: "r1",
        name: "Both",
        uid: context.bothUID,
        modDate: context.currentTime,
        sequence: Sequence(
          format: "r2",
          duration: context.maxDuration,
          tcStart: "0s",
          tcFormat: "NDF",
          spine: Spine(refClips: [
            RefClip(
              ref: "r3",
              offset: "0s",
              name: context.leftName,
              duration: context.leftDuration,
              useAudioSubroles: "1",
              adjustTransform: AdjustTransform(position: "\(leftSideVideoOffset) 0"),
              refClips: [
                RefClip(
                  ref: "r5",
                  offset: "0s",
                  name: context.rightName,
                  duration: context.rightDuration,
                  lane: "1",
                  useAudioSubroles: "1",
                  adjustTransform: AdjustTransform(position: "\(rightSideVideoOffset) 0"),
                  adjustCrop: AdjustCrop(
                    mode: "trim",
                    trimRect: TrimRect(left: "\(rightSideVideoLeftTrim)")
                  )
                )
              ]
            )
          ])
        )
      )
    }

    /// Media wrapper for the left source clip.
    private func buildLeftMedia(
      context: BuildContext
    ) -> Media {
      Media(
        id: "r3",
        name: context.leftName,
        uid: context.leftMediaUID,
        modDate: context.currentTime,
        sequence: Sequence(
          format: "r2",
          duration: context.leftDuration,
          tcStart: "0s",
          tcFormat: "NDF",
          spine: Spine(assetClips: [
            AssetClip(
              ref: "r4",
              name: context.leftName,
              duration: context.leftDuration,
              tcFormat: "NDF",
              audioRole: "dialogue",
              offset: "0s"
            )
          ])
        )
      )
    }

    /// Media wrapper for the right source clip.
    private func buildRightMedia(
      context: BuildContext
    ) -> Media {
      Media(
        id: "r5",
        name: context.rightName,
        uid: context.rightMediaUID,
        modDate: context.currentTime,
        sequence: Sequence(
          format: "r6",
          duration: context.rightDuration,
          tcStart: "0s",
          tcFormat: "NDF",
          spine: Spine(assetClips: [
            AssetClip(
              ref: "r7",
              name: context.rightName,
              duration: context.rightDuration,
              tcFormat: "NDF",
              audioRole: "dialogue",
              offset: "0s"
            )
          ])
        )
      )
    }

    /// Multicam media clip holding the three angles.
    private func buildMulticamMedia(
      context: BuildContext
    ) -> Media {
      Media(
        id: "r8",
        name: "Multicam Clip",
        uid: context.multicamUID,
        modDate: context.currentTime,
        multicam: Multicam(
          format: "r2",
          tcStart: "0s",
          tcFormat: "NDF",
          mcAngles: [
            MCAngle(
              name: "Both",
              angleID: context.angleBothID,
              refClips: [
                RefClip(
                  ref: "r1",
                  offset: "0s",
                  name: "Both",
                  duration: context.maxDuration,
                  useAudioSubroles: "1"
                )
              ]
            ),
            MCAngle(
              name: context.leftName,
              angleID: context.angleLeftID,
              refClips: [
                RefClip(
                  ref: "r3",
                  offset: "0s",
                  name: context.leftName,
                  duration: context.leftDuration,
                  useAudioSubroles: "1"
                )
              ]
            ),
            MCAngle(
              name: context.rightName,
              angleID: context.angleRightID,
              refClips: [
                RefClip(
                  ref: "r5",
                  offset: "0s",
                  name: context.rightName,
                  duration: context.rightDuration,
                  useAudioSubroles: "1"
                )
              ]
            ),
          ]
        )
      )
    }

    /// Builds the library tree: event, project, sequence and multicam clip.
    private func buildLibrary(projectName: String, context: BuildContext) -> Library {
      Library(
        location: "file:///Users/Shared/Generated.fcpbundle/",
        events: [
          Event(
            name: projectName,
            uid: context.eventUID,
            refClips: [
              RefClip(
                ref: "r1",
                name: "Both",
                duration: context.maxDuration,
                modDate: context.currentTime,
                useAudioSubroles: "1"
              ),
              RefClip(
                ref: "r3",
                name: context.leftName,
                duration: context.leftDuration,
                modDate: context.currentTime,
                useAudioSubroles: "1"
              ),
              RefClip(
                ref: "r5",
                name: context.rightName,
                duration: context.rightDuration,
                modDate: context.currentTime,
                useAudioSubroles: "1"
              ),
            ],
            mcClips: [
              MCClip(
                ref: "r8",
                name: "Multicam Clip",
                duration: context.maxDuration,
                modDate: context.currentTime,
                mcSources: [
                  MCSource(angleID: context.angleBothID, srcEnable: "all")
                ]
              )
            ]
          )
        ]
      )
    }
  }
#endif

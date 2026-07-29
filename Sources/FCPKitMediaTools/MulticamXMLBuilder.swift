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

      return FCPXML(
        version: FCPXMLVersion.supportedGenerationVersion.rawValue,
        resources: Resources(
          assets: [
            Asset(
              id: "r4",
              name: leftName,
              uid: leftSig,
              start: "0s",
              duration: leftDuration,
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
                  sig: leftSig,
                  src: FCPXMLUtilities.formatFileURL(leftSideVideo.url)
                )
              ]
            ),
            Asset(
              id: "r7",
              name: rightName,
              uid: rightSig,
              start: "0s",
              duration: rightDuration,
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
                  sig: rightSig,
                  src: FCPXMLUtilities.formatFileURL(rightSideVideo.url)
                )
              ]
            ),
          ],
          formats: [
            Format(
              id: "r2",
              name: leftFormatName,
              frameDuration: FCPXMLUtilities.frameDurationFromFrameRate(leftSideVideo.frameRate),
              width: "\(Int(leftSideVideo.dimensions.width))",
              height: "\(Int(leftSideVideo.dimensions.height))",
              colorSpace: "1-1-1 (Rec. 709)"
            ),
            Format(
              id: "r6",
              name: rightFormatName,
              frameDuration: FCPXMLUtilities.frameDurationFromFrameRate(rightSideVideo.frameRate),
              width: "\(Int(rightSideVideo.dimensions.width))",
              height: "\(Int(rightSideVideo.dimensions.height))",
              colorSpace: "1-1-1 (Rec. 709)"
            ),
          ],
          media: [
            Media(
              id: "r1",
              name: "Both",
              uid: bothUID,
              modDate: currentTime,
              sequence: Sequence(
                format: "r2",
                duration: maxDuration,
                tcStart: "0s",
                tcFormat: "NDF",
                spine: Spine(refClips: [
                  RefClip(
                    ref: "r3",
                    offset: "0s",
                    name: leftName,
                    duration: leftDuration,
                    useAudioSubroles: "1",
                    adjustTransform: AdjustTransform(position: "\(leftSideVideoOffset) 0"),
                    refClips: [
                      RefClip(
                        ref: "r5",
                        offset: "0s",
                        name: rightName,
                        duration: rightDuration,
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
            ),
            Media(
              id: "r3",
              name: leftName,
              uid: leftMediaUID,
              modDate: currentTime,
              sequence: Sequence(
                format: "r2",
                duration: leftDuration,
                tcStart: "0s",
                tcFormat: "NDF",
                spine: Spine(assetClips: [
                  AssetClip(
                    ref: "r4",
                    name: leftName,
                    duration: leftDuration,
                    tcFormat: "NDF",
                    audioRole: "dialogue",
                    offset: "0s"
                  )
                ])
              )
            ),
            Media(
              id: "r5",
              name: rightName,
              uid: rightMediaUID,
              modDate: currentTime,
              sequence: Sequence(
                format: "r6",
                duration: rightDuration,
                tcStart: "0s",
                tcFormat: "NDF",
                spine: Spine(assetClips: [
                  AssetClip(
                    ref: "r7",
                    name: rightName,
                    duration: rightDuration,
                    tcFormat: "NDF",
                    audioRole: "dialogue",
                    offset: "0s"
                  )
                ])
              )
            ),
            Media(
              id: "r8",
              name: "Multicam Clip",
              uid: multicamUID,
              modDate: currentTime,
              multicam: Multicam(
                format: "r2",
                tcStart: "0s",
                tcFormat: "NDF",
                mcAngles: [
                  MCAngle(
                    name: "Both",
                    angleID: angleBothID,
                    refClips: [
                      RefClip(
                        ref: "r1",
                        offset: "0s",
                        name: "Both",
                        duration: maxDuration,
                        useAudioSubroles: "1"
                      )
                    ]
                  ),
                  MCAngle(
                    name: leftName,
                    angleID: angleLeftID,
                    refClips: [
                      RefClip(
                        ref: "r3",
                        offset: "0s",
                        name: leftName,
                        duration: leftDuration,
                        useAudioSubroles: "1"
                      )
                    ]
                  ),
                  MCAngle(
                    name: rightName,
                    angleID: angleRightID,
                    refClips: [
                      RefClip(
                        ref: "r5",
                        offset: "0s",
                        name: rightName,
                        duration: rightDuration,
                        useAudioSubroles: "1"
                      )
                    ]
                  ),
                ]
              )
            ),
          ]
        ),
        library: Library(
          location: "file:///Users/Shared/Generated.fcpbundle/",
          events: [
            Event(
              name: projectName,
              uid: eventUID,
              refClips: [
                RefClip(
                  ref: "r1",
                  name: "Both",
                  duration: maxDuration,
                  modDate: currentTime,
                  useAudioSubroles: "1"
                ),
                RefClip(
                  ref: "r3",
                  name: leftName,
                  duration: leftDuration,
                  modDate: currentTime,
                  useAudioSubroles: "1"
                ),
                RefClip(
                  ref: "r5",
                  name: rightName,
                  duration: rightDuration,
                  modDate: currentTime,
                  useAudioSubroles: "1"
                ),
              ],
              mcClips: [
                MCClip(
                  ref: "r8",
                  name: "Multicam Clip",
                  duration: maxDuration,
                  modDate: currentTime,
                  mcSources: [
                    MCSource(angleID: angleBothID, srcEnable: "all")
                  ]
                )
              ]
            )
          ]
        )
      )
    }
  }
#endif

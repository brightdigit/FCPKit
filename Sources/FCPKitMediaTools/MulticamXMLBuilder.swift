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
    internal struct BuildContext {
      internal let currentTime: String
      internal let leftDuration: String
      internal let rightDuration: String
      internal let maxDuration: String
      internal let leftName: String
      internal let rightName: String
      internal let bothUID: String
      internal let leftMediaUID: String
      internal let rightMediaUID: String
      internal let multicamUID: String
      internal let eventUID: String
      internal let angleBothID: String
      internal let angleLeftID: String
      internal let angleRightID: String
      internal let leftSig: String
      internal let rightSig: String
      internal let leftFormatName: String
      internal let rightFormatName: String

      /// Derives all shared identifiers, names and durations from the two source videos.
      internal init(leftSideVideo: VideoMetadata, rightSideVideo: VideoMetadata) {
        currentTime = FCPXMLUtilities.currentTimestamp()
        let maxDurationTime =
          leftSideVideo.duration > rightSideVideo.duration
          ? leftSideVideo.duration
          : rightSideVideo.duration
        leftDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(leftSideVideo.duration)
        rightDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(rightSideVideo.duration)
        maxDuration = FCPXMLUtilities.cmTimeToFCPXMLDuration(maxDurationTime)
        leftName = leftSideVideo.url.deletingPathExtension().lastPathComponent
        rightName = rightSideVideo.url.deletingPathExtension().lastPathComponent
        bothUID = FCPXMLUtilities.generateUID()
        leftMediaUID = FCPXMLUtilities.generateUID()
        rightMediaUID = FCPXMLUtilities.generateUID()
        multicamUID = FCPXMLUtilities.generateUID()
        eventUID = FCPXMLUtilities.generateUID()
        angleBothID = FCPXMLUtilities.generateUID()
        angleLeftID = FCPXMLUtilities.generateUID()
        angleRightID = FCPXMLUtilities.generateUID()
        leftSig = FCPXMLUtilities.generateAssetSignature(from: leftSideVideo)
        rightSig = FCPXMLUtilities.generateAssetSignature(from: rightSideVideo)
        leftFormatName = FCPXMLUtilities.generateFormatName(
          dimensions: leftSideVideo.dimensions,
          frameRate: leftSideVideo.frameRate
        )
        rightFormatName = FCPXMLUtilities.generateFormatName(
          dimensions: rightSideVideo.dimensions,
          frameRate: rightSideVideo.frameRate
        )
      }
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
      let context = BuildContext(leftSideVideo: leftSideVideo, rightSideVideo: rightSideVideo)

      return FCPXML(
        version: FCPXMLVersion.supportedGeneration.rawValue,
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
  }
#endif

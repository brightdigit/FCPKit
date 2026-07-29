//
//  MulticamXMLBuilder+Resources.swift
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

  extension MulticamXMLBuilder {
    /// Builds the asset entries for the two source videos.
    internal func buildAssets(
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
    internal func buildFormats(
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
  }
#endif

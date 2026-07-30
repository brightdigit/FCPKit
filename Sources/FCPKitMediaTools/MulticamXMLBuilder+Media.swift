//
//  MulticamXMLBuilder+Media.swift
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
    /// Builds the media entries: combined clip and multicam clip.
    internal func buildMedia(
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
    internal func buildCombinedMedia(
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
    internal func buildLeftMedia(
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
    internal func buildRightMedia(
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
  }
#endif

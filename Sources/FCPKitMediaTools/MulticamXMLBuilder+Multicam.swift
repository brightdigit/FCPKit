//
//  MulticamXMLBuilder+Multicam.swift
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
    /// Multicam media clip holding the three angles.
    internal func buildMulticamMedia(
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
            buildAngle(
              name: "Both",
              angleID: context.angleBothID,
              ref: "r1",
              duration: context.maxDuration
            ),
            buildAngle(
              name: context.leftName,
              angleID: context.angleLeftID,
              ref: "r3",
              duration: context.leftDuration
            ),
            buildAngle(
              name: context.rightName,
              angleID: context.angleRightID,
              ref: "r5",
              duration: context.rightDuration
            ),
          ]
        )
      )
    }

    /// Builds a single multicam angle wrapping one reference clip.
    private func buildAngle(
      name: String,
      angleID: String,
      ref: String,
      duration: String
    ) -> MCAngle {
      MCAngle(
        name: name,
        angleID: angleID,
        refClips: [
          RefClip(
            ref: ResourceRef(ref),
            offset: "0s",
            name: name,
            duration: duration,
            useAudioSubroles: "1"
          )
        ]
      )
    }
  }
#endif

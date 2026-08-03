//
//  PresentationSequence.swift
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

/// The primary storyline of a ``PresentationDocument``.
///
/// A slide deck's length is data-driven, so its story items are assembled as an
/// array rather than through the result builder's fixed-arity `buildBlock`.
internal struct PresentationSequence: DSLNode {
  internal let document: PresentationDocument

  internal func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    let format = FormatPreset.p1080p24
    let formatRef = try resources.format(format)

    // Publish the frame size so anchored titles can resolve their positions.
    let outerFrameSize = resources.frameSize
    if let width = format.format.width.flatMap(Double.init),
      let height = format.format.height.flatMap(Double.init)
    {
      resources.frameSize = (width: width, height: height)
    }
    defer { resources.frameSize = outerFrameSize }

    let packed = try Layout.pack(
      document.storyContent().spineItems(resources: &resources),
      frameDuration: format.format.frameDuration
    )

    return .sequence(
      FCPKit.Sequence(
        format: formatRef,
        duration: packed.duration,
        tcStart: "0s",
        tcFormat: .nonDropFrame,
        audioLayout: .stereo,
        audioRate: .hz48000,
        renderFormat: "FFRenderFormatProRes422HQ",
        spine: FCPKit.Spine(items: packed.items)
      )
    )
  }
}

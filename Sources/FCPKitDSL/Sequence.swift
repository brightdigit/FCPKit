//
//  Sequence.swift
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

/// The primary storyline. Use ``Spine`` only inside an anchor.
public struct Sequence: DSLNode {
  internal let format: FormatPreset?
  internal let content: DocumentGroup

  /// Creates a sequence that hides its primary spine under the builder content.
  public init(format: FormatPreset? = .p1080p24, @DocumentBuilder content: () -> DocumentGroup) {
    self.format = format
    self.content = content()
  }

  internal func build(_ resources: inout ResourceStore) throws -> Built {
    let formatRef = try format.map { try resources.format($0) }
    let packed = try Layout.pack(
      storyItems(content.contents, resources: &resources),
      frameDuration: format?.format.frameDuration
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

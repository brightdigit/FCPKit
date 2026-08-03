//
//  ModelSequence.swift
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

/// The FCPXML model sequence, disambiguated from the DSL's own ``Sequence``.
internal typealias ModelSequence = FCPKit.Sequence

extension ModelSequence {
  /// Creates a sequence around a spine, packing its items onto the timeline.
  ///
  /// Used when a document is soft-promoted from a bare spine or story item and
  /// no explicit ``Sequence`` shell was authored. The non-spine settings match
  /// what Final Cut writes for a new 1080p24 project.
  ///
  /// - Parameters:
  ///   - spine: The spine whose items are packed.
  ///   - format: The interned format resource, when one is available.
  /// - Throws: ``BuildError`` when an item carries an unusable duration.
  internal init(
    packing spine: FCPKit.Spine,
    format: ResourceRef<FormatKind>?
  ) throws(BuildError) {
    let packed = try Layout.pack(
      spine.items,
      frameDuration: FormatPreset.p1080p24.format.frameDuration
    )
    self.init(
      format: format,
      duration: packed.duration,
      tcStart: "0s",
      tcFormat: .nonDropFrame,
      audioLayout: .stereo,
      audioRate: .hz48000,
      renderFormat: "FFRenderFormatProRes422HQ",
      spine: FCPKit.Spine(items: packed.items)
    )
  }
}

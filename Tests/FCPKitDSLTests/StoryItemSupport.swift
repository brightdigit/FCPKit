//
//  StoryItemSupport.swift
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
import FCPKitDSL
import Foundation
import Testing

internal enum StoryItemSupport {
  /// A deck whose middle transition carries an anchor that must not be emitted.
  internal struct TransitionAnchored: Document {
    internal var body: some DocumentContent {
      Sequence(format: .p1080p24) {
        Generator(.custom, duration: FCPTime(numerator: 5)).color(.blue)
        Transition(.crossDissolve)
          .anchor(lane: 1) {
            Title("Ignored", duration: FCPTime(numerator: 2))
          }
        Generator(.custom, duration: FCPTime(numerator: 5)).color(.green)
      }
    }
  }

  /// Returns the packed spine items of an exported document.
  internal static func spine(_ exported: FCPXML) throws -> [FCPKit.SpineItem] {
    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    return try #require(sequence.spine?.items)
  }

  /// Returns the `lane` of every anchored title, in order.
  internal static func anchoredTitleLanes(_ items: [FCPKit.AnchoredItem]) -> [String?] {
    items.compactMap { item in
      guard case .title(let title) = item else {
        return nil
      }
      return title.lane
    }
  }
}

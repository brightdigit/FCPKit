//
//  Gap.swift
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

/// A gap on the storyline. Duration is required — set in initializer or via `.duration(...)`.
public struct Gap: StoryItem {
  /// Gap duration on the storyline, when set.
  public let duration: FCPTime?
  /// The anchors attached to this gap.
  public let anchors: [any DSLNode]

  /// Creates a gap. Export fails when `duration` is omitted.
  public init(duration: FCPTime? = nil) {
    self.init(duration: duration, anchors: [])
  }

  private init(duration: FCPTime?, anchors: [any DSLNode]) {
    self.duration = duration
    self.anchors = anchors
  }

  /// Sets the gap duration.
  public func duration(_ duration: FCPTime) -> Gap {
    Gap(duration: duration, anchors: anchors)
  }

  /// Returns a copy of this gap carrying exactly the given anchors.
  public func replacingAnchors(_ anchors: [any DSLNode]) -> Gap {
    Gap(duration: duration, anchors: anchors)
  }

  /// Lowers this gap into a `<gap>` story item.
  public func build(_ resources: inout ResourceStore) throws -> Built {
    guard let duration else { throw BuildError.missingDuration("gap") }
    var element = FCPKit.Gap(duration: duration.description)
    element.anchoredItems = try AnchoredItemBuilder.items(anchors, resources: &resources)
    return .item(.gap(element))
  }
}

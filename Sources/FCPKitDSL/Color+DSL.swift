//
//  Color+DSL.swift
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

/// Re-export ``Color`` for FCPKitDSL users.
public typealias Color = FCPKit.Color

extension Color: DSLNode {
  /// Returns a copy of this color with the specified clip duration.
  public func duration(_ duration: FCPTime) -> Color {
    var copy = self
    copy.duration = duration
    return copy
  }

  /// Lowers this color into a custom solid generator `<video>` story item.
  public func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    guard let duration else {
      throw BuildError.missingDuration("color generator")
    }
    let generator = Generator(.custom).duration(duration).color(self)
    return try generator.build(&resources)
  }
}

extension Color: StoryItem {
  /// Always empty: a color carries no anchors until it is promoted to a ``Generator``.
  public var anchors: [any DSLNode] { [] }

  /// Promotes this color to a ``Generator`` carrying the given anchors.
  ///
  /// `Color` is a model type and cannot gain stored properties, so anchoring performs
  /// the `Color` → `Generator` desugaring one step early. Chaining still works, because
  /// ``Generator`` is itself a ``StoryItem``.
  ///
  /// - Important: Call `.duration(_:)` *before* `.anchor(lane:offset:content:)` on the
  ///   color host. Anchored children without an explicit duration inherit that host
  ///   duration at export.
  public func replacingAnchors(_ anchors: [any DSLNode]) -> Generator {
    var generator = Generator(.custom).color(self)
    if let duration {
      generator = generator.duration(duration)
    }
    return generator.replacingAnchors(anchors)
  }
}

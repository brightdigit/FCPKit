//
//  Anchor.swift
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

internal struct Anchor: DSLNode {
  internal let lane: Int
  internal let offset: FCPTime
  internal let content: any DSLNode

  internal func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    try build(&resources, hostDuration: nil)
  }

  /// Lowers anchored content, inheriting `hostDuration` when the content has none.
  internal func build(
    _ resources: inout ResourceStore,
    hostDuration: FCPTime?
  ) throws(BuildError) -> Built {
    guard lane != 0 else {
      throw BuildError.invalidLane
    }
    let content = Self.resolvingDuration(hostDuration, into: content)
    let built = try content.build(&resources)
    if let item = built.placed(lane: lane, offset: offset) {
      return item
    }
    guard case .spine(let spine) = built else {
      throw BuildError.unsupportedContent
    }
    return .spine(spine)
  }
}

extension Anchor {
  /// Applies the host's duration to content that has not set one.
  private static func resolvingDuration(
    _ host: FCPTime?,
    into content: any DSLNode
  ) -> any DSLNode {
    guard let host, host != .zero else {
      return content
    }
    return applying(host, to: content) ?? content
  }

  private static func applying(_ host: FCPTime, to content: any DSLNode) -> (any DSLNode)? {
    if let title = content as? Title, title.duration == nil {
      return title.duration(host)
    }
    if let generator = content as? Generator, generator.duration == nil {
      return generator.duration(host)
    }
    if let gap = content as? Gap, gap.duration == nil {
      return gap.duration(host)
    }
    if let clip = content as? AssetClip, clip.duration == nil, clip.source.asset.duration == nil {
      return clip.duration(host)
    }
    if let color = content as? Color, color.duration == nil {
      return color.duration(host)
    }
    return nil
  }
}

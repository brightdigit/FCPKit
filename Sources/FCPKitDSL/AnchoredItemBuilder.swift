//
//  AnchoredItemBuilder.swift
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

/// Lowers anchor nodes into the DTD's `%anchor_item;` entity.
internal enum AnchoredItemBuilder {
  /// Lowers a single anchor node into an anchored item.
  internal static func item(
    _ node: any DSLNode,
    resources: inout ResourceStore
  ) throws -> FCPKit.AnchoredItem {
    switch try node.build(&resources) {
    case .item(.title(let title)): return .title(title)
    case .item(.assetClip(let clip)): return .assetClip(clip)
    case .item(.generator(let gen)): return .generator(gen)
    case .item(.video(let vid)): return .video(vid)
    case .spine(let spine): return .spine(spine)
    default: throw BuildError.unsupportedContent
    }
  }

  /// Lowers a list of anchor nodes, returning `nil` when the list is empty.
  internal static func items(
    _ nodes: [any DSLNode],
    resources: inout ResourceStore
  ) throws -> [FCPKit.AnchoredItem]? {
    let items = try nodes.map { try item($0, resources: &resources) }
    return items.isEmpty ? nil : items
  }
}

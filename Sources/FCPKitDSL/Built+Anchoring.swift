//
//  Built+Anchoring.swift
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

extension Built {
  /// This value as an anchorable element, or `nil` if it cannot be anchored.
  ///
  /// The single description of what the DTD's `%anchor_item;` entity admits.
  /// A `<gap>` is anchorable per the schema but is not produced here, matching
  /// long-standing behaviour; widening that is a capability change.
  internal var anchorable: (any AnchorableItem)? {
    switch self {
    case .item(.title(let title)): return title
    case .item(.assetClip(let clip)): return clip
    case .item(.generator(let generator)): return generator
    case .item(.video(let video)): return video
    default: return nil
    }
  }

  /// This value lowered into the DTD's `%anchor_item;` entity.
  ///
  /// - Throws: ``BuildError/unsupportedContent`` when the value cannot be anchored.
  internal func anchoredItem() throws(BuildError) -> FCPKit.AnchoredItem {
    if case .spine(let spine) = self {
      return .spine(spine)
    }
    guard let anchorable else {
      throw BuildError.unsupportedContent
    }
    return anchorable.asAnchoredItem
  }

  /// A copy placed on `lane` at `offset`, or `nil` if it cannot be anchored.
  internal func placed(lane: Int, offset: FCPTime) -> Built? {
    guard var item = anchorable else {
      return nil
    }
    item.lane = String(lane)
    item.offset = offset.description
    return .item(item.asSpineItem)
  }
}

extension Array where Element == any DSLNode {
  /// Lowers these nodes into anchored items, returning `nil` when empty.
  ///
  /// The optional is load-bearing: the model omits the element entirely rather
  /// than emitting an empty container.
  internal func anchoredItems(
    resources: inout ResourceStore
  ) throws(BuildError) -> [FCPKit.AnchoredItem]? {
    var items: [FCPKit.AnchoredItem] = []
    items.reserveCapacity(count)
    for node in self {
      items.append(try node.build(&resources).anchoredItem())
    }
    return items.isEmpty ? nil : items
  }
}

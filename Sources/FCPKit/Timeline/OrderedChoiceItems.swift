//
//  OrderedChoiceItems.swift
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

import Foundation

/// Helpers for building and mutating ordered choice-item arrays.
internal enum OrderedChoiceItems {
  /// Appends each non-nil batch onto `base` in declaration order.
  internal static func appending<Item>(
    _ batches: [[Item]?],
    onto base: [Item] = []
  ) -> [Item] {
    var items = base
    for batch in batches {
      if let batch {
        items.append(contentsOf: batch)
      }
    }
    return items
  }

  /// Returns non-empty payloads extracted from `items`, or `nil` when none match.
  internal static func payloads<Item, T>(
    in items: [Item],
    extract: (Item) -> T?
  ) -> [T]? {
    let list = items.compactMap(extract)
    return list.isEmpty ? nil : list
  }

  /// Replaces items matching `extract` with `newValue`, preserving relative order.
  ///
  /// Matching uses `extract($0) != nil`. Passing `nil` removes all matching items.
  internal static func replace<Item, T>(
    _ items: inout [Item],
    with newValue: [T]?,
    extract: @escaping (Item) -> T?,
    wrap: (T) -> Item
  ) {
    guard let newValue else {
      items.removeAll { extract($0) != nil }
      return
    }
    var newIndex = 0
    var indicesToRemove = [Int]()
    for index in items.indices where extract(items[index]) != nil {
      if newIndex < newValue.count {
        items[index] = wrap(newValue[newIndex])
        newIndex += 1
      } else {
        indicesToRemove.append(index)
      }
    }
    for index in indicesToRemove.reversed() {
      items.remove(at: index)
    }
    while newIndex < newValue.count {
      items.append(wrap(newValue[newIndex]))
      newIndex += 1
    }
  }
}
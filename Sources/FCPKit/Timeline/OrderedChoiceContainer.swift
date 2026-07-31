//
//  OrderedChoiceContainer.swift
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

/// A timeline element that stores ordered choice-item children.
internal protocol OrderedChoiceContainer {
  associatedtype Item
  var orderedItems: [Item] { get set }
}

extension OrderedChoiceContainer {
  /// Appends each non-nil batch onto `base` in declaration order.
  internal static func appending(
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

  /// Returns non-empty payloads extracted from ``orderedItems``, or `nil` when none match.
  internal func payloads<T>(_ extract: (Item) -> T?) -> [T]? {
    let list = orderedItems.compactMap(extract)
    return list.isEmpty ? nil : list
  }

  /// Replaces items matching `extract` with `newValue`, preserving relative order.
  ///
  /// Matching uses `extract($0) != nil`. Passing `nil` removes all matching items.
  internal mutating func replace<T>(
    with newValue: [T]?,
    extract: @escaping (Item) -> T?,
    wrap: (T) -> Item
  ) {
    guard let newValue else {
      orderedItems.removeAll { extract($0) != nil }
      return
    }
    var newIndex = 0
    var indicesToRemove = [Int]()
    for index in orderedItems.indices where extract(orderedItems[index]) != nil {
      if newIndex < newValue.count {
        orderedItems[index] = wrap(newValue[newIndex])
        newIndex += 1
      } else {
        indicesToRemove.append(index)
      }
    }
    for index in indicesToRemove.reversed() {
      orderedItems.remove(at: index)
    }
    while newIndex < newValue.count {
      orderedItems.append(wrap(newValue[newIndex]))
      newIndex += 1
    }
  }
}

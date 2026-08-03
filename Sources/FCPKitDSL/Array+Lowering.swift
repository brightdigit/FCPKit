//
//  Array+Lowering.swift
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

extension Array where Element == any DocumentContent {
  /// Lowers this content into ordered spine items, preserving authored order.
  ///
  /// - Throws: ``BuildError/unsupportedContent`` when a value is not a story
  ///   item — a document shell such as a `Project` cannot sit in a spine.
  internal func spineItems(
    resources: inout ResourceStore
  ) throws(BuildError) -> [FCPKit.SpineItem] {
    var items: [FCPKit.SpineItem] = []
    items.reserveCapacity(count)
    for value in self {
      guard let node = value as? any DSLNode,
        case .item(let item) = try node.build(&resources)
      else {
        throw BuildError.unsupportedContent
      }
      items.append(item)
    }
    return items
  }
}

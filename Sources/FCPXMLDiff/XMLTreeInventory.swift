//
//  XMLTreeInventory.swift
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

/// A flattened path-indexed inventory of the elements, attributes, and text in an XML tree.
internal struct XMLTreeInventory {
  /// Occurrence counts of each element, keyed by its slash-separated path.
  internal var elements: [String: Int] = [:]
  /// Attribute values collected per attribute path.
  internal var attributes: [String: [String]] = [:]
  /// Text content collected per text-node path.
  internal var text: [String: [String]] = [:]

  /// Creates an inventory by walking the tree rooted at `root`.
  internal init(root: XMLTreeNode) {
    collect(root, parentPath: "")
  }

  private mutating func collect(_ node: XMLTreeNode, parentPath: String) {
    let path = "\(parentPath)/\(node.name)"
    elements[path, default: 0] += 1
    for (name, value) in node.attributes {
      attributes["\(path)/@\(name)", default: []].append(value)
    }
    if !node.text.isEmpty && node.text != "$opaque" {
      text["\(path)/#text", default: []].append(node.text)
    }
    for child in node.children {
      collect(child, parentPath: path)
    }
  }
}

//
//  XMLTreeNode.swift
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

/// A lightweight, mutable representation of an XML element and its subtree.
public struct XMLTreeNode: Equatable, Sendable {
  /// The element name.
  public var name: String
  /// The element's attributes keyed by attribute name.
  public var attributes: [String: String]
  /// The concatenated, trimmed text content of the element.
  public var text: String
  /// The child elements in document order.
  public var children: [XMLTreeNode]

  /// Creates a node with the given name, attributes, text, and children.
  public init(
    name: String,
    attributes: [String: String] = [:],
    text: String = "",
    children: [XMLTreeNode] = []
  ) {
    self.name = name
    self.attributes = attributes
    self.text = text
    self.children = children
  }
}

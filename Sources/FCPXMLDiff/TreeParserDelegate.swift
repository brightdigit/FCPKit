//
//  TreeParserDelegate.swift
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

#if canImport(FoundationXML)
  import FoundationXML
#endif

/// An `XMLParserDelegate` that builds an `XMLTreeNode` tree from parser events.
internal final class TreeParserDelegate: NSObject, XMLParserDelegate {
  private struct Builder {
    var name: String
    var attributes: [String: String]
    var text = ""
    var children: [XMLTreeNode] = []

    func build() -> XMLTreeNode {
      XMLTreeNode(
        name: name,
        attributes: attributes,
        text: text.trimmingCharacters(in: .whitespacesAndNewlines),
        children: children
      )
    }
  }

  private var stack: [Builder] = []
  /// The root node of the parsed tree, available after parsing completes.
  internal private(set) var root: XMLTreeNode?

  /// Pushes a builder for the element that just started.
  internal func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String] = [:]
  ) {
    stack.append(Builder(name: qName ?? elementName, attributes: attributeDict))
  }

  /// Appends character data to the current element's text.
  internal func parser(_ parser: XMLParser, foundCharacters string: String) {
    guard !stack.isEmpty else {
      return
    }
    stack[stack.count - 1].text += string
  }

  /// Appends CDATA content to the current element's text.
  internal func parser(_ parser: XMLParser, foundCDATA cdataBlock: Data) {
    guard !stack.isEmpty, let string = String(data: cdataBlock, encoding: .utf8) else {
      return
    }
    stack[stack.count - 1].text += string
  }

  /// Finalizes the current element and attaches it to its parent or the root.
  internal func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?
  ) {
    guard let builder = stack.popLast() else {
      return
    }
    let node = builder.build()
    if stack.isEmpty {
      root = node
    } else {
      stack[stack.count - 1].children.append(node)
    }
  }
}

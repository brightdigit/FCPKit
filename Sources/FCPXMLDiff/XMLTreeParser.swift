//
//  XMLTreeParser.swift
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

private final class TreeParserDelegate: NSObject, XMLParserDelegate {
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
  fileprivate var root: XMLTreeNode?

  func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String] = [:]
  ) {
    stack.append(Builder(name: qName ?? elementName, attributes: attributeDict))
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    guard !stack.isEmpty else {
      return
    }
    stack[stack.count - 1].text += string
  }

  func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    guard !stack.isEmpty, let string = String(data: CDATABlock, encoding: .utf8) else {
      return
    }
    stack[stack.count - 1].text += string
  }

  func parser(
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

public struct XMLTreeParser: Sendable {
  public init() {}

  public func parse(_ data: Data) throws -> XMLTreeNode {
    let delegate = TreeParserDelegate()
    let parser = XMLParser(data: data)
    parser.delegate = delegate
    parser.shouldProcessNamespaces = false
    parser.shouldReportNamespacePrefixes = true
    parser.shouldResolveExternalEntities = false

    guard parser.parse() else {
      throw XMLTreeParserError.invalidDocument(
        parser.parserError?.localizedDescription ?? "unknown parser error"
      )
    }
    guard let root = delegate.root else {
      throw XMLTreeParserError.missingRootElement
    }
    return root
  }
}

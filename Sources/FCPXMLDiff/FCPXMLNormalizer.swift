//
//  FCPXMLNormalizer.swift
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

public struct FCPXMLNormalizer: Sendable {
  public static let rules = [
    "Resource identifiers matching r1...rN are replaced with pair-stable symbolic references.",
    "uid, sig, and modDate attribute values are replaced with a volatile placeholder.",
    "bookmark and data[key=effectConfig] text is replaced with an opaque placeholder.",
    "Formatting-only whitespace and attribute ordering are ignored.",
  ]

  public init() {}

  public func normalizePair(
    _ left: XMLTreeNode,
    _ right: XMLTreeNode
  ) -> (left: XMLTreeNode, right: XMLTreeNode) {
    let mappings = resourceMappings(left: left, right: right)
    return (
      normalize(left, resourceMap: mappings.left),
      normalize(right, resourceMap: mappings.right)
    )
  }

  private func normalize(
    _ node: XMLTreeNode,
    resourceMap: [String: String]
  ) -> XMLTreeNode {
    var normalized = node
    normalized.attributes = Dictionary(
      uniqueKeysWithValues: node.attributes.map { name, value in
        if ["uid", "sig", "modDate"].contains(name) {
          return (name, "$volatile")
        }
        if isResourceIdentifier(value) {
          return (name, resourceMap[value] ?? "$resource-unmapped")
        }
        return (name, value)
      })
    normalized.children = node.children.map { normalize($0, resourceMap: resourceMap) }

    if node.name == "bookmark"
      || (node.name == "data" && node.attributes["key"] == "effectConfig")
    {
      normalized.text = "$opaque"
    }
    return normalized
  }

  private func resourceMappings(
    left: XMLTreeNode,
    right: XMLTreeNode
  ) -> (left: [String: String], right: [String: String]) {
    let leftResources = resources(in: left)
    let rightResources = resources(in: right)
    var rightByFingerprint: [String: [(id: String, index: Int)]] = [:]

    for (index, resource) in rightResources.enumerated() {
      rightByFingerprint[fingerprint(resource.node), default: []].append((resource.id, index))
    }

    var leftMap: [String: String] = [:]
    var rightMap: [String: String] = [:]
    var usedRight = Set<Int>()
    var sharedIndex = 1
    var removedIndex = 1

    for resource in leftResources {
      let key = fingerprint(resource.node)
      let match = rightByFingerprint[key]?.first(where: { !usedRight.contains($0.index) })
      if let match {
        let placeholder = "$resource-\(sharedIndex)"
        sharedIndex += 1
        leftMap[resource.id] = placeholder
        rightMap[match.id] = placeholder
        usedRight.insert(match.index)
      } else {
        leftMap[resource.id] = "$resource-removed-\(removedIndex)"
        removedIndex += 1
      }
    }

    var addedIndex = 1
    for (index, resource) in rightResources.enumerated() where !usedRight.contains(index) {
      rightMap[resource.id] = "$resource-added-\(addedIndex)"
      addedIndex += 1
    }

    return (leftMap, rightMap)
  }

  private func resources(in root: XMLTreeNode) -> [(id: String, node: XMLTreeNode)] {
    guard let resources = root.children.first(where: { $0.name == "resources" }) else { return [] }
    return resources.children.compactMap { node in
      guard let id = node.attributes["id"], isResourceIdentifier(id) else { return nil }
      return (id, node)
    }
  }

  private func fingerprint(_ node: XMLTreeNode) -> String {
    let attributes = node.attributes
      .filter { name, _ in name != "id" && !["uid", "sig", "modDate"].contains(name) }
      .map { name, value in
        "\(name)=\(isResourceIdentifier(value) ? "$resource" : value)"
      }
      .sorted()
      .joined(separator: ",")
    let text: String
    if node.name == "bookmark"
      || (node.name == "data" && node.attributes["key"] == "effectConfig")
    {
      text = "$opaque"
    } else {
      text = node.text
    }
    let children = node.children.map(fingerprint).joined(separator: "|")
    return "\(node.name)[\(attributes)]{\(text)}<\(children)>"
  }

  private func isResourceIdentifier(_ value: String) -> Bool {
    guard value.first == "r", value.count > 1 else { return false }
    return value.dropFirst().allSatisfy(\.isNumber)
      && value.dropFirst().first != "0"
  }
}

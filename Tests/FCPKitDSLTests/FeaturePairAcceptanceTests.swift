//
//  FeaturePairAcceptanceTests.swift
//  FCPKitDSLTests
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
import FCPKitDSL
import FCPXMLDiff
import Foundation
import Testing

@Suite
internal struct FeaturePairAcceptanceTests {
  @Test
  internal func transitionsFeaturePairMatchesAfterNormalize() throws {
    let fixtureURL = featurePairURL("transitions")
    let fixtureData = try Data(contentsOf: fixtureURL)
    let fixture = try FCPXMLParser().parse(data: fixtureData)
    let resources = try #require(fixture.resources)
    let formats = try #require(resources.formats)
    let assets = try #require(resources.assets)
    let format1080 = try #require(formats.first { $0.name == "FFVideoFormat1080p24" })
    let format720 = try #require(formats.first { $0.name == "FFVideoFormat720p24" })
    let left = try #require(assets.first { $0.name == "Left" })
    let right = try #require(assets.first { $0.name == "Right" })
    let library = try #require(fixture.library)
    let event = try #require(library.events?.first)
    let project = try #require(event.projects?.first)

    let document = FeaturePairDocuments.Transitions(
      left: left,
      right: right,
      format1080: format1080,
      format720: format720,
      libraryLocation: library.location,
      eventName: event.name,
      eventUID: event.uid,
      projectName: project.name,
      projectUID: project.uid,
      projectModDate: project.modDate
    )
    let generated = try document.export(version: FCPXMLVersion("1.14"))
    let generatedData = try FCPXMLParser().encode(generated)
    try assertStructurallyEqual(generatedData, fixtureData)
    try assertSpineChildNames(
      generatedData,
      ["asset-clip", "transition", "asset-clip"]
    )
    try assertDTDValidates(generatedData)
  }

  @Test
  internal func titlesFeaturePairMatchesAfterNormalize() throws {
    let fixtureURL = featurePairURL("titles")
    let fixtureData = try Data(contentsOf: fixtureURL)
    let fixture = try FCPXMLParser().parse(data: fixtureData)
    let resources = try #require(fixture.resources)
    let formats = try #require(resources.formats)
    let assets = try #require(resources.assets)
    let format1080 = try #require(formats.first { $0.name == "FFVideoFormat1080p24" })
    let left = try #require(assets.first { $0.name == "Left" })
    let library = try #require(fixture.library)
    let event = try #require(library.events?.first)
    let project = try #require(event.projects?.first)

    let document = FeaturePairDocuments.Titles(
      left: left,
      format1080: format1080,
      libraryLocation: library.location,
      eventName: event.name,
      eventUID: event.uid,
      projectName: project.name,
      projectUID: project.uid,
      projectModDate: project.modDate
    )
    let generated = try document.export(version: FCPXMLVersion("1.14"))
    let generatedData = try FCPXMLParser().encode(generated)
    try assertStructurallyEqual(generatedData, fixtureData)
    let root = try XMLTreeParser().parse(generatedData)
    let clip = try #require(firstNode(named: "asset-clip", in: root))
    #expect(clip.children.map(\.name) == ["title"])
    try assertDTDValidates(generatedData)
  }

  private func featurePairURL(_ name: String) -> URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("FCPKitTests", isDirectory: true)
      .appendingPathComponent("FeaturePairs", isDirectory: true)
      .appendingPathComponent(name, isDirectory: true)
      .appendingPathComponent("after.fcpxml")
  }

  private func assertStructurallyEqual(_ left: Data, _ right: Data) throws {
    let parser = XMLTreeParser()
    let engine = FCPXMLDiffEngine()
    let differences = engine.compare(
      try parser.parse(left),
      try parser.parse(right),
      mode: .symmetric
    )
    #expect(differences.isEmpty, "Unexpected differences: \(differences)")
  }

  private func assertSpineChildNames(_ data: Data, _ names: [String]) throws {
    let root = try XMLTreeParser().parse(data)
    let spine = try #require(firstNode(named: "spine", in: root))
    #expect(spine.children.map(\.name) == names)
  }

  private func assertDTDValidates(_ data: Data) throws {
    let requireDTD = ProcessInfo.processInfo.environment["FCPKIT_REQUIRE_DTD"] != nil
    do {
      let report = try FCPXMLDTDValidator().validate(data: data)
      #expect(report.isValid, "DTD issues: \(report.issues)")
    } catch FCPXMLValidationError.dtdNotFound, FCPXMLValidationError.xmllintUnavailable {
      if requireDTD {
        Issue.record("FCPKIT_REQUIRE_DTD is set but DTD tooling is unavailable")
      } else {
        // Soft skip when Final Cut / xmllint are absent.
      }
    }
  }

  private func firstNode(named name: String, in node: XMLTreeNode) -> XMLTreeNode? {
    if node.name == name {
      return node
    }
    for child in node.children {
      if let match = firstNode(named: name, in: child) {
        return match
      }
    }
    return nil
  }
}

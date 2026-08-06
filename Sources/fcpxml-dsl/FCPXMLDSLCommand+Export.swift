//
//  FCPXMLDSLCommand+Export.swift
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

// swiftlint:disable sorted_imports
import FCPKit
import FCPKitDSL
import FCPKitDemo
import Foundation
// swiftlint:enable sorted_imports

extension FCPXMLDSLCommand {
  #if canImport(AVFoundation)
    internal static func exportTransitions(
      left: URL,
      right: URL,
      output: URL,
      projectName: String,
      version: FCPXMLVersion
    ) async throws {
      let leftDuration = try await FCPXMLDSLMediaProbe.duration(of: left)
      let rightDuration = try await FCPXMLDSLMediaProbe.duration(of: right)
      let document = TransitionsCutDocument(
        leftURL: left,
        rightURL: right,
        leftDuration: leftDuration,
        rightDuration: rightDuration,
        projectName: projectName
      )
      try write(document: document, to: output, version: version)
      print("Wrote transitions cut → \(output.path)")
    }

    internal static func exportTitles(
      media: URL,
      output: URL,
      projectName: String,
      titleText: String,
      version: FCPXMLVersion
    ) async throws {
      let mediaDuration = try await FCPXMLDSLMediaProbe.duration(of: media)
      let defaultTitle = FCPTime(numerator: 24_100, denominator: 2_400)
      let titleDuration = mediaDuration < defaultTitle ? mediaDuration : defaultTitle
      let document = TitlesCutDocument(
        mediaURL: media,
        mediaDuration: mediaDuration,
        titleText: titleText,
        titleDuration: titleDuration,
        projectName: projectName
      )
      try write(document: document, to: output, version: version)
      print("Wrote titles cut → \(output.path)")
    }

    internal static func exportRGB(
      output: URL,
      projectName: String,
      version: FCPXMLVersion
    ) async throws {
      let document = RGBDocument(projectName: projectName)
      try write(document: document, to: output, version: version)
      print("Wrote RGB cut → \(output.path)")
    }

    internal static func exportPresentation(
      output: URL,
      projectName: String,
      version: FCPXMLVersion
    ) async throws {
      // Thin editable shell in FCPKitDemo; this command only invokes it.
      let document = PresentationDocument(projectName: projectName)
      try write(document: document, to: output, version: version)
      print("Wrote presentation → \(output.path)")
    }
  #endif

  private static func write(
    document: some Document,
    to output: URL,
    version: FCPXMLVersion
  ) throws {
    let model = try document.export(version: version)
    try FCPXMLParser().write(model, to: output)
  }
}

//
//  RawPairAnalyzer.swift
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

public struct RawPairAnalyzer: Sendable {
  private let parser = XMLTreeParser()
  private let engine = FCPXMLDiffEngine()

  public init() {}

  public func analyze(
    beforeData: Data,
    afterData: Data,
    beforePath: String = "before.fcpxml",
    afterPath: String = "after.fcpxml",
    pathFilter: String? = nil
  ) throws -> RawPairReport {
    let before = try parser.parse(beforeData)
    let after = try parser.parse(afterData)
    let findings = engine.compare(before, after, mode: .symmetric).filter {
      guard let pathFilter else { return true }
      return $0.path.hasPrefix(pathFilter)
    }
    return RawPairReport(
      beforePath: beforePath,
      afterPath: afterPath,
      beforeFCPXMLVersion: before.attributes["version"],
      afterFCPXMLVersion: after.attributes["version"],
      pathFilter: pathFilter,
      findings: findings
    )
  }
}

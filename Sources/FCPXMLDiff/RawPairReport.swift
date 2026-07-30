//
//  RawPairReport.swift
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

/// The structural differences found between two arbitrary FCPXML documents.
public struct RawPairReport: Codable, Equatable, Sendable {
  /// The version of this report's serialized format.
  public let formatVersion: Int
  /// The path of the first ("before") document.
  public let beforePath: String
  /// The path of the second ("after") document.
  public let afterPath: String
  /// The FCPXML version declared by the before document, if any.
  public let beforeFCPXMLVersion: String?
  /// The FCPXML version declared by the after document, if any.
  public let afterFCPXMLVersion: String?
  /// The structural path prefix used to filter findings, if any.
  public let pathFilter: String?
  /// Descriptions of the normalization rules applied before comparison.
  public let normalization: [String]
  /// The structural differences detected between the two documents.
  public let findings: [FCPXMLDifference]

  /// Creates a report describing the differences between two documents.
  public init(
    beforePath: String,
    afterPath: String,
    beforeFCPXMLVersion: String?,
    afterFCPXMLVersion: String?,
    pathFilter: String?,
    findings: [FCPXMLDifference]
  ) {
    formatVersion = 1
    self.beforePath = beforePath
    self.afterPath = afterPath
    self.beforeFCPXMLVersion = beforeFCPXMLVersion
    self.afterFCPXMLVersion = afterFCPXMLVersion
    self.pathFilter = pathFilter
    normalization = FCPXMLNormalizer.rules
    self.findings = findings
  }
}

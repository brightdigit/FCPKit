//
//  FCPXMLValidationReport.swift
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

/// Result of validating an FCPXML document against an Apple FCPXML DTD.
public struct FCPXMLValidationReport: Codable, Equatable, Sendable {
  /// The version of this report's serialized format.
  public let formatVersion: Int
  /// The path of the FCPXML document that was validated.
  public let sourcePath: String
  /// The FCPXML version declared by the source document, if any.
  public let fcpxmlVersion: String?
  /// The filesystem path of the DTD used for validation.
  public let dtdPath: String
  /// Whether the document passed DTD validation with no issues.
  public let isValid: Bool
  /// The issues reported by the validator, if any.
  public let issues: [FCPXMLValidationIssue]

  /// Creates a validation report for the given source document and DTD.
  public init(
    sourcePath: String,
    fcpxmlVersion: String?,
    dtdPath: String,
    isValid: Bool,
    issues: [FCPXMLValidationIssue]
  ) {
    formatVersion = 1
    self.sourcePath = sourcePath
    self.fcpxmlVersion = fcpxmlVersion
    self.dtdPath = dtdPath
    self.isValid = isValid
    self.issues = issues
  }
}

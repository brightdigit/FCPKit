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
  public let formatVersion: Int
  public let sourcePath: String
  public let fcpxmlVersion: String?
  public let dtdPath: String
  public let isValid: Bool
  public let issues: [FCPXMLValidationIssue]

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

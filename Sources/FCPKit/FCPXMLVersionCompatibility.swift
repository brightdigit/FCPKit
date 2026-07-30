//
//  FCPXMLVersionCompatibility.swift
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

/// Compatibility of a declared FCPXML version against the library policy.
public enum FCPXMLVersionCompatibility: String, Sendable, Equatable {
  /// Declared version matches the current generation/fixture baseline.
  case supported
  /// Declared version is older than the generation baseline but parseable best-effort.
  case older
  /// Declared version is newer than the generation baseline; parse remains best-effort.
  case newer
  /// Declared version string is not a dotted numeric FCPXML version.
  case malformed
}

extension FCPXML {
  /// Compatibility of `version` against the library generation baseline.
  public var versionCompatibility: FCPXMLVersionCompatibility {
    FCPXMLVersion(version).compatibility()
  }
}

extension FCPXMLParser {
  /// Inspects a declared version string without requiring a full document parse.
  public func compatibility(ofVersion version: String) -> FCPXMLVersionCompatibility {
    FCPXMLVersion(version).compatibility()
  }

  /// Parses a document and returns it with an explicit compatibility classification.
  public func parseWithCompatibility(data: Data) throws -> (
    document: FCPXML, compatibility: FCPXMLVersionCompatibility
  ) {
    let document = try parse(data: data)
    return (document, document.versionCompatibility)
  }

  /// Parses a document and throws when the declared version is malformed.
  ///
  /// Older and newer versions still decode best-effort per ADR 0001; only
  /// malformed version declarations fail this policy entry point.
  public func parseRequiringWellFormedVersion(data: Data) throws -> FCPXML {
    let (document, compatibility) = try parseWithCompatibility(data: data)
    if compatibility == .malformed {
      throw FCPXMLError.unsupportedVersion(document.version)
    }
    return document
  }
}

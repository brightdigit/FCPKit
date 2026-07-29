//
//  FCPXMLVersion.swift
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

/// Declared FCPXML document version and library compatibility policy.
///
/// A version string alone does not imply complete schema coverage. Support is
/// limited to the explicitly tested vocabulary for that version.
public struct FCPXMLVersion: RawRepresentable, Hashable, Sendable, Codable {
  /// Version emitted by typed generation and `MulticamXMLBuilder`.
  public static let supportedGeneration = FCPXMLVersion("1.13")

  /// Fixture versions currently covered by schema-completeness evidence.
  public static let testedFixtureVersions: Set<FCPXMLVersion> = [
    FCPXMLVersion("1.13"),
    FCPXMLVersion("1.14"),
  ]

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public init(_ rawValue: String) {
    self.rawValue = rawValue
  }
}

extension FCPXMLVersion {
  private static func numericComponents(_ value: String) -> [Int]? {
    let parts = value.split(separator: ".", omittingEmptySubsequences: false)
    guard !parts.isEmpty else {
      return nil
    }
    var components: [Int] = []
    components.reserveCapacity(parts.count)
    for part in parts {
      guard let number = Int(part), String(number) == part else {
        return nil
      }
      components.append(number)
    }
    return components
  }

  /// Evaluates compatibility of this declared version against the generation baseline.
  public func compatibility(
    relativeTo baseline: FCPXMLVersion = .supportedGeneration
  ) -> FCPXMLVersionCompatibility {
    guard let declaredComponents = Self.numericComponents(rawValue),
      let baselineComponents = Self.numericComponents(baseline.rawValue)
    else {
      return .malformed
    }

    if declaredComponents == baselineComponents {
      return .supported
    }
    if declaredComponents.lexicographicallyPrecedes(baselineComponents) {
      return .older
    }
    return .newer
  }
}

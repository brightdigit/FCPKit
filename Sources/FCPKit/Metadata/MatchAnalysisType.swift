//
//  MatchAnalysisType.swift
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
import XMLCoder

/// A `match-analysis-type` rule matching items by analysis result in a smart collection.
public struct MatchAnalysisType: Codable {
  internal enum CodingKeys: String, CodingKey {
    case rule
    case value
  }

  /// How the rule compares, e.g. "includesAny" or "doesNotIncludeAny".
  public var rule: String?
  /// The analysis type to match, e.g. "onePerson" or "wideShot".
  public var value: String?

  /// Creates a `match-analysis-type` rule with the given comparison and analysis type.
  public init(rule: String? = nil, value: String? = nil) {
    self.rule = rule
    self.value = value
  }
}

extension MatchAnalysisType: DynamicNodeEncoding {
  /// Encodes every property of the `match-analysis-type` element as an XML attribute.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding { .attribute }
}

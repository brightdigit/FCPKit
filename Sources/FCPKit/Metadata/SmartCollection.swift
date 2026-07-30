//
//  SmartCollection.swift
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

/// A `smart-collection` element that gathers library items matching a set of filter rules.
public struct SmartCollection: Codable {
  internal enum CodingKeys: String, CodingKey {
    case name
    case match
    case matchClip = "match-clip"
    case matchMedia = "match-media"
    case matchRatings = "match-ratings"
    case matchAnalysisType = "match-analysis-type"
  }

  /// The smart collection's display name, e.g. "All Video".
  public var name: String?
  /// How the rules combine: "all" (every rule) or "any" (at least one rule).
  public var match: String?
  /// The `match-clip` rules matching items by clip type.
  public var matchClip: [MatchClip]?
  /// The `match-media` rules matching items by media type.
  public var matchMedia: [MatchMedia]?
  /// The `match-ratings` rules matching items by favorite or rejected rating.
  public var matchRatings: [MatchRatings]?
  /// The `match-analysis-type` rules matching items by analysis results such as people or shots.
  public var matchAnalysisType: [MatchAnalysisType]?

  /// Creates a `smart-collection` element with the given name and filter rules.
  public init(
    name: String? = nil,
    match: String? = nil,
    matchClip: [MatchClip]? = nil,
    matchMedia: [MatchMedia]? = nil,
    matchRatings: [MatchRatings]? = nil,
    matchAnalysisType: [MatchAnalysisType]? = nil
  ) {
    self.name = name
    self.match = match
    self.matchClip = matchClip
    self.matchMedia = matchMedia
    self.matchRatings = matchRatings
    self.matchAnalysisType = matchAnalysisType
  }
}

extension SmartCollection: DynamicNodeEncoding {
  /// Encodes the match rules as child elements and all other keys as attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(
      for: key,
      elementKeys: [
        "match-clip", "match-media", "match-ratings", "match-analysis-type",
      ]
    )
  }
}

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

public struct SmartCollection: Codable {
  internal enum CodingKeys: String, CodingKey {
    case name
    case match
    case matchClip = "match-clip"
    case matchMedia = "match-media"
    case matchRatings = "match-ratings"
    case matchAnalysisType = "match-analysis-type"
  }

  public var name: String?
  public var match: String?
  public var matchClip: [MatchClip]?
  public var matchMedia: [MatchMedia]?
  public var matchRatings: [MatchRatings]?
  public var matchAnalysisType: [MatchAnalysisType]?

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
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(
      for: key,
      elementKeys: [
        "match-clip", "match-media", "match-ratings", "match-analysis-type",
      ]
    )
  }
}

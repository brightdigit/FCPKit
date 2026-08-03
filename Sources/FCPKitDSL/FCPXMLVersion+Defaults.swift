//
//  FCPXMLVersion+Defaults.swift
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

import FCPKit

extension FCPXMLVersion {
  /// The FCPXML version that introduced `match-analysis-type`.
  private static let analysisMatchingIntroduced = FCPXMLVersion("1.14")

  /// Indicates whether this version's DTD declares `match-analysis-type`.
  ///
  /// The element was introduced in FCPXML 1.14; emitting it in a 1.13 document
  /// makes the document invalid against Final Cut's own 1.13 DTD. A malformed
  /// version string is admitted so unparseable inputs keep prior behavior.
  internal var admitsAnalysisMatching: Bool {
    compatibility(relativeTo: Self.analysisMatchingIntroduced) != .older
  }

  /// The smart collections Final Cut creates in a new library at this version.
  ///
  /// `Missing Analysis` is included only where the schema declares
  /// `match-analysis-type`; see ``admitsAnalysisMatching``.
  internal var defaultSmartCollections: [SmartCollection] {
    var collections: [SmartCollection] = [
      SmartCollection(
        name: "Projects",
        match: "all",
        matchClip: [MatchClip(rule: "is", type: "project")]
      ),
      SmartCollection(
        name: "All Video",
        match: "any",
        matchMedia: [
          MatchMedia(rule: "is", type: "videoOnly"),
          MatchMedia(rule: "is", type: "videoWithAudio"),
        ]
      ),
      SmartCollection(
        name: "Audio Only",
        match: "all",
        matchMedia: [MatchMedia(rule: "is", type: "audioOnly")]
      ),
      SmartCollection(
        name: "Stills",
        match: "all",
        matchMedia: [MatchMedia(rule: "is", type: "stills")]
      ),
      SmartCollection(
        name: "Favorites",
        match: "all",
        matchRatings: [MatchRatings(value: "favorites")]
      ),
    ]
    if admitsAnalysisMatching {
      collections.append(
        SmartCollection(
          name: "Missing Analysis",
          match: "all",
          matchAnalysisType: [MatchAnalysisType(rule: "isMissing", value: "any")]
        )
      )
    }
    return collections
  }
}

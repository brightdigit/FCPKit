//
//  Defaults.swift
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

internal enum Defaults {
  internal static func smartCollections() -> [SmartCollection] {
    [
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
      SmartCollection(
        name: "Missing Analysis",
        match: "all",
        matchAnalysisType: [MatchAnalysisType(rule: "isMissing", value: "any")]
      ),
    ]
  }

  internal static func sequence(
    spine: FCPKit.Spine,
    format: ResourceRef<FormatKind>?
  ) throws(BuildError) -> FCPKit.Sequence {
    let packed = try Layout.pack(
      spine.items,
      frameDuration: FormatPreset.p1080p24.format.frameDuration
    )
    return FCPKit.Sequence(
      format: format,
      duration: packed.duration,
      tcStart: "0s",
      tcFormat: .nonDropFrame,
      audioLayout: .stereo,
      audioRate: .hz48000,
      renderFormat: "FFRenderFormatProRes422HQ",
      spine: FCPKit.Spine(items: packed.items)
    )
  }
}

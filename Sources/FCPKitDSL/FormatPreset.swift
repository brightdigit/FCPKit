//
//  FormatPreset.swift
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

/// A video format preset or custom format whose id is assigned on export.
public struct FormatPreset {
  /// 1080p24 Rec. 709, matching `FFVideoFormat1080p24`.
  public static var p1080p24: FormatPreset {
    FormatPreset(
      FCPKit.Format(
        id: ResourceStore.draftID,
        name: "FFVideoFormat1080p24",
        frameDuration: "100/2400s",
        width: "1920",
        height: "1080",
        colorSpace: "1-1-1 (Rec. 709)"
      )
    )
  }
  /// 720p24 Rec. 709, matching `FFVideoFormat720p24`.
  public static var p720p24: FormatPreset {
    FormatPreset(
      FCPKit.Format(
        id: ResourceStore.draftID,
        name: "FFVideoFormat720p24",
        frameDuration: "100/2400s",
        width: "1280",
        height: "720",
        colorSpace: "1-1-1 (Rec. 709)"
      )
    )
  }

  internal let format: FCPKit.Format
  internal let explicitID: ResourceID?

  /// Wraps a format resource as a preset.
  public init(_ format: FCPKit.Format, id: ResourceID? = nil) {
    var copy = format
    copy.id = id ?? ResourceStore.draftID
    self.format = copy
    self.explicitID = id
  }
}

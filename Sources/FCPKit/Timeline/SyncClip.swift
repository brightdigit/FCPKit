//
//  SyncClip.swift
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

/// A `sync-clip` element containing clips synchronized by matching audio or timecode.
public struct SyncClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    case offset
    case name
    case duration
    case tcFormat
    case format
    case start
    case modDate
    case assetClips = "asset-clip"
    case video
    case filterVideo = "filter-video"
  }

  /// The clip's start position on the parent timeline, as a rational time string.
  public let offset: String?
  /// The display name of the clip.
  public let name: String?
  /// The playback duration of the clip, as a rational time string.
  public let duration: String?
  /// The timecode format, such as `DF` (drop frame) or `NDF` (non-drop frame).
  public let tcFormat: String?
  /// The identifier of the `format` resource describing the clip's video format.
  public let format: String?
  /// The start time within the clip's local timeline, as a rational time string.
  public let start: String?
  /// The date the clip was last modified.
  public let modDate: String?
  /// The synchronized `asset-clip` elements contained in the clip.
  public let assetClips: [AssetClip]?
  /// Nested `video` elements contained in the clip.
  public let video: [Video]?
  /// The `filter-video` elements applying video effects to the clip.
  public let filterVideo: [FilterVideo]?
}

extension SyncClip: FCPNodeEncodable {
  /// Encodes child clip content as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = ["asset-clip", "video", "filter-video"]
}

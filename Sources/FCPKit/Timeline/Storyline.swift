//
//  Storyline.swift
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

/// A `storyline` element: a connected secondary storyline anchored to the primary spine.
public struct Storyline: Codable {
  internal enum CodingKeys: String, CodingKey {
    case lane
    case offset
    case format
    case clips = "clip"
    case assetClips = "asset-clip"
    case refClips = "ref-clip"
    case titles = "title"
    case generators = "generator"
  }

  /// The vertical lane the storyline occupies relative to the primary spine.
  public let lane: String?
  /// The storyline's start position on the parent timeline, as a rational time string.
  public let offset: String?
  /// The identifier of the `format` resource describing the storyline's video format.
  public let format: String?
  /// The `clip` elements in the storyline.
  public let clips: [Clip]?
  /// The `asset-clip` elements referencing asset resources.
  public let assetClips: [AssetClip]?
  /// The `ref-clip` elements referencing compound clips or other media resources.
  public let refClips: [RefClip]?
  /// The `title` elements in the storyline.
  public let titles: [Title]?
  /// The `generator` elements referencing generator effects.
  public let generators: [Generator]?
}

extension Storyline: FCPNodeEncodable {
  /// Encodes child clip content as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = [
    "clip", "asset-clip", "ref-clip", "title", "generator",
  ]
}

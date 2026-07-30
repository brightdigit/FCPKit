//
//  MCClip.swift
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

/// An `mc-clip` element that places a multicam media resource on the timeline.
public struct MCClip: Codable {
  internal enum CodingKeys: String, CodingKey {
    case ref
    case offset
    case name
    case start
    case duration
    case modDate
    case mcSources = "mc-source"
    case video
  }

  /// The identifier of the referenced multicam media resource.
  public var ref: String?
  /// The clip's start position on the parent timeline, as a rational time string.
  public var offset: String?
  /// The display name of the clip.
  public var name: String?
  /// The start time within the clip's local timeline, as a rational time string.
  public var start: String?
  /// The playback duration of the clip, as a rational time string.
  public var duration: String?
  /// The date the clip was last modified.
  public var modDate: String?
  /// The `mc-source` elements selecting which multicam angles are active.
  public var mcSources: [MCSource]?
  /// Nested `video` elements anchored to the clip.
  public var video: [Video]?

  /// Creates a multicam clip with the given attributes and contents.
  public init(
    ref: String? = nil,
    offset: String? = nil,
    name: String? = nil,
    start: String? = nil,
    duration: String? = nil,
    modDate: String? = nil,
    mcSources: [MCSource]? = nil,
    video: [Video]? = nil
  ) {
    self.ref = ref
    self.offset = offset
    self.name = name
    self.start = start
    self.duration = duration
    self.modDate = modDate
    self.mcSources = mcSources
    self.video = video
  }
}

extension MCClip: FCPNodeEncodable {
  /// Encodes child clip content as XML elements and remaining keys as attributes.
  public static let elementKeys: Set<String> = ["mc-source", "video"]
}

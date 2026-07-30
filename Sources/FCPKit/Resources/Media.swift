//
//  Media.swift
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

/// A `media` resource containing a compound clip sequence or multicam referenced by clips.
public struct Media: Codable {
  internal enum CodingKeys: String, CodingKey {
    case id
    case name
    case uid
    case modDate
    case sequence
    case multicam
    case mediaRep = "media-rep"
  }

  /// The resource identifier other elements use to reference this media, e.g. "r4".
  public let id: String?
  /// The media's display name as shown in the browser.
  public var name: String?
  /// A globally unique identifier for the media.
  public let uid: String?
  /// The media's last modification date, e.g. "2026-01-01 12:00:00 -0500".
  public var modDate: String?
  /// The compound clip's `sequence` content, if this media is a compound clip.
  public var sequence: Sequence?
  /// The `multicam` content with camera angles, if this media is a multicam clip.
  public var multicam: Multicam?
  /// The `media-rep` elements locating representations of the media.
  public var mediaRep: [MediaRep]?

  /// Creates a `media` resource wrapping a compound clip sequence or multicam.
  public init(
    id: String,
    name: String? = nil,
    uid: String? = nil,
    modDate: String? = nil,
    sequence: Sequence? = nil,
    multicam: Multicam? = nil,
    mediaRep: [MediaRep]? = nil
  ) {
    self.id = id
    self.name = name
    self.uid = uid
    self.modDate = modDate
    self.sequence = sequence
    self.multicam = multicam
    self.mediaRep = mediaRep
  }
}

extension Media: FCPNodeEncodable {
  /// Encodes `sequence`, `multicam`, and `media-rep` as child elements; other keys as attributes.
  public static let elementKeys: Set<String> = ["sequence", "multicam", "media-rep"]
}

//
//  MediaRep.swift
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

/// A `media-rep` element locating a representation (original or proxy) of an asset's media.
public struct MediaRep: Codable {
  internal enum CodingKeys: String, CodingKey {
    case kind
    case sig
    case src
    case bookmark
  }

  /// The representation kind.
  public var kind: MediaRepKind?
  /// The media file's content signature used to relink the representation.
  public var sig: String?
  /// The URL of the media file for this representation.
  public var src: String?
  /// A security-scoped bookmark, base64-encoded, for locating the media file.
  public var bookmark: String?

  /// Creates a `media-rep` element describing one representation of an asset's media.
  public init(
    kind: MediaRepKind? = nil,
    sig: String? = nil,
    src: String? = nil,
    bookmark: String? = nil
  ) {
    self.kind = kind
    self.sig = sig
    self.src = src
    self.bookmark = bookmark
  }
}

extension MediaRep: FCPNodeEncodable {
  /// Encodes `bookmark` as a child element and all other keys as attributes.
  public static let elementKeys: Set<String> = ["bookmark"]
}

//
//  MediaRepKind.swift
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

/// The `media-rep` element's `kind` attribute: which representation of an asset it locates.
///
/// DTD vocabulary: `(original-media | proxy-media)`, defaulting to
/// `original-media` in the schema. Out-of-vocabulary values decode as
/// ``unknown(_:)`` by default; see ``XMLEnumDecodingMode`` for strict decoding.
public enum MediaRepKind: XMLAttributeEnum {
  /// The original media file, written `"original-media"`.
  case originalMedia

  /// A proxy transcode of the media, written `"proxy-media"`.
  case proxyMedia

  /// An out-of-vocabulary value preserved for round-tripping.
  case unknown(String)

  /// The FCPXML attribute string for this value.
  public var fcpxmlString: String {
    switch self {
    case .originalMedia: "original-media"
    case .proxyMedia: "proxy-media"
    case .unknown(let rawValue): rawValue
    }
  }

  /// Creates a value from the known `kind` vocabulary.
  public static func known(fcpxmlString: String) -> MediaRepKind? {
    switch fcpxmlString {
    case "original-media": .originalMedia
    case "proxy-media": .proxyMedia
    default: nil
    }
  }
}

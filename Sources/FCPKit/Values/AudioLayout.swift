//
//  AudioLayout.swift
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

/// The `audioLayout` attribute: the channel layout of sequence audio.
///
/// DTD vocabulary: `(mono | stereo | surround)`. Out-of-vocabulary values decode
/// as ``unknown(_:)`` by default; see ``XMLEnumDecodingMode`` for strict decoding.
public enum AudioLayout: XMLAttributeEnum {
  /// Single-channel audio, written `"mono"`.
  case mono

  /// Two-channel audio, written `"stereo"`.
  case stereo

  /// Multi-channel surround audio, written `"surround"`.
  case surround

  /// An out-of-vocabulary value preserved for round-tripping.
  case unknown(String)

  /// The FCPXML attribute string for this value.
  public var fcpxmlString: String {
    switch self {
    case .mono: "mono"
    case .stereo: "stereo"
    case .surround: "surround"
    case .unknown(let rawValue): rawValue
    }
  }

  /// Creates a value from the known `audioLayout` vocabulary.
  public static func known(fcpxmlString: String) -> AudioLayout? {
    switch fcpxmlString {
    case "mono": .mono
    case "stereo": .stereo
    case "surround": .surround
    default: nil
    }
  }
}

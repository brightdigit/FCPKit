//
//  AudioRate.swift
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

/// The sequence-style `audioRate` attribute: the audio sample rate vocabulary.
///
/// DTD vocabulary (`%audioHz;`): `(32k | 44.1k | 48k | 88.2k | 96k | 176.4k | 192k)`.
/// This is the `sequence`/`multicam` value space; `asset.audioRate` is a plain
/// integer in hertz (for example `"48000"`) and must not use this type.
/// Out-of-vocabulary values decode as ``unknown(_:)`` by default; see
/// ``XMLEnumDecodingMode`` for strict decoding.
public enum AudioRate: XMLAttributeEnum {
  /// 32,000 Hz, written `"32k"`.
  case hz32000

  /// 44,100 Hz, written `"44.1k"`.
  case hz44100

  /// 48,000 Hz, written `"48k"`.
  case hz48000

  /// 88,200 Hz, written `"88.2k"`.
  case hz88200

  /// 96,000 Hz, written `"96k"`.
  case hz96000

  /// 176,400 Hz, written `"176.4k"`.
  case hz176400

  /// 192,000 Hz, written `"192k"`.
  case hz192000

  /// An out-of-vocabulary value preserved for round-tripping.
  case unknown(String)

  private static let knownValues: [String: AudioRate] = [
    "32k": .hz32000,
    "44.1k": .hz44100,
    "48k": .hz48000,
    "88.2k": .hz88200,
    "96k": .hz96000,
    "176.4k": .hz176400,
    "192k": .hz192000,
  ]

  /// The FCPXML attribute string for this value.
  public var fcpxmlString: String {
    switch self {
    case .hz32000: "32k"
    case .hz44100: "44.1k"
    case .hz48000: "48k"
    case .hz88200: "88.2k"
    case .hz96000: "96k"
    case .hz176400: "176.4k"
    case .hz192000: "192k"
    case .unknown(let rawValue): rawValue
    }
  }

  /// Creates a value from the known `audioRate` vocabulary.
  public static func known(fcpxmlString: String) -> AudioRate? {
    knownValues[fcpxmlString]
  }
}

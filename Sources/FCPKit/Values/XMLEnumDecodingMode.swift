//
//  XMLEnumDecodingMode.swift
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

/// Controls how DTD-enumeration attributes treat out-of-vocabulary raw values on decode.
///
/// Pass a mode to a decoder through its `userInfo` under ``userInfoKey``:
///
/// ```swift
/// let decoder = XMLDecoder()
/// decoder.userInfo[XMLEnumDecodingMode.userInfoKey] = XMLEnumDecodingMode.strict
/// ```
///
/// When no mode is set, decoding defaults to ``passThrough`` so real documents
/// written by newer Final Cut Pro versions keep loading and round-tripping.
public enum XMLEnumDecodingMode: Sendable {
  /// Unknown raw values decode into a pass-through `unknown` case and re-encode unchanged.
  case passThrough

  /// Unknown raw values fail decoding with `DecodingError.dataCorrupted`.
  case strict

  /// The `userInfo` key under which a decoder declares its enum decoding mode.
  public static let userInfoKey: CodingUserInfoKey = {
    guard let key = CodingUserInfoKey(rawValue: "FCPKit.XMLEnumDecodingMode") else {
      fatalError("CodingUserInfoKey initialization never fails for a non-empty raw value")
    }
    return key
  }()

  /// The mode declared in the decoder's `userInfo`, defaulting to ``passThrough``.
  public static func resolved(from decoder: any Decoder) -> XMLEnumDecodingMode {
    decoder.userInfo[userInfoKey] as? XMLEnumDecodingMode ?? .passThrough
  }
}

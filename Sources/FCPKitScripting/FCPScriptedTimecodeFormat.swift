//
//  FCPScriptedTimecodeFormat.swift
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

/// Timecode format from Final Cut Pro's scripting dictionary.
///
/// The sdef enumeration includes `unspecified`, which has no FCPXML `tcFormat` counterpart.
public enum FCPScriptedTimecodeFormat: Hashable, Sendable {
  /// Timecode format has not been set on the sequence.
  case unspecified

  /// Drop-frame timecode.
  case dropFrame

  /// Non-drop-frame timecode.
  case nonDropFrame

  /// Maps to FCPXML `tcFormat` when the scripting value is known; ``unspecified`` becomes `nil`.
  public var tcFormat: TCFormat? {
    switch self {
    case .unspecified: nil
    case .dropFrame: .dropFrame
    case .nonDropFrame: .nonDropFrame
    }
  }

  /// Maps FCPXML drop-frame / non-drop-frame values; there is no XML value for ``unspecified``.
  public init(_ xml: TCFormat) {
    switch xml {
    case .dropFrame: self = .dropFrame
    case .nonDropFrame: self = .nonDropFrame
    }
  }
}

//
//  TextMargins.swift
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

/// The wrap box for a title, in Final Cut margin space (origin at frame
/// centre; +X right, +Y up).
public struct TextMargins: Equatable, Sendable {
  /// Left margin.
  public var left: Double
  /// Right margin.
  public var right: Double
  /// Top margin.
  public var top: Double
  /// Bottom margin.
  public var bottom: Double

  /// Creates absolute margins in Final Cut's text-box coordinate space.
  public init(left: Double, right: Double, top: Double, bottom: Double) {
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
  }

  /// Margins that inset the wrap box from each edge of a `width`×`height` frame.
  internal static func fillFrame(
    inset: Double,
    width: Double,
    height: Double
  ) -> TextMargins {
    let halfWidth = width / 2
    let halfHeight = height / 2
    return TextMargins(
      left: -(halfWidth - inset),
      right: halfWidth - inset,
      top: halfHeight - inset,
      bottom: -(halfHeight - inset)
    )
  }
}

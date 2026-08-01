//
//  Color+AppKit.swift
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

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit

  extension Color {
    /// Creates a ``Color`` from an `NSColor`.
    public init(_ nsColor: NSColor) {
      if let srgb = nsColor.usingColorSpace(.sRGB) {
        self.init(
          red: Double(srgb.redComponent),
          green: Double(srgb.greenComponent),
          blue: Double(srgb.blueComponent),
          alpha: Double(srgb.alphaComponent)
        )
      } else if let converted = Color(nsColor.cgColor) {
        self = converted
      } else {
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
      }
    }
  }
#endif

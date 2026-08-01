//
//  Color+CoreGraphics.swift
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

#if canImport(CoreGraphics)
  import CoreGraphics

  extension Color {
    /// Creates a ``Color`` from a `CGColor`.
    public init?(_ cgColor: CGColor) {
      guard let srgbSpace = CGColorSpace(name: CGColorSpace.sRGB),
        let converted = cgColor.converted(to: srgbSpace, intent: .defaultIntent, options: nil),
        let components = converted.components,
        components.count >= 3
      else {
        return nil
      }
      let redVal = Double(components[0])
      let greenVal = Double(components[1])
      let blueVal = Double(components[2])
      let alphaVal = components.count >= 4 ? Double(components[3]) : 1.0
      self.init(red: redVal, green: greenVal, blue: blueVal, alpha: alphaVal)
    }
  }
#endif

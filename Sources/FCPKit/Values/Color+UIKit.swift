//
//  Color+UIKit.swift
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

#if canImport(UIKit)
  import UIKit

  extension Color {
    /// Creates a ``Color`` from a `UIColor`.
    public init(_ uiColor: UIColor) {
      var redVal: CGFloat = 0
      var greenVal: CGFloat = 0
      var blueVal: CGFloat = 0
      var alphaVal: CGFloat = 0
      if uiColor.getRed(&redVal, green: &greenVal, blue: &blueVal, alpha: &alphaVal) {
        self.init(
          red: Double(redVal),
          green: Double(greenVal),
          blue: Double(blueVal),
          alpha: Double(alphaVal)
        )
      } else if let converted = Color(uiColor.cgColor) {
        self = converted
      } else {
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
      }
    }
  }
#endif

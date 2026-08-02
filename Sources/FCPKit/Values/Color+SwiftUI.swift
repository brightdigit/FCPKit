//
//  Color+SwiftUI.swift
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

#if canImport(SwiftUI)
  import SwiftUI

  #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
  #endif

  #if canImport(UIKit)
    import UIKit
  #endif

  extension Color {
    /// Creates a ``Color`` from a `SwiftUI.Color`.
    public init?(_ color: SwiftUI.Color) {
      if let cgColor = color.cgColor, let converted = Color(cgColor) {
        self = converted
        return
      }
      #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        self.init(NSColor(color))
      #elseif canImport(UIKit)
        self.init(UIColor(color))
      #else
        return nil
      #endif
    }
  }
#endif

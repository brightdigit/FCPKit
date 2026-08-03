//
//  ColorTests.swift
//  FCPKitTests
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
import Testing

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
  import AppKit
#endif

#if canImport(UIKit)
  import UIKit
#endif

#if canImport(SwiftUI)
  import SwiftUI
#endif

@Suite
internal struct ColorTests {
  private typealias Color = FCPKit.Color

  @Test
  internal func descriptionFormatsFCPRationalStrings() {
    #expect(Color.red.description == "1 0 0 1")
    #expect(Color(red: 0.5, green: 0.25, blue: 0, alpha: 1).description == "0.5 0.25 0 1")
  }

  @Test
  internal func parsesFCPRationalString() {
    let color = Color(fcpString: "1 0 0 1")
    #expect(color == Color.red)

    let parsedGrayscale = Color(fcpString: "0.5 0.5 0.5")
    #expect(parsedGrayscale == Color(white: 0.5, alpha: 1.0))
  }

  @Test
  internal func parsesHexStrings() {
    #expect(Color(hex: "#FF0000") == Color.red)
    #expect(Color(hex: "00FF00") == Color.green)
    #expect(Color(hex: "#0000FF80") == Color(red: 0, green: 0, blue: 1, alpha: 128.0 / 255.0))
    #expect(Color(hex: "F00") == Color.red)
  }

  #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    @Test
    internal func convertsFromNSColor() {
      let nsColor = NSColor.red
      let color = Color(nsColor)
      #expect(color.red == 1.0)
      #expect(color.green == 0.0)
      #expect(color.blue == 0.0)
    }
  #endif

  #if canImport(UIKit)
    @Test
    internal func convertsFromUIColor() {
      let uiColor = UIColor.red
      let color = Color(uiColor)
      #expect(color.red == 1.0)
      #expect(color.green == 0.0)
      #expect(color.blue == 0.0)
    }
  #endif

  #if canImport(SwiftUI)
    @Test
    internal func convertsFromSwiftUIColor() {
      let swiftUIColor = SwiftUI.Color.red
      if let color = Color(swiftUIColor) {
        #expect(color.red == 1.0)
      }
    }
  #endif
}

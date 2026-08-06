//
//  Title+TextBox.swift
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

extension Title {
  /// Sets the text layout method (for example Paragraph wrapping).
  public func layout(_ method: TextLayoutMethod) -> Title {
    var layout = textBoxLayout ?? TextBoxLayout()
    layout.method = method
    return replacing(textBoxLayout: layout)
  }

  /// Sets absolute text-box margins in Final Cut's margin coordinate space.
  ///
  /// Also enables ``TextLayoutMethod/paragraph`` when no layout method was set.
  public func margins(left: Double, right: Double, top: Double, bottom: Double) -> Title {
    var layout = textBoxLayout ?? TextBoxLayout()
    if layout.method == nil {
      layout.method = .paragraph
    }
    layout.margins = TextMargins(left: left, right: right, top: top, bottom: bottom)
    layout.fillInset = nil
    return replacing(textBoxLayout: layout)
  }

  /// Configures a wrap box for this title.
  ///
  /// ``TextBox/fillFrame(inset:)`` sets Paragraph layout and derives margins from
  /// the enclosing sequence frame.
  public func textBox(_ box: TextBox) -> Title {
    var layout = textBoxLayout ?? TextBoxLayout()
    layout.method = .paragraph
    switch box.kind {
    case .fillFrame(let inset):
      layout.fillInset = inset
      layout.margins = nil
    }
    return replacing(textBoxLayout: layout)
  }
}

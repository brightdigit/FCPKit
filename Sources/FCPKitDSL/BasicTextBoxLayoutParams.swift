//
//  BasicTextBoxLayoutParams.swift
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

/// Basic Title Motion param keys from FeaturePairs/title-wrap/after.fcpxml.
internal enum BasicTextBoxLayoutParams {
  private static let prefix = "9999/999166631/999166633/2"

  internal static func parameters(
    method: TextLayoutMethod?,
    margins: TextMargins?
  ) -> [ParamElement]? {
    var params: [ParamElement] = []
    if method == .paragraph || margins != nil {
      params.append(
        ParamElement(
          name: "Layout Method",
          key: "\(prefix)/314",
          value: "1 (Paragraph)"
        )
      )
      // Real Motion → FCP exports set Flatten when using Paragraph layout.
      params.append(
        ParamElement(name: "Flatten", key: "\(prefix)/351", value: "1")
      )
    }
    if let margins {
      params.append(contentsOf: [
        ParamElement(
          name: "Left Margin",
          key: "\(prefix)/323",
          value: String(fcpxmlValue: margins.left)
        ),
        ParamElement(
          name: "Right Margin",
          key: "\(prefix)/324",
          value: String(fcpxmlValue: margins.right)
        ),
        ParamElement(
          name: "Top Margin",
          key: "\(prefix)/325",
          value: String(fcpxmlValue: margins.top)
        ),
        ParamElement(
          name: "Bottom Margin",
          key: "\(prefix)/326",
          value: String(fcpxmlValue: margins.bottom)
        ),
      ])
    }
    return params.isEmpty ? nil : params
  }
}

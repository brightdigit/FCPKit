//
//  TitlesCutDocument.swift
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
import FCPKitDSL
import Foundation

/// A clip with a Basic Title anchored on lane 1, for Final Cut import smoke tests.
internal struct TitlesCutDocument: Document {
  internal let mediaURL: URL
  internal let mediaDuration: FCPTime
  internal let titleText: String
  internal let titleDuration: FCPTime
  internal let projectName: String

  internal var body: some DocumentContent {
    Project(name: projectName) {
      Sequence(format: .p1080p24) {
        AssetClip(mediaURL, duration: mediaDuration)
          .audioRole("dialogue")
          .anchor(lane: 1) {
            Title(.basic, text: titleText, duration: titleDuration)
          }
      }
    }
  }
}

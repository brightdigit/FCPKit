//
//  PresentationDocument.swift
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

/// A starter `FCPKitDSL` document for hand-authored presentation video.
///
/// Replace the placeholder cut in ``body`` with your own storyline — colors,
/// titles, clips, transitions, and anything else the DSL supports. Export with
/// `fcpxml-dsl export presentation`.
public struct PresentationDocument: Document {
  /// The Final Cut Pro project name written into the exported document.
  public let projectName: String

  /// The project shell; author the cut inside the ``Sequence``.
  public var body: DocumentGroup {
    Project(name: projectName) {
      Sequence {
        Color.white.duration(2.0).anchor(lane: 1) {
          Title("Welcome to FCPKit!").fontColor(.black).alignment(.center)
        }
        // insert wipes ad movement transitions
        Color.green.duration(5.0).anchor(lane: 1) {
          Title("This library allows you to create Final Cut Pro project documents at ease.").alignment(.center)
        }
      }
    }
    .colorProcessing(.wideHDR)
  }

  /// Creates a presentation document shell.
  public init(projectName: String = "FCPKit Presentation") {
    self.projectName = projectName
  }
}

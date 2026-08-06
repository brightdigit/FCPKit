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
import Foundation

/// A starter `FCPKitDSL` document for hand-authored presentation video.
///
/// Replace the placeholder cut in ``body`` with your own storyline — colors,
/// titles, clips, transitions, and anything else the DSL supports. Export with
/// `fcpxml-dsl export presentation`.
public struct PresentationDocument: Document {
  /// Bundled demo still used by the sample image slide.
  public static var placeholderImageURL: URL {
    guard let url = resourceBundle.url(forResource: "Placeholder", withExtension: "jpg") else {
      fatalError("Missing Placeholder.jpg in FCPKitDemo module resources")
    }
    return url
  }

  /// The Final Cut Pro project name written into the exported document.
  public let projectName: String

  /// The project shell; author the cut inside the ``Sequence``.
  public var body: DocumentGroup {
    Project(name: projectName) {
      Sequence {
        Color.white.duration(2.0).anchor(lane: 1) {
          Title("Welcome to FCPKit!").fontColor(.black).alignment(.center)
        }
        Transition(.diagonal)
        Color.green.duration(5.0).anchor(lane: 1) {
          Title("This library allows you to create Final Cut Pro project documents at ease.")
            .alignment(.center)
            .textBox(.fillFrame(inset: 80))
        }
        Transition(.push)
        Color.blue.duration(3.0).anchor(lane: 1) {
          Title("Typed FCPXML, ready for Final Cut Pro.").alignment(.center)
        }
        Transition(.crossDissolve)
        AssetClip(
          .still(url: Self.placeholderImageURL, width: 1_920, height: 1_080)
        )
        .duration(4.0)
        .anchor(lane: 1) {
          Title("Bundled stills ship with FCPKitDemo resources.").alignment(.center)
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

extension PresentationDocument {
  private final class ResourceBundleToken {}

  /// Locates `FCPKit_FCPKitDemo.bundle` without using SPM's `Bundle.module`
  /// (SourceKit often fails to surface that synthesized accessor).
  private static var resourceBundle: Bundle {
    let bundleName = "FCPKit_FCPKitDemo"
    let candidates: [URL?] = [
      Bundle.main.resourceURL?.appendingPathComponent("\(bundleName).bundle"),
      Bundle(for: ResourceBundleToken.self).resourceURL?
        .appendingPathComponent("\(bundleName).bundle"),
      Bundle.main.bundleURL.appendingPathComponent("\(bundleName).bundle"),
    ]
    for candidate in candidates {
      if let candidate, let bundle = Bundle(url: candidate) {
        return bundle
      }
    }
    fatalError("unable to find bundle named \(bundleName)")
  }
}

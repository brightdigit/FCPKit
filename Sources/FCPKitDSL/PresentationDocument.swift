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

/// A media-free slide deck showcasing `FCPKitDSL`.
///
/// Each slide is a solid color generator with a styled title anchored on lane 1,
/// separated by cross dissolves. No `.mov` files and no `ffmpeg` are involved, so
/// anyone who clones the repository can regenerate the `.fcpxml` with one command.
public struct PresentationDocument: Document {
  /// The Final Cut Pro project name written into the exported document.
  public let projectName: String
  /// The slides, in order.
  public let slides: [PresentationSlide]
  /// The cross dissolve duration between consecutive slides.
  public let transitionDuration: FCPTime

  /// The slides, interleaved with cross dissolves.
  public var body: some DocumentContent {
    Project(name: projectName) {
      PresentationSequence(document: self)
    }
  }

  /// Creates a presentation document.
  public init(
    projectName: String = "FCPKit Presentation",
    slides: [PresentationSlide] = PresentationDocument.featureShowcase,
    transitionDuration: FCPTime = FCPTime(numerator: 1)
  ) {
    self.projectName = projectName
    self.slides = slides
    self.transitionDuration = transitionDuration
  }

  /// Builds the alternating background / transition sequence.
  internal func storyContent() -> [any DocumentContent] {
    var content: [any DocumentContent] = []
    for (index, slide) in slides.enumerated() {
      if index > 0 {
        content.append(Transition(.crossDissolve, duration: transitionDuration))
      }
      content.append(background(for: slide, at: index))
    }
    return content
  }

  /// A slide's color background carrying its anchored, dissolve-safe title.
  private func background(for slide: PresentationSlide, at index: Int) -> any DocumentContent {
    slide.background
      .duration(slide.duration)
      .anchor(lane: 1, offset: .zero) {
        Title(slide.heading, duration: titleDuration(for: slide, at: index))
          .font("Helvetica")
          .fontFace("Bold")
          .fontSize(96)
          .position(.center)
      }
  }

  /// The visible span of a slide after its dissolves are deducted.
  ///
  /// Anchored items are not swept into a primary-storyline transition, so a title
  /// spanning a dissolve would hard-cut while its background dissolved. Packing
  /// sets a dissolved clip's `start` to T/2 and shrinks its duration by both
  /// overlaps, and an anchor's offset is relative to that trimmed start — so a
  /// title at offset zero already begins where the incoming dissolve ends, and
  /// only the tail needs trimming.
  public func titleDuration(for slide: PresentationSlide, at index: Int) -> FCPTime {
    let incoming = index == 0 ? 0 : transitionDuration.seconds / 2
    let outgoing = index == slides.count - 1 ? 0 : transitionDuration.seconds / 2
    return .seconds(slide.duration.seconds - incoming - outgoing)
  }
}

extension PresentationDocument {
  /// The default FCPKit feature deck.
  public static let featureShowcase: [PresentationSlide] = [
    PresentationSlide(heading: "FCPKit", background: Color(red: 0.08, green: 0.08, blue: 0.08)),
    PresentationSlide(
      heading: "Typed FCPXML model",
      background: Color(red: 0.05, green: 0.15, blue: 0.42)
    ),
    PresentationSlide(
      heading: "Ordered spine, preserved",
      background: Color(red: 0.0, green: 0.32, blue: 0.36)
    ),
    PresentationSlide(
      heading: "SwiftUI-shaped DSL",
      background: Color(red: 0.29, green: 0.12, blue: 0.45)
    ),
    PresentationSlide(
      heading: "Resource interning",
      background: Color(red: 0.6, green: 0.28, blue: 0.02)
    ),
    PresentationSlide(
      heading: "DTD-validated output",
      background: Color(red: 0.06, green: 0.36, blue: 0.16)
    ),
    PresentationSlide(
      heading: "brightdigit/FCPKit",
      background: Color(red: 0.08, green: 0.08, blue: 0.08)
    ),
  ]
}

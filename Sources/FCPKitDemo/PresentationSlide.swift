//
//  PresentationSlide.swift
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

/// A slide in a ``PresentationDocument``: a heading over a solid color background.
public struct PresentationSlide: Sendable {
  /// The slide's primary heading.
  public var heading: String
  /// An optional secondary line beneath the heading.
  public var subheading: String?
  /// The solid color filling the frame behind the text.
  public var background: Color
  /// How long the slide holds on screen, before dissolve overlap is deducted.
  public var duration: FCPTime

  /// Creates a slide.
  public init(
    heading: String,
    subheading: String? = nil,
    background: Color,
    duration: FCPTime = .seconds(6)
  ) {
    self.heading = heading
    self.subheading = subheading
    self.background = background
    self.duration = duration
  }
}

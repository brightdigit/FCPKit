//
//  FramePosition.swift
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

import Foundation

/// A position within the video frame.
///
/// Final Cut's `adjust-transform position` is expressed as a percentage of the
/// frame **height on both axes**, measured from the frame centre, with Y
/// pointing up. Alignment cases resolve without knowing the frame size;
/// absolute pixel coordinates need the enclosing sequence's format.
public struct FramePosition: Equatable, Sendable {
  /// The nine standard frame alignments.
  public enum Alignment: Equatable, Sendable {
    /// The top-leading corner.
    case topLeading
    /// The top edge, horizontally centered.
    case top
    /// The top-trailing corner.
    case topTrailing
    /// The leading edge, vertically centered.
    case leading
    /// The frame centre.
    case center
    /// The trailing edge, vertically centered.
    case trailing
    /// The bottom-leading corner.
    case bottomLeading
    /// The bottom edge, horizontally centered.
    case bottom
    /// The bottom-trailing corner.
    case bottomTrailing
  }

  /// How a position is expressed before resolution.
  internal enum Kind: Equatable, Sendable {
    case alignment(Alignment, inset: Double)
    case absolute(x: Double, y: Double)
  }

  internal let kind: Kind

  /// A position at a frame alignment, optionally inset in points.
  public static func aligned(_ alignment: Alignment, inset: Double = 0) -> FramePosition {
    FramePosition(kind: .alignment(alignment, inset: inset))
  }

  /// A position at absolute pixel coordinates, with the origin at the top left.
  public static func absolute(x: Double, y: Double) -> FramePosition {
    FramePosition(kind: .absolute(x: x, y: y))
  }
}

extension FramePosition {
  /// Converts absolute pixels (origin top-left) into Final Cut's percent-of-height units.
  ///
  /// The divisor is the frame **height** on both axes; that is what makes the
  /// values in the 16:9 fixtures land correctly.
  internal static func percent(
    x absoluteX: Double,
    y absoluteY: Double,
    width: Double,
    height: Double
  ) -> (x: Double, y: Double) {
    (
      x: (absoluteX - width / 2) / height * 100,
      y: (height / 2 - absoluteY) / height * 100
    )
  }

  /// Resolves an alignment, returning `nil` when it needs no transform.
  ///
  /// - Throws: ``BuildError/missingFrameSize`` when a non-zero inset is requested
  ///   without a frame size. An inset is in points, and converting points to
  ///   Final Cut's percent-of-height unit requires the frame height — silently
  ///   dropping it would emit a position the caller did not ask for.
  private static func alignmentPercent(
    _ alignment: Alignment,
    inset: Double,
    frameSize: (width: Double, height: Double)?
  ) throws -> (x: Double, y: Double)? {
    // `.center` is the frame centre on both axes, so an inset has no direction
    // to move along and the position needs no `adjust-transform` at all.
    if alignment == .center {
      return nil
    }

    guard inset == 0 || frameSize != nil else {
      throw BuildError.missingFrameSize
    }

    // Vertical extent is exactly ±50% of the height. Horizontal extent depends
    // on the aspect ratio, because the unit's divisor is the height on both
    // axes; 16:9 is assumed when no format is known.
    let aspect = frameSize.map { $0.width / $0.height } ?? (16.0 / 9.0)
    let halfWidth = aspect / 2 * 100
    let insetPercent = frameSize.map { inset / $0.height * 100 } ?? 0

    return (
      x: horizontalPercent(alignment, extent: halfWidth, inset: insetPercent),
      y: verticalPercent(alignment, inset: insetPercent)
    )
  }

  /// The horizontal component of an alignment, in percent-of-height units.
  private static func horizontalPercent(
    _ alignment: Alignment,
    extent: Double,
    inset: Double
  ) -> Double {
    switch alignment {
    case .topLeading, .leading, .bottomLeading:
      return -extent + inset
    case .topTrailing, .trailing, .bottomTrailing:
      return extent - inset
    case .top, .center, .bottom:
      return 0
    }
  }

  /// The vertical component of an alignment, in percent-of-height units.
  private static func verticalPercent(_ alignment: Alignment, inset: Double) -> Double {
    switch alignment {
    case .topLeading, .top, .topTrailing:
      return 50 - inset
    case .bottomLeading, .bottom, .bottomTrailing:
      return -50 + inset
    case .leading, .center, .trailing:
      return 0
    }
  }
}

extension FramePosition {
  /// Resolves this position into an `adjust-transform position` value.
  ///
  /// - Parameter frameSize: The enclosing sequence's frame size, when known.
  /// - Returns: The formatted `"x y"` pair, or `nil` when the position is the
  ///   frame centre and therefore needs no `adjust-transform` at all.
  /// - Throws: ``BuildError/missingFrameSize`` when absolute coordinates were
  ///   used without an enclosing format.
  internal func resolve(frameSize: (width: Double, height: Double)?) throws -> String? {
    let point: (x: Double, y: Double)

    switch kind {
    case .alignment(let alignment, let inset):
      guard
        let resolved = try Self.alignmentPercent(alignment, inset: inset, frameSize: frameSize)
      else {
        return nil
      }
      point = resolved

    case .absolute(let absoluteX, let absoluteY):
      guard let frameSize else {
        throw BuildError.missingFrameSize
      }
      point = Self.percent(
        x: absoluteX,
        y: absoluteY,
        width: frameSize.width,
        height: frameSize.height
      )
    }

    return "\(format(point.x)) \(format(point.y))"
  }

  /// Formats a component, collapsing whole numbers (`0`, not `0.0`).
  fileprivate func format(_ value: Double) -> String {
    decimalString(value)
  }
}

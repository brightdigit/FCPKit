//
//  Layout.swift
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

internal enum Layout {
  internal struct Packed {
    internal let items: [FCPKit.SpineItem]
    internal let duration: String
  }

  internal struct Overlap {
    internal let previous: Int64
    internal let next: Int64
  }

  internal struct Placement {
    internal let offset: Int64
    internal let start: Int64
    internal let duration: Int64
    internal let cursor: Int64
    internal let longest: Int64
  }

  internal struct PackStep {
    internal let item: FCPKit.SpineItem
    internal let cursor: Int64
    internal let longest: Int64
  }

  /// Packs spine offsets using centered transition overlap.
  ///
  /// Each transition of duration `T` overlaps the previous clip's end and the next
  /// clip's start by `T/2`. Times that reduce to whole seconds render as `"Ns"`;
  /// otherwise they keep the sequence tick denominator (for 24fps, `/2400s`).
  internal static func pack(_ items: [FCPKit.SpineItem], frameDuration: String?) throws -> Packed {
    let tickDenominator = tickDenominator(for: frameDuration)
    var cursor: Int64 = 0
    var longest: Int64 = 0
    var output: [FCPKit.SpineItem] = []

    for index in items.indices {
      let packed = try packItem(
        items[index],
        overlap: overlap(at: index, in: items, tickDenominator: tickDenominator),
        cursor: cursor,
        longest: longest,
        tickDenominator: tickDenominator
      )
      cursor = packed.cursor
      longest = packed.longest
      output.append(packed.item)
    }

    return Packed(items: output, duration: render(max(cursor, longest), tickDenominator))
  }

  private static func packItem(
    _ item: FCPKit.SpineItem,
    overlap: Overlap,
    cursor: Int64,
    longest: Int64,
    tickDenominator: Int32
  ) throws -> PackStep {
    if let overlapping = try packOverlapping(
      item,
      overlap: overlap,
      cursor: cursor,
      longest: longest,
      tickDenominator: tickDenominator
    ) {
      return overlapping
    }
    return try packNonOverlapping(
      item,
      cursor: cursor,
      longest: longest,
      tickDenominator: tickDenominator
    )
  }

  private static func overlap(
    at index: Int,
    in items: [FCPKit.SpineItem],
    tickDenominator: Int32
  ) -> Overlap {
    let previous = index > 0 ? transitionDuration(items[index - 1], tickDenominator) / 2 : 0
    let next =
      index + 1 < items.count
      ? transitionDuration(items[index + 1], tickDenominator) / 2
      : 0
    return Overlap(previous: previous, next: next)
  }

  private static func tickDenominator(for frameDuration: String?) -> Int32 {
    guard let frameDuration, let time = FCPTime(frameDuration) else {
      return 1
    }
    return time.denominator
  }

  private static func transitionDuration(_ item: FCPKit.SpineItem, _ denominator: Int32) -> Int64 {
    guard case .transition(let transition) = item else {
      return 0
    }
    return (try? ticks(transition.duration, denominator, "transition")) ?? 0
  }
}

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

  /// Packs spine offsets using centered transition overlap.
  ///
  /// Each transition of duration `T` overlaps the previous clip's end and the next
  /// clip's start by `T/2`. Times that reduce to whole seconds render as `"Ns"`;
  /// otherwise they keep the sequence tick denominator (for 24fps, `/2400s`).
  internal static func pack(_ items: [FCPKit.SpineItem], frameDuration: String?) throws -> Packed {
    let tickDenominator = tickDenominator(for: frameDuration)
    var cursor: Int64 = 0
    var output: [FCPKit.SpineItem] = []
    var longest: Int64 = 0

    for index in items.indices {
      let previousOverlap =
        index > 0 ? transitionDuration(items[index - 1], tickDenominator) / 2 : 0
      let nextOverlap =
        index + 1 < items.count
        ? transitionDuration(items[index + 1], tickDenominator) / 2
        : 0

      switch items[index] {
      case .assetClip(var clip):
        let original = try ticks(clip.duration, tickDenominator, "asset clip")
        let start = previousOverlap
        let duration = original - start - nextOverlap
        let offset = cursor
        clip.offset = render(offset, tickDenominator)
        clip.start = start == 0 ? nil : render(start, tickDenominator)
        clip.duration = render(duration, tickDenominator)
        longest = max(
          longest,
          offset + duration,
          offset + anchoredExtent(clip.anchoredItems, tickDenominator)
        )
        cursor += duration
        output.append(.assetClip(clip))

      case .gap(var gap):
        let duration = try ticks(gap.duration, tickDenominator, "gap")
        gap.offset = render(cursor, tickDenominator)
        cursor += duration
        longest = max(longest, cursor)
        output.append(.gap(gap))

      case .transition(var transition):
        let duration = try ticks(transition.duration, tickDenominator, "transition")
        transition.offset = render(cursor - duration / 2, tickDenominator)
        transition.duration = render(duration, tickDenominator)
        output.append(.transition(transition))

      case .title(var title):
        let duration = try ticks(title.duration, tickDenominator, "title")
        title.offset = render(cursor, tickDenominator)
        title.duration = render(duration, tickDenominator)
        cursor += duration
        longest = max(longest, cursor)
        output.append(.title(title))

      default:
        output.append(items[index])
      }
    }

    return Packed(items: output, duration: render(max(cursor, longest), tickDenominator))
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

  private static func ticks(
    _ description: String?,
    _ denominator: Int32,
    _ subject: String
  ) throws -> Int64 {
    guard let description, let value = FCPTime(description) else {
      throw BuildError.missingDuration(subject)
    }
    return value.numerator * Int64(denominator) / Int64(value.denominator)
  }

  private static func render(_ ticks: Int64, _ denominator: Int32) -> String {
    if ticks.isMultiple(of: Int64(denominator)) {
      return "\(ticks / Int64(denominator))s"
    }
    return "\(ticks)/\(denominator)s"
  }

  private static func anchoredExtent(
    _ items: [FCPKit.AnchoredItem]?,
    _ denominator: Int32
  ) -> Int64 {
    (items ?? []).reduce(0) { result, item in
      switch item {
      case .title(let title):
        let offset = (try? ticks(title.offset ?? "0s", denominator, "title")) ?? 0
        let duration = (try? ticks(title.duration, denominator, "title")) ?? 0
        return max(result, offset + duration)
      case .assetClip(let clip):
        let offset = (try? ticks(clip.offset ?? "0s", denominator, "asset clip")) ?? 0
        let duration = (try? ticks(clip.duration, denominator, "asset clip")) ?? 0
        return max(result, offset + duration)
      default:
        return result
      }
    }
  }
}

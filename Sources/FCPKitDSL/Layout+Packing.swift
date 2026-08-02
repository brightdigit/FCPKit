//
//  Layout+Packing.swift
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

extension Layout {
  internal static func packOverlapping(
    _ item: FCPKit.SpineItem,
    overlap: Overlap,
    cursor: Int64,
    longest: Int64,
    tickDenominator: Int32
  ) throws -> PackStep? {
    switch item {
    case .assetClip(var clip):
      let placement = try placeOverlapping(
        duration: clip.duration,
        subject: "asset clip",
        overlap: overlap,
        cursor: cursor,
        longest: longest,
        tickDenominator: tickDenominator,
        anchoredExtent: anchoredExtent(clip.anchoredItems, tickDenominator)
      )
      clip.offset = render(placement.offset, tickDenominator)
      clip.start = placement.start == 0 ? nil : render(placement.start, tickDenominator)
      clip.duration = render(placement.duration, tickDenominator)
      return PackStep(item: .assetClip(clip), cursor: placement.cursor, longest: placement.longest)

    case .video(var video):
      let placement = try placeOverlapping(
        duration: video.duration,
        subject: "video",
        overlap: overlap,
        cursor: cursor,
        longest: longest,
        tickDenominator: tickDenominator,
        anchoredExtent: anchoredExtent(video.anchoredItems, tickDenominator)
      )
      video.offset = render(placement.offset, tickDenominator)
      video.start = placement.start == 0 ? nil : render(placement.start, tickDenominator)
      video.duration = render(placement.duration, tickDenominator)
      return PackStep(item: .video(video), cursor: placement.cursor, longest: placement.longest)

    case .generator(var gen):
      let placement = try placeOverlapping(
        duration: gen.duration,
        subject: "generator",
        overlap: overlap,
        cursor: cursor,
        longest: longest,
        tickDenominator: tickDenominator,
        anchoredExtent: 0
      )
      gen.offset = render(placement.offset, tickDenominator)
      gen.start = placement.start == 0 ? nil : render(placement.start, tickDenominator)
      gen.duration = render(placement.duration, tickDenominator)
      return PackStep(item: .generator(gen), cursor: placement.cursor, longest: placement.longest)

    default:
      return nil
    }
  }

  internal static func packNonOverlapping(
    _ item: FCPKit.SpineItem,
    cursor: Int64,
    longest: Int64,
    tickDenominator: Int32
  ) throws -> PackStep {
    switch item {
    case .gap(var gap):
      let duration = try ticks(gap.duration, tickDenominator, "gap")
      gap.offset = render(cursor, tickDenominator)
      let nextCursor = cursor + duration
      return PackStep(item: .gap(gap), cursor: nextCursor, longest: max(longest, nextCursor))

    case .transition(var transition):
      let duration = try ticks(transition.duration, tickDenominator, "transition")
      transition.offset = render(cursor - duration / 2, tickDenominator)
      transition.duration = render(duration, tickDenominator)
      return PackStep(item: .transition(transition), cursor: cursor, longest: longest)

    case .title(var title):
      let duration = try ticks(title.duration, tickDenominator, "title")
      title.offset = render(cursor, tickDenominator)
      title.duration = render(duration, tickDenominator)
      let nextCursor = cursor + duration
      return PackStep(item: .title(title), cursor: nextCursor, longest: max(longest, nextCursor))

    default:
      return PackStep(item: item, cursor: cursor, longest: longest)
    }
  }

  internal static func placeOverlapping(
    duration description: String?,
    subject: String,
    overlap: Overlap,
    cursor: Int64,
    longest: Int64,
    tickDenominator: Int32,
    anchoredExtent: Int64
  ) throws -> Placement {
    let original = try ticks(description, tickDenominator, subject)
    let start = overlap.previous
    let duration = original - start - overlap.next
    let nextCursor = cursor + duration
    return Placement(
      offset: cursor,
      start: start,
      duration: duration,
      cursor: nextCursor,
      longest: max(longest, nextCursor, cursor + anchoredExtent)
    )
  }

  internal static func ticks(
    _ description: String?,
    _ denominator: Int32,
    _ subject: String
  ) throws -> Int64 {
    guard let description, let value = FCPTime(description) else {
      throw BuildError.missingDuration(subject)
    }
    return value.numerator * Int64(denominator) / Int64(value.denominator)
  }

  internal static func render(_ ticks: Int64, _ denominator: Int32) -> String {
    if ticks.isMultiple(of: Int64(denominator)) {
      return "\(ticks / Int64(denominator))s"
    }
    return "\(ticks)/\(denominator)s"
  }

  internal static func anchoredExtent(
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

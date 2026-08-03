//
//  StoryItem.swift
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

/// Content that can sit in a spine, per the FCPXML DTD's `%clip_item;` entity.
///
/// Conformers gain ``anchor(lane:offset:content:)``, which attaches connected clips on
/// numbered lanes above or below the storyline.
public protocol StoryItem: DSLNode {
  /// The type produced by anchoring. Usually `Self`, but ``Color`` promotes to
  /// ``Generator`` because a model type cannot gain stored properties.
  associatedtype Anchored: DocumentContent

  /// The anchors already attached to this item.
  var anchors: [any DSLNode] { get }

  /// Returns a copy of this item carrying exactly the given anchors.
  ///
  /// This is a pure setter: it replaces rather than appends. Callers that want to add
  /// anchors should use ``anchor(lane:offset:content:)``.
  ///
  /// - Parameter anchors: The complete anchor list for the returned copy.
  /// - Returns: A copy carrying `anchors`.
  func replacingAnchors(_ anchors: [any DSLNode]) -> Anchored
}

extension StoryItem {
  /// Anchors content on a connected lane. `lane` must be nonzero.
  ///
  /// Chaining accumulates: each call appends to the anchors already present, so
  /// `clip.anchor(lane: 1) { … }.anchor(lane: 2) { … }` keeps both lanes.
  ///
  /// A lane of `0` is the storyline itself and is rejected at build time with
  /// ``BuildError/invalidLane``, because this modifier cannot throw from builder
  /// position.
  ///
  /// Anchoring onto a ``Transition`` has no effect: the FCPXML DTD does not admit
  /// anchored items on transitions, so they are accepted but never emitted.
  ///
  /// - Parameters:
  ///   - lane: The connected lane. Positive lanes sit above the storyline, negative
  ///     lanes below. Must not be `0`.
  ///   - offset: How far into this item the anchored content begins.
  ///   - content: The content to anchor.
  /// - Returns: A copy of this item carrying the existing anchors plus the new ones.
  public func anchor(
    lane: Int,
    offset: FCPTime = .zero,
    @DocumentBuilder content: () -> DocumentGroup
  ) -> Anchored {
    let added: [any DSLNode] = content().contents.compactMap { value in
      guard let node = value as? any DSLNode else {
        return nil
      }
      return Anchor(lane: lane, offset: offset, content: node)
    }
    return replacingAnchors(anchors + added)
  }
}

//
//  AnchorableItem.swift
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

/// A model element that may be attached to a connected lane.
///
/// The FCPXML DTD's `%anchor_item;` entity admits a subset of story elements.
/// Conformers describe how to re-wrap themselves into both ordered-choice
/// containers, so the set of anchorable shapes is stated exactly once — in
/// ``Built/anchorable`` — instead of being re-enumerated by every caller.
internal protocol AnchorableItem {
  /// The connected lane this element sits on.
  var lane: String? { get set }
  /// The element's offset within its parent.
  var offset: String? { get set }
  /// This element as an anchored child.
  var asAnchoredItem: FCPKit.AnchoredItem { get }
  /// This element as a spine item.
  var asSpineItem: FCPKit.SpineItem { get }
}

extension FCPKit.Title: AnchorableItem {
  internal var asAnchoredItem: FCPKit.AnchoredItem { .title(self) }
  internal var asSpineItem: FCPKit.SpineItem { .title(self) }
}

extension FCPKit.AssetClip: AnchorableItem {
  internal var asAnchoredItem: FCPKit.AnchoredItem { .assetClip(self) }
  internal var asSpineItem: FCPKit.SpineItem { .assetClip(self) }
}

extension FCPKit.Generator: AnchorableItem {
  internal var asAnchoredItem: FCPKit.AnchoredItem { .generator(self) }
  internal var asSpineItem: FCPKit.SpineItem { .generator(self) }
}

extension FCPKit.Video: AnchorableItem {
  internal var asAnchoredItem: FCPKit.AnchoredItem { .video(self) }
  internal var asSpineItem: FCPKit.SpineItem { .video(self) }
}

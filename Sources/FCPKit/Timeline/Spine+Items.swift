//
//  Spine+Items.swift
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

extension Spine {
  /// The `clip` elements in the spine.
  public var clips: [Clip]? {
    get { payloads(\.clip) }
    set { replace(with: newValue, extract: \.clip, wrap: SpineItem.clip) }
  }

  /// The `gap` elements filling empty stretches of the spine.
  public var gaps: [Gap]? {
    get { payloads(\.gap) }
    set { replace(with: newValue, extract: \.gap, wrap: SpineItem.gap) }
  }

  /// The `mc-clip` elements referencing multicam media resources.
  public var mcClips: [MCClip]? {
    get { payloads(\.mcClip) }
    set { replace(with: newValue, extract: \.mcClip, wrap: SpineItem.mcClip) }
  }

  /// The `ref-clip` elements referencing compound clips or other media resources.
  public var refClips: [RefClip]? {
    get { payloads(\.refClip) }
    set { replace(with: newValue, extract: \.refClip, wrap: SpineItem.refClip) }
  }

  /// The `sync-clip` elements containing synchronized audio and video.
  public var syncClips: [SyncClip]? {
    get { payloads(\.syncClip) }
    set { replace(with: newValue, extract: \.syncClip, wrap: SpineItem.syncClip) }
  }

  /// The `asset-clip` elements referencing asset resources.
  public var assetClips: [AssetClip]? {
    get { payloads(\.assetClip) }
    set { replace(with: newValue, extract: \.assetClip, wrap: SpineItem.assetClip) }
  }

  /// The `title` elements in the spine.
  public var titles: [Title]? {
    get { payloads(\.title) }
    set { replace(with: newValue, extract: \.title, wrap: SpineItem.title) }
  }

  /// The `generator` elements referencing generator effects.
  public var generators: [Generator]? {
    get { payloads(\.generator) }
    set { replace(with: newValue, extract: \.generator, wrap: SpineItem.generator) }
  }

  /// The `transition` elements joining adjacent story elements.
  public var transitions: [Transition]? {
    get { payloads(\.transition) }
    set { replace(with: newValue, extract: \.transition, wrap: SpineItem.transition) }
  }

  /// Nested `storyline` elements connected to the spine.
  public var storylines: [Storyline]? {
    get { payloads(\.storyline) }
    set { replace(with: newValue, extract: \.storyline, wrap: SpineItem.storyline) }
  }

  /// The `compound-clip` elements in the spine.
  public var compoundClips: [CompoundClip]? {
    get { payloads(\.compoundClip) }
    set { replace(with: newValue, extract: \.compoundClip, wrap: SpineItem.compoundClip) }
  }

  /// The `retime-clip` elements applying retiming to their contents.
  public var retimeClips: [RetimeClip]? {
    get { payloads(\.retimeClip) }
    set { replace(with: newValue, extract: \.retimeClip, wrap: SpineItem.retimeClip) }
  }

  /// The `caption` elements in the spine.
  public var captions: [Caption]? {
    get { payloads(\.caption) }
    set { replace(with: newValue, extract: \.caption, wrap: SpineItem.caption) }
  }

  /// The `video` elements in the spine.
  public var video: [Video]? {
    get { payloads(\.video) }
    set { replace(with: newValue, extract: \.video, wrap: SpineItem.video) }
  }
}

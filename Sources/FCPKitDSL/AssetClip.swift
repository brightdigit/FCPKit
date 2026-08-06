//
//  AssetClip.swift
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
import Foundation

/// An `asset-clip` story item with optional anchors and audio role.
public struct AssetClip: StoryItem {
  internal let source: AssetSource
  /// Clip duration on the storyline, when set explicitly via ``duration(_:)``.
  public let duration: FCPTime?
  internal let name: String?
  /// The anchors attached to this clip.
  public let anchors: [any DSLNode]
  internal let audioRole: String?

  /// Creates a clip from an ``AssetSource``.
  public init(_ source: AssetSource, name: String? = nil) {
    self.init(source: source, duration: nil, name: name, anchors: [], audioRole: nil)
  }

  /// Creates a clip from a model asset and optional format.
  public init(
    _ asset: FCPKit.Asset,
    format: FCPKit.Format? = nil,
    formatOnClip: Bool = false,
    name: String? = nil
  ) {
    self.init(
      AssetSource(asset, format: format, formatOnClip: formatOnClip),
      name: name
    )
  }

  /// Creates a clip from a media URL.
  public init(_ url: URL, name: String? = nil) {
    self.init(AssetSource(url: url, name: name), name: name)
  }

  /// Creates a clip from an ``AssetSource`` with an optional duration.
  @available(
    *, deprecated,
    message: """
      Use `.duration(_:)` instead of passing duration to the initializer. \
      Anchored clips inherit the host duration when omitted.
      """
  )
  public init(_ source: AssetSource, duration: FCPTime?, name: String? = nil) {
    self.init(source: source, duration: duration, name: name, anchors: [], audioRole: nil)
  }

  /// Creates a clip from a model asset with an optional duration.
  @available(
    *, deprecated,
    message: """
      Use `.duration(_:)` instead of passing duration to the initializer. \
      Anchored clips inherit the host duration when omitted.
      """
  )
  public init(
    _ asset: FCPKit.Asset,
    format: FCPKit.Format? = nil,
    formatOnClip: Bool = false,
    duration: FCPTime?,
    name: String? = nil
  ) {
    self.init(
      AssetSource(asset, format: format, formatOnClip: formatOnClip),
      duration: duration,
      name: name
    )
  }

  /// Creates a clip from a media URL with an optional duration.
  @available(
    *, deprecated,
    message: """
      Use `.duration(_:)` instead of passing duration to the initializer. \
      Anchored clips inherit the host duration when omitted.
      """
  )
  public init(_ url: URL, duration: FCPTime?, name: String? = nil) {
    self.init(AssetSource(url: url, name: name, duration: duration), duration: duration, name: name)
  }

  private init(
    source: AssetSource,
    duration: FCPTime?,
    name: String?,
    anchors: [any DSLNode],
    audioRole: String?
  ) {
    self.source = source
    self.duration = duration
    self.name = name
    self.anchors = anchors
    self.audioRole = audioRole
  }

  /// Sets the clip duration.
  public func duration(_ duration: FCPTime) -> AssetClip {
    AssetClip(
      source: source,
      duration: duration,
      name: name,
      anchors: anchors,
      audioRole: audioRole
    )
  }

  /// Returns a copy of this clip carrying exactly the given anchors.
  public func replacingAnchors(_ anchors: [any DSLNode]) -> AssetClip {
    replacing(anchors: anchors)
  }

  /// Lowers this clip into an `<asset-clip>` story item.
  public func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    let ref = try resources.asset(source)
    guard let value = duration?.description ?? source.asset.duration, FCPTime(value) != nil else {
      throw BuildError.missingDuration(name ?? source.asset.name ?? "asset clip")
    }
    var clip = FCPKit.AssetClip(
      ref: ref,
      name: name ?? source.asset.name,
      duration: value,
      tcFormat: .nonDropFrame,
      audioRole: audioRole
    )
    if let format = source.format, source.formatOnClip {
      clip.format = try resources.format(FormatPreset(format))
    }
    let hostDuration = FCPTime(value)
    clip.anchoredItems = try anchors.anchoredItems(
      resources: &resources,
      hostDuration: hostDuration
    )
    return .item(.assetClip(clip))
  }

  internal func replacing(audioRole: String? = nil, anchors: [any DSLNode]? = nil) -> AssetClip {
    AssetClip(
      source: source,
      duration: duration,
      name: name,
      anchors: anchors ?? self.anchors,
      audioRole: audioRole ?? self.audioRole
    )
  }
}

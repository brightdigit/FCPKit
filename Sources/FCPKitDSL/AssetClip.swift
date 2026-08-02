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
public struct AssetClip: DSLNode {
  internal let source: AssetSource
  /// Clip duration on the storyline, when set explicitly.
  public let duration: FCPTime?
  internal let name: String?
  internal let anchors: [any DSLNode]
  internal let audioRole: String?

  /// Creates a clip from an ``AssetSource``.
  public init(_ source: AssetSource, duration: FCPTime? = nil, name: String? = nil) {
    self.init(source: source, duration: duration, name: name, anchors: [], audioRole: nil)
  }

  /// Creates a clip from a model asset and optional format.
  public init(
    _ asset: FCPKit.Asset,
    format: FCPKit.Format? = nil,
    formatOnClip: Bool = false,
    duration: FCPTime? = nil,
    name: String? = nil
  ) {
    self.init(
      AssetSource(asset, format: format, formatOnClip: formatOnClip),
      duration: duration,
      name: name
    )
  }

  /// Creates a clip from a media URL.
  public init(_ url: URL, duration: FCPTime? = nil, name: String? = nil) {
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

  internal func build(_ resources: inout ResourceStore) throws -> Built {
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
    let items = try anchors.map { try anchoredItem($0, resources: &resources) }
    clip.anchoredItems = items.isEmpty ? nil : items
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

  private func anchoredItem(_ node: any DSLNode, resources: inout ResourceStore) throws
    -> FCPKit.AnchoredItem
  {
    switch try node.build(&resources) {
    case .item(.title(let title)): return .title(title)
    case .item(.assetClip(let clip)): return .assetClip(clip)
    case .item(.generator(let gen)): return .generator(gen)
    case .item(.video(let vid)): return .video(vid)
    case .spine(let spine): return .spine(spine)
    default: throw BuildError.unsupportedContent
    }
  }
}

//
//  Title.swift
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

/// A title clip, typically anchored onto an asset clip.
public struct Title: DSLNode {
  internal let preset: TitlePreset
  internal let text: String
  /// Clip duration on the storyline.
  public let duration: FCPTime
  internal let lane: Int?
  internal let offset: FCPTime?
  internal let style: TitleStyle
  internal let position: FramePosition?
  internal let displayName: String?

  /// Creates a Basic Title from text and optional duration.
  public init(_ text: String, duration: FCPTime? = nil) {
    self.init(.basic, text: text, duration: duration)
  }

  /// Creates a title from a preset, text, and optional duration.
  public init(_ preset: TitlePreset, text: String, duration: FCPTime? = nil) {
    self.init(preset: preset, text: text, duration: duration ?? .zero, lane: nil, offset: nil)
  }

  internal init(
    preset: TitlePreset,
    text: String,
    duration: FCPTime,
    lane: Int?,
    offset: FCPTime?,
    style: TitleStyle = .default,
    position: FramePosition? = nil,
    displayName: String? = nil
  ) {
    self.preset = preset
    self.text = text
    self.duration = duration
    self.lane = lane
    self.offset = offset
    self.style = style
    self.position = position
    self.displayName = displayName
  }

  /// Sets the title clip duration.
  public func duration(_ duration: FCPTime) -> Title {
    replacing(duration: duration)
  }

  /// Returns a copy of this title with the given fields replaced.
  internal func replacing(
    duration: FCPTime? = nil,
    style: TitleStyle? = nil,
    position: FramePosition? = nil,
    displayName: String? = nil
  ) -> Title {
    Title(
      preset: preset,
      text: text,
      duration: duration ?? self.duration,
      lane: lane,
      offset: offset,
      style: style ?? self.style,
      position: position ?? self.position,
      displayName: displayName ?? self.displayName
    )
  }

  internal func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    let ref = try resources.effect(name: preset.name, uid: preset.uid)
    let styleID = resources.textStyleID()
    let style = FCPKit.TextStyle(ref: styleID, content: text)
    let definition = FCPKit.TextStyleDef(id: styleID, textStyle: self.style.textStyle())

    // No adjust-transform unless a position was requested, so unpositioned
    // titles stay byte-identical to real Final Cut output.
    var transform: FCPKit.AdjustTransform?
    if let position, let resolved = try position.resolve(frameSize: resources.frameSize) {
      transform = FCPKit.AdjustTransform(position: resolved)
    }

    var element = FCPKit.Title(
      ref: ref,
      name: displayName ?? preset.name,
      duration: duration.description,
      start: "3600s",
      lane: lane.map(String.init),
      offset: offset?.description ?? "0s",
      text: [FCPKit.TextElement(textStyle: [style])],
      textStyleDef: [definition]
    )
    element.adjustTransform = transform
    return .item(.title(element))
  }
}

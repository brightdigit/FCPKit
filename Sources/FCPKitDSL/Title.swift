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
public struct Title: StoryItem {
  internal let preset: TitlePreset
  internal let text: String
  /// Clip duration on the storyline, when set via ``duration(_:)`` or inherited from a host.
  public let duration: FCPTime?
  internal let lane: Int?
  internal let offset: FCPTime?
  /// The anchors attached to this title.
  public let anchors: [any DSLNode]
  internal let style: TitleStyle
  internal let position: FramePosition?
  internal let displayName: String?
  internal let textLayout: TitleTextLayout?

  /// Creates a Basic Title from text.
  ///
  /// Set duration with ``duration(_:)``. When this title is anchored and has no
  /// duration, it inherits the host clip's duration.
  public init(_ text: String) {
    self.init(.basic, text: text)
  }

  /// Creates a title from a preset and text.
  ///
  /// Set duration with ``duration(_:)``. When this title is anchored and has no
  /// duration, it inherits the host clip's duration.
  public init(_ preset: TitlePreset, text: String) {
    self.init(preset: preset, text: text, duration: nil, lane: nil, offset: nil)
  }

  /// Creates a Basic Title from text and optional duration.
  @available(
    *, deprecated,
    message: """
      Use `.duration(_:)` instead of passing duration to the initializer. \
      Anchored titles inherit the host duration when omitted.
      """
  )
  public init(_ text: String, duration: FCPTime?) {
    self.init(.basic, text: text, duration: duration)
  }

  /// Creates a title from a preset, text, and optional duration.
  @available(
    *, deprecated,
    message: """
      Use `.duration(_:)` instead of passing duration to the initializer. \
      Anchored titles inherit the host duration when omitted.
      """
  )
  public init(_ preset: TitlePreset, text: String, duration: FCPTime?) {
    self.init(preset: preset, text: text, duration: duration, lane: nil, offset: nil)
  }

  internal init(
    preset: TitlePreset,
    text: String,
    duration: FCPTime?,
    lane: Int?,
    offset: FCPTime?,
    anchors: [any DSLNode] = [],
    style: TitleStyle = .default,
    position: FramePosition? = nil,
    displayName: String? = nil,
    textLayout: TitleTextLayout? = nil
  ) {
    self.preset = preset
    self.text = text
    self.duration = duration
    self.lane = lane
    self.offset = offset
    self.anchors = anchors
    self.style = style
    self.position = position
    self.displayName = displayName
    self.textLayout = textLayout
  }

  /// Sets the title clip duration.
  public func duration(_ duration: FCPTime) -> Title {
    replacing(duration: duration)
  }

  /// Returns a copy of this title with the given fields replaced.
  internal func replacing(
    duration: FCPTime? = nil,
    anchors: [any DSLNode]? = nil,
    style: TitleStyle? = nil,
    position: FramePosition? = nil,
    displayName: String? = nil,
    textLayout: TitleTextLayout? = nil
  ) -> Title {
    Title(
      preset: preset,
      text: text,
      duration: duration ?? self.duration,
      lane: lane,
      offset: offset,
      anchors: anchors ?? self.anchors,
      style: style ?? self.style,
      position: position ?? self.position,
      displayName: displayName ?? self.displayName,
      textLayout: textLayout ?? self.textLayout
    )
  }

  /// Returns a copy of this title carrying exactly the given anchors.
  public func replacingAnchors(_ anchors: [any DSLNode]) -> Title {
    replacing(anchors: anchors)
  }

  /// Lowers this title into a `<title>` story item.
  ///
  /// - Throws: ``BuildError/missingDuration(_:)`` when no duration was set and
  ///   none was inherited from an anchor host.
  /// - Throws: ``BuildError/missingFrameSize`` when ``textBox(_:)`` /
  ///   ``TextBox/fillFrame(inset:)`` needs a sequence format.
  public func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    guard let duration else {
      throw BuildError.missingDuration(displayName ?? preset.name)
    }
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

    let params = try textLayoutParameters(frameSize: resources.frameSize)

    var element = FCPKit.Title(
      ref: ref,
      name: displayName ?? preset.name,
      duration: duration.description,
      start: "3600s",
      lane: lane.map(String.init),
      offset: offset?.description ?? "0s",
      param: params,
      text: [FCPKit.TextElement(textStyle: [style])],
      textStyleDef: [definition]
    )
    element.adjustTransform = transform
    element.anchoredItems = try anchors.anchoredItems(
      resources: &resources,
      hostDuration: duration
    )
    return .item(.title(element))
  }

  private func textLayoutParameters(
    frameSize: (width: Double, height: Double)?
  ) throws(BuildError) -> [ParamElement]? {
    guard let textLayout else {
      return nil
    }
    var method = textLayout.method
    let margins: TextMargins?
    if let inset = textLayout.fillInset {
      guard let frameSize else {
        throw BuildError.missingFrameSize
      }
      method = method ?? .paragraph
      margins = TextMargins.fillFrame(
        inset: inset,
        width: frameSize.width,
        height: frameSize.height
      )
    } else {
      margins = textLayout.margins
    }
    return BasicTitleTextLayoutParams.parameters(method: method, margins: margins)
  }
}

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
  internal let duration: FCPTime
  internal let lane: Int?
  internal let offset: FCPTime?
  /// Creates a title from a preset, text, and duration.
  public init(_ preset: TitlePreset, text: String, duration: FCPTime) {
    self.init(preset: preset, text: text, duration: duration, lane: nil, offset: nil)
  }
  private init(preset: TitlePreset, text: String, duration: FCPTime, lane: Int?, offset: FCPTime?) {
    self.preset = preset
    self.text = text
    self.duration = duration
    self.lane = lane
    self.offset = offset
  }
  internal func build(_ resources: inout ResourceStore) throws -> Built {
    let ref = try resources.effect(name: "Basic Title", uid: TitlePreset.uid)
    let style = FCPKit.TextStyle(ref: "ts1", content: text)
    let definition = FCPKit.TextStyleDef(
      id: "ts1",
      textStyle: FCPKit.TextStyle(
        font: "Helvetica",
        fontSize: "63",
        fontFace: "Regular",
        fontColor: "1 1 1 1",
        alignment: "center"
      )
    )
    return .item(
      .title(
        FCPKit.Title(
          ref: ref,
          name: "Basic Title",
          duration: duration.description,
          start: "3600s",
          lane: lane.map(String.init),
          offset: offset?.description ?? "0s",
          text: [FCPKit.TextElement(textStyle: [style])],
          textStyleDef: [definition]
        )
      )
    )
  }
}

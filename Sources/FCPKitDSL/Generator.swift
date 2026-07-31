//
//  Generator.swift
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

/// A generator story item (such as Solids > Custom).
public struct Generator: DSLNode, DSLNodeWithDuration {
  internal let preset: GeneratorPreset
  public let duration: FCPTime
  internal let name: String?
  internal let params: [ParamElement]
  internal let lane: Int?
  internal let offset: FCPTime?

  /// Default parameter key used by Final Cut Pro for Solids > Custom color parameter.
  public static let customColorKey = "9999/10008/10006/2/1/1"

  /// Creates a generator clip from a preset and optional duration.
  public init(_ preset: GeneratorPreset = .custom, duration: FCPTime? = nil, name: String? = nil) {
    self.init(
      preset: preset,
      duration: duration ?? .zero,
      name: name,
      params: [],
      lane: nil,
      offset: nil
    )
  }

  private init(
    preset: GeneratorPreset,
    duration: FCPTime,
    name: String?,
    params: [ParamElement],
    lane: Int?,
    offset: FCPTime?
  ) {
    self.preset = preset
    self.duration = duration
    self.name = name
    self.params = params
    self.lane = lane
    self.offset = offset
  }

  /// Sets the clip duration.
  public func duration(_ duration: FCPTime) -> Generator {
    replacing(duration: duration)
  }

  /// Assigns a custom display name to the generator clip.
  public func name(_ name: String) -> Generator {
    replacing(name: name)
  }

  /// Sets the solid color parameter using a ``Color``.
  public func color(_ color: Color) -> Generator {
    param(name: "Color", key: Self.customColorKey, value: color.description)
  }

  /// Sets the solid color parameter using RGB/RGBA values (0.0 to 1.0).
  public func color(red: Double, green: Double, blue: Double, alpha: Double = 1.0) -> Generator {
    color(Color(red: red, green: green, blue: blue, alpha: alpha))
  }

  /// Sets the solid color parameter using an FCP rational color string (e.g. `"1 0 0 1"`).
  public func color(_ colorString: String) -> Generator {
    param(name: "Color", key: Self.customColorKey, value: colorString)
  }

  /// Appends an effect parameter key/value pair.
  public func param(name: String, key: String? = nil, value: String? = nil) -> Generator {
    var updated = params
    if let index = updated.firstIndex(where: { $0.name == name }) {
      updated[index] = ParamElement(
        name: name, key: key ?? updated[index].key, value: value ?? updated[index].value)
    } else {
      updated.append(ParamElement(name: name, key: key, value: value))
    }
    return replacing(params: updated)
  }

  internal func build(_ resources: inout ResourceStore) throws -> Built {
    let ref = try resources.effect(name: preset.name, uid: preset.uid)
    let videoElement = FCPKit.Video(
      ref: ResourceRef<AssetKind>(ref.rawValue),
      lane: lane.map(String.init),
      offset: offset?.description ?? "0s",
      name: name ?? (preset == .custom ? "Color Solid" : preset.name),
      start: "0s",
      duration: duration.description,
      param: params.isEmpty ? nil : params
    )
    return .item(.video(videoElement))
  }

  private func replacing(
    preset: GeneratorPreset? = nil,
    duration: FCPTime? = nil,
    name: String? = nil,
    params: [ParamElement]? = nil,
    lane: Int? = nil,
    offset: FCPTime? = nil
  ) -> Generator {
    Generator(
      preset: preset ?? self.preset,
      duration: duration ?? self.duration,
      name: name ?? self.name,
      params: params ?? self.params,
      lane: lane ?? self.lane,
      offset: offset ?? self.offset
    )
  }
}

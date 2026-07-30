//
//  Resources.swift
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

import Foundation
import XMLCoder

/// The `resources` element listing media and effects shared across the document.
public struct Resources: Codable {
  internal enum CodingKeys: String, CodingKey {
    case assets = "asset"
    case formats = "format"
    case effects = "effect"
    case media
  }

  /// The `asset` elements describing source media files.
  public var assets: [Asset]?
  /// The `format` elements describing video and audio format settings.
  public var formats: [Format]?
  /// The `effect` elements referencing Motion templates and built-in effects.
  public var effects: [Effect]?
  /// The `media` elements containing compound clip and multicam definitions.
  public var media: [Media]?

  /// Creates a `resources` element with the given assets, formats, effects, and media.
  public init(
    assets: [Asset]? = nil,
    formats: [Format]? = nil,
    effects: [Effect]? = nil,
    media: [Media]? = nil
  ) {
    self.assets = assets
    self.formats = formats
    self.effects = effects
    self.media = media
  }
}

extension Resources: DynamicNodeEncoding {
  /// Encodes every child resource as an XML element.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    .element
  }
}

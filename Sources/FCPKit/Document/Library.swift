//
//  Library.swift
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

/// A Final Cut Pro `library` element containing events and smart collections.
public struct Library: Codable {
  internal enum CodingKeys: String, CodingKey {
    case location
    case colorProcessing
    case events = "event"
    case smartCollections = "smart-collection"
  }

  /// The file URL of the library bundle on disk.
  public var location: String?
  /// The library's color-processing mode (for example, `.wideHDR`).
  public var colorProcessing: ColorProcessing?
  /// The `event` elements grouped inside the library.
  public var events: [Event]?
  /// The library-level `smart-collection` elements.
  public var smartCollections: [SmartCollection]?

  /// Creates a `library` element with the given location, color processing, and contents.
  public init(
    location: String? = nil,
    colorProcessing: ColorProcessing? = nil,
    events: [Event]? = nil,
    smartCollections: [SmartCollection]? = nil
  ) {
    self.location = location
    self.colorProcessing = colorProcessing
    self.events = events
    self.smartCollections = smartCollections
  }
}

extension Library: FCPNodeEncodable {
  /// Encodes events and smart collections as child elements and other keys as XML attributes.
  public static let elementKeys: Set<String> = ["event", "smart-collection"]
}

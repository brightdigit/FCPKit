//
//  FCPXML.swift
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

/// The root `fcpxml` element of a Final Cut Pro XML interchange document.
public struct FCPXML: Codable {
  internal enum CodingKeys: String, CodingKey {
    case version
    case resources
    case library
  }

  /// The FCPXML schema version declared by the document (for example, `"1.13"`).
  public let version: String
  /// The `resources` element listing shared assets, formats, effects, and media.
  public var resources: Resources?
  /// The `library` element containing the document's events.
  public var library: Library?

  /// Creates an `fcpxml` root element with the given version, resources, and library.
  public init(version: String, resources: Resources? = nil, library: Library? = nil) {
    self.version = version
    self.resources = resources
    self.library = library
  }
}

extension FCPXML: FCPNodeEncodable {
  /// Encodes `resources` and `library` as child elements and other keys as XML attributes.
  public static let elementKeys: Set<String> = ["resources", "library"]
}

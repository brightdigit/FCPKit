//
//  FCPXMLDTDLocator.swift
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

/// Locates Apple FCPXML DTDs bundled with Final Cut Pro when present.
public struct FCPXMLDTDLocator: Sendable {
  /// The directories searched for versioned FCPXML DTD files.
  public var searchRoots: [URL]

  /// Creates a locator that searches the given directories for DTD files.
  public init(searchRoots: [URL] = FCPXMLDTDLocator.defaultSearchRoots()) {
    self.searchRoots = searchRoots
  }

  /// Returns the DTD resource directories inside known Final Cut Pro app bundles.
  public static func defaultSearchRoots() -> [URL] {
    let applications = URL(fileURLWithPath: "/Applications", isDirectory: true)
    let names = [
      "Final Cut Pro Creator Studio.app",
      "Final Cut Pro.app",
    ]
    return names.map {
      applications
        .appendingPathComponent($0, isDirectory: true)
        .appendingPathComponent(
          "Contents/Frameworks/Interchange.framework/Versions/A/Resources", isDirectory: true
        )
    }
  }

  /// Returns the URL of the DTD file for the given FCPXML version, if one exists.
  public func dtdURL(forVersion version: String) -> URL? {
    let sanitized = version.replacingOccurrences(of: ".", with: "_")
    let fileName = "FCPXMLv\(sanitized).dtd"
    for root in searchRoots {
      let candidate = root.appendingPathComponent(fileName)
      if FileManager.default.fileExists(atPath: candidate.path) {
        return candidate
      }
    }
    return nil
  }
}

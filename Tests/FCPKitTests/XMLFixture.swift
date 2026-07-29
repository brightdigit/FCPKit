//
//  XMLFixture.swift
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

/// Loads a checked-in XML fixture from `Tests/FCPKitTests/Fixtures`.
///
/// Fixtures live as real `.fcpxml` files rather than Swift string literals: the
/// documents are XML, and keeping them out of Swift source means their
/// indentation and line length are not measured as if they were Swift code.
///
/// The trailing newline every text file ends with is stripped, so the returned
/// string matches what the equivalent multi-line string literal produced.
///
/// - Parameter name: Fixture file name without the `.fcpxml` extension.
/// - Returns: The fixture's contents.
internal func fixture(
  _ name: String,
  file: StaticString = #filePath,
  line: UInt = #line
) -> String {
  let url = URL(fileURLWithPath: "\(file)")
    .deletingLastPathComponent()
    .appendingPathComponent("Fixtures")
    .appendingPathComponent("\(name).fcpxml")
  guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
    preconditionFailure("missing fixture \(name).fcpxml at \(url.path)")
  }
  return contents.hasSuffix("\n") ? String(contents.dropLast()) : contents
}

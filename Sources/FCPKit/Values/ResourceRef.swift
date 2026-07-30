//
//  ResourceRef.swift
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

/// A typed reference to a resource id, phantom-parameterized by ``ResourceKind``.
///
/// The phantom `Kind` keeps call sites honest — an asset reference cannot be
/// passed where a format reference is expected — but the typing is advisory:
/// the DTD only declares these attributes as `IDREF`, so decoding accepts any
/// non-empty string without whitespace and real documents always load.
public struct ResourceRef<Kind: ResourceKind>: XMLAttributeValue {
  /// The referenced resource identifier exactly as written, such as `"r1"`.
  public let rawValue: String

  /// The FCPXML attribute string for this reference.
  public var fcpxmlString: String {
    rawValue
  }

  /// Creates a reference from a non-empty identifier string without whitespace.
  public init?(fcpxmlString: String) {
    guard !fcpxmlString.isEmpty, !fcpxmlString.contains(where: \.isWhitespace) else {
      return nil
    }
    self.rawValue = fcpxmlString
  }
}

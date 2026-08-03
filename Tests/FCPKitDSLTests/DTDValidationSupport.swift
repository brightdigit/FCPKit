//
//  DTDValidationSupport.swift
//  FCPKitDSLTests
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

import FCPXMLDiff
import Foundation
import Testing

/// Validates serialized FCPXML against Final Cut's bundled DTD.
///
/// When Final Cut or `xmllint` are unavailable the check soft-skips, unless the
/// `FCPKIT_REQUIRE_DTD` environment variable is set, in which case the missing
/// tooling is recorded as a failure.
internal func assertDTDValidates(_ data: Data) throws {
  let requireDTD = ProcessInfo.processInfo.environment["FCPKIT_REQUIRE_DTD"] != nil
  do {
    let report = try FCPXMLDTDValidator().validate(data: data)
    #expect(report.isValid, "DTD issues: \(report.issues)")
  } catch FCPXMLValidationError.dtdNotFound, FCPXMLValidationError.xmllintUnavailable {
    if requireDTD {
      Issue.record("FCPKIT_REQUIRE_DTD is set but DTD tooling is unavailable")
    } else {
      // Soft skip when Final Cut / xmllint are absent.
    }
  }
}

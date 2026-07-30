//
//  SchemaCompletenessAcceptance.swift
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
import Foundation

/// A threshold that decides whether a schema-completeness report is acceptable.
public struct SchemaCompletenessAcceptance: Equatable, Sendable {
  /// The maximum total structural loss a report may contain and still be accepted.
  public let maximumTotalLoss: Int

  /// Creates an acceptance threshold with the given non-negative maximum total loss.
  public init(maximumTotalLoss: Int) {
    precondition(maximumTotalLoss >= 0, "maximumTotalLoss must not be negative")
    self.maximumTotalLoss = maximumTotalLoss
  }

  /// Returns whether the report's total structural loss is within the threshold.
  public func accepts(_ report: SchemaCompletenessReport) -> Bool {
    report.totals.total <= maximumTotalLoss
  }
}

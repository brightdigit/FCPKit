//
//  FCPScriptedLibrary+ProjectCounts.swift
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

extension FCPScriptedLibrary {
  /// Flattens open projects to their display names, duplicates preserved.
  ///
  /// Import verification compares snapshots taken before and after sending an
  /// FCPXML document to Final Cut Pro: a name whose count increased was imported.
  public static func projectNames(in libraries: [FCPScriptedLibrary]) -> [String] {
    libraries.flatMap { library in
      library.events.flatMap { event in
        event.projects.map(\.name)
      }
    }
  }

  /// Returns the expected names whose project count increased between two snapshots.
  public static func newlyImportedNames(
    expected: [String],
    before: [String],
    after: [String]
  ) -> [String] {
    let beforeCounts = counts(of: before)
    let afterCounts = counts(of: after)
    return expected.filter { afterCounts[$0, default: 0] > beforeCounts[$0, default: 0] }
  }

  private static func counts(of names: [String]) -> [String: Int] {
    names.reduce(into: [:]) { counts, name in
      counts[name, default: 0] += 1
    }
  }
}

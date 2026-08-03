//
//  FCPScriptedLibraryProjectCountsTests.swift
//  FCPKitScriptingTests
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

import FCPKitScripting
import Foundation
import Testing

@Suite
internal struct FCPScriptedLibraryProjectCountsTests {
  private func library(events: [FCPScriptedEvent]) -> FCPScriptedLibrary {
    FCPScriptedLibrary(
      name: "Library",
      id: "lib-1",
      persistentID: "feedface",
      fileURL: nil,
      events: events
    )
  }

  private func event(name: String, projectNames: [String]) -> FCPScriptedEvent {
    FCPScriptedEvent(
      name: name,
      id: "event-\(name)",
      persistentID: name,
      projects: projectNames.map {
        FCPScriptedProject(name: $0, id: "proj-\($0)", persistentID: $0, sequence: nil)
      },
      sequences: []
    )
  }

  @Test
  internal func flattensProjectNamesAcrossEventsPreservingDuplicates() {
    let libraries = [
      library(events: [
        event(name: "One", projectNames: ["Cut", "Cut", "Other"]),
        event(name: "Two", projectNames: ["Cut"]),
      ])
    ]
    let names = FCPScriptedLibrary.projectNames(in: libraries)
    #expect(names == ["Cut", "Cut", "Other", "Cut"])
  }

  @Test
  internal func newlyImportedNamesRequiresCountIncrease() {
    let before = ["DSL Titles", "Other", "Other"]
    let after = ["DSL Titles", "DSL Titles", "Other", "Other", "DSL Transitions"]
    let imported = FCPScriptedLibrary.newlyImportedNames(
      expected: ["DSL Titles", "DSL Transitions", "Other", "Absent"],
      before: before,
      after: after
    )
    #expect(imported == ["DSL Titles", "DSL Transitions"])
  }
}

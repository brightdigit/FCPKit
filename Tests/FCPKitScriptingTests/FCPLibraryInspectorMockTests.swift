//
//  FCPLibraryInspectorMockTests.swift
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

#if os(macOS)

  import FCPKit
  @testable import FCPKitScripting
  import Foundation
  import Testing

  @Suite
  internal struct FCPLibraryInspectorMockTests {
    // The mock keys pin the sdef *term-name* contract that live SBObject
    // proxies resolve (verified against a running Final Cut Pro, #27). Do
    // not switch these to the sdef cocoa keys (`displayName`,
    // `uniqueIdentifier`, `durationDict`, …) — those crash live.
    private static var sampleApplication: FCPScriptingObjectMock {
      let sequence = FCPScriptingObjectMock(
        strings: [
          "name": "Main Sequence",
          "id": "seq-1",
        ],
        mediaTimes: [
          "duration": FCPTime(numerator: 240, denominator: 24),
          "frameDuration": FCPTime(numerator: 1, denominator: 24),
          "startTime": FCPTime(numerator: 0, denominator: 1),
        ],
        timecodeFormats: ["timecodeFormat": .dropFrame]
      )
      let project = FCPScriptingObjectMock(
        strings: [
          "name": "Project A",
          "id": "proj-1",
          "persistentID": "deadbeef",
        ],
        childObjects: ["sequence": [sequence]]
      )
      let event = FCPScriptingObjectMock(
        strings: [
          "name": "Event 1",
          "id": "event-1",
          "persistentID": "cafebabe",
        ],
        childObjects: [
          "projects": [project],
          "sequences": [sequence],
        ]
      )
      let library = FCPScriptingObjectMock(
        strings: [
          "name": "Library",
          "id": "lib-1",
          "persistentID": "feedface",
        ],
        urls: ["file": URL(fileURLWithPath: "/tmp/Library.fcpbundle")],
        childObjects: ["events": [event]]
      )
      return FCPScriptingObjectMock(childObjects: ["libraries": [library]])
    }

    @Test
    internal func mapsMockHierarchy() throws {
      let inspector = FCPLibraryInspector(applicationProvider: { Self.sampleApplication })
      let libraries = try inspector.libraries()
      #expect(libraries.count == 1)
      #expect(libraries[0].name == "Library")
      #expect(libraries[0].persistentID == "feedface")
      #expect(libraries[0].fileURL?.path == "/tmp/Library.fcpbundle")
      #expect(libraries[0].events.count == 1)
      #expect(libraries[0].events[0].projects.count == 1)
      #expect(libraries[0].events[0].projects[0].sequence?.name == "Main Sequence")
      #expect(libraries[0].events[0].sequences[0].timecodeFormat == .dropFrame)
      #expect(libraries[0].events[0].sequences[0].frameDuration.description == "1/24s")
    }

    @Test
    internal func defaultInspectorRequiresFinalCutRunning() throws {
      guard !FCPLibraryInspector.isFinalCutRunning() else {
        return
      }
      let inspector = FCPLibraryInspector()
      #expect(throws: FCPScriptingError.finalCutNotRunning) {
        _ = try inspector.libraries()
      }
    }
  }

#endif
